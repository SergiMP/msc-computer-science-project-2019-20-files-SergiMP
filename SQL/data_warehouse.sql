---------------------------------------------
--
-- Database dwarehouse
--
---------------------------------------------

-- CREATE DATABASE dwarehouse

DROP SCHEMA IF EXISTS data_mart CASCADE;
SET TRANSACTION READ WRITE;  


---------------------------------------------
--
-- Staging area schema creation
--
---------------------------------------------

BEGIN WORK;
CREATE SCHEMA data_mart;

---------------------------------------------
--
-- Table sa_d_customer
--
---------------------------------------------

CREATE TABLE data_mart.dw_d_customer (

    customer_id INTEGER CONSTRAINT pk_customer_id PRIMARY KEY,
    customer_name varchar(20) NOT NULL,
    customer_surname varchar(20) NOT NULL,
    country_name varchar(50) NOT NULL

);

---------------------------------------------
--
-- Table sa_d_location
--
---------------------------------------------

CREATE TABLE data_mart.dw_d_location (

  location_id INTEGER CONSTRAINT pk_location PRIMARY KEY,
  location_name VARCHAR(50) NOT NULL

);

---------------------------------------------
--
-- Table sa_d_subscription_type
--
---------------------------------------------

CREATE TABLE data_mart.dw_d_subscription_type (
  subscription_id INTEGER CONSTRAINT pk_subscription PRIMARY KEY,
  subscription_name VARCHAR(50) NOT NULL 
);
---------------------------------------------
--
-- Table sa_d_client_manager
--
---------------------------------------------

CREATE TABLE data_mart.dw_d_client_manager (

  client_manager_id INTEGER CONSTRAINT pk_manager PRIMARY KEY,
  client_manager_name VARCHAR(50) NOT NULL,
  client_manager_surname VARCHAR(50) NOT NULL

);
---------------------------------------------
--
-- Table sa_d_account_category
--
----------------------------------------------

CREATE TABLE data_mart.dw_d_account_category (

  category_id INTEGER CONSTRAINT pk_category PRIMARY KEY,
  account_category VARCHAR(50) NOT NULL
  
);

---------------------------------------------
--
-- Table sa_d_calendar
--
----------------------------------------------

CREATE TABLE data_mart.dw_d_calendar (
 calendar_id INTEGER CONSTRAINT pk_calendar PRIMARY KEY,
 calendar_date  DATE NOT NULL,
 calendar_day INTEGER NOT NULL,
 calendar_month INTEGER NOT NULL,
 calendar_year INTEGER NOT NULL
);

---------------------------------------------
--
-- Table sa_d_promotion
--
----------------------------------------------

CREATE TABLE data_mart.dw_d_promotion (

 promotion_id INTEGER CONSTRAINT pk_promotion PRIMARY KEY,
 promotion_name VARCHAR(50) NOT NULL,
 promotion_description VARCHAR(100) NOT NULL

);

---------------------------------------------
--
-- Table sa_f_satisfaction
--
----------------------------------------------

CREATE TABLE data_mart.dw_f_satisfaction(

 satisfaction_id INTEGER CONSTRAINT pk_satisfaction PRIMARY KEY,
 calendar_id INTEGER NOT NULL,
 customer_id INTEGER NOT NULL,
 subscription_id INTEGER NOT NULL,
 location_id INTEGER NOT NULL,
 client_manager_id INTEGER NOT NULL,
 category_id INTEGER NOT NULL,
 overall_satisfaction INTEGER,
 advisor_satisfaction INTEGER,
 easiness_interface INTEGER,
 usefulness_service INTEGER,
 interest_mob_app INTEGER,
 recommend_friend INTEGER,
 CONSTRAINT fk_calendar_sat FOREIGN KEY (calendar_id) REFERENCES data_mart.dw_d_calendar (calendar_id),
 CONSTRAINT fk_customer_sat FOREIGN KEY (customer_id) REFERENCES data_mart.dw_d_customer (customer_id),
 CONSTRAINT fk_acc_type_sat FOREIGN KEY (subscription_id) REFERENCES data_mart.dw_d_subscription_type (subscription_id),
 CONSTRAINT fk_location_sat FOREIGN KEY (location_id) REFERENCES data_mart.dw_d_location (location_id),
 CONSTRAINT fk_manager_sat FOREIGN KEY (client_manager_id) REFERENCES data_mart.dw_d_client_manager (client_manager_id),
 CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES data_mart.dw_d_account_category (category_id)

);

