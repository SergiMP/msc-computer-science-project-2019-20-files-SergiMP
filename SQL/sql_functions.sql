-------------------------------------------
--
-- Create taging_area.clean_staging_tables()
--
-------------------------------------------

CREATE OR REPLACE FUNCTION staging_area.clean_staging_tables()
RETURNS VOID AS $$
BEGIN
DELETE FROM staging_area.sa_f_complaints;
DELETE FROM staging_area.sa_f_promotions;
DELETE FROM staging_area.sa_f_satisfaction;
DELETE FROM staging_area.sa_surveys;
DELETE FROM staging_area.sa_complaints;
DELETE FROM staging_area.sa_d_account_category;
DELETE FROM staging_area.sa_d_calendar;
DELETE FROM staging_area.sa_d_client_manager;
DELETE FROM staging_area.sa_d_customer;
DELETE FROM staging_area.sa_d_location;
DELETE FROM staging_area.sa_d_promotion;
DELETE FROM staging_area.sa_d_subscription_type;
END;
$$ LANGUAGE PLPGSQL;
COMMIT;


-------------------------------------------
--
-- Create staging_area.sa_create_calendar()
--
-------------------------------------------

CREATE OR REPLACE FUNCTION staging_area.sa_create_calendar()
RETURNS VOID AS $$
BEGIN
INSERT INTO staging_area.sa_d_calendar(calendar_date,calendar_day,calendar_month,calendar_year)
                   SELECT DISTINCT VALUATION_DATE, 
                   CAST(EXTRACT(DAY FROM VALUATION_DATE) AS INTEGER) calendar_day,
                   CAST(EXTRACT(MONTH FROM VALUATION_DATE) AS INTEGER) calendar_month,
                   CAST(EXTRACT(YEAR FROM VALUATION_DATE) AS INTEGER) calendar_year
                   FROM INVESTMENT_MANAGER.TB_STOCK_VALUATION
                   ORDER BY VALUATION_DATE ASC;
END;
$$ LANGUAGE PLPGSQL;
COMMIT;

-------------------------------------------
--
-- Create staging_area.sa_create_incremental_calendar()
--
-------------------------------------------

CREATE OR REPLACE FUNCTION staging_area.sa_create_incremental_calendar()
RETURNS VOID AS $$
BEGIN
INSERT INTO staging_area.sa_d_calendar(calendar_date,calendar_day,calendar_month,calendar_year)
                   SELECT  CURRENT_DATE - 1 AS VALUATION_DATE,
                  CAST(EXTRACT(DAY FROM CURRENT_DATE - 1) AS INTEGER) calendar_day,
                  CAST(EXTRACT(MONTH FROM CURRENT_DATE - 1) AS INTEGER) calendar_month,
                  CAST(EXTRACT(YEAR FROM CURRENT_DATE - 1) AS INTEGER) calendar_year;
          
END;
$$ LANGUAGE PLPGSQL;
COMMIT;
-------------------------------------------
--
-- Create staging_area.fill_f_complaints()
--
-------------------------------------------
CREATE OR REPLACE FUNCTION staging_area.fill_f_complaints()
RETURNS VOID AS $$
BEGIN
INSERT INTO staging_area.SA_F_COMPLAINTS(calendar_id,customer_id,subscription_id,location_id,
client_manager_id,category_id,complaint_category)
SELECT DISTINCT CAL.CALENDAR_ID,CUSTOMER_ID,subscription_id,country_id,
client_manager_id,category_id,complaint_category
FROM temp_table t, staging_area.sa_d_calendar cal
WHERE CAL.CALENDAR_DATE = COMPLAINT_DATE
AND complaint_category IS NOT NULL;
END;
$$ LANGUAGE PLPGSQL;
COMMIT;

