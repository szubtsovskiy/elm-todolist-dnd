module App exposing (main)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, on, keyCode)
import Json.Decode as Json
import Json.Encode as Encode
import List exposing (map)

-- TODO next: add function to create data-* attributes (requires native code)
-- TODO next: implement gif-like drag and drop in JavaScript (need to test which HTML markup to use/how to mark empty slots and so on)
-- TODO next: implement gif-like drag and drop items
-- TODO next: implement gif-like drag and drop subtasks

-- MAIN

main : Program Styles
main =
  Html.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = (\x -> Sub.none)
    }

-- MODEL

type alias Styles =
  { container : String
  , item : String
  , input : String
  }

type alias Model =
  { items : List String
  , current : String
  , styles : Styles
  }


-- UPDATE

type Action
  = NoOp
  | SetCurrent String
  | KeyDown Int
  | DragStart String


update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    NoOp ->
      (model, Cmd.none)

    SetCurrent value ->
      ({model | current = value}, Cmd.none)

    KeyDown code ->
      case code of
        13 ->
          ({model | current = ""}, Cmd.none)

        27 ->
          ({model | current = ""}, Cmd.none)

        _ ->
          (model, Cmd.none)

    DragStart item ->
      let
        _ = Debug.log "DragStart" item
      in
        (model, Cmd.none)

-- VIEW

view : Model -> Html Action
view model =
  let
    items = model.items
    styles = model.styles
  in
    div [ ]
    [ input
      [ type' "text"
      , class styles.input
      , placeholder "To do..."
      , onInput SetCurrent
      , onKeyDown KeyDown
      , value model.current
      ] []
    , div [ class styles.container ] (map (todo styles) items)
    ]

todo : Styles -> String -> Html Action
todo styles item =
  div [ class styles.item, id item, draggable "true", onDragStart DragStart ]
  [ span [] [ text item ]
  ]

onDragStart : (String -> Action) -> Attribute Action
onDragStart tagger =
  on "dragstart" (Json.map tagger (Json.at ["target", "id"] Json.string))

onKeyDown : (Int -> action) -> Attribute action
onKeyDown tagger =
  on "keydown" (Json.map tagger keyCode)


-- INIT

init : Styles -> (Model, Cmd Action)
init styles =
  { items = [ "First", "Second", "Third" ]
  , current = ""
  , styles = styles
  } ! [Cmd.none]

