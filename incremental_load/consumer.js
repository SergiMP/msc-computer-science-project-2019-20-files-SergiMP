"use strict";

const amqp = require("amqplib");
const Document = require("./model");
//const notification = require("./email");
let counter = 1;

async function consumer(){

    try {

        const connection = await amqp.connect("amqp://localhost:5672");
        const channel =  await connection.createChannel();
        const queue = await channel.assertQueue("web-data");
        
        channel.prefetch(1);
        
        channel.consume("web-data", message => {

            let data = JSON.parse(message.content.toString());
            let survey = new Document({reviewer_id: data["content"]["reviewer_id"],
                                       overall_satisfaction: data["content"]["overall_satisfaction"],
                                       advisor_satisfaction: data["content"]["advisor_satisfaction"],
                                       easiness_interface: data["content"]["easiness_interface"],
                                       usefulness_service: data["content"]["usefulness_service"],
                                       interest_mob_app:  data["content"]["interest_mob_app"],
                                       recommend_friend: data["content"]["recommend_friend"],
                                       date_submitted: data["date_submitted"]
                                      });
            
            //if ( data["content"]["overall_satisfaction"] < 5){ notification(String(data["content"]["reviewer_id"]))};
            
             survey.save(function(error,object){
                if(!error){
                    console.log(`Writing message ${counter}`)
                    counter +=1;
                    channel.ack(message);
                }
            })
        })
        
    }
    catch (e) {
        console.log(`The following error has been found:\n${e}`);
    }
}

consumer();