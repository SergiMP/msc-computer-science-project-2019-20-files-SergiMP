const cron = require('node-cron');
const incrementalLoad = require("./postgreSQLincremental");

// Used for demonstration purposes.
// cron.schedule( ' */1 * * * * ',()=>{
//   incrementalLoad();
// })


cron.schedule( '01 00 * * *',()=>{
  incrementalLoad();
})
