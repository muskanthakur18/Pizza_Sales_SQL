CREATE database PIZZA;

CREATE TABLE orders(
order_id int not null,
ortder_date date not null,
order_time time not null,
primary key(order_id) );

SHOW COLUMNS FROM orders;
create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id) );

-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.

select pizza_types.name, pizzas.price 
from pizza_types
join pizzas
on pizza_types.pizza_type_id= pizzas.pizza_type_id
order by pizzas.price desc limit 1;

-- Identify the most common pizza size ordered.


select size,count(size)
from pizzas
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by size;

select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizzas.size order by order_count desc;


-- List the top 5 most ordered pizza types along with their quantities.


select pizza_types.name,sum(order_details.quantity) as Total_Orders
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name order by total_orders desc limit 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category, sum(order_details.quantity) as quantity
from pizza_types
join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by quantity desc;

-- Determine the distribution of orders by hour of the day.

select hour(order_time) as hour, count(order_id) as order_count from orders
group by hour(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas

SELECT 
    category, COUNT(name) AS No_of_Pizzas
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),0) from
(select orders.order_date as Date, sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id=order_details.order_id
group by orders.order_date)  as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, sum(order_details.quantity * pizzas.price) as Revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category, round(sum(order_details.quantity*pizzas.price)/(select round (sum(order_details.quantity*pizzas.price),2) as total_sales
from order_details join pizzas on order_details.pizza_id=pizzas.pizza_id)*100,2) as ptg_contri
from pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by ptg_contri desc;

-- Analyze the cumulative revenue generated over time.
select order_date,sum(revenue) over (order by order_date) as cum_revenue
from
(select orders.order_date, round(sum(order_details.quantity*pizzas.price),2) as revenue
from order_details join pizzas 
on order_details.pizza_id=pizzas.pizza_id
join orders on order_details.order_id=orders.order_id
group by orders.order_date) as daily_revenue;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue 
from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category ,pizza_types.name, 
sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn<=3;
