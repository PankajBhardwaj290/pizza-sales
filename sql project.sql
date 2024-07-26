CREATE DATABASE PIZZA_HUT;
use pizza_hut;

select * from pizza_types;
select * from pizzas;
select * from orders;
select * from order_details;

create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);

-- select  the total number of orders placed 

select count(order_id) from orders;

-- calculate the total revenue generated from pizza sales
select sum(p.price*ed.quantity) as total_revenue from pizzas p
join order_details ed
on p.pizza_id = ed.pizza_id ;

-- identify the highest price pizza 
select price,name from pizzas as p
join pizza_types as pt
order by price desc 
limit 1;

-- identify the most common pizza size ordered
select count(order_details_id) as order_count,size from order_details od
join pizzas p
on p.pizza_id = od.pizza_id
group by size
order by order_count desc
limit 1;

-- list the top 5 most ordered pizza types along with their quantiies.
SELECT 
    pt.name, SUM(od.quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- join the necessary tables to find the total quantity of each pizza category ordered.
select category,round(sum(quantity*price),0) as total_revenue from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details pd
on p.pizza_id = pd.pizza_id
group by category;

-- determine the distributon of orders by hour of the day
select hour(time) as hour,count(order_id) from orders
group by hour
order by count(order_id)desc;

-- join relevant tables to find the category wise distribution of pizzas
select count(category),category from pizza_types
group by category;

-- group the orders by date and calculate the average number of pizzas ordered per day
SELECT 
    date, COUNT(order_id) AS total_orders
FROM
    orders
GROUP BY date;

select avg(quantity) from
(select orders.date,sum(order_details.quantity)  as quantity from order_details join orders 
on order_details.order_id =  orders.order_id
group by orders.date) t ;


-- determine the top 3 most ordered pizza types based on revenue.
select name,sum(od.quantity*price ) as total_revenue from pizza_types pt join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on p.pizza_id = od.pizza_id
group by name
order by total_revenue desc
limit 3;

-- calculate the percentage contribution of each pozza type to total revenue

SELECT 
    category,
    ROUND(SUM(quantity * price), 0) / (SELECT 
            SUM(p.price * ed.quantity) AS total_revenue
        FROM
            pizzas p
                JOIN
            order_details ed ON p.pizza_id = ed.pizza_id) * 100 AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details pd ON p.pizza_id = pd.pizza_id
GROUP BY category;

-- analyze the cumulative revenue generated over time

select date,sum(revenue) over(order by date) as cum_revenue
from 
(select o.date,sum(od.quantity* p.price) as revenue
from order_details od join pizzas p
on od.pizza_id = p.pizza_id 
join orders o
on  o.order_id = od.order_id 
group by o.date) as sales;


