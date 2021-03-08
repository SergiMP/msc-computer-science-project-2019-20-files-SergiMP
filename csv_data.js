const fs = require("fs");
const csv = require("csv-parser");


function getComplaints(){
  return new Promise((resolve,reject)=>{
      const csvData = [];
      fs.createReadStream('complaints.csv').pipe(csv())
      .on('data',(data)=> {
          csvData.push(
              [Number(data['customer_id']),
              Number(data['complaint_category']),
              data['customer_comments'].replace(/[\W_]+/g," "),
              String(data['date_received'].trim())])
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

module.exports = getComplaints;