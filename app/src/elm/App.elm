module App exposing (main)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, on, keyCode)
import Json.Decode as Json
import List exposing (map)

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
  div [ class styles.item, draggable "true", dropzone "true" ]
  [ span [] [ text item ]
  ]


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

