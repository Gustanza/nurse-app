const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const adminApprovals = functions.firestore.document('shift_requests/{approved}').onUpdate(async(snapshot, context)=>{
   const oldD = snapshot.before.data();
   const newD = snapshot.after.data();
   if (newD.approved) {
    var payload = {
        notification: {
            title: "Updates about your shift",
            body: "Congrats, your shift request has been approved",
            sound: 'beep',
            priority: 'high'
        }
    }
    try {
       await admin.messaging().sendToDevice(oldD.token, payload); 
    } catch (error) {
       console.log(error);
    }
   } else {
    var payload = {
        notification: {
            title: "Updates about your shift",
            body: "Sorry, your shift request has been denied",
            sound: 'beep',
            priority: 'high'
        }
    }
    try {
        await admin.messaging().sendToDevice(oldD.token, payload); 
    } catch (error) {
        console.log(error);
    }
   } 
});

const adminOffApprovals = functions.firestore.document('offs/{approved}').onUpdate(async(snapshot, context)=>{
    const oldD = snapshot.before.data();
    const newD = snapshot.after.data();
    if (newD.approved) {
     var payload = {
         notification: {
             title: "Updates about your off request",
             body: "Congrats, your off request has been approved",
             sound: 'beep',
             priority: 'high'
         }
     }
     try {
        await admin.messaging().sendToDevice(oldD.token, payload); 
     } catch (error) {
        console.log(error);
     }
    } else {
     var payload = {
         notification: {
             title: "Updates about your off request",
             body: "Sorry, your off request has been rejected",
             sound: 'beep',
             priority: 'high'
         }
     }
     try {
         await admin.messaging().sendToDevice(oldD.token, payload); 
     } catch (error) {
         console.log(error);
     }
    } 
 });


const swapApprovals = functions.firestore.document('swap_requests/{requested}').onUpdate(async(snapshot, context)=>{
const oldD = snapshot.before.data();
const newD = snapshot.after.data();
var payload = {
    notification: {
        title: "Updates about your swap request",
        body: "Congrats, your swap request has been accepted",
        sound: 'beep',
        priority: 'high'
    }
}
try {
await admin.messaging().sendToDevice(oldD.token, payload); 
} catch (error) {
    console.log(error);
}
});

const shiftStarts = functions.firestore.document('shifts/{starttime}').onUpdate(async(snapshot, context)=>{
const oldD = snapshot.before.data();
const newD = snapshot.after.data();
const shift = oldD.shift;
const who = oldD.who;
var payload = {
    notification: {
        title: "Shift update",
        body: `Hello Manaseh, ${who} just started their ${shift} shift.`,
        sound: 'beep',
        priority: 'high'
    }
}
try {
await admin.messaging().sendToDevice(oldD.token, payload); 
} catch (error) {
    console.log(error);
}
});

const shiftEnds = functions.firestore.document('shifts/{endtime}').onUpdate(async(snapshot, context)=>{
const oldD = snapshot.before.data();
const newD = snapshot.after.data();
const shift = oldD.shift;
const who = oldD.who;
var payload = {
    notification: {
        title: "Shift update",
        body: `Hello Manaseh, ${who} just completed their ${shift} shift.`,
        sound: 'beep',
        priority: 'high'
    }
}
try {
await admin.messaging().sendToDevice(oldD.token, payload); 
} catch (error) {
    console.log(error);
}
});

module.exports = {
    adminApprovals,
    adminOffApprovals,
    swapApprovals,
    shiftStarts,
    shiftEnds
}