use restaurant_analysis;
create table highways
( highway_id int primary key,
  highway_name varchar(50) not null,
  route varchar(150)not null,
  direction_type varchar(50),
  agv_distance_km decimal(6,2) not null
  ); 
  
insert into highways values
(1, 'NH-16', 'Chennai ↔ Kolkata (via Nellore/Vijayawada)', 'Inter-state', 1659),
(2, 'NH-48', 'Chennai ↔ Bengaluru/Mumbai', 'Inter-state', 534),
(3, 'NH-716', 'Chennai ↔ Tirupati/Muddanur', 'Inter-state', 319),
(4, 'NH-32', 'Chennai ↔ Thoothukudi (via Chengalpattu)', 'Intra-state & Inter-state', 657),
(5, 'NH-332A', 'Chennai/ECR ↔ Puducherry', 'Inter-state', 95),
(6, 'Chennai Bypass Road', 'Perungalathur ↔ Puzhal (Connects NH-32/16/48/716)', 'Inter-urban expressway', 32),
(7, 'Outer Ring Road (CORR)', 'Vandalur ↔ Minjur', 'Urban tolled ring road', 60),
(8, 'East Coast Elevated Expressway', 'Light House ↔ East Coast Road', 'Intra-city express route', 9.7);

select * from highways;

create table restaurants(
         restaurant_id int primary key,
         highway_id int,
         restaurant_type enum('Veg','Non-Veg','Both'),
         restaurant_category varchar(15)
                    check(restaurant_category in ('Budget','Mid-range','Diner')),
		 rating decimal(2,1),
         avg_price_for_two int,
         foreign key(highway_id) references highways(highway_id)
         );
         
select * from restaurants;

create table toll_traffic(
           toll_id int primary key,
           highway_id int,
           avg_daily_traffic int,
           peak_hours varchar(50),
           foreign key(highway_id) references highways(highway_id)
           );
           
insert into toll_traffic values
(1,1,150000,'6-9 AM, 5-8 PM'),
(2,2,120000,'7-10 AM, 6-9 PM'),
(3,3,80000,'5-8 AM, 4-7 PM'),
(4,4,90000,'6-9 AM, 5-8 PM'),
(5,5,70000,'10 AM-1 PM, 4-7 PM'),
(6,6,60000,'7-10 AM, 5-8 PM'),
(7,7,50000,'6-9 AM, 5-7 PM'),
(8,8,20000,'8-10 AM, 5-7 PM');

select * from toll_traffic;

create table destinations(
         destination_id int primary key,
         highway_id int,
         destination_name varchar(100),
         destination_type varchar(20),
         foreign key (highway_id) references highways(highway_id)
         );
insert into destinations values
(1,1,'Nellore','Industrial'),
(2,1,'Vijayawada','Urban'),
(3,1,'Kolkata','Industrial'),
(4,2,'Hosur','Industrial'),
(5,2,'Bengaluru','Urban'),
(6,2,'Krishnagiri','Tourist'),
(7,3,'Tirupati','Pilgrim'),
(8,3,'Chittoor','Urban'),
(9,4,'Chidambaram','Pilgrim'),
(10,4,'Thoothukudi','Industrial'),
(11,4,'Rameswaram','Pilgrim'),
(12,5,'Puducherry','Tourist'),
(13,5,'Chidambaram','Tourist'),
(14,6,'Tambaram','Urban'),
(15,6,'Ambattur','Industrial'),
(16,7,'Minjur','Urban'),
(17,7,'Red Hills','Industrial'),
(18,8,'ECR Beaches','Coastal'),
(19,8,'IT Corridor','Urban');
		
select * from destinations;

create table traveller_profile(
           highway_id int primary key,
           family_pct decimal(5,2),
           tourist_pct decimal(5,2),
           bikers_pct decimal(5,2),
           workers_pct decimal(5,2),
           commercial_pct decimal(5,2),
           foreign key(highway_id) references highways(highway_id),
           check (family_pct + tourist_pct + bikers_pct + workers_pct + commercial_pct =100)
           );
           
insert into traveller_profile values
(1,20,15,10,25,30),
(2,18,20,12,25,25),
(3,35,10,8,17,30),
(4,30,15,10,20,25),
(5,25,35,15,15,10),
(6,15,10,8,45,22),
(7,12,8,10,50,20),
(8,10,25,35,20,10);

----------------------------------------------------
-- Singlevariate Analysis--

select * from restaurants;

-- how many restaurants per highway--
select highway_id, count(restaurant_id) as restaurant_count
from restaurants
group by highway_id;

-- the avg ratings per highway--
select highway_id, round(avg(rating),1) as avg_ratings 
from restaurants 
group by highway_id;

-- which highway looks underserved--
select highway_id,count(restaurant_id), round(avg(rating),1) as avg_rating 
from restaurants
group by highway_id
order by count(restaurant_id) asc, avg_rating asc;

-- restaurant type count per hw--
select highway_id, count(restaurant_id), restaurant_type 
from restaurants
group by highway_id,restaurant_type
order by highway_id;

 -- count of distinct type of restaurant in highway--
select highway_id,count(distinct(restaurant_type)) 
from restaurants
group by highway_id
having count(distinct(restaurant_type)) < 3;

-- avg price per highway--
select highway_id,round(avg(avg_price_for_two),2) as avg_price 
from restaurants
group by highway_id;

-- max avg price--
select max(avg_price) from
(
select highway_id,round(avg(avg_price_for_two),2) as avg_price 
from restaurants
group by highway_id) as sub ;

