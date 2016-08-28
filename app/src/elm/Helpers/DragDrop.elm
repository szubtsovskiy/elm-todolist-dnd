port module Helpers.DragDrop exposing (init)

port inits : String -> Cmd action

init : String -> Cmd action
init id =
  inits id