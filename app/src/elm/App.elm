module App exposing (main)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, on, keyCode)
import Json.Decode as Json
import List exposing (map)
import Helpers.DragDrop as DragDrop

-- TODO next: send drag/drop feedback to Elm to apply changes to model
-- TODO next: implement gif-like drag and drop items
-- TODO next: add subtasks
-- TODO next: implement adding new items
-- TODO next: save items in local storage

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


type alias ViewItem =
  { id : String
  , title : String
  , empty : Bool
  , dragged : Bool
  }


type alias Model =
  { items : List ViewItem
  , current : String
  , styles : Styles
  }


-- UPDATE

type Action
  = NoOp
  | SetCurrent String
  | KeyDown Int
  | DragStart DragDrop.Model


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

    DragStart dndModel ->
      let
        _ = Debug.log "DragStart" dndModel.draggedItem
        id = dndModel.draggedItem
        items = model.items
        newItems = List.map (\item -> if item.id == id then {item | dragged = True} else item) items
      in
        ({model | items = newItems}, Cmd.none)


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

todo : Styles -> ViewItem -> Html Action
todo styles item =
  div [ id item.id
      , class styles.item
      , draggable "true"
      ]
  [ span [] [ text item.title ]
  ]


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
    items = [ ViewItem "_szubtsovskiy$elm_todolist_dnd$item$1" "First" False False
            , ViewItem "_szubtsovskiy$elm_todolist_dnd$item$2" "Second" False False
            , ViewItem "_szubtsovskiy$elm_todolist_dnd$item$3" "Third" False False
            ]
  in
    { items = items
    , current = ""
    , styles = styles
    } ! List.map DragDrop.init (map (.id) items)

