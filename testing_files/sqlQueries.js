let sa_queries = {
  insertComplaints : "INSERT INTO staging_area.sa_complaints VALUES %L",

  intertSurveys : "INSERT INTO staging_area.sa_surveys VALUES %L",

  insertCustomers : `INSERT INTO staging_area.sa_d_customer 
                      SELECT DISTINCT customer_id, customer_name, customer_surname,country_name 
                      FROM temp_table
                      ORDER BY customer_id ASC`,
  insertLocation: `INSERT INTO staging_area.sa_d_location(location_id,location_name)
                   SELECT DISTINCT country_id, country_name
                   FROM temp_table
                   ORDER BY country_id ASC`,

  insertCategory: `INSERT INTO staging_area.sa_d_account_category(category_id,account_category)
                   SELECT DISTINCT category_id, customer_category
                   FROM temp_table
                   ORDER BY category_id ASC`,
  
  insertManager: `INSERT INTO staging_area.sa_d_client_manager(client_manager_id,client_manager_name,client_manager_surname)
                  SELECT DISTINCT client_manager_id,client_manager_name,client_manager_surname
                  FROM temp_table
                  ORDER BY client_manager_id ASC`,

  insertSubscription:`INSERT INTO staging_area.sa_d_subscription_type(subscription_id,subscription_name)
                      SELECT DISTINCT subscription_id,subscription_name
                      FROM temp_table
                      ORDER BY subscription_id ASC`,

  insertPromotion: `INSERT INTO staging_area.sa_d_promotion(promotion_id,promotion_name,promotion_description)
                    SELECT DISTINCT promotion_id,promotion_name,promo_description
                    FROM investment_manager.tb_promotions
                    ORDER BY promotion_id ASC`,

  insertCalendar: `SELECT STAGING_AREA.SA_CREATE_CALENDAR();`,

  insertFactComplaints: `SELECT staging_area.fill_f_complaints()`,

  insertFactPromotions: `SELECT staging_area.fill_f_promotions();`,

  insertFactSatisfaction: `SELECT staging_area.fill_f_satisfaction();`,

  createTempTable: `CREATE TEMPORARY TABLE temp_table AS(
    SELECT  DISTINCT ca.customer_id, c.customer_name, c.customer_surname,co.country_id, co.country_name, cm.client_manager_id, 
                      cm.client_manager_name, cm.client_manager_surname, ca.subscription_id, st.subscription_name, 
                      ca.category_id, cc.customer_category, com.complaint_category, to_date(com.complaint_date,'YYYY/MM/DD') as complaint_date,
                      s.overall_satisfaction,s.advisor_satisfaction, s.easiness_interface, s.usefulness_service, s.interest_mob_app,
                      s.recommend_friend, to_date(s.survey_rec_date,'DD/MM/YYYY') AS survey_date
    FROM investment_manager.tb_customer_account ca 
    JOIN investment_manager.tb_customer c ON ca.customer_id = c.customer_id 
    JOIN investment_manager.tb_country co ON c.country_id = co.country_id
    JOIN investment_manager.tb_client_manager cm ON cm.client_manager_id = ca.client_manager_id
    JOIN investment_manager.tb_subscription_type st ON ca.subscription_id = st.subscription_id
    JOIN investment_manager.tb_customer_category cc ON ca.category_id = cc.category_id
    LEFT JOIN staging_area.sa_complaints com ON com.customer_id = ca.customer_id
    LEFT JOIN staging_area.sa_surveys s ON s.reviewer_id = ca.customer_id
    ORDER BY customer_id asc)`
}

module.exports = sa_queries;