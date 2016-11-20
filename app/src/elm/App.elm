module App exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, on, keyCode)
import Json.Decode as Json
import List
import Mouse exposing (Position)
import String


main : Program Styles Model Msg
main =
  Html.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


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


type Mode
  = Default Position
  | Dragging Position Position Position


type alias ViewItem =
  { id : ID
  , title : String
  , mode : Mode
  }


type alias Model =
  { items : List ViewItem
  , newItemTitle : String
  , styles : Styles
  }


type Msg
  = NoOp
  | SetNewItemTitle String
  | KeyDown Int
  | DragStart ID Position
  | DragAt Position
  | DragEnd Position


init : Styles -> ( Model, Cmd Msg )
init styles =
  let
    items =
      [ ViewItem 1 "First" (Default (Position 0 2))
      , ViewItem 2 "Second" (Default (Position 0 44))
      , ViewItem 3 "Third" (Default (Position 0 86))
      ]

    model =
      { items = items
      , newItemTitle = ""
      , styles = styles
      }
  in
    model ! [ Cmd.none ]


subscriptions : Model -> Sub Msg
subscriptions model =
  let
    onlyDragging item =
      case item.mode of
        Dragging _ _ _ ->
          Just item

        Default _ ->
          Nothing
  in
    if List.length (List.filterMap onlyDragging model.items) > 0 then
      Sub.batch
        [ Mouse.moves DragAt
        , Mouse.ups DragEnd
        ]
    else
      Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    NoOp ->
      model ! [ Cmd.none ]

    SetNewItemTitle value ->
      { model | newItemTitle = value } ! [ Cmd.none ]

    KeyDown code ->
      case code of
        13 ->
          { model | newItemTitle = "" } ! [ Cmd.none ]

        27 ->
          { model | newItemTitle = "" } ! [ Cmd.none ]

        _ ->
          model ! [ Cmd.none ]

    DragStart id xy ->
      let
        _ =
          Debug.log "DragStart" (toString ( id, xy ))

        updateItem item =
          if item.id == id then
            case item.mode of
              Default current ->
                { item | mode = Dragging current xy xy }

              _ ->
                item
          else
            item
      in
        { model | items = List.map updateItem model.items } ! [ Cmd.none ]

    DragAt xy ->
      model ! [ Cmd.none ]

    DragEnd xy ->
      model ! [ Cmd.none ]



-- VIEW


(=>) : String -> String -> ( String, String )
(=>) =
  (,)


px : Int -> String
px amount =
  (toString amount) ++ "px"


view : Model -> Html Msg
view model =
  let
    items =
      model.items

    styles =
      model.styles
  in
    div [ class styles.container ]
      [ fieldset []
          [ legend [] [ text "Week 47" ]
          , input
              [ type_ "text"
              , class styles.input
              , placeholder "To do..."
              , onInput SetNewItemTitle
              , onKeyDown KeyDown
              , value model.newItemTitle
              ]
              []
          , div [ class styles.group ]
              [ groupTitle model
              , div [ style [ "position" => "absolute", "width" => "100%" ] ]
                  (List.map (todo styles) items)
              ]
          ]
      ]


groupTitle : Model -> Html Msg
groupTitle model =
  let
    styles =
      model.styles
  in
    div [ class styles.groupTitle ] [ text "Monday" ]


todo : Styles -> ViewItem -> Html Msg
todo styles item =
  let
    position =
      getPosition item

    inlineStyles =
      [ "position" => "absolute"
      , "left" => px position.x
      , "top" => px position.y
      ]
  in
    div [ dataItemId item.id, onMouseDown, class styles.item, style inlineStyles ]
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


positionDecoder : Json.Decoder Position
positionDecoder =
  Mouse.position


getPosition : ViewItem -> Position
getPosition item =
  case item.mode of
    Default position ->
      position

    Dragging current dragStarted draggedTo ->
      Position current.x (current.y + draggedTo.y - dragStarted.y)
