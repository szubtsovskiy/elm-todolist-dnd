module App exposing (main)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, on, keyCode)
import Json.Decode as Json
import List exposing (map)
import Helpers.DragDrop as DragDrop

-- TODO next: send drop feedback to Elm to apply changes to model
-- TODO next: add real item objects with id and title fields
-- TODO next: implement gif-like drag and drop items
-- TODO next: add subtasks

-- MAIN

main : Program Styles
main =
  Html.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Styles =
  { container : String
  , item : String
  , subTask : String
  , group : String
  , groupTitle : String
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

    DragStart id ->
      let
        _ = Debug.log "DragStart" id
      in
        (model, Cmd.none)


-- VIEW

view : Model -> Html Action
view model =
  let
    items = model.items
    styles = model.styles
  in
    div [ class styles.container ]
    [ fieldset []
      [ legend [] [ text "Week 35" ]
      , input
        [ type' "text"
        , class styles.input
        , placeholder "To do..."
        , onInput SetCurrent
        , onKeyDown KeyDown
        , value model.current
        ] []
      , div [ class styles.group ] ((groupTitle model) :: (map (todo styles) items))
      ]
    ]

groupTitle : Model -> Html Action
groupTitle model =
  let
    styles = model.styles
  in
    div [ class styles.groupTitle ] [ text "Group 1" ]

todo : Styles -> String -> Html Action
todo styles item =
  div [ class styles.item, id (itemId item), draggable "true" ]
  [ span [] [ text item ]
  ]


itemId : String -> String
itemId id =
  "_szubtsovskiy$elm_todolist_dnd$" ++ id


onKeyDown : (Int -> action) -> Attribute action
onKeyDown tagger =
  on "keydown" (Json.map tagger keyCode)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Action
subscriptions model =
  DragDrop.onDragStart DragStart


-- INIT

init : Styles -> (Model, Cmd Action)
init styles =
  let
    items = [ "First", "Second", "Third" ]
  in
    { items = items
    , current = ""
    , styles = styles
    } ! List.map DragDrop.init (map itemId items)

