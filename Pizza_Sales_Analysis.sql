create database pizzahut;
create table orders(
order_id int primary key,
order_date date not null,
order_time time not null
);

create table orders_details(
order_details_id int primary key,
order_id int,
pizza_id text,
quantity int not null);

-- Q1.Retrieve the total number of orders placed.

SELECT 
    COUNT(*)
FROM
    orders AS total_orders;
    
-- Q2.Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS total_sales
FROM
    orders_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id;
    
-- Q2.Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS total_sales
FROM
    orders_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id;
    
-- Q3.Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price AS highest_priced_pizza
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Q4.Identify the most common pizza size ordered.
 SELECT 
    p.size, COUNT(o.order_details_id) AS size_order
FROM
    orders_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY size_order DESC;

-- Q5.List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- Q6.Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Q7.Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);

-- Q8.Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Q9.Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS average_pizzas_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
-- Q10.Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name,
sum(orders_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas 
on pizzas.pizza_type_id=pizza_types.pizza_type_id
join orders_details 
on orders_details.pizza_id=pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;

-- Q11. Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category,
round(sum(orders_details.quantity*pizzas.price) /(SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS total_sales
FROM
    orders_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id)*100 ,2)as revenue
from pizza_types join pizzas 
on pizzas.pizza_type_id=pizza_types.pizza_type_id
join orders_details 
on orders_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by revenue desc ;

-- Q12.Analyze the cumulative revenue generated over time.
select order_date , sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date,
sum( orders_details.quantity*pizzas.price) as revenue 
from orders_details
join pizzas on orders_details.pizza_id=pizzas.pizza_id
join orders 
on orders.order_id=orders_details.order_id
group by orders.order_date) as sales;

-- Q13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,revenue from
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category,pizza_types.name,
sum((orders_details.quantity)*pizzas.price) as revenue
from pizza_types
join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category,pizza_types.name
) as a) as b
where rn <=3;

