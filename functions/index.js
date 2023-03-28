// const functions = require("firebase-functions");

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started

const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();

const firestore = admin.firestore();
const settings = {timestampsInSnapshots: true};
firestore.settings(settings);

exports.updateAccess = functions.firestore
    .document("users/{uid}")
    .onUpdate((change, context) => {
      const newValue = change.after.data();
      const customClaims = {
        CBUAccess: newValue.CBUAccess,
      };

      // Set custom user claims on this update.
      return admin.auth().setCustomUserClaims(
          context.params.uid, customClaims)
          .then(() => {
            console.log("Done!");
          })
          .catch((error) => {
            console.log(error);
          });
    });


// On sign up.
exports.processSignUp = functions.auth.user().onCreate(async (user) =>{
  const customClaims = {
    CBUAccess: user.CBUAccess,
  };
  
  try {
    // Set custom user claims on this newly created user.
    await getAuth().setCustomUserClaims(user.uid, customClaims);

    // Update real-time database to notify client to force refresh.
    const metadataRef = getDatabase().ref('metadata/' + user.uid);

    // Set the refresh time to the current UTC timestamp.
    // This will be captured on the client to force a token refresh.
    await  metadataRef.set({refreshTime: new Date().getTime()});
  } catch (error) {
    console.log(error);
  }

});

