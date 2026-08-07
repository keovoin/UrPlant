const admin = require('firebase-admin');
admin.initializeApp({ projectId: 'urplant-app' });

admin.auth().getUserByEmail('keovoin@gmail.com').then(user => {
  console.log('UID:', user.uid);
  console.log('Custom claims:', JSON.stringify(user.customClaims));
  if (!user.customClaims || !user.customClaims.admin) {
    console.log('Admin claim NOT set — setting now...');
    return admin.auth().setCustomUserClaims(user.uid, { admin: true }).then(() => {
      console.log('Admin claim SET successfully');
    });
  } else {
    console.log('Admin: YES');
  }
}).then(() => process.exit(0)).catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});