const {Client} = require("pg");
let format = require("pg-format");
const { connection, mongo } = require("mongoose");
const getMongoData = require('./getMongoData');
const CSV =  require('./csv_data');
const saQueries = require("./sqlQueriesincremental");

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

function incrementalDWload(){
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
              .then(result=>{
                console.log("Connection to PostgreSQL stablished");
                return client.query("select staging_area.clean_staging_tables()")
              })
              .then(result=>{
                console.log("Staging tables have been deleted.....")
                if(csvData.length !== 0){
                return client.query(format(saQueries.insertComplaints, csvData ),[])
                }else{
                  return client.query('SELECT * FROM STAGING_AREA.MAX_CATEGORY')
                }
              })
              .then(result=>{
                if(mongodata.length !== 0){
                return client.query(format(saQueries.intertSurveys, mongodata ),[])
                }else{
                  return client.query('SELECT * FROM STAGING_AREA.MAX_CATEGORY')
                }
              })
              .then(result=> {
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
                return client.query(('SELECT staging_area.sa_create_incremental_calendar()'))
              })
              .then(result=>{
                console.log(`${result.rowCount} rows have been inserted into sa_d_calendar`)
                return client.query(saQueries.insertFactComplaints)
              })
              .then(result=>{
                return client.query('SELECT * FROM STAGING_AREA.SA_F_COMPLAINTS')
              })
              .then(result=>{
                console.log(`${result.rowCount} row(s) has/have been inserted into sa_f_complaints`)
                return client.query(saQueries.insertFactPromotions)
              })
              .then((result=>{
                console.log(`${result.rowCount -1} row(s) has/have been inserted into sa_f_promotions`)
                return client.query(saQueries.insertFactSatisfaction)
              }))
              .then(result=>{
                console.log(`${result.rowCount-1} row(s) has/have been inserted into sa_f_satisfaction`)
                return DW.connect();
              })
              .then(result=>{
                
                console.log("Connecting to the D.W database.....")
                console.log("Filtering Dimension tables....")
                return DW.query('SELECT data_mart.incremental_load_dw()')
              })
              .then(result=>{
                console.log("Data has been transferred to the data mart.")
                console.log("The incremental load has been completed")
                return client.query(saQueries.updateCategory);
              })
              .then(result=>{
                console.log(`${result.rowCount} row in max_category has been updated`);
                return client.query(saQueries.updateClientManager)
              })
              .then(result=>{
                console.log(`${result.rowCount} row in max_client_manager has been updated`)
                return client.query(saQueries.updateMaxCustomer)
              })
              .then(result=>{
                console.log(`${result.rowCount} row has been updated in max_customer`)
                return client.query(saQueries.updateMaxDate)
              })
              .then(result=>{
                console.log(`${result.rowCount} has been updated in max_date`)
                return client.query(saQueries.updateMaxLocation)
              })
              .then(result=>{
                console.log(`${result.rowCount} has been updated in max_location`)
                return client.query(saQueries.updateMaxPromotion)
              })
              .then(result=>{
                console.log(`${result.rowCount} has been updated in max_promotion`)
                return client.query(saQueries.updateMaxSubscription)
              })
          
.catch(e=>console.log(e))
.finally(()=>{
  console.log("Shutting down connection to the server.")
  connection.close();
  client.end();
  DW.end();
})

}



 module.exports = incrementalDWload;