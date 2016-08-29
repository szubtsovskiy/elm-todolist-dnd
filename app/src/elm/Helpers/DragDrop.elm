port module Helpers.DragDrop exposing (init, onDragStart)

type Action
  = DragStart String

port inits : String -> Cmd action

init : String -> Cmd action
init id =
  inits id

port dragStarts : (String -> action) -> Sub action

onDragStart : (String -> action) -> Sub action
onDragStart tagger =
  dragStarts tagger