CREATE OR REPLACE FUNCTION staging_area.incremental_f_complaints()
RETURNS VOID AS $$
BEGIN
INSERT INTO staging_area.SA_F_COMPLAINTS(calendar_id,customer_id,subscription_id,location_id,
client_manager_id,category_id,complaint_category)
SELECT DISTINCT CAL.CALENDAR_ID,CUSTOMER_ID,subscription_id,country_id,
client_manager_id,category_id,complaint_category
FROM temp_table t, staging_area.sa_d_calendar cal
WHERE CAL.CALENDAR_DATE = complaint_date
--AND COMPLAINT_DATE = (SELECT CURRENT_DATE - 1)
AND complaint_category IS NOT NULL;
END;
$$ LANGUAGE PLPGSQL;
COMMIT;

-------------------------------------------
--
-- Create staging_area.fill_f_promotions()
--
-------------------------------------------
CREATE OR REPLACE FUNCTION staging_area.fill_f_promotions()
RETURNS VOID AS $$
BEGIN
INSERT INTO staging_area.sa_f_promotions(promotion_id,calendar_id,customer_id,subscription_id,location_id,
client_manager_id,category_id,promotion_taken)
SELECT DISTINCT p.promotion_id,cal.calendar_id,t.customer_id,t.subscription_id,t.country_id,
t.client_manager_id,t.category_id,p.promotion_taken
FROM temp_table t
JOIN investment_manager.tb_customer_promotions p ON t.customer_id = p.customer_id
JOIN staging_area.sa_d_calendar cal ON cal.calendar_date = p.promotion_date
ORDER BY CALENDAR_ID ASC;
END;
$$ LANGUAGE PLPGSQL;
COMMIT;


-------------------------------------------
--
-- Create staging_area.fill_f_satisfaction()
--
-------------------------------------------

CREATE OR REPLACE FUNCTION staging_area.fill_f_satisfaction()
RETURNS VOID AS $$
BEGIN
INSERT INTO staging_area.sa_f_satisfaction(calendar_id,customer_id,subscription_id,location_id,
										   client_manager_id,category_id,overall_satisfaction,
										  advisor_satisfaction,easiness_interface,
										  usefulness_service,interest_mob_app,
										  recommend_friend)
SELECT  distinct cal.calendar_id,t.customer_id,t.subscription_id,t.country_id,t.client_manager_id,
t.category_id,t.overall_satisfaction,t.advisor_satisfaction,t.easiness_interface,
t.usefulness_service,t.interest_mob_app,t.recommend_friend
FROM temp_table t, staging_area.sa_d_calendar cal
WHERE t.survey_date = cal.calendar_date
ORDER BY CALENDAR_ID ASC;
END;
$$ LANGUAGE PLPGSQL;
COMMIT;


--The below statement is used to reset the serial sequence.

SELECT SETVAL((SELECT pg_get_serial_sequence('staging_area.SA_D_CALENDAR', 'calendar_id')), 1, false);
SELECT SETVAL((SELECT pg_get_serial_sequence('staging_area.SA_F_COMPLAINTS', 'complaint_id')), 1, false);
SELECT SETVAL((SELECT pg_get_serial_sequence('staging_area.SA_F_PROMOTIONS', 'f_complaint_id')), 1, false);
SELECT SETVAL((SELECT pg_get_serial_sequence('staging_area.SA_F_SATISFACTION','satisfaction_id')),1,false);

-----------------------------------------------------
--
-- Create data_mart.incremental_load_DW()
--
-----------------------------------------------------

CREATE OR REPLACE FUNCTION data_mart.incremental_load_DW()
RETURNS VOID AS $$
BEGIN
INSERT INTO DATA_MART.DW_D_account_category(category_id,account_category)
                          SELECT *
                          FROM DBLINK('host = localhost
                                      user = postgres
                                      password = postgres
                                      dbname = investor',
                                      'SELECT * FROM staging_area.sa_d_account_category WHERE category_id > (SELECT max_category FROM staging_area.max_category)') as linktable(a int, b varchar(50));
