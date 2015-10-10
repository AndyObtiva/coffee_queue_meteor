App.info({
  id: 'com.meteor.coffee-queue',
  name: 'CoffeeQueue',
  description: 'Express Coffee Ordering Service',
  author: 'Soft Buzz Inc',
  email: 'andy.maleh@softbuzz.ca',
  website: 'http://softbuzz.ca'
});

// // Set up resources such as icons and launch screens.
// App.icons({
//   'iphone': 'icons/icon-60.png',
//   'iphone_2x': 'icons/icon-60@2x.png',
//   // ... more screen sizes and platforms ...
// });
//
// App.launchScreens({
//   'iphone': 'splash/Default~iphone.png',
//   'iphone_2x': 'splash/Default@2x~iphone.png',
//   // ... more screen sizes and platforms ...
// });

App.setPreference('EnableViewportScale', 'true');
App.setPreference('SuppressesIncrementalRendering', 'true');

// // Pass preferences for a particular PhoneGap/Cordova plugin
// App.configurePlugin('com.phonegap.plugins.facebookconnect', {
//   APP_ID: '1234567890',
//   API_KEY: 'supersecretapikey'
// });
