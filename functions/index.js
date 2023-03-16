// const functions = require("firebase-functions");

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

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


/*
// Verify the ID token first.
getAuth()
    .verifyIdToken(idToken)
    .then((claims) => {
      if (claims.admin === true) {
      // Allow access to requested admin resource.
      }
    });


// Lookup the user associated with the specified uid.
getAuth()
.getUser(uid)
.then((userRecord) => {

// The claims can be accessed on the user record.
  console.log(userRecord.customClaims['admin']);
});

// Lookup the user associated with the specified uid.
admin.auth().getUser(uid).then((userRecord) => {
    // The claims can be accessed on the user record.
    console.log(userRecord.customClaims);
  });

*/
