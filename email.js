"use strict";

const sgMail = require("@sendgrid/mail");
// The API key is not included in the code.
const API_KEY = "supersecretAPI key";

sgMail.setApiKey(API_KEY);

function customerNotification(account){
// For testing purposes my bbk email address was used.
    sgMail.send({
        to: "xxxx@mail.bbk.ac.uk",
        from : "xxxx@mail.bbk.ac.uk",
        subject: `Please contact the account ${account}.`,
        text: `Please contact customer ${account} and follow the guidelines discussed in the last meeting.`
    
    })


}

module.exports = customerNotification;