-- min  avg price--
select min(avg_price) from(
select highway_id,round(avg(avg_price_for_two),2) as avg_price from restaurants
group by highway_id) as sub ;

-- count of restaurant category--
select highway_id, restaurant_category, count(restaurant_id),
rank() over(partition by highway_id order by count(restaurant_id) desc) as rn  
from restaurants
group by highway_id, restaurant_category
order by highway_id,count(restaurant_id) desc; 

-- dominant restaurant category per highway--
with dominant_category_cte as
(select highway_id,restaurant_category , count(restaurant_id)as res_count,
rank() over(partition by highway_id order by count(restaurant_id) desc) as rn  
from restaurants
group by highway_id, restaurant_category
order by highway_id,count(restaurant_id) desc
)
select highway_id,restaurant_category as dominant_restaurant_category, res_count 
from dominant_category_cte
where rn =1;

-- less dominant restaurant category per highway--
with dominant_category_cte as
(select highway_id,restaurant_category , count(restaurant_id)as res_count,
rank() over(partition by highway_id order by count(restaurant_id) desc) as rn  from restaurants
group by highway_id, restaurant_category
order by highway_id,count(restaurant_id) desc
)
select highway_id,restaurant_category as less_dominant_restaurant_category, res_count from dominant_category_cte
where rn =3;

------------------------------------------------------------
select * from toll_traffic;

-- highway that has most traffic--
select highway_id 
from toll_traffic 
where avg_daily_traffic =(select max(avg_daily_traffic) from toll_traffic);

-- highway that has least traffic--
select highway_id 
from toll_traffic
where avg_daily_traffic= (select min(avg_daily_traffic) from toll_traffic);

-- top 3 busiest highway--
select highway_id, avg_daily_traffic 
from toll_traffic
order by avg_daily_traffic desc
limit 3;

-- bottom 3 least used highway--
select highway_id, avg_daily_traffic 
from toll_traffic
order by avg_daily_traffic asc
limit 3;

-- overall avg traffic--
select avg(avg_daily_traffic) as overall_avg_traffic 
from toll_traffic;

select highway_id,avg_daily_traffic 
from toll_traffic 
where avg_daily_traffic > ( select avg(avg_daily_traffic) as overall_avg_traffic from toll_traffic);

-- traffic segmantation --
with traffic_score_cte as
(
select highway_id,avg_daily_traffic,
case 
	when avg_daily_traffic >=90000 then 'High' 
    when avg_daily_traffic >= 70000 then 'Medium'
	when avg_daily_traffic < 70000 then 'Low'
end as traffic_rate
from toll_traffic
order by avg_daily_traffic desc)
select highway_id,traffic_rate,
case when traffic_rate='High' then 5
     when traffic_rate='Medium' then 3
     when traffic_rate='Low' then 1
	end as traffic_score
from traffic_score_cte;

------------------------------------------------------------------
select * from traveller_profile;

-- hw which has max family travellers--
select highway_id,family_pct 
from traveller_profile
order by family_pct desc
limit 1;

-- hw which has max tourist travellers--
select highway_id,tourist_pct 
from traveller_profile
order by tourist_pct desc
limit 1;

-- hw which has max biker travellers--
select highway_id,bikers_pct 
from traveller_profile
order by bikers_pct desc
limit 1;

-- hw which has max workers travellers--
select highway_id,workers_pct 
from traveller_profile
order by workers_pct desc
limit 1;

-- hw which has max commercial travellers--
select highway_id,commercial_pct 
from traveller_profile
order by commercial_pct desc
limit 1;

-- dominant traveller per highway--

with cte as
(
select highway_id, traveller_type,pct,
rank() over(partition by highway_id order by pct desc)as rn
from(
     select highway_id,'family' as traveller_type, family_pct as pct from traveller_profile
     union all
     select highway_id,'tourist' , tourist_pct  from traveller_profile
      union all
     select highway_id,'biker' , bikers_pct  from traveller_profile
      union all
     select highway_id,'worker' , workers_pct  from traveller_profile
      union all
     select highway_id,'commercial' , commercial_pct  from traveller_profile)t
     
	)
    select highway_id,traveller_type,pct
    
    from cte
    where rn=1;
    
    -- traveller spending score-----
    
    select highway_id,round(
   (family_pct * 5 +
    tourist_pct * 5 +
    commercial_pct * 3 +
    workers_pct * 2 +
    bikers_pct * 1) / 100
 ,2) as traveller_spending_score
from traveller_profile
order by traveller_spending_score desc;
    
    
----------------------------------------------------------------------

select * from destinations;

-- no of destinations per highway--
select highway_id, count(destination_id) 
from destinations
group by highway_id;

-- no of destination_types per highway--
select highway_id, count(distinct(destination_type)) as destination_type_count 
from destinations
group by highway_id;

-- dominant destination type per highway--

with dominant_desti_cte as 
(
 select highway_id,destination_type,count(destination_type) as desti_count,
 rank() over(partition by highway_id order by count(destination_type) desc) as rk
 from destinations 
 group by highway_id,destination_type
 )
 
 select highway_id,destination_type from dominant_desti_cte
 where rk=1;
 
-- destination demand score--
select
 highway_id,count(*),
 round(
   (sum(
      case
        when destination_type in ('Tourist','Pilgrim') then 5
        when destination_type in ('Urban','Coastal') then 4
        when destination_type = 'Industrial' then 3
      end
   ) / count(*))
 ,2) as destination_demand_score
from destinations
group by highway_id;

