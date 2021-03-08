DROP SCHEMA IF EXISTS STAGING_AREA CASCADE;
SET TRANSACTION READ WRITE;  
---------------------------------------------
--
-- Staging area schema creation
--
---------------------------------------------

BEGIN WORK;
CREATE SCHEMA staging_area;

---------------------------------------------
--
-- Table sa_surveys
--
---------------------------------------------

CREATE TABLE staging_area.sa_surveys(

  reviewer_id INTEGER NOT NULL,
  overall_satisfaction INTEGER NOT NULL,
  advisor_satisfaction INTEGER NOT NULL,
  easiness_interface INTEGER NOT NULL,
  usefulness_service INTEGER NOT NULL,
  interest_mob_app INTEGER NOT NULL,
  recommend_friend INTEGER NOT NULL,
  survey_rec_date VARCHAR(20)
);

---------------------------------------------
--
-- Table sa_complaints
--
---------------------------------------------

CREATE TABLE staging_area.sa_complaints (

  customer_id INTEGER NOT NULL,
  complaint_category VARCHAR(30) NOT NULL,
  complaint_date VARCHAR(20)

);

---------------------------------------------
--
-- Table sa_d_customer
--
---------------------------------------------

CREATE TABLE staging_area.sa_d_customer (

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

CREATE TABLE staging_area.sa_d_location (

  location_id INTEGER CONSTRAINT pk_location PRIMARY KEY,
  location_name VARCHAR(50) NOT NULL

);

---------------------------------------------
--
-- Table sa_d_subscription_type
--
---------------------------------------------

CREATE TABLE staging_area.sa_d_subscription_type (
  subscription_id INTEGER CONSTRAINT pk_subscription PRIMARY KEY,
  subscription_name VARCHAR(50) NOT NULL 
);
---------------------------------------------
--
-- Table sa_d_client_manager
--
---------------------------------------------

CREATE TABLE staging_area.sa_d_client_manager (

  client_manager_id INTEGER CONSTRAINT pk_manager PRIMARY KEY,
  client_manager_name VARCHAR(50) NOT NULL,
  client_manager_surname VARCHAR(50) NOT NULL

);
---------------------------------------------
--
-- Table sa_d_account_category
--
----------------------------------------------

CREATE TABLE staging_area.sa_d_account_category (

  category_id INTEGER CONSTRAINT pk_category PRIMARY KEY,
  account_category VARCHAR(50) NOT NULL
  
);

---------------------------------------------
--
-- Table sa_d_calendar
--
----------------------------------------------

CREATE TABLE staging_area.sa_d_calendar (
 calendar_id SERIAL CONSTRAINT pk_calendar PRIMARY KEY,
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

CREATE TABLE staging_area.sa_d_promotion (

 promotion_id INTEGER CONSTRAINT pk_promotion PRIMARY KEY,
 promotion_name VARCHAR(50) NOT NULL,
 promotion_description VARCHAR(100) NOT NULL

);

---------------------------------------------
--
-- Table sa_f_satisfaction
--
----------------------------------------------

CREATE TABLE staging_area.sa_f_satisfaction(

 satisfaction_id SERIAL CONSTRAINT pk_satisfaction PRIMARY KEY,
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
 CONSTRAINT fk_calendar_sat FOREIGN KEY (calendar_id) REFERENCES staging_area.sa_d_calendar (calendar_id),
 CONSTRAINT fk_customer_sat FOREIGN KEY (customer_id) REFERENCES staging_area.sa_d_customer (customer_id),
 CONSTRAINT fk_acc_type_sat FOREIGN KEY (subscription_id) REFERENCES staging_area.sa_d_subscription_type (subscription_id),
 CONSTRAINT fk_location_sat FOREIGN KEY (location_id) REFERENCES staging_area.sa_d_location (location_id),
 CONSTRAINT fk_manager_sat FOREIGN KEY (client_manager_id) REFERENCES staging_area.sa_d_client_manager (client_manager_id),
 CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES staging_area.sa_d_account_category (category_id)

);

---------------------------------------------
--
-- Table sa_f_complaints
--
----------------------------------------------

CREATE TABLE staging_area.sa_f_complaints (

  complaint_id SERIAL CONSTRAINT pk_complaint PRIMARY KEY,
  calendar_id INTEGER NOT NULL,
  customer_id INTEGER NOT NULL,
  subscription_id INTEGER NOT NULL,
  location_id INTEGER NOT NULL,
  client_manager_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL,
  complaint_category VARCHAR(30),
  CONSTRAINT fk_calendar_comp FOREIGN KEY (calendar_id) REFERENCES staging_area.sa_d_calendar (calendar_id),
  CONSTRAINT fk_customer_comp FOREIGN KEY (customer_id) REFERENCES staging_area.sa_d_customer (customer_id),
  CONSTRAINT fk_acc_type_comp FOREIGN KEY (subscription_id) REFERENCES staging_area.sa_d_subscription_type (subscription_id),
  CONSTRAINT fk_location_comp FOREIGN KEY (location_id) REFERENCES staging_area.sa_d_location (location_id),
  CONSTRAINT fk_manager_comp FOREIGN KEY (client_manager_id) REFERENCES staging_area.sa_d_client_manager (client_manager_id),
  CONSTRAINT fk_category_comp FOREIGN KEY (category_id) REFERENCES staging_area.sa_d_account_category (category_id)
);

---------------------------------------------
--
-- Table sa_f_promotions
--
----------------------------------------------

CREATE TABLE staging_area.sa_f_promotions (

  f_promotion_id SERIAL CONSTRAINT pk_promo PRIMARY KEY,
  promotion_id INTEGER NOT NULL,
  calendar_id INTEGER NOT NULL,
  customer_id INTEGER NOT NULL,
  subscription_id INTEGER NOT NULL,
  location_id INTEGER NOT NULL,
  client_manager_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL,
  promotion_taken BOOLEAN NOT NULL,
  CONSTRAINT fk_promo FOREIGN KEY (promotion_id) REFERENCES staging_area.sa_d_promotion (promotion_id),
  CONSTRAINT fk_calendar_prom FOREIGN KEY (calendar_id) REFERENCES staging_area.sa_d_calendar (calendar_id),
  CONSTRAINT fk_customer_prom FOREIGN KEY (customer_id) REFERENCES staging_area.sa_d_customer (customer_id),
  CONSTRAINT fk_acc_type_prom FOREIGN KEY (subscription_id) REFERENCES staging_area.sa_d_subscription_type (subscription_id),
  CONSTRAINT fk_location_prom FOREIGN KEY (location_id) REFERENCES staging_area.sa_d_location (location_id),
  CONSTRAINT fk_manager_prom FOREIGN KEY (client_manager_id) REFERENCES staging_area.sa_d_client_manager (client_manager_id),
  CONSTRAINT fk_category_prom FOREIGN KEY (category_id) REFERENCES staging_area.sa_d_account_category (category_id)
);

---------------------------------------------
--
-- Creation of the helper tables
--
----------------------------------------------

CREATE TABLE staging_area.max_date (
   max_date DATE PRIMARY KEY
);

CREATE TABLE staging_area.max_subscription_type (
   max_subscription INTEGER PRIMARY KEY
);

CREATE TABLE staging_area.max_client_manager (
   max_manager INTEGER PRIMARY KEY
);

CREATE TABLE staging_area.max_promotion (
   max_promotion INTEGER PRIMARY KEY
);

CREATE TABLE staging_area.max_customer (
   max_customer INTEGER PRIMARY KEY
);

CREATE TABLE staging_area.max_location (
   max_location INTEGER PRIMARY KEY
);

CREATE TABLE staging_area.max_category (
   max_category INTEGER PRIMARY KEY
);


COMMIT;



