#### 1.What is the total amount each customer spent at the restaurant?

```sql
select customer_id, sum(price) as amount_spent
from sales s join menu m
	on s.product_id = m.product_id
group by customer_id
order by customer_id;
```

| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

#### 2.How many days has each customer visited the restaurant?

```sql
select customer_id, count(distinct order_date) as visits
from sales
group by customer_id;
```
| customer_id | visits      |
| ----------- | ----------- |
| A           | 4           |
| B           | 6           |
| C           | 2           |

#### 3.What was the first item from the menu purchased by each customer?

```sql
with cte as (select customer_id, product_name, dense_rank()over(partition by customer_id order by order_date) as ranking
from sales s join menu m
	on s.product_id = m.product_id)

select distinct customer_id, product_name
from cte
where ranking = 1;
```
| customer_id | product_name      |
| ----------- | ----------- |
| A           | curry          |
| A           | sushi           |
| B           | curry           |
|C            | ramen           |

#### 4.What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
with cte as (select product_name, count(*) as ordered_quantity, dense_rank()over(order by count(*) desc)as ranking
from sales s join menu m
	on s.product_id = m.product_id
group by product_name)

select product_name, ordered_quantity
from cte
where ranking = 1;
```

| product_name | ordered_quantity      |
| ----------- | ----------- |
| ramen          | 8          |

##### Bonus: how many times each customer ordered most purchased item?

```sql
select customer_id, count(product_name)
from sales s join menu m
	on s.product_id = m.product_id
where product_name = (with cte as (select product_name, count(*) as                                   ordered_quantity, dense_rank()over(order by count(*)                           desc)as ranking
	                 from sales s join menu m
	                 on s.product_id = m.product_id
	                 group by product_name)

	                 select product_name
	                 from cte
	                 where ranking = 1)
group by customer_id;
```

| customer_id | count|
| ----------- | ----------- |
| A           | 3          |
| B           | 2           |
| C           | 3           |

#### 5.Which item was the most popular for each customer?

```sql
with cte as (select customer_id,product_name, count(*), dense_rank()over(partition by customer_id order by count(*)desc) 
			 as ranking
from sales s join menu m
	on s.product_id = m.product_id
group by customer_id, product_name)

select customer_id, product_name
from cte
where ranking=1
```
| customer_id | product_name|
| ----------- | ----------- |
| A           | ramen        |
| B           | sushi       |
| B           | curry        |
|B          |ramen          |
|C          |ramen          |

#### 6.Which item was purchased first by the customer after they became a member?

```sql
with cte as (select s.customer_id, product_name, dense_rank()over(partition by s.customer_id order by order_date) as ranking
from sales s join members m
	on s.customer_id = m.customer_id
	join menu on s.product_id = menu.product_id
where order_date>=join_date)

select customer_id, product_name
from cte
where  ranking=1;
```
| customer_id | product_name|
| ----------- | ----------- |
| A           | curry        |
| B           | sushi       |

#### 7.Which item was purchased just before the customer became a member?

```sql
with cte as (select s.customer_id, product_name, dense_rank()over(partition by s.customer_id order by order_date desc) as ranking
from sales s join members m
	on s.customer_id = m.customer_id
	join menu on s.product_id = menu.product_id
where order_date < join_date)

select customer_id, product_name
from cte
where ranking=1;
```

| customer_id | product_name|
| ----------- | ----------- |
| A           | sushi        |
| A          | curry      |
|B          |   sushi       |

#### 8.What is the total items and amount spent for each member before they became a member?

```sql
select s.customer_id, count(product_name) as total_items, sum(price) as amount_purchased
from sales s join members m
	on s.customer_id = m.customer_id
	join menu on s.product_id = menu.product_id
where order_date < join_date
group by s.customer_id
order by s.customer_id;
```

| customer_id | total_items|total_amount|
| ----------- | ----------- | ----------|
| A           | 2       |25
| A          | 3      |40|

#### 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

```sql
with cte as (select customer_id, case when product_name = 'sushi' then 2*10*price else 1*10*price end as points
from sales s join menu m
	on s.product_id = m.product_id)
	
select customer_id, sum(points) as total_points
from cte
group by customer_id
order by customer_id;
```

| customer_id | total_points|
| ----------- | ----------- |
| A           | 860        |
| B          | 940      |
|C         |   360       |
