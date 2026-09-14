create database eda_using_sql;

-- Truncate the table to get the structure of the table. As Infile statement can only be used on existing table to get data from an external source.
truncate electronics;
select * from electronics;

set sql_safe_updates =0;

LOAD DATA INFILE "ElectronicsData.csv"
INTO TABLE electronics
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

describe electronics;

-- DATA CLEANING AND FEATURE ENGINEERING
select distinct `sub category` from electronics;

select price, replace(replace(price,"$",""),",","") from electronics;
update electronics set price = replace(replace(price,"$",""),",","");

select price, (substring_index(replace(price,"-",""), "through", 1)+substring_index(replace(price,"-",""), "through", -1))/2 from electronics;
update electronics set price=(substring_index(replace(price,"-",""), "through", 1)+substring_index(replace(price,"-",""), "through", -1))/2 where price like "%through%";

select * from electronics;
alter table electronics add column `Discount Given` varchar(3) after Discount;

select discount, 
case when discount like "%No Discount%" then "No" else "Yes" end
from electronics;

update electronics set `discount given`= case when discount like "%No Discount%" then "No" else "Yes" end;

alter table electronics add column MRP decimal(50,2) after Price;

select discount, regexp_replace(Discount, '[^0-9]',"") from electronics;

select price, discount,
case when discount like "%No Discount%" then price
	 when discount like "%After%" then round(price+regexp_replace(Discount, '[^0-9]',""),2)
     else round(price*1.27,2)
end
from electronics;
     
update electronics set MRP= case when discount like "%No Discount%" then price
	 when discount like "%After%" then price+regexp_replace(Discount, '[^0-9]',"")
     else round(price*1.27,2)
end;

alter table electronics add column `Discount Type` text after Discount;

select discount,
case when discount like "%No Discount%" then "No Discount"
	 when discount like "%After%" then "Flat Discount Offer"
     when discount like "%Price Valid%" then "Limited Time Offer"
     else "Special Discount"
end
from electronics;

update electronics set `Discount Type`= case when discount like "%No Discount%" then "No Discount"
	 when discount like "%After%" then "Flat Discount Offer"
     when discount like "%Price Valid%" then "Limited Time Offer"
     else "Special Discount"
end;

alter table electronics add column `Avg Rating` decimal(5,1) after rating;

select rating, regexp_substr(rating,"[0-9]+(\\.[0-9]+)?") from electronics;

update electronics set `Avg Rating`=regexp_substr(rating,"[0-9]+(\\.[0-9]+)?");

alter table electronics add column Reviews int after `Avg Rating`;

select rating, regexp_substr(rating, "[0-9]+(?= reviews)") from electronics;

update electronics set Reviews=regexp_substr(rating, "[0-9]+(?= reviews)");

alter table electronics drop column rating;
alter table electronics drop column currency;

alter table electronics rename column `Avg Rating` to Rating;

alter table electronics add column `Brand Name` varchar(30) after Reviews;

select title,
case when substring_index(title, ' ', 1) LIKE '$%' then substring_index(substring_index(title, ' ', 2), ' ', -1)
	 when title like "%Atari%" then "Atari"
     when title like "%PlayStation%" and title not like "Backbone%" then "Sony"
	 else substring_index(title, ' ', 1)
end
from electronics;

update electronics set `Brand Name`= case when substring_index(title, ' ', 1) LIKE '$%' then substring_index(substring_index(title, ' ', 2), ' ', -1)
	 when title like "%Atari%" then "Atari"
     when title like "%PlayStation%" and title not like "Backbone%" then "Sony"
	 else substring_index(title, ' ', 1)
end;

update electronics set `Brand Name`= "Apple" where `Brand Name` like "%mac%" or `Brand Name` like "ipad" or `Brand Name` like "%airpods%";

update electronics set Price = trim(replace(replace(Price, '\r', ''), '\n', ''));

update electronics set Price = NULL where Price = '';

alter table electronics modify column Price decimal(50,2);

describe electronics;

-- EXPLORATORY DATA ANALYSIS

-- UNIVARIATE ANALYSIS
-- Numerical Columns
-- Removing Nulls
select * from electronics where price is null;
delete from electronics where price is null;

-- Min, MAx, Avg, STD
select min(price) as Minimum,max(price) as Maximum, avg(price) as Average, std(price) as STD from electronics;

-- Percentiles
select price, max(percentile) from 
(
	select price, round(percent_rank() over (order by price),2) as percentile from electronics
)k group by price;

