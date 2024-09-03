-- create database music;
use music;
-- here we will solve the queries of music data question bank is divide in 3 parts easy, medium, and hard 
-- ------------------------------------------------------------------------------------------------------------------
-- FROM EASY - question no. 1: Who is the senior most employee based on job title?
select concat(first_name,' ', last_name)as emp_name, title from employee order by levels desc limit 1 ;
-- question no. 2: Which countries have the most Invoices?
select billing_country, count(*) as most_invoice from invoice group by billing_country order by most_invoice desc;
-- question 3: What are top 3 values of total invoice?
select total from invoice order by total desc limit 3;
-- question 4: Which city has the best customers? We would like to throw a promotional Music
--  Festival in the city we made the most money. Write a query that
 -- returns one city that has the highest sum of invoice totals.
 -- Return both the city name & sum of all invoice totals
 select * from invoice;
select billing_city , sum(total) as city_wise_invoice_sum from invoice 
group by billing_city order by city_wise_invoice_sum desc limit 1 ;
-- question 5: : Who is the best customer? The customer who has spent the 
-- most money will be declared the best customer.
 -- Write a query that returns the person who has spent the most money.
select c.first_name , sum(i.total) as total_spend_money
from customer c join invoice i 
on c.customer_id = i.customer_id group by c.first_name
order by total_spend_money desc limit 1;
-- ------------------------------------------------------------------------------------------------------------------
-- From Medium = question 1: : Write query to return the email, first name, last name,
--  & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
select distinct(c.email), c.first_name, c.last_name from customer c join invoice i on 
c.customer_id= i.customer_id join
invoice_line il on 
il.invoice_id= i.invoice_id where trim(c.email) like "%a"and  track_id in(
select t.track_id from track t join genre g on t.genre_id=g.genre_id where 
g.name like "rock")
order by c.email;
-- question 2 = Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands
select a.artist_id ,a.name , count(t.track_id) as total_songs
from artist a inner join album al on a.artist_id= al.artist_id 
inner join track t on t.album_id=al.album_id 
inner join genre g on g.genre_id = t.genre_id
where g.name like 'rock'
group by a.artist_id,a.name
order by total_songs desc
limit 10;
-- question 3 = Return all the track names that have a song 
-- length longer than the average song length. Return the Name and
-- Milliseconds for each track. Order by the song length with the longest
-- songs listed first.
select name as track_name, milliseconds 
from track 
where milliseconds>(select avg(milliseconds) as avg_total_length from track )
order by milliseconds desc;
-- ----------------------------------------------------------------------------------------------------
-- from advance - question 1 = Find how much amount spent by 
-- each customer on artists? Write a query to return 
-- customer name, artist name and total spent
-- answer - in this we have to create the temporary table 
with temp_table as ( select
			a.artist_id as artist_ids , a.name as artist_names , sum(il.unit_price* il.quantity)as total_spends
            from invoice_line il
            join track t 
            on t.track_id=il.track_id
            join album ab
            on ab.album_id=t.album_id
            join artist a 
            on a.artist_id=ab.artist_id
            group by 1,2
            order by 3 desc
            limit 1
            )
select concat(trim(c.first_name),' ', trim(c.last_name)) as customer_name , tem.artist_names ,sum(il.unit_price*il.quantity) as total_spent
from customer c 
join invoice i 
on i.customer_id=c.customer_id
join invoice_line il
on i.invoice_id=il.invoice_id
join track t 
on t.track_id=il.track_id
join album ab 
on ab.album_id=t.album_id
join temp_table tem 
on tem.artist_ids=ab.artist_id
group by 1,2
order by 3 desc;       
-- question 2 = We want to find out the most popular music Genre 
-- for each country. We determine the most popular genre as the genre 
-- with the highest amount of purchases. Write a query that returns 
-- each country along with the top Genre. For countries where the
-- maximum number of purchases is shared return all Genres.
-- Steps to Solve:  There are two parts in question- first most
-- popular music genre and second need data at country level. 
with popular_genre as ( 
            select count(il.quantity) as purchases , c.country, g.name, g.genre_id 
            , row_number() over(partition by country order by count(il.quantity) ) as row_no
            from customer c 
            join invoice i on i.customer_id=c.customer_id
            join invoice_line il on il.invoice_id=i.invoice_id 
            join track t on t.track_id=il.track_id
            join genre g on g.genre_id=t.genre_id
            group by 2,3,4
            order by 2 asc, 1 desc
            )
select * from popular_genre where row_no<=1;      
-- question 3 = Write a query that determines the customer that has spent the most on music for 
-- each country. Write a query that returns the country along with the top customer and
-- how much they spent. For countries where the top amount spent is shared, provide
-- all customers who spent this amount Steps to Solve:  Similar to the 
-- above question. There are two parts in question- 
-- first find the most spent on music for each country and
-- second filter the data for respective customers. 
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;





