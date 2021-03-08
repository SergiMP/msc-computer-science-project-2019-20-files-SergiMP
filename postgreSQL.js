const {Client} = require("pg");
let format = require("pg-format");
const { connection, mongo } = require("mongoose");
const getMongoData = require('./getMongoData');
const CSV =  require('./csv_data');
const saQueries = require("./sqlQueries");
const dwQueries = require("./dwQueries");
const dw = require("./dwQueries");

const client =  new Client({
    user: "postgres",
    password: "postgres",
    host: "localhost",
    port:5432,
    database: "investor",
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 20000
})

const DW =  new Client({
  user: "postgres",
  password: "postgres",
  host: "localhost",
  port:5432,
  database: "dwarehouse",
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 20000
})

function initialDWload(){
let mongodata = [];
let csvData = [];
// make the field of the table where data will be inserted of type varchar, you will then apply the transformation to_date() in sql
getMongoData().then(collection => {
                        collection.forEach(doc=>{
                        mongodata.push([doc["reviewer_id"],
                                        doc["overall_satisfaction"],
                                        doc["advisor_satisfaction"],
                                        doc["easiness_interface"],
                                        doc["usefulness_service"],
                                        doc["interest_mob_app"],
                                        doc["recommend_friend"],
                                        doc["date_submitted"]]);
                          });
                          console.log(`${mongodata.length} objects from MongoDB have been processed.`); 
                          return CSV()
                          })
              .then(data => {
                        let complaintCode = {1: "Service Provided", 2: "Billing Issues", 3: "Technical"}
                        data.forEach(row => {
                        csvData.push([row[0],complaintCode[row[1]],row[3]]);
                          })
                          console.log(`${csvData.length} complaints from the .csv file have been processed.`)
                         return client.connect() 
                          })
              .then(()=> client.query(format(saQueries.insertComplaints, csvData ),[]))
              .then(()=> {
                client.query(format(saQueries.intertSurveys, mongodata ),[])
                return client.query(format(saQueries.createTempTable))
              })
              .then((result)=>{
                console.log(`${result.rowCount} rows have been generated in the temporary table.`);
                return client.query(format(saQueries.insertCustomers))
              })
              .then(result => {
                console.log(`${result.rowCount} customer(s) have been inserted into sa_d_customer`);
                return client.query(format(saQueries.insertLocation))
              })
              .then(result=>{
                console.log(`${result.rowCount} rows have been inserted into sa_d_location`);
                return client.query(format(saQueries.insertCategory))
              })
              .then((result)=>{
                console.log(`${result.rowCount} rows have been inserted into sa_d_account_category`);
                return client.query(format(saQueries.insertManager))
              })
              .then(result=>{
                console.log(`${result.rowCount} rows have been inserted into sa_d_client_manager`);
                return client.query(format(saQueries.insertSubscription))
              })
              .then(result=>{
                console.log(`${result.rowCount} rows have been inserted into sa_d_subscription_type`);
                return client.query(format(saQueries.insertPromotion))
              })
              .then(result=>{
                console.log(`${result.rowCount} rows have been inserted into sa_d_promotion`);
                return client.query((saQueries.insertCalendar))
              })
              .then(result=>{
                return client.query(('SELECT * FROM STAGING_AREA.SA_D_CALENDAR'))
                
              })
              .then(result=>{
                console.log(`${result.rowCount} rows have been inserted into sa_d_calendar`)
                return client.query(saQueries.insertFactComplaints)
              })
              .then(result=>{
                return client.query('SELECT * FROM STAGING_AREA.SA_F_COMPLAINTS')
              })
              .then(result=>{
                console.log(`${result.rowCount} rows have been inserted into sa_f_complaints`)
                return client.query(saQueries.insertFactPromotions)
              })
              .then(result=>{
                return client.query('SELECT * FROM staging_area.sa_f_promotions')
              })
              .then(result=>{
                console.log(`${result.rowCount} rows have been inserted into sa_f_promotions`)
                return client.query(saQueries.insertFactSatisfaction)
              })
              .then(result=>{
                return client.query('SELECT * FROM staging_area.sa_f_satisfaction')
              })
              .then(result=>{
                console.log(`${result.rowCount} rows have been inserted into sa_f_satisfaction`)
                return DW.connect();
              })
              .then(result=>{
                console.log("")
                console.log("Connecting to the D.W database.....")
                return DW.query(dwQueries.insertDWcustomer)
              })
              .then(result=>{
                console.log(`Connection to D.W stablished....`)
                console.log(`${result.rowCount} were loaded into dw_d_customer`)
                return DW.query(dwQueries.insertDWaccountCat)
              })
              .then(result=>{
                console.log(`${result.rowCount} rows were inserted into dw_d_account_category`)
                return DW.query(dwQueries.insertDWcalendar)
              })
              .then(result=>{
                console.log(`${result.rowCount} rows were inserted into dw_d_calendar.`)
                return DW.query(dwQueries.insertDWclientManager)
              })
              .then(result=>{
                console.log(`${result.rowCount} rows were inserted into dw_d_client_manager.`)
                return DW.query(dwQueries.insertDWlocation)
              })
              .then(result =>{
                console.log(`${result.rowCount} rows were inserted into dw_d_location.`)
                return DW.query(dwQueries.insertDWpromotion)
              })
              .then(result=>{
                console.log(`${result.rowCount} rows were inserted into dw_d_promotion`)
                return DW.query(dwQueries.insertDWsubscription)
              })
              .then(result=>{
                console.log(`${result.rowCount} rows were inserted into dw_d_subscription_type`)
                return DW.query(dwQueries.inserDWfcomplaints)
              })
              .then(result=>{
                console.log(`${result.rowCount} rows have been inserted into dw_f_complaints`)
                return DW.query(dwQueries.insertDWfpromotions)
              })
              .then(result=>{
                console.log(`${result.rowCount} rows have been inserted into dw_f_promotions`)
                return DW.query(dwQueries.insertDWfsatisfaction)
              })
              .then(result=>{
                console.log(`${result.rowCount} rows have been inserted into dw_f_satisfaction`)
                console.log("")
                console.log("The process of transferring the data to the D.W has been completed.")
                return client.query('INSERT INTO staging_area.max_date(max_date) select max(calendar_date) from staging_area.sa_d_calendar')
              })
              .then(result=>{
                //console.log("max_date table has been updated")
                return client.query('INSERT INTO staging_area.max_category(max_category) select max(category_id) from staging_area.sa_d_account_category')
              })
              .then(result=>{
                //console.log(result.rowCount)
                return client.query('INSERT INTO staging_area.max_client_manager(max_manager) select max(client_manager_id) from staging_area.sa_d_client_manager')
              })
              .then(result=>{
                return client.query('INSERT INTO staging_area.max_customer(max_customer) select max(customer_id) from staging_area.sa_d_customer')
              })
              .then(result=>{
                return client.query('INSERT INTO staging_area.max_location(max_location) select max(location_id) from staging_area.sa_d_location')
              })
              .then(result=>{
                return client.query('INSERT INTO staging_area.max_promotion(max_promotion) select max(promotion_id) from staging_area.sa_d_promotion')
              })
              .then(result=>{
                return client.query('INSERT INTO staging_area.max_subscription_type(max_subscription) select max(subscription_id) from staging_area.sa_d_subscription_type')
              })
              .then(result=>{
                  return DW.query("refresh materialized view data_mart.average_satisfaction");
              })



.catch(e=>console.log(e))
.finally(()=>{
  connection.close();
  client.end();
  DW.end();
})

}

initialDWload();

 