delimiter $$
create procedure GetpriceBypercentile( in percentile_value decimal(3,2), out price_limit decimal(10,2))
begin
select max(price) into price_limit
from (
	select price, round(percent_rank() over (order by price),2) as percentile from electronics
)k where percentile = percentile_value;
end $$
delimiter ;

call GetpriceBypercentile(0.25, @q1);
call GetpriceBypercentile(0.50, @q2);
call GetpriceBypercentile(0.73, @q3);

select @q1 as Quarter1, @q2 as Median, @q3 as Quarter3;

-- Outliers
select * from electronics where price < (@q1-1.5*(@q3-@q1)) or price > (@q3+1.5*(@q3-@q1));

select bucket, count(*)
from (
	select price,
		case when price <=500 then "0-0.5k"
			 when price >500 and price <=1500 then "0.5k-1.5k"
             when price >1500 and price <=3000 then "1.5k-3k"
             when price >3000 and price <=4000 then "3k-4k"
             else ">4k"
		end as bucket
	from electronics
)k group by bucket;

-- Categorical Columns
-- Checking for nulls
select count(*) from electronics where `Sub Category` is null;

select `Sub Category`, count(*) as counts from electronics group by `Sub Category`;

-- BIVARIATE ANALYSIS
-- Numerical -  Numerical Columns

select reviews, rating from electronics;

-- Check Covariance
select round((sum((rating-(select avg(rating) from electronics))*(reviews-(select avg(reviews) from electronics))))/(count(*)-1),2)  as Covariance from electronics;

-- Check Correlation
select round((sum((rating-(select avg(rating) from electronics))*(reviews-(select avg(reviews) from electronics))))/(count(*)-1)/(std(rating)*std(reviews)),2) as Correlation from electronics;

-- Find Slope
select round(sum((rating-(select avg(rating) from electronics))*(reviews-(select avg(reviews) from electronics)))/sum(power(rating-(select avg(rating) from electronics),2)),2) as Slope from electronics;
-- So to increase 1 point in rating, we need 255 reviews.

-- Categorical - Categorical Columns
select `Brand Name`, count(distinct `Sub CAtegory`) as Sectors from electronics group by `Brand Name`;

-- Numerical - Categorical Columns
select `Brand Name`, round(min(price),2) as Minimum, round(max(price),2) as Maximum, round(avg(price),2) as Average, round(std(price),2) as STD from electronics group by `Brand Name`;

-- MULTIVARIANT ANALYSIS
select `Sub Category`, round((sum((price-(select avg(price) from electronics))*(MRP-(select avg(MRP) from electronics))))/(count(*)-1),2)  as Covariance from electronics group by `Sub Category`;

-- Business Insights
-- Insight 1: Market Preferences
SELECT 
    `Sub Category`, 
    `Brand Name`, 
    COUNT(*) as Top_3_Placements
FROM (
    SELECT 
        `Sub Category`, 
        `Brand Name`, 
        DENSE_RANK() OVER(PARTITION BY `Sub Category` ORDER BY Reviews DESC) as Category_Rank
    FROM electronics
    WHERE Reviews IS NOT NULL
) ranked_data
WHERE Category_Rank <= 3
GROUP BY `Sub Category`, `Brand Name`
ORDER BY Top_3_Placements DESC;
-- Apple secures top-3 engagement ranks across 7 distinct product verticals (e.g., iPads, PCs, Watches), cross-selling their ecosystem.
-- Samsung heavily concentrates its market power, capturing 5 top-tier engagement spots strictly within the TVs category.

-- Insight 2: Hardware Preferences
SELECT 
    REGEXP_SUBSTR(title, '[0-9]+(GB|TB)') AS Storage_Capacity,
    COUNT(*) AS Total_Products,
    ROUND(AVG(Reviews), 0) AS Avg_Reviews,
    ROUND(AVG(Price), 2) AS Avg_Price
FROM electronics
WHERE title REGEXP '[0-9]+(GB|TB)'
GROUP BY Storage_Capacity
ORDER BY Avg_Reviews DESC;
-- Entry-level storage models (64GB and 256GB) drive the highest consumer engagement (800+ average reviews), indicating a highly price-sensitive consumer base.
-- Despite 1TB models dominating the catalog with the highest product count (15), they yield less than half the average engagement of 64GB models, suggesting potential overstocking in premium tiers.

