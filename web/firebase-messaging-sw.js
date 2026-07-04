importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyCQ3cLpHpn3pSLODZhbPI5krTCN2MqRZrA",
  authDomain: "fresh-market-ecb8d.firebaseapp.com",
  projectId: "fresh-market-ecb8d",
  storageBucket: "fresh-market-ecb8d.firebasestorage.app",
  messagingSenderId: "812344604161",
  appId: "1:812344604161:web:60ab00867a662223c9f200"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("Background message received:", payload);
});
