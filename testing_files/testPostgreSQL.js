const {Client} = require("pg");
let format = require("pg-format");
const { connection, mongo } = require("mongoose");
const getMongoData = require('./getMongoData');
const CSV =  require('./testCsvData');

const client =  new Client({
    user: "postgres",
    password: "postgres",
    host: "localhost",
    port:5432,
    database: "test",
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 20000
})


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
                          console.log(`${mongodata.length} objects from testing collection have been processed.`); 
                          return CSV()
                          })
              .then(data => {
                        
                        data.forEach(row => {
                        csvData.push([row[0]]);
                          })
                          console.log(`${csvData.length} rows from the  testing .csv file have been processed.`)
                          console.log(csvData[0])
                          console.log(csvData[1])
                         return client.connect() 
                          })

              .then((result)=>{
               console.log('Connection stablished')
               return client.query(format('INSERT INTO testing.test_csv VALUES %L', csvData ),[])
              })
              .then((result)=> {
                 console.log(`${result.rowCount} rows have been inserted into the csv table`)
                return client.query(format("INSERT INTO testing.test_surveys VALUES %L", mongodata ),[])
              })
              .then(result=>{
                console.log(`${result.rowCount} objects from the testing area have been inserted`)
              })



.catch(e=>console.log(e))
.finally(()=>{
  connection.close();
  client.end();
})



 