module App exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, on, keyCode)
import Json.Decode as Json
import List
import Mouse
import String

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

type alias ID =
  Int

type alias ViewItem =
  { id : ID
  , title : String
  , dragged : Bool
  }


type alias Model =
  { items : List ViewItem
  , current : String
  , styles : Styles
  }


type Msg
  = NoOp
  | SetCurrent String
  | KeyDown Int
  | DragStart ID Mouse.Position


init : Styles -> (Model, Cmd Msg)
init styles =
  let
    items = [ ViewItem 1 "First" False
            , ViewItem 2 "Second" False
            , ViewItem 3 "Third" False
            ]
  in
    { items = items
    , current = ""
    , styles = styles
    } ! [Cmd.none]

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    NoOp ->
      model ! [Cmd.none]

    SetCurrent value ->
      {model | current = value} ! [Cmd.none]

    KeyDown code ->
      case code of
        13 ->
          {model | current = ""} ! [Cmd.none]

        27 ->
          {model | current = ""} ! [Cmd.none]

        _ ->
          model ! [Cmd.none]

    DragStart id position ->
      let
        _ =
          Debug.log "DragStart" (toString (id, position))
      in
        model ! [Cmd.none]



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
  div [ dataItemId item.id
      , class styles.item
      , onMouseDown
      ]
  [ span [] [ text item.title ]
  ]


onKeyDown : (Int -> action) -> Attribute action
onKeyDown tagger =
  on "keydown" (Json.map tagger keyCode)

onMouseDown : Attribute Msg
onMouseDown =
  on "mousedown" (Json.map2 DragStart dataItemIdDecoder positionDecoder)

dataItemId : Int -> Attribute Msg
dataItemId id =
  attribute "data-item-id" (toString id)


dataItemIdDecoder : Json.Decoder ID
dataItemIdDecoder =
  let
    toInt s =
      Result.withDefault 0 (String.toInt s)

  in
    Json.at [ "target", "dataset", "itemId" ] (Json.map toInt Json.string)


positionDecoder : Json.Decoder Mouse.Position
positionDecoder =
  Mouse.position