SELECT data_mart.filter_date();
-- INSERT INTO DATA_MART.DW_D_calendar(calendar_id,calendar_date,calendar_day,calendar_month,calendar_year)
--                         SELECT *
--                         FROM DBLINK('host = localhost
--                               user = postgres
--                               password = postgres
--                               dbname = investor',
--                               'SELECT * FROM staging_area.sa_d_calendar WHERE calendar_date > (SELECT max_date FROM staging_area.max_date)') as linktable(a int, b date, c int, d int, e int)
--                               WHERE calendar_date > (SELECT max_date FROM staging_area.max_date);
INSERT INTO DATA_MART.dw_d_client_manager(client_manager_id,client_manager_name,client_manager_surname)
                           SELECT *
                           FROM DBLINK('host = localhost
                                      user = postgres
                                      password = postgres
                                      dbname = investor',
                                      'SELECT * FROM staging_area.sa_d_client_manager WHERE client_manager_id > (SELECT max_manager FROM staging_area.max_client_manager)') as linktable(a int, b varchar(50), c varchar(50));
INSERT INTO DATA_MART.dw_d_customer(customer_id,customer_name,customer_surname,country_name)
                      SELECT *
                      FROM DBLINK('host = localhost
                                  user = postgres
                                  password = postgres
                                  dbname = investor',
                                  'SELECT * FROM staging_area.sa_d_customer WHERE customer_id > (SELECT MAX_CUSTOMER FROM staging_area.max_customer)') as linktable(a int, b varchar(20), c varchar(20), d varchar(50));
INSERT INTO DATA_MART.DW_D_LOCATION(location_id,location_name)
                      SELECT *
                      FROM DBLINK('host = localhost
                                  user = postgres
                                  password = postgres
                                  dbname = investor',
                                  'SELECT * FROM staging_area.sa_d_location WHERE location_id > (SELECT max_location FROM staging_area.max_location )') as linktable(a int, b varchar(50));
INSERT INTO DATA_MART.dw_d_promotion(promotion_id,promotion_name,promotion_description)
                        SELECT *
                        FROM DBLINK('host = localhost
                                    user = postgres
                                    password = postgres
                                    dbname = investor',
                                    'SELECT * FROM staging_area.sa_d_promotion WHERE promotion_id > (SELECT max_promotion FROM staging_area.max_promotion)') as linktable(a int, b varchar(50), c varchar(100));
INSERT INTO DATA_MART.dw_d_subscription_type(subscription_id,subscription_name)
                        SELECT *
                        FROM DBLINK('host = localhost
                                    user = postgres
                                    password = postgres
                                    dbname = investor',
                                    'SELECT * FROM staging_area.sa_d_subscription_type WHERE subscription_id > (select max_subscription FROM staging_area.max_subscription_type)') as linktable(a int, b varchar(50));
INSERT INTO DATA_MART.dw_f_complaints(complaint_id,calendar_id,customer_id,subscription_id,location_id,client_manager_id,category_id,complaint_category)
                        SELECT * 
                        FROM DBLINK('host = localhost
                                    user = postgres
                                    password = postgres
                                    dbname = investor',
                                    'SELECT * FROM staging_area.sa_f_complaints') as linktable(a int,b int,c int, d int, e int, f int, g int, h varchar(30));
INSERT INTO DATA_MART.dw_f_promotions(f_promotion_id,promotion_id,calendar_id,customer_id,subscription_id,location_id,client_manager_id,category_id,promotion_taken)
                        SELECT *
                        FROM DBLINK('host = localhost
                        user = postgres
                        password = postgres
                        dbname = investor',
                        'SELECT * FROM staging_area.sa_f_promotions') as linktable(a int,b int,c int, d int, e int, f int, g int, h int, i boolean);
INSERT INTO DATA_MART.dw_f_satisfaction(satisfaction_id,calendar_id,customer_id,
                          subscription_id,location_id,client_manager_id,category_id,overall_satisfaction,advisor_satisfaction,
                          easiness_interface,usefulness_service,interest_mob_app,recommend_friend)
                          SELECT * 
                          FROM DBLINK('host = localhost
                          user = postgres
                          password = postgres
                          dbname = investor',
                          'SELECT * FROM staging_area.sa_f_satisfaction') as linktable(a int,b int, c int,
                            d int, e int, f int, g int, h int, i int, j int, k int, l int, m int);
END;
$$ LANGUAGE PLPGSQL;
COMMIT;