
const dw = {


  insertDWaccountCat : `INSERT INTO DATA_MART.DW_D_account_category(category_id,account_category)
                          SELECT *
                          FROM DBLINK('host = localhost
                                      user = postgres
                                      password = postgres
                                      dbname = investor',
                                      'SELECT * FROM staging_area.sa_d_account_category') as linktable(a int, b varchar(50))`,

  insertDWcalendar :`INSERT INTO DATA_MART.DW_D_calendar(calendar_id,calendar_date,calendar_day,calendar_month,calendar_year)
                        SELECT *
                        FROM DBLINK('host = localhost
                              user = postgres
                              password = postgres
                              dbname = investor',
                              'SELECT * FROM staging_area.sa_d_calendar') as linktable(a int, b date, c int, d int, e int)`,

  insertDWclientManager : `INSERT INTO DATA_MART.dw_d_client_manager(client_manager_id,client_manager_name,client_manager_surname)
                           SELECT *
                           FROM DBLINK('host = localhost
                                      user = postgres
                                      password = postgres
                                      dbname = investor',
                                      'SELECT * FROM staging_area.sa_d_client_manager') as linktable(a int, b varchar(50), c varchar(50))`,

  insertDWcustomer : `INSERT INTO DATA_MART.dw_d_customer(customer_id,customer_name,customer_surname,country_name)
                      SELECT *
                      FROM DBLINK('host = localhost
                                  user = postgres
                                  password = postgres
                                  dbname = investor',
                                  'SELECT * FROM staging_area.sa_d_customer') as linktable(a int, b varchar(20), c varchar(20), d varchar(50))`,

  insertDWlocation : `INSERT INTO DATA_MART.DW_D_LOCATION(location_id,location_name)
                      SELECT *
                      FROM DBLINK('host = localhost
                                  user = postgres
                                  password = postgres
                                  dbname = investor',
                                  'SELECT * FROM staging_area.sa_d_location') as linktable(a int, b varchar(50))`,
  
  insertDWpromotion : `INSERT INTO DATA_MART.dw_d_promotion(promotion_id,promotion_name,promotion_description)
                        SELECT *
                        FROM DBLINK('host = localhost
                                    user = postgres
                                    password = postgres
                                    dbname = investor',
                                    'SELECT * FROM staging_area.sa_d_promotion') as linktable(a int, b varchar(50), c varchar(100))`,

  insertDWsubscription : `INSERT INTO DATA_MART.dw_d_subscription_type(subscription_id,subscription_name)
                        SELECT *
                        FROM DBLINK('host = localhost
                                    user = postgres
                                    password = postgres
                                    dbname = investor',
                                    'SELECT * FROM staging_area.sa_d_subscription_type') as linktable(a int, b varchar(50))`,
                                  
  inserDWfcomplaints : `INSERT INTO DATA_MART.dw_f_complaints(complaint_id,calendar_id,customer_id,subscription_id,location_id,client_manager_id,category_id,complaint_category)
                        SELECT * 
                        FROM DBLINK('host = localhost
                                    user = postgres
                                    password = postgres
                                    dbname = investor',
                                    'SELECT * FROM staging_area.sa_f_complaints') as linktable(a int,b int,c int, d int, e int, f int, g int, h varchar(30))
                        `,
  insertDWfpromotions: `INSERT INTO DATA_MART.dw_f_promotions(f_promotion_id,promotion_id,calendar_id,customer_id,subscription_id,location_id,client_manager_id,category_id,promotion_taken)
                        SELECT *
                        FROM DBLINK('host = localhost
                        user = postgres
                        password = postgres
                        dbname = investor',
                        'SELECT * FROM staging_area.sa_f_promotions') as linktable(a int,b int,c int, d int, e int, f int, g int, h int, i boolean)
                        `,
  insertDWfsatisfaction: `INSERT INTO DATA_MART.dw_f_satisfaction(satisfaction_id,calendar_id,customer_id,
                          subscription_id,location_id,client_manager_id,category_id,overall_satisfaction,advisor_satisfaction,
                          easiness_interface,usefulness_service,interest_mob_app,recommend_friend)
                          SELECT * 
                          FROM DBLINK('host = localhost
                          user = postgres
                          password = postgres
                          dbname = investor',
                          'SELECT * FROM staging_area.sa_f_satisfaction') as linktable(a int,b int, c int,
                            d int, e int, f int, g int, h int, i int, j int, k int, l int, m int)
                          `
}

module.exports = dw;