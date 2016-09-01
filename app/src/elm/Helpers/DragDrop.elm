port module Helpers.DragDrop exposing (init, onDragStart, Model)

type alias Model =
  { draggedItem : String
  }

port inits : String -> Cmd action

init : String -> Cmd action
init id =
  inits id

port dragStarts : (Model -> action) -> Sub action

onDragStart : (Model -> action) -> Sub action
onDragStart tagger =
  dragStarts tagger
