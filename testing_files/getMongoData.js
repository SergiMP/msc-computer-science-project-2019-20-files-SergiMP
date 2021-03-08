const Document = require("./model");
const { connection } = require("mongoose");

function getMongoData(){
  return new Promise((resolve,reject)=>{
      const collection =  Document.find({})
      if(collection){
          resolve(collection)
      }else{
          reject(Error("No data was found in MongoDB"))
      }
  })
}


module.exports = getMongoData;
