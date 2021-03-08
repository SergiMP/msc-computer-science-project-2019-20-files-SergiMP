---------------------------------------------
--
-- Student: Sergio Munoz Paino
--
---------------------------------------------

--
--  CREATE DATABASE investor;
--

---------------------------------------------
--
-- Session configuration and start
--
---------------------------------------------

SET datestyle = DMY;   -- Date format as day-month-year
SET TRANSACTION READ WRITE;  

BEGIN WORK;

---------------------------------------------
--
-- Delete tables if they exist
--
---------------------------------------------
DROP TABLE IF EXISTS investment_manager.tb_country CASCADE;

DROP TABLE IF EXISTS investment_manager.tb_client_manager CASCADE;

DROP TABLE IF EXISTS investment_manager.tb_subscription_type CASCADE;

DROP TABLE IF EXISTS investment_manager.tb_customer_category CASCADE;

DROP TABLE IF EXISTS investment_manager.tb_customer CASCADE;

DROP TABLE IF EXISTS investment_manager.tb_sales_area CASCADE;

DROP TABLE IF EXISTS investment_manager.tb_promotions CASCADE;

DROP TABLE IF EXISTS investment_manager.tb_customer_promotions CASCADE;

DROP TABLE IF EXISTS investment_manager.tb_customer_account CASCADE;

DROP TABLE IF EXISTS investment_manager.tb_cryptocurrencies CASCADE;

DROP TABLE IF EXISTS investment_manager.tb_crypto_valuation CASCADE;

DROP TABLE IF EXISTS investment_manager.tb_stocks CASCADE;

DROP TABLE IF EXISTS investment_manager.tb_customer_portfolio CASCADE;

DROP TABLE IF EXISTS investment_manager.tb_stock_valuation CASCADE;

DROP TABLE IF EXISTS investment_manager.tb_customer_portfolio_value CASCADE;

DROP SEQUENCE IF EXISTS serial;




DROP SCHEMA IF EXISTS investment_manager CASCADE;

---------------------------------------------
--
-- Schema creation
--
---------------------------------------------

CREATE SCHEMA investment_manager;

---------------------------------------------
--
-- tb_country definition
--
---------------------------------------------

CREATE TABLE investment_manager.tb_country (
    
    country_id INTEGER CONSTRAINT pk_country PRIMARY KEY,
    country_name varchar(20) NOT NULL
    
);


---------------------------------------------
--
-- tb_client_manager definition
--
---------------------------------------------

CREATE TABLE investment_manager.tb_client_manager (
    
    client_manager_id INTEGER CONSTRAINT pk_client_manager PRIMARY KEY,
    client_manager_name varchar(50),
    client_manager_surname varchar(50),
    country_id INTEGER NOT NULL,
    CONSTRAINT fk_manager_country FOREIGN KEY (country_id) REFERENCES investment_manager.tb_country (country_id)

);

---------------------------------------------
--
-- tb_subscription_type definition
--
---------------------------------------------

CREATE TABLE investment_manager.tb_subscription_type (
    
    subscription_id  INTEGER CONSTRAINT pk_subscription PRIMARY KEY,
    subscription_name   varchar(10) NOT NULL,
    subscription_fee INTEGER NOT NULL CHECK(subscription_fee >= 0)

);

---------------------------------------------
--
-- tb_customer_category definition
--
---------------------------------------------

CREATE TABLE investment_manager.tb_customer_category (

    category_id INTEGER CONSTRAINT pk_category PRIMARY KEY,
    customer_category VARCHAR(50) NOT NULL

);



---------------------------------------------
--
-- tb_customer	definition
--
---------------------------------------------

CREATE TABLE investment_manager.tb_customer (
    
    customer_id INTEGER CONSTRAINT pk_customer_id PRIMARY KEY,
    customer_name varchar(20) NOT NULL,
    customer_surname char(20) NOT NULL,
    country_id INTEGER NOT NULL,
    customer_email varchar(50) UNIQUE,
    CONSTRAINT fk_cust_country FOREIGN KEY (country_id) REFERENCES investment_manager.tb_country (country_id)
);

---------------------------------------------
--
-- tb_sales_area definition
--
---------------------------------------------

CREATE TABLE investment_manager.tb_sales_area (
    
    client_manager_id INTEGER,
    country_id INTEGER,
    CONSTRAINT pk_sales_area PRIMARY KEY (client_manager_id,country_id),
    CONSTRAINT fk_manager FOREIGN KEY (client_manager_id) REFERENCES investment_manager.tb_client_manager (client_manager_id),
    CONSTRAINT fk_territory FOREIGN KEY (country_id) REFERENCES investment_manager.tb_country (country_id)
    
);

---------------------------------------------
--
-- tb_promotions definition
--
---------------------------------------------

CREATE TABLE investment_manager.tb_promotions (
    
    promotion_id INTEGER CONSTRAINT pk_promotion PRIMARY KEY,
    promotion_name varchar(50) NOT NULL,
    promo_description varchar(100) NOT NULL

);


---------------------------------------------
--
-- tb_customer_promotions definition
--
---------------------------------------------

CREATE TABLE investment_manager.tb_customer_promotions (
    customer_promo_id SERIAL CONSTRAINT pk_promo_id PRIMARY KEY,
    promotion_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    promotion_taken BOOLEAN DEFAULT FALSE,
    promotion_date DATE NOT NULL,
    CONSTRAINT fk_promotions_promoted FOREIGN KEY (promotion_id) REFERENCES investment_manager.tb_promotions,
    CONSTRAINT fk_customer_promotions FOREIGN KEY (customer_id) REFERENCES investment_manager.tb_customer  

);

---------------------------------------------
--
-- tb_customer_account definition
--
---------------------------------------------

CREATE TABLE investment_manager.tb_customer_account (
    
    account_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    client_manager_id INTEGER NOT NULL,
    subscription_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    account_created DATE NOT NULL,
    account_active BOOLEAN NOT NULL DEFAULT TRUE,
    account_deactivation DATE DEFAULT NULL,
    CONSTRAINT fk_customer_acc_id FOREIGN KEY (customer_id) REFERENCES investment_manager.tb_customer,
    CONSTRAINT fk_customer_category FOREIGN KEY (category_id) REFERENCES investment_manager.tb_customer_category,
    CONSTRAINT fk_customer_acc_manager FOREIGN KEY (client_manager_id) REFERENCES investment_manager.tb_client_manager,
    CONSTRAINT fk_customer_acc_subscription FOREIGN KEY (subscription_id) REFERENCES investment_manager.tb_subscription_type,
    CONSTRAINT fk_customer_acc_type FOREIGN KEY (subscription_id) REFERENCES investment_manager.tb_subscription_type

);

------------------------------------------------------------------------------------------------
--
-- Data tb_cryptocurrencies
--
------------------------------------------------------------------------------------------------

CREATE TABLE investment_manager.tb_cryptocurrencies (
    cryptocurrency_symbol varchar(10) PRIMARY KEY,
    cryptocurrency_name varchar(50) NOT NULL
    
);

    ------------------------------------------------------------------------------------------------
    --
    --  tb_crypto_valuation
    --
    ------------------------------------------------------------------------------------------------

CREATE TABLE investment_manager.tb_crypto_valuation (
    crypto_valuation_id INTEGER PRIMARY KEY,
    cryptocurrency_symbol VARCHAR(10) NOT NULL,
    crypto_exchange_rate DECIMAL,
    crypto_valuation_date DATE,    
    CONSTRAINT fk_crypto_symbol FOREIGN KEY (cryptocurrency_symbol) REFERENCES investment_manager.tb_cryptocurrencies

);

---------------------------------------------
--
-- tb_stocks definition
--
---------------------------------------------
                                           
CREATE TABLE investment_manager.tb_stocks (

    stock_id INTEGER CONSTRAINT pk_stock PRIMARY KEY,
    stock_symbol varchar(10) NOT NULL UNIQUE,
    stock_name varchar(100)
);

---------------------------------------------
--
-- tb_customer_portfolio definition
--
---------------------------------------------
                                           

-- We assume customers have at least 1 stock and may or may not have cryptocurrencies.

CREATE TABLE investment_manager.tb_customer_portfolio (

    portfolio_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    stock_id INTEGER NOT NULL,
    number_of_stocks INTEGER NOT NULL CHECK (number_of_stocks >= 0),
    cryptocurrency VARCHAR(10),
    crypto_units INTEGER,
    CONSTRAINT fk_portfolio_customer FOREIGN KEY (customer_id) REFERENCES investment_manager.tb_customer,
    CONSTRAINT fk_portfolio_stocks FOREIGN KEY (stock_id) REFERENCES investment_manager.tb_stocks,
    CONSTRAINT fk_crypto_currency FOREIGN KEY (cryptocurrency) REFERENCES investment_manager.tb_cryptocurrencies
);



---------------------------------------------
--
-- tb_stock_valuation definition
--
---------------------------------------------

CREATE TABLE investment_manager.tb_stock_valuation (

  valuation_id INTEGER CONSTRAINT pk_valuation_id PRIMARY KEY,
  stock_id INTEGER NOT NULL,
  closing_value DECIMAL NOT NULL CHECK(closing_value >= 0),
  valuation_date DATE NOT NULL, 
  CONSTRAINT fk_stock_valuation FOREIGN KEY (stock_id) REFERENCES investment_manager.tb_stocks

 );


COMMIT;


---------------------------------------------
--
-- End of schema creation
--
---------------------------------------------





























