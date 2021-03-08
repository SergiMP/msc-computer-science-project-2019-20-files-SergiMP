const fs = require("fs");
const csv = require("csv-parser");


function getComplaints(){
  return new Promise((resolve,reject)=>{
      const csvData = [];
      fs.createReadStream('testing.csv').pipe(csv())
      .on('data',(data)=> {
          csvData.push(
              [Number(data['listing_id'])])
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