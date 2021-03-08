"use strict";
//docker run --name rabbitmq -p 5672:5672 rabbitmq
const amqp = require("amqplib");
const data =  require("./testingData.json");
let randomIntervalTime = () => (Math.floor(Math.random() * 30) + 1) * 1000;
let counter = 0;
async function publisher(){

    try {
            const connection = await amqp.connect("amqp://localhost:5672");
            const channel =  await connection.createChannel();
            // {durable: true} ensures messages are not wiped-out if server fails.
            const queue = await channel.assertQueue("web-data", {durable: true});
            for(const message in data) {
                    setTimeout(() => {
                        let object = data[message];
                        channel.sendToQueue("web-data", Buffer.from(JSON.stringify(object)),{persistent: true, contentType: 'application/json' });
                        counter += 1;
                        console.log(`Object num ${counter}`);
                        console.log(`{ \n
                    reviewer_id: ${object["content"]["reviewer_id"]},\n 
                    overall_satisfaction: ${object["content"]["overall_satisfaction"]},\n
                    advisor_satisfaction: ${object["content"]["advisor_satisfaction"]},\n 
                    easiness_interface: ${object["content"]["easiness_interface"]}, \n
                    usefulness_service: ${object["content"]["usefulness_service"]}, \n
                    interest_mob_app: ${object["content"]["interest_mob_app"]},\n 
                    recommend_friend: ${object["content"]["recommend_friend"]},\n 
                    date_submitted:${object["date_submitted"]}
                }`);
                    }, randomIntervalTime());
            } 
    }
    catch (e) {
        console.log(`The following error has been found:\n${e}`);
    }

}

publisher();