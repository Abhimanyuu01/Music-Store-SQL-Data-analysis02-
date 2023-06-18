			#DATA ANALYSIS OF MUSIC STORE USING SQL


/* Ques1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1

/*This query retrieves the "title," "last_name," and "first_name" columns from the "employee" table. 
The results are then sorted in descending order based on the values in the "levels" column. 
The "LIMIT 1" clause ensures that only the top record with the highest "levels" value is returned.*/


/* Ques2: Which countries have the most Invoices? */

Select COUNT(*) , billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY count(1) DESC

/*This query retrieves the count of invoices for each billing country from the "invoice" table,
 ordering the results in descending order based on the count.*/



/* Ques3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC
limit 3 

/*This query retrieves the "total" column from the "invoice" table. It then sorts the results 
in descending order based on the values in the "total" column. The "limit 3" clause ensures 
that only the top three records with the highest "total" values are returned.*/



/* Ques4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city, SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;

/*This query retrieves the billing city and the sum of invoice totals for each city from the "invoice"
 table. The results are grouped by city, ordered in descending order based on the invoice total,
 and limited to the city with the highest total.*/


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1; 

/*This query retrieves data from the "customer" and "invoice" tables. It selects the "customer_id,
" "first_name," and "last_name" columns from the "customer" table and calculates the sum of 
the "total" column from the "invoice" table for each customer. The results are grouped by customer ID,
 ordered in descending order based on the total spending, and limited to the customer with the highest
 total spending.*/
 



/* Ques6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */


SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoiceline ON invoice.invoice_id = invoiceline.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

/*This query retrieves distinct email addresses along with the corresponding first name and last name
 from the "customer" table. It performs multiple joins with the "invoice" and "invoiceline" tables 
 to connect customers with their associated invoices and invoice lines. The query filters the results
 based on tracks that belong to the "Rock" genre. The final result set is ordered by email address.*/



/* Ques7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

/*This query retrieves the artist ID, name, and the count of songs for each artist who has tracks 
in the "Rock" genre. It joins the "track," "album," "artist," and "genre" tables to establish the 
relationships between tracks, albums, artists, and genres. The results are then grouped by artist ID
 and ordered in descending order based on the number of songs. The query limits the output to the top
 10 artists with the highest number of songs in the "Rock" genre.*/


/* Ques8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name,miliseconds
FROM track
WHERE miliseconds > (
	SELECT AVG(miliseconds) AS avg_track_length
	FROM track )
ORDER BY miliseconds DESC;


/*This query retrieves the name and duration (in milliseconds) of tracks from the "track" table.
 It filters the tracks based on their duration, specifically selecting tracks that have a duration
 greater than the average track length in the entire table. The results are then sorted in descending 
 order based on track duration.*/


/* Ques9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */


WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


/*This query calculates the total sales for the best-selling artist and then retrieves customer 
information along with the total amount spent by each customer on tracks associated with that artist.
 It joins multiple tables, including "invoice," "customer," "invoice_line," "track," "album," and
 "best_selling_artist," to establish the necessary relationships. The results are grouped by customer
 ID, first name, last name, and artist name.*/


/* Ques10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */


WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

/*This query determines the most popular genre for each country by analyzing customer purchases.
 It retrieves data from the "invoice_line," "invoice," "customer," "track," and "genre" tables. 
 The query calculates the count of purchases for each genre and country combination, assigns a 
 row number to each combination within its respective country, and orders the results by country 
 in ascending order and count in descending order. It selects the rows with a row number equal to 
 or less than 1 for each country and genre combination.*/



/* Ques11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */



WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;

/*This query utilizes recursive common table expressions (CTEs) to identify the customers with the 
highest total spending for each billing country. The first CTE, "customter_with_country," calculates 
the total spending for each customer and their respective billing country. The second CTE, 
"country_max_spending," determines the maximum total spending for each billing country. 
The final query joins these CTEs and selects the customers whose total spending matches the maximum 
spending for their country. The results are ordered by billing country.*/


/*In conclusion, this SQL data analytics project successfully leveraged SQL queries and techniques
 to extract valuable insights from the data. By utilizing various SQL functionalities such as joins,
 aggregations, and ordering, we were able to analyze the data effectively. The project highlights the
 importance of SQL as a powerful tool for data analysis and demonstrates its ability to provide 
 valuable information for decision-making processes. Moving forward, further analysis and 
 visualization techniques can be applied to gain deeper insights and drive informed business 
 decisions based on the data at hand.*/





