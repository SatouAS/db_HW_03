# Задание 1

select job_industry_category,
	count(*) as customers_cnt
from customer
group BY job_industry_category
order BY customers_cnt desc;

# Задание 2


with ord as (
    select o.order_id,
           c.job_industry_category,
           date_trunc('month', to_date(o.order_date, 'YYYY-MM-DD')) as ym
    from orders   o
    join customer c on c.customer_id = o.customer_id
    where o.order_status = 'Approved'
)
select date_part('year',  ym) as yr,
       date_part('month', ym) as mon,
       o.job_industry_category,
       sum(p.list_price * oi.quantity) as rev
from ord          o
join order_items  oi ON oi.order_id  = o.order_id
join product      p  ON p.product_id = oi.product_id
group by yr, mon, o.job_industry_category
order by yr, mon, o.job_industry_category;


# Задание 3

with onl_ord as (
    select distinct o.order_id, p.brand
    from orders o
    join customer c on c.customer_id = o.customer_id
    join order_items oi on oi.order_id = o.order_id
    join product p on p.product_id  = oi.product_id
    where c.job_industry_category = 'IT'
      and o.order_status = 'Approved'
      and o.online_order = TRUE
)
select p.brand,
	count(io.order_id) as it_onl_ord
from product p
left join onl_ord io on io.brand = p.brand
group by p.brand
order by it_onl_ord DESC, p.brand;



# Задание 6

with or_d as (
    select o.*,
           row_number() over (partition by o.customer_id
                              order by to_date(o.order_date,'YYYY-MM-DD')) as rn
    from orders o
    where o.order_status = 'Approved'
)
select *
from or_d
where rn = 2;


# Задание 7

with b_orders as (
    select o.customer_id,
           cast(o.order_date as date) as order_dt
    from orders o
    where o.order_status = 'Approved'
),
gaps as (
    select bo.customer_id,
           bo.order_dt,
           bo.order_dt - lag(bo.order_dt) over (
               partition by bo.customer_id
               order by bo.order_dt
           ) as diff_days
    from b_orders bo
),
max_gaps as (
    select g.customer_id,
           max(g.diff_days) AS longest_gap
    from gaps g
    group by g.customer_id
    having count(*) > 1
)
select c.first_name,
       c.last_name,
       c.job_title,
       mg.longest_gap
from max_gaps mg
join customer c on c.customer_id = mg.customer_id
order by mg.longest_gap desc;