---------------------------------------------
--
-- Table sa_f_complaints
--
----------------------------------------------

CREATE TABLE data_mart.dw_f_complaints (

  complaint_id INTEGER CONSTRAINT pk_complaint PRIMARY KEY,
  calendar_id INTEGER NOT NULL,
  customer_id INTEGER NOT NULL,
  subscription_id INTEGER NOT NULL,
  location_id INTEGER NOT NULL,
  client_manager_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL,
  complaint_category VARCHAR(30),
  CONSTRAINT fk_calendar_comp FOREIGN KEY (calendar_id) REFERENCES data_mart.dw_d_calendar (calendar_id),
  CONSTRAINT fk_customer_comp FOREIGN KEY (customer_id) REFERENCES data_mart.dw_d_customer (customer_id),
  CONSTRAINT fk_acc_type_comp FOREIGN KEY (subscription_id) REFERENCES data_mart.dw_d_subscription_type (subscription_id),
  CONSTRAINT fk_location_comp FOREIGN KEY (location_id) REFERENCES data_mart.dw_d_location (location_id),
  CONSTRAINT fk_manager_comp FOREIGN KEY (client_manager_id) REFERENCES data_mart.dw_d_client_manager (client_manager_id),
  CONSTRAINT fk_category_comp FOREIGN KEY (category_id) REFERENCES data_mart.dw_d_account_category (category_id)
);

---------------------------------------------
--
-- Table sa_f_promotions
--
----------------------------------------------

CREATE TABLE data_mart.dw_f_promotions (

  f_promotion_id INTEGER CONSTRAINT pk_promo PRIMARY KEY,
  promotion_id INTEGER NOT NULL,
  calendar_id INTEGER NOT NULL,
  customer_id INTEGER NOT NULL,
  subscription_id INTEGER NOT NULL,
  location_id INTEGER NOT NULL,
  client_manager_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL,
  promotion_taken BOOLEAN NOT NULL,
  CONSTRAINT fk_promo FOREIGN KEY (promotion_id) REFERENCES data_mart.dw_d_promotion (promotion_id),
  CONSTRAINT fk_calendar_prom FOREIGN KEY (calendar_id) REFERENCES data_mart.dw_d_calendar (calendar_id),
  CONSTRAINT fk_customer_prom FOREIGN KEY (customer_id) REFERENCES data_mart.dw_d_customer (customer_id),
  CONSTRAINT fk_acc_type_prom FOREIGN KEY (subscription_id) REFERENCES data_mart.dw_d_subscription_type (subscription_id),
  CONSTRAINT fk_location_prom FOREIGN KEY (location_id) REFERENCES data_mart.dw_d_location (location_id),
  CONSTRAINT fk_manager_prom FOREIGN KEY (client_manager_id) REFERENCES data_mart.dw_d_client_manager (client_manager_id),
  CONSTRAINT fk_category_prom FOREIGN KEY (category_id) REFERENCES data_mart.dw_d_account_category (category_id)
);

---------------------------------------------
--
-- Materialized view
--
----------------------------------------------


CREATE MATERIALIZED VIEW data_mart.average_satisfaction AS (
SELECT ca.calendar_year, round(AVG(overall_satisfaction),2) AS average_overall,
round(avg(advisor_satisfaction),2) as avg_sat_advisor,round(avg(easiness_interface),2) AS avg_interface,
round(avg(usefulness_service),2) AS avg_usefulness, round(avg(interest_mob_app),2) AS avg_mbile, round(avg(recommend_friend),2) as avg_rec_friend
from data_mart.dw_f_satisfaction p, data_mart.dw_f_complaints c, data_mart.dw_d_calendar ca
WHERE p.customer_id = c.customer_id AND ca.calendar_id = p.calendar_id
GROUP BY ca.calendar_year
ORDER BY calendar_year ASC
);

COMMIT;



