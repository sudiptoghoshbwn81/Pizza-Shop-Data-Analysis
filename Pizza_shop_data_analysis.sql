create database my_pizza;
use my_pizza;
describe pizzas;
select * from pizzas;

describe pizza_types;
select * from pizza_types;

-- creating order table
create table orders(
order_id int primary key not null,
order_date date not null,
order_time time not null);

describe orders;
select * from orders;

-- creating order details table
create table order_details(
order_details_id int primary key not null,
order_id int not null,
pizza_id text not null,
quantity int not null);

describe order_details;
select * from order_details;

-- Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS total_orders
FROM orders;

-- Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

-- Identify the highest-priced pizza.
SELECT pt.name,p.size,p.price
FROM pizzas p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT p.size,SUM(od.quantity) AS total_quantity_ordered
FROM order_details od
JOIN pizzas p 
ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_quantity_ordered DESC
LIMIT 1;

-- . List the top 5 most ordered pizza types along with their quantities.
SELECT pt.name,SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p 
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p 
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT HOUR (order_time) AS order_hour,COUNT(order_id) AS order_count
FROM orders
GROUP BY order_time
ORDER BY order_time;

-- Join relevant tables to find the category-wise distribution of pizzas (number of pizza types per category).
SELECT category,COUNT(pizza_type_id) AS number_of_pizzas
FROM pizza_types
GROUP BY category
ORDER BY number_of_pizzas DESC;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
WITH daily_pizza_counts AS 
(SELECT o.order_date,SUM(od.quantity) AS total_pizzas
FROM orders o
JOIN order_details od 
ON o.order_id = od.order_id
GROUP BY o.order_date
)
SELECT ROUND(AVG(total_pizzas), 2) AS avg_pizzas_per_day
FROM daily_pizza_counts;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.name,ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p 
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT pt.name,ROUND(SUM(od.quantity * p.price), 2) AS pizza_revenue,ROUND((SUM(od.quantity * p.price) / (SELECT SUM(od2.quantity * p2.price) 
FROM order_details od2 
JOIN pizzas p2 
ON od2.pizza_id = p2.pizza_id) * 100), 2) AS pct_contribution
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY pct_contribution DESC;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH category_pizza_revenue AS (SELECT pt.category,pt.name,SUM(od.quantity * p.price) AS total_revenue,
DENSE_RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rank_num
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category, pt.name
)
SELECT category,name,ROUND(total_revenue, 2) AS revenue,rank_num
FROM category_pizza_revenue
WHERE rank_num <= 3
ORDER BY category, rank_num;