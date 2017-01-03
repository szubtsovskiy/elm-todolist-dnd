import firebase from 'firebase';
import {App} from './elm/App';
import {App2} from './elm/App2';

App.embed(document.getElementById('app'));
App2.embed(document.getElementById('app2'));

var config = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: process.env.FIREBASE_AUTH_DOMAIN,
  databaseURL: process.env.FIREBASE_DB_URL,
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID
};
firebase.initializeApp(config);