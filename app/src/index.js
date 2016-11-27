require ('./elm/Stylesheets.elm');

// inject bundled Elm app into div#content
var App = require('./elm/App').App;
app = App.embed(document.getElementById('content'));
