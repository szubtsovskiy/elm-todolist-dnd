require('../styles/main.scss');

// inject bundled Elm app into div#content
var App = require('./elm/App').App;
app = App.embed(document.getElementById('content'), require('./elm/App.scss'));
app.ports.inits.subscribe(function(elementId) {
  var element = document.getElementById(elementId);
  if ( element ) {

    element.addEventListener("dragstart", function(event) {
      event.dataTransfer.setData("text/plain", elementId);
      app.ports.dragStarts.send({draggedItem: elementId});
    });

    element.addEventListener("dragover", function(event) {
      event.preventDefault();
      event.dataTransfer.dropEffect = "move";
    });

    element.addEventListener("drop", function(event) {
      var draggedId = event.dataTransfer.getData('text/plain');
      var dropTargetId = event.target.id;
      console.log(`drop ${draggedId} on ${dropTargetId}`);
    });

  } else {
    console.error("No such element", elementId);
  }
});
