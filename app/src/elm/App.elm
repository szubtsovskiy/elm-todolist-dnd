module App exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, on, keyCode)
import Json.Decode as Json
import List

-- TODO next: send drag/drop feedback to Elm to apply changes to model
-- TODO next: implement gif-like drag and drop items
-- TODO next: implement adding new items
-- TODO next: save items in local storage

-- MAIN

main : Program Styles Model Msg
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

type Msg
  = NoOp
  | SetCurrent String
  | KeyDown Int


update : Msg -> Model -> (Model, Cmd Msg)
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



-- VIEW

view : Model -> Html Msg
view model =
  let
    items = model.items
    styles = model.styles
  in
    div [ class styles.container ]
    [ fieldset []
      [ legend [] [ text "Week 47" ]
      , input
        [ type_ "text"
        , class styles.input
        , placeholder "To do..."
        , onInput SetCurrent
        , onKeyDown KeyDown
        , value model.current
        ] []
      , div [ class styles.group ] ((groupTitle model) :: (List.map (todo styles) items))
      ]
    ]

groupTitle : Model -> Html Msg
groupTitle model =
  let
    styles = model.styles
  in
    div [ class styles.groupTitle ] [ text "Group 1" ]

todo : Styles -> ViewItem -> Html Msg
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

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- INIT

init : Styles -> (Model, Cmd Msg)
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
    } ! [Cmd.none]

