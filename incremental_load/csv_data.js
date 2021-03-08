const fs = require("fs");
const csv = require("csv-parser");
const moment = require('moment');
let yesterday = moment().subtract(1,'days').format('YYYY-MM-DD');

function getComplaints(){
  return new Promise((resolve,reject)=>{
      const csvData = [];
      fs.createReadStream('incremental_complaints.csv').pipe(csv())
      .on('data',(data)=> {
          if (String(data['date_received'].trim()) == yesterday){
          csvData.push(
              [Number(data['customer_id']),
              Number(data['complaint_category']),
              data['customer_comments'].replace(/[\W_]+/g," "),
              String(data['date_received'].trim())])
          }
          })
      .on('end',()=> {
          if(csvData){
              resolve(csvData)
          }else{
              reject(Error("No data was found in the .csv"))
          }
      });
  })
  }

getComplaints().then(rows=> rows.forEach( row => console.log(row)))
module.exports = getComplaints;