-- retreive the total number orders placed 
select count(order_id) from pizzahut.orders

-- calculate total number of revenue generated from the total sales
use pizzahut
Select sum(order_details.quantity * pizzas.price) as totasales
from order_details  
JOIN pizzas 
on pizzas.pizza_id = order_details.pizza_id

-- identitfy the highest priced pizza
select pizza_types.name ,pizzas.price 
from pizza_types JOIN pizzas 
ON pizza_Types.pizza_type_id=pizzas.pizza_type_id 
order by price DESC
limit 1;

-- identify the most common pizza order 
SELECT pt.name AS pizza_name, SUM(od.quantity) AS total_ordered
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_ordered DESC
LIMIT 1;

--   List  the top 5 most common pizza typesalong with their quantities
SELECT pizza_types.name,
SUM(order_details.quantity) AS Quantity
FROM pizza_types JOIN pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
 on order_details.pizza_id = pizzas.pizza_id 
group by pizza_types.name 
Order by Quantity desc
limit 5;

-- join the necessary table to find order quantity of each pizza category  ordered

select pizza_types.category,
SUM(order_details.quantity) as Quantity 
FROM pizza_types
join pizzas
 on pizza_types.pizza_type_id = pizzas.pizza_type_id 
join order_details
on order_details.pizza_id = pizzas. pizza_id 
group by  pizza_types.category
order by Quantity DESc; 

-- determine the distribution of orders by hour of the day 
select hour(order_time) ,
count(order_id)
from pizzahut.orders
group by hour(order_time);

-- join relevant tables to find the category wise distribution of pizzas
SELECT category , count(name) as TotalTypes 
from pizzahut.pizza_types
group by category;

-- group the orders by date and calculate the average number of  pizzas ordered per day 

select avg(daily_pizzas) as avg_pizzas_per_day
from (
    select 
        date(o.order_date) as day,
        sum(od.quantity) as daily_pizzas
    from orders o
    join order_details od
        on o.order_id = od.order_id
    group by date(o.order_date)
) t;

-- determine most 3 ordered pizza based on revenue 

select pizza_types.name ,
sum(pizzas.price * order_details.quantity) AS Revenue 
from pizza_types
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name 
order by revenue DESC 
limit 3;

--  calculate the percentage contribution of each pizza type to total revenue 
SELECT 
    pt.name AS pizza_name,
    SUM(p.price * od.quantity) AS revenue,
    ROUND(
        (SUM(p.price * od.quantity) * 100.0) /
        (SELECT SUM(p2.price * od2.quantity)
         FROM pizzas p2
         JOIN order_details od2 ON od2.pizza_id = p2.pizza_id),
        2
    ) AS revenue_percentage
FROM pizza_types pt
JOIN pizzas p
    ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
    ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue_percentage DESC;

-- analyse the cumulative revenue generated over time
SELECT DATE(o.order_date) AS order_day,
    SUM(p.price * od.quantity) AS daily_revenue,
    SUM(round(SUM(p.price * od.quantity))) 
        OVER (ORDER BY DATE(o.order_date)) AS cumulative_revenue
FROM orders o
JOIN order_details od 
    ON o.order_id = od.order_id
JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
GROUP BY DATE(o.order_date)
ORDER BY order_day;
