const Document = require("./model");
const { connection } = require("mongoose");
const moment = require('moment');
let yesterday = moment().subtract(1,'days').format('DD-MM-YYYY');

function getMongoData(){
  return new Promise((resolve,reject)=>{
      const collection =  Document.find({date_submitted: yesterday})
      if(collection){
          resolve(collection)
      }else{
          reject(Error("No data was found in MongoDB"))
      }
  })
}

module.exports = getMongoData;
