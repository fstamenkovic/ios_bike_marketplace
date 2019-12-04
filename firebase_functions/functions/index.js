const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');

// Twilio credentials were removed to make repo public.
const twilio = require('twilio')
const accountSid = ''
const authToken = ''

const client = new twilio(accountSid, authToken)

const twilioNumber = '+14015371117'

admin.initializeApp({
  credential: admin.credential.cert(require('./admin.json')),
  databaseURL: "https://bike-marketplace.firebaseio.com"
});


exports.update_user = functions.https.onCall((data, context) => {
  const type = data.bike_type;
  const color = data.bike_color;
  const poster_username = data.username;
  var db = admin.firestore();

  console.log("Looking for: ", type, " ", color);

  db.collection("users").get().then(function(snapshot) {
    snapshot.forEach(function(user) {
      const user_info = user.data();
      const n = type.localeCompare(user_info.fav_category);
      const m = color.localeCompare(user_info.fav_color);
      const i = poster_username.localeCompare(user_info.username)
      const msg = 'Hi '.concat(user_info.username, '! We found a bike you might like. Go to your Bike Marketplace app to view the posting!')

      console.log(user_info.fav_color, " ", user_info.fav_category);

      if(n === 0 && m === 0 && i !== 0){
        console.log(user_info.phone_number);
        const textMessage = {
          body: msg,
          to: user_info.phone_number,
          from: twilioNumber
        }

        client.messages.create(textMessage).then(message => console.log(message.sid)).catch(err => console.log(err))
        console.log("Message sent!")
      }

    });

    return null
  }).catch(function(error) {
      console.log("Error getting documents: ", error);
      return null;
  });



  //console.log(type, " ", color);
});
