require('../styles/main.scss');

// inject bundled Elm app into div#content
var App = require('./elm/App').App;
app = App.embed(document.getElementById('content'), require('./elm/App.scss'));
