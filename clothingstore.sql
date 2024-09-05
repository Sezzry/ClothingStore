-- Skapa databasen
CREATE DATABASE IF NOT EXISTS ClothingStore;  
USE ClothingStore;  

-- Ta bort tabeller om de redan finns för att undvika kollisioner
DROP TABLE IF EXISTS Product_Category;  
DROP TABLE IF EXISTS Order_Product;  
DROP TABLE IF EXISTS Orders;  
DROP TABLE IF EXISTS Products;  
DROP TABLE IF EXISTS Categories;  
DROP TABLE IF EXISTS Customers;  

-- DDL Statements: Skapa tabelllen för kunder
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,  
    first_name VARCHAR(100),                      
    last_name VARCHAR(100),                       
    address VARCHAR(255),                         
    city VARCHAR(100),                           
    postal_code VARCHAR(10),                      
    email VARCHAR(100)                            
);

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,  
    name VARCHAR(100),                         
    size VARCHAR(10),                           
    color VARCHAR(50),                          
    price DECIMAL(10, 2),                       
    brand VARCHAR(100),                         
    stock_quantity INT                         
);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,    -- Unik identifierare för varje beställning, auto-inkrementerande
    order_date DATE,                           
    customer_id INT,                           -- Koppling till kunden som gjort beställningen
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)  -- Främmande nyckel som refererar till Customers-tabellen
);

CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,  
    category_name VARCHAR(100)                   
);

CREATE TABLE Order_Product (
    order_id INT,                               
    product_id INT,                             
    quantity INT,                              
    PRIMARY KEY (order_id, product_id),         
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),   
    FOREIGN KEY (product_id) REFERENCES Products(product_id)  
);

CREATE TABLE Product_Category (
    product_id INT,                            
    category_id INT,                            
    PRIMARY KEY (product_id, category_id),      
    FOREIGN KEY (product_id) REFERENCES Products(product_id),  
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)  
);

-- DML Statements: Lägg till initiala kunder
INSERT INTO Customers (first_name, last_name, address, city, postal_code, email) VALUES
('Anna', 'Tjernstrom', 'First Street 1', 'Solna', '11122', 'anna@example.com'),
('Bert', 'Bengtsson', 'Second Street 3', 'Varmdo', '11223', 'bert@example.com'),
('Kalle', 'Carlsson', 'Third Street 5', 'Danderyd', '11334', 'kalle@example.com'),
('David', 'Svensson', 'Fourth Street 7', 'Uppsala', '11445', 'david@example.com'),
('Eric', 'Andersson', 'Fifth Street 9', 'Stockholm', '11556', 'eric@example.com');

INSERT INTO Products (name, size, color, price, brand, stock_quantity) VALUES
('SweetPants Black Trousers', '38', 'Black', 399.00, 'SweetPants', 10),
('T-Shirt', 'M', 'White', 199.00, 'Adidas', 50),
('Dress', 'L', 'Red', 399.00, 'Gucci', 20),
('Coat', 'M', 'Blue', 799.00, 'TheNorthFace', 15),
('Shoes', '42', 'Black', 699.00, 'Epic', 30),
('Jeans', '32', 'Blue', 299.00, 'Denim', 25),
('Socks', 'L', 'White', 99.00, 'Gigabyte', 100),
('Jacket', 'L', 'Green', 699.00, 'Steelseries', 5);

INSERT INTO Categories (category_name) VALUES
('Trousers'),
('Shirts'),
('Dresses'),
('Outerwear'),
('Footwear');

-- Koppla produkter till deras kategorier
INSERT INTO Product_Category (product_id, category_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 1), (7, 5), (8, 4);

-- Lägg till initiala beställningar
INSERT INTO Orders (order_date, customer_id) VALUES
('2024-06-15', 1),
('2024-07-18', 2),
('2024-08-01', 3),
('2024-08-10', 1),
('2024-08-20', 4),
('2024-08-25', 5);

-- Lägg till produkter i beställningarna
INSERT INTO Order_Product (order_id, product_id, quantity) VALUES
(1, 1, 1), (1, 2, 2),
(2, 3, 1), (2, 4, 1),
(3, 5, 1), (3, 1, 2),
(4, 6, 1), (4, 1, 1),
(5, 7, 3), (5, 8, 1),
(6, 1, 1), (6, 5, 2);

-- Queries
-- 1. Vilka kunder har köpt svarta byxor i storlek 38 av märket "SweetPants"?
SELECT c.first_name, c.last_name
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_Product op ON o.order_id = op.order_id
JOIN Products p ON op.product_id = p.product_id
WHERE p.name = 'SweetPants Black Trousers' AND p.size = '38' AND p.color = 'Black';

-- 2. Lista antalet produkter per kategori.
SELECT cat.category_name, COUNT(pc.product_id) AS product_count
FROM Categories cat
LEFT JOIN Product_Category pc ON cat.category_id = pc.category_id
GROUP BY cat.category_name;

-- 3. Skapa en kundlista med det totala belopp som varje kund har spenderat.
SELECT c.first_name, c.last_name, SUM(p.price * op.quantity) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_Product op ON o.order_id = op.order_id
JOIN Products p ON op.product_id = p.product_id
GROUP BY c.first_name, c.last_name;

-- 4. Skriv ut en lista över den totala ordervärdet per stad där ordervärdet är större än 1000 kr.
SELECT c.city, SUM(p.price * op.quantity) AS total_order_value
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_Product op ON o.order_id = op.order_id
JOIN Products p ON op.product_id = p.product_id
GROUP BY c.city
HAVING SUM(p.price * op.quantity) > 1000;

-- 5. Skapa en topp-5 lista över de mest sålda produkterna.
SELECT p.name, SUM(op.quantity) AS total_sold
FROM Products p
JOIN Order_Product op ON p.product_id = op.product_id
GROUP BY p.name
ORDER BY total_sold DESC
LIMIT 5;

-- 6. Vilken månad hade de högsta försäljningarna?
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month, SUM(p.price * op.quantity) AS total_sales
FROM Orders o
JOIN Order_Product op ON o.order_id = op.order_id
JOIN Products p ON op.product_id = p.product_id
GROUP BY sales_month
ORDER BY total_sales DESC
LIMIT 1;
