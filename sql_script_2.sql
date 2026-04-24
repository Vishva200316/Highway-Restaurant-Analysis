use restaurant_analysis;

-- Multivariate Analysis--


 
 -- profit score---
 
 -- -------- restaurant_competition -----------
 
create temporary table restaurant_competition as
select highway_id,
count(restaurant_id) as total_restaurants,
case
    when count(restaurant_id) < 20 then 5
    when count(restaurant_id) <=30  then 3
    else 1
end as competition_score
from restaurants
group by highway_id;
 
select * from restaurant_competition;
 
-- -------------traffic score--------

create temporary table traffic_score as
select highway_id,
avg_daily_traffic,
case 
    when avg_daily_traffic >= 90000 then 5
    when avg_daily_traffic >= 70000 then 3
    else 1
end as traffic_score
from toll_traffic;
select* from traffic_score;

-- ----------------travellers spending ------------

create temporary table traveller_spending as
select 
highway_id,
round(
(family_pct * 5 +
 tourist_pct * 5 +
 commercial_pct * 3 +
 workers_pct * 2 +
 bikers_pct * 1) / 100
,2) as traveller_spending_score
from traveller_profile;

select * from traveller_spending ;


-- Dominant traveller--

create temporary table dominant_traveller as
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
     
	) ;
   
   select * from dominant_traveller;


-- ------

-- dominant destination--

create temporary table dominant_desti_cte as 
(
 select highway_id,destination_type,count(destination_type) as desti_count,
 rank() over(partition by highway_id order by count(destination_type) desc) as rk
 from destinations 
 group by highway_id,destination_type
 );
 select highway_id,destination_type from dominant_desti_cte
 where rk=1;

-- profit score--

create temporary table profit_score as
select 
h.highway_id,
h.highway_name,
tt.avg_daily_traffic,
ts.traffic_score,
tp.traveller_spending_score,
dd.destination_demand_score,
rc.competition_score,

round(
(ts.traffic_score *0.35)+
(tp.traveller_spending_score*0.25)+
(dd.destination_demand_score*0.20)+
(rc.competition_score*0.20)
,2) as final_profit_score

from highways h

join traffic_score ts
on h.highway_id = ts.highway_id

join traveller_spending tp
on h.highway_id = tp.highway_id

join restaurant_competition rc
on h.highway_id = rc.highway_id

join
(
select highway_id,
round(
(sum(
case
when destination_type in ('Tourist','Pilgrim') then 5
when destination_type in ('Urban','Coastal') then 4
when destination_type='Industrial' then 3
end)/count(*)),2) as destination_demand_score
from destinations
group by highway_id
) dd
on h.highway_id = dd.highway_id

join toll_traffic tt
on h.highway_id = tt.highway_id;

select * from profit_score;


-- --
-- least dominant restaurant types--

select highway_id,
restaurant_type,
count(*) as type_count,
rank() over(partition by highway_id order by count(*) asc) as r
from restaurants
group by highway_id, restaurant_type;

select highway_id, restaurant_type
from
(
select highway_id,
restaurant_type,
count(*) as type_count,
rank() over(partition by highway_id order by count(*) asc) as r
from restaurants
group by highway_id, restaurant_type
) t
where r = 1;

-- top 3 recommended restaurant--

select 
p.highway_name,
p.final_profit_score,
dt.traveller_type,
dd.destination_type,

case
when dt.traveller_type='family'
     and dd.destination_type in ('Pilgrim','Urban')
     then 'Veg Family Restaurant'

when dt.traveller_type='tourist'
     and dd.destination_type in ('Tourist','Coastal')
     then 'Non-Veg / Multi-Cuisine Restaurant'

when dt.traveller_type in ('commercial','worker')
     and dd.destination_type='Industrial'
     then 'Budget Highway Diner'

when dt.traveller_type='biker'
     then 'Cafe / Fast Food Diner'

else 'Multi-Cuisine Both-Type Restaurant'
end as recommended_restaurant

from profit_score p
join dominant_traveller dt
on p.highway_id = dt.highway_id

join dominant_desti_cte dd
on p.highway_id = dd.highway_id

where dt.rn = 1
and dd.rk = 1
order by p.final_profit_score desc
limit 3;

-- all tables --

select * from highways;
select * from restaurants;
select * from destinations;
select * from toll_traffic;
select * from traveller_profile;
select * from profit_score;
select * from dominant_traveller;