-- Insight 3: Engagement  Segmentation
SELECT 
    CASE 
        WHEN Reviews >= 10000 THEN 'Viral / High Engagement'
        WHEN Reviews >= 1000 THEN 'Strong Engagement'
        WHEN Reviews >= 100 THEN 'Moderate Engagement'
        ELSE 'Low / Niche'
    END AS Engagement_Tier,
    COUNT(*) AS Product_Count,
    ROUND(AVG(Price), 2) AS Avg_Tier_Price
FROM electronics
WHERE Reviews IS NOT NULL
GROUP BY Engagement_Tier
ORDER BY Product_Count DESC;
-- Product engagement reveals a strict inverse correlation between pricing and consumer interaction, with the only "Viral" product priced at a highly accessible $149.99 compared to the $1,134.05 average of the lowest tier.
-- Half of the entire product line (300 items) falls into the "Low / Niche" engagement category, indicating that premium pricing acts as a significant bottleneck and the business should strategically optimize inventory around the $640–$730 sweet spot.

-- Insight 4: Price Volatility & Market Tiering (Coefficient of Variation)
SELECT 
    `Sub Category`,
    COUNT(*) AS Product_Count,
    ROUND(AVG(Price), 2) AS Avg_Price,
    ROUND(STD(Price), 2) AS Std_Price,
    ROUND((STD(Price) / AVG(Price)) * 100, 2) AS Price_CV_Percentage
FROM electronics
WHERE Price IS NOT NULL
GROUP BY `Sub Category`
HAVING Product_Count >= 10
ORDER BY Price_CV_Percentage DESC;
-- The 'Smart Home & Safety' and 'Home Security Systems & Cameras' categories exhibit extreme price volatility (CVs of 174.13% and 134.69%), indicating a heavily tiered market designed to cater to both budget-conscious entry-level consumers and premium enterprise buyers.
-- In contrast, specialized hardware categories like 'Gaming Laptops & Notebooks' and 'Gaming Desktop Computers' demonstrate the lowest price volatility (CVs under 35%), suggesting a highly commoditized market with strict minimum price floors governed by expensive internal components.

-- Insight 5: Brand Quality Consistency & Trust Metrics
SELECT 
    `Brand Name`,
    COUNT(*) AS Product_Count,
    ROUND(AVG(Rating), 2) AS Avg_Rating,
    ROUND(STD(Rating), 2) AS Rating_Volatility
FROM electronics
WHERE Rating IS NOT NULL
GROUP BY `Brand Name`
HAVING Product_Count >= 5
ORDER BY Rating_Volatility ASC;
-- Brands such as Ring, Microsoft, and Duracell achieve perfect rating consistency (0.00 volatility) while maintaining solid 4.00 average ratings, indicating exceptional quality control and reliable customer satisfaction across their product lines.
-- In stark contrast, security brands like SWANN and Lorex exhibit severe rating volatility (0.99 and 0.83 respectively) combined with the lowest average ratings in the catalog (2.63 and 2.14). This points to significant quality control issues, defective product batches, or highly polarizing customer experiences that damage brand trust.

-- Insight 6: Feature Text Mining & Buzzword Valuation
SELECT 
    CASE 
        WHEN Feature LIKE '%Smart%' THEN 'Smart Enabled'
        WHEN Feature LIKE '%Wireless%' THEN 'Wireless'
        WHEN Feature LIKE '%Waterproof%' THEN 'Waterproof'
        ELSE 'Standard / Unspecified'
    END AS Feature_Tag,
    COUNT(*) AS Product_Count,
    ROUND(AVG(Price), 2) AS Avg_Price,
    ROUND(AVG(Reviews), 0) AS Avg_Reviews
FROM electronics
WHERE Price IS NOT NULL AND Reviews IS NOT NULL
GROUP BY Feature_Tag
ORDER BY Avg_Reviews DESC;
-- Text mining reveals that standard or unspecified electronics drive the highest average consumer engagement (530 reviews). In contrast, hardware heavily marketed with buzzwords like "Smart Enabled" or "Wireless" significantly underperforms in engagement (345 and 143 reviews, respectively), suggesting these specific tags do not inherently drive higher sales volume.
-- Counterintuitively, products tagged with advanced features like "Wireless" ($526.60) and "Smart Enabled" ($477.32) hold significantly lower average price points than the broader "Standard / Unspecified" catalog ($989.06). This indicates that the most expensive core electronics (like PCs or large displays) do not rely on these specific feature buzzwords to command a premium price.
