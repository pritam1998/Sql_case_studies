create table sales (
	"customer_id" varchar(1),
	"order_date" date,
	"product_id" integer
);

insert into sales
	("customer_id","order_date","product_id")
values
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
create table menu (
	"product_id" integer,
	"product_name" varchar(10),
	"price" integer);
	
insert into menu
	("product_id","product_name","price")
values
	(1,'sushi',10),
	(2,'curry',15),
	(3,'ramen',12);
	
create table members (
	"customer_id" varchar(1),
	"join_date" date);
	
insert into members
	("customer_id","join_date")
values
	('A', '2021-01-07'),
	('B', '2021-01-09');
	
select *
from sales;

select *
from menu;

select *
from members;

/* -------------------------------------------------------------------*/
/*						CASE STUDY QUESTIONS						  */
/* -------------------------------------------------------------------*/

/* 1.What is the total amount each customer spent at the restaurant?*/

select customer_id, sum(price) as amount_spent
from sales s join menu m
	on s.product_id = m.product_id
group by customer_id
order by customer_id;

/* 2.How many days has each customer visited the restaurant?*/

select customer_id, count(distinct order_date) as visits
from sales
group by customer_id;

/* 3.What was the first item from the menu purchased by each customer?*/

with cte as (select customer_id, product_name, dense_rank()over(partition by customer_id order by order_date) as ranking
from sales s join menu m
	on s.product_id = m.product_id)

select distinct customer_id, product_name
from cte
where ranking = 1;

/*What is the most purchased item on the menu and how many times was it purchased by all customers?*/

with cte as (select product_name, count(*) as ordered_quantity, dense_rank()over(order by count(*) desc)as ranking
from sales s join menu m
	on s.product_id = m.product_id
group by product_name)

select product_name, ordered_quantity
from cte
where ranking = 1;

/*Bonus: how many times each customer ordered most purchased item?*/

select customer_id, count(product_name)
from sales s join menu m
	on s.product_id = m.product_id
where product_name = (with cte as (select product_name, count(*) as ordered_quantity, dense_rank()over(order by count(*) desc)as ranking
	from sales s join menu m
		on s.product_id = m.product_id
	group by product_name)

	select product_name
	from cte
	where ranking = 1)
group by customer_id
order by customer_id;

/*5.Which item was the most popular for each customer?*/

with cte as (select customer_id,product_name, count(*), dense_rank()over(partition by customer_id order by count(*)desc) 
			 as ranking
from sales s join menu m
	on s.product_id = m.product_id
group by customer_id, product_name)

select customer_id, product_name
from cte
where ranking=1;

/*6. Which item was purchased first by the customer after they became a member?*/

with cte as (select s.customer_id, product_name, dense_rank()over(partition by s.customer_id order by order_date) as ranking
from sales s join members m
	on s.customer_id = m.customer_id
	join menu on s.product_id = menu.product_id
where order_date>=join_date)

select customer_id, product_name
from cte
where  ranking=1;

/*7.Which item was purchased just before the customer became a member?*/

with cte as (select s.customer_id, product_name, dense_rank()over(partition by s.customer_id order by order_date desc) as ranking
from sales s join members m
	on s.customer_id = m.customer_id
	join menu on s.product_id = menu.product_id
where order_date < join_date)

select customer_id, product_name
from cte
where ranking=1;

/*8.What is the total items and amount spent for each member before they became a member?*/

select s.customer_id, count(product_name) as total_items, sum(price) as amount_purchased
from sales s join members m
	on s.customer_id = m.customer_id
	join menu on s.product_id = menu.product_id
where order_date < join_date
group by s.customer_id
order by s.customer_id; 

/*9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?*/

with cte as (select customer_id, case when product_name = 'sushi' then 2*10*price else 1*10*price end as points
from sales s join menu m
	on s.product_id = m.product_id)
	
select customer_id, sum(points) as total_points
from cte
group by customer_id
order by customer_id;