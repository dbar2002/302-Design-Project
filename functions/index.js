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

exports.assignUserRoleforCBU = functions.https
.onCall(async (data, context) => {
  try {
    const {email} = data;
    const domain = email.split('@')[1]; //saves what comes after the @
    const first = email.split(domain).join('');// saves what comes before the @
    const isPartofOrg = false;
          
    let role;
  
      switch (isPartofOrg) {
        case 'calbaptist.edu':
          isPartofOrg = true;
          break;
        default:
          role = 'visitor';
          break;
      }

      if(isPartofOrg) {
      switch (first) {
       case first.includes('.'):
          role = 'student';
          break;
        default:
          role = 'employee';
          break;
        }
      }
      const uid = context.auth.uid;
      const customClaims = {
        CBUAccess: role,
      };
      
      await admin.auth().setCustomUserClaims(uid, customClaims);

      // Update real-time database to notify client to force refresh.
      const metadataRef = getDatabase().ref('metadata/' + user.uid);
      
      console.log(`${email} was granted the ${role} role`);
      return `User ${email} was granted the ${role} role`;
      } catch (err) {
        console.error(err);
        throw new functions.https.HttpsError('internal', 'Internal server error');
        }
});

exports.assignUserRole = functions.firestore.document("users/{uid}")
.onUpdate(async (data, context) => {
  try {
    const {email} = data;
    const domain = email.split('@')[1]; //saves what comes after the @
    const first = email.split(domain).join('');// saves what comes before the @
    const isPartofOrg = false;
          
    let role;
  
      switch (isPartofOrg) {
        case 'calbaptist.edu':
          isPartofOrg = true;
          break;
        default:
          role = 'visitor';
          break;
      }

      if(isPartofOrg) {
      switch (first) {
       case first.includes('.'):
          role = 'student';
          break;
        default:
          role = 'employee';
          break;
        }
      }
      const uid = context.auth.uid;
      const customClaims = {
        CBUAccess: role,
      };
      
      await admin.auth().setCustomUserClaims(uid, customClaims);

      // Update real-time database to notify client to force refresh.
      const metadataRef = getDatabase().ref('metadata/' + user.uid);
      
      console.log(`${email} was granted the ${role} role`);
      return `User ${email} was granted the ${role} role`;
      } catch (err) {
        console.error(err);
        throw new functions.https.HttpsError('internal', 'Internal server error');
        }
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
