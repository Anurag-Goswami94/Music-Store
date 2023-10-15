## Who is the senior most employee based on job title?
SELECT * from employee;
SELECT employee_id, first_name, last_name, title, levels, hire_date FROM employee ORDER BY levels DESC LIMIT 1;

## Which countries have the most invoices? 
SELECT * FROM invoice;
SELECT count(billing_country) as No_of_invoice , billing_country FROM invoice GROUP BY billing_country ORDER BY No_of_invoice DESC;

## What are the top 3 values of total invoice? 
SELECT total FROM invoice ORDER BY total DESC LIMIT 3;

## Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
## Write a query that returns one city that has the highest sum of invoice totals. 
## Return both the city name & sum of all invoice totals

SELECT * FROM invoice;
SELECT SUM(total) as total_invoice, billing_city FROM invoice GROUP BY billing_city ORDER BY total_invoice DESC LIMIT 1;

## Who is the best customer? The customer who has spent the most money will be declared the best customer. 
## Write a query that returns the person who has spent the most money

SELECT * FROM invoice;
SELECT * FROM customer;

SELECT SUM(invoice.total) AS Money_spent, customer.customer_id, customer.first_name, customer.last_name FROM customer 
JOIN invoice on invoice.customer_id= customer.customer_id
GROUP BY customer.first_name, invoice.customer_id, customer.last_name ORDER BY Money_spent DESC LIMIT 1;

## Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
## Return your list ordered alphabetically by email starting with A.
SELECT * FROM customer;
SELECT * FROM genre;
SELECT * FROM invoice_line;
SELECT * FROM track;
SELECT * FROM invoice;

SELECT customer.first_name, customer.last_name, customer.email, genre.name AS Music_Genre FROM customer 
JOIN invoice on customer.customer_id=invoice.customer_id
JOIN invoice_line on invoice.invoice_id = invoice_line.invoice_id
JOIN track on invoice_line.track_id=track.track_id
JOIN genre on genre.genre_id=track.genre_id WHERE genre.name= 'Rock' 
GROUP BY customer.first_name, customer.last_name, customer.email, genre.name ORDER BY customer.email ASC ;

## Let's invite the artists who have written the most rock music in our dataset. Write a
## query that returns the Artist name and total track count of the top 10 rock bands

SELECT * FROM artist;
SELECT * FROM genre;
SELECT * FROM album;
SELECT * FROM track;

SELECT COUNT(artist.artist_id) AS Total_Track, artist.artist_id AS Art_ID, artist.name AS Artist_Name FROM artist
JOIN album ON artist.artist_id= album.artist_id
JOIN track ON album.album_id=track.album_id
JOIN genre on genre.genre_id=track.genre_id WHERE genre.name= 'Rock' 
GROUP BY Art_ID ,Artist_Name
ORDER BY Total_Track DESC LIMIT 10;

## Return all the track names that have a song length longer than the average song length.
## Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. 

SELECT * FROM track;
SELECT AVG(milliseconds) FROM track;

SELECT name AS Track_Name, milliseconds FROM track WHERE milliseconds >(SELECT AVG(milliseconds) FROM track ) ORDER BY milliseconds DESC;

## Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

SELECT * FROM customer;
SELECT * FROM invoice;
SELECT * FROM invoice_line;
SELECT * FROM track;

SELECT customer.first_name, customer.last_name, track.composer AS Artist_Name, SUM(invoice_line.unit_price* invoice_line.quantity) AS Total_Amount FROM customer 
JOIN invoice on customer.customer_id= invoice.invoice_id
JOIN invoice_line on invoice.invoice_id=invoice_line.invoice_id
JOIN track on track.track_id= invoice_line.track_id
WHERE length(track.composer)!=0
GROUP BY customer.first_name, customer.last_name, track.composer
ORDER BY Total_Amount DESC;

#### EXACT SOLUTION :-

With BEST_SELLING_ARTIST As (
	SELECT artist.artist_id AS Artist_ID, artist.name AS Artist_Name, SUM(invoice_line.unit_price*invoice_line.quantity) AS Total_Sale
	FROM invoice_line
	JOIN track on track.track_id= invoice_line.track_id
	JOIN album on album.album_id=track.album_id
	JOIN artist on artist.artist_id=album.artist_id
	GROUP BY Artist_ID,Artist_Name
	ORDER BY Total_Sale DESC
	LIMIT 1
)
SELECT customer.customer_id, customer.first_name, customer.last_name, BEST_SELLING_ARTIST.artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS amount_spent
FROM invoice
JOIN customer on customer.customer_id= invoice.customer_id
JOIN invoice_line on invoice.invoice_id=invoice_line.invoice_id
JOIN track on track.track_id= invoice_line.track_id
JOIN album on album.album_id=track.album_id
JOIN BEST_SELLING_ARTIST ON BEST_SELLING_ARTIST.artist_id= album.artist_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name, BEST_SELLING_ARTIST.artist_name
ORDER BY amount_spent DESC;


## We want to find out the most popular music Genre for each country. We determine the most popular genre 
## as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. 
## For countries where the maximum number of purchases is shared return all Genres

SELECT * FROM customer;
SELECT * FROM invoice;
SELECT * FROM invoice_line;
SELECT * FROM genre;

WITH Most_Popular AS(
    SELECT invoice.billing_country , genre.name AS Genre_Name, SUM(invoice_line.quantity) AS Total_Purchase,
	ROW_NUMBER() OVER(PARTITION BY invoice.billing_country ORDER BY SUM(invoice_line.quantity) DESC) as RowNO FROM invoice_line
	JOIN invoice ON invoice.invoice_id=invoice_line.invoice_id
	JOIN track ON invoice_line.track_id=track.track_id
	JOIN genre ON track.genre_id=genre.genre_id
   	GROUP BY genre.name, invoice.billing_country
	ORDER BY invoice.billing_country ASC, Total_Purchase DESC
)
SELECT * FROM Most_Popular WHERE RowNO <=1;

## Write a query that determines the customer that has spent the most on music for each country.
## Write a query that returns the country along with the top customer and how much they spent. 
## For countries where the top amount spent is shared, provide all customers who spent this amount. 

SELECT * FROM customer; 
SELECT * FROM invoice;

WITH Top_Customer as (
	SELECT customer.first_name, customer.last_name, customer.country AS Country, SUM(invoice.total) AS Total_Spent,
    ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY SUM(invoice.total) DESC) as Seprt_Row 
    FROM customer 
	JOIN invoice ON customer.customer_id = invoice.customer_id GROUP BY customer.first_name, customer.last_name, customer.country
	ORDER BY Country ASC, Total_Spent DESC
)
SELECT * FROM Top_Customer WHERE Seprt_Row <=1

