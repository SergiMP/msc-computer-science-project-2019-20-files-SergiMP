let mongoose = require('mongoose');


mongoose.connect("mongodb://127.0.0.1:27017/testing-database",{ useNewUrlParser: true, useUnifiedTopology: true, useCreateIndex: true });

mongoose.connection.on("open", function(){
  console.log("Connection to MongoDB stablished.");
});

let Schema = mongoose.model('testing-object', {
    reviewer_id: { type: Number, required: true},
    overall_satisfaction: { type: Number, required: true},
    advisor_satisfaction: { type: Number, required: true},
    easiness_interface: { type: Number, required: true},
    usefulness_service: { type: Number, required: true},
    interest_mob_app: { type: Number, required: true},
    recommend_friend: { type: Number, required: true},
    date_submitted: {type: String, required: true}
  }
);

module.exports = Schema;