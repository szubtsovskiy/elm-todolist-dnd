module App exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, on, keyCode)
import Json.Decode as Json
import Dict exposing (Dict)
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
  , group : String
  , groupTitle : String
  , input : String
  , dragged : String
  }


type alias ID =
  Int


type alias ViewItem =
  { title : String
  , topLeft : Position
  }


type alias Model =
  { items : Dict ID ViewItem
  , draggedItem : Maybe ( ID, ViewItem, Position, Position )
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
      [ "First", "Second", "Third" ]
        |> List.indexedMap (\i title -> ( i, ViewItem title { x = 0, y = i * itemBoxHeight + itemSpacing } ))
        |> Dict.fromList

    model =
      { items = items
      , draggedItem = Nothing
      , newItemTitle = ""
      , styles = styles
      }
  in
    model ! [ Cmd.none ]


subscriptions : Model -> Sub Msg
subscriptions model =
  case model.draggedItem of
    Just _ ->
      Sub.batch
        [ Mouse.moves DragAt
        , Mouse.ups DragEnd
        ]

    Nothing ->
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
      case Dict.get id model.items of
        Just item ->
          { model | items = Dict.remove id model.items, draggedItem = Just ( id, item, item.topLeft, xy ) } ! [ Cmd.none ]

        Nothing ->
          model ! [ Cmd.none ]

    DragAt xy ->
      case model.draggedItem of
        Just ( id, item, orig, dragStarted ) ->
          let
            newY =
              orig.y + xy.y - dragStarted.y

            minY =
              itemSpacing

            maxY =
              (Dict.size model.items) * itemBoxHeight + itemSpacing

            prevTopLeft =
              item.topLeft

            newTopLeft =
              if newY > maxY then
                Position orig.x maxY
              else if newY >= minY then
                Position orig.x newY
              else
                Position orig.x minY

            newDraggedItem =
              { item | topLeft = newTopLeft }

            newItems =
              Dict.map (over newTopLeft prevTopLeft) model.items
          in
            { model | items = newItems, draggedItem = Just ( id, newDraggedItem, orig, dragStarted ) } ! [ Cmd.none ]

        Nothing ->
          model ! [ Cmd.none ]

    DragEnd xy ->
      case model.draggedItem of
        Just ( id, item, orig, _ ) ->
          let
            newY =
              item.topLeft.y

            adjustedY =
              if newY > orig.y + itemBoxHeight // 2 || newY < orig.y - itemBoxHeight // 2 then
                (toFloat newY)
                  / (toFloat itemBoxHeight)
                  |> round
                  |> (*) itemBoxHeight
                  |> (+) itemSpacing
              else
                orig.y

            droppedItem =
              { item | topLeft = Position item.topLeft.x adjustedY }
          in
            { model | items = Dict.insert id droppedItem model.items, draggedItem = Nothing } ! [ Cmd.none ]

        Nothing ->
          model ! [ Cmd.none ]


over : Position -> Position -> ID -> ViewItem -> ViewItem
over newTopLeft prevTopLeft _ item =
  if newTopLeft.y < prevTopLeft.y then
    -- moving upwards
    if item.topLeft.y <= newTopLeft.y && newTopLeft.y <= item.topLeft.y + itemHeight // 2 then
      { item | topLeft = Position item.topLeft.x (item.topLeft.y + itemBoxHeight) }
    else
      item
  else if newTopLeft.y <= item.topLeft.y && newTopLeft.y + itemHeight >= item.topLeft.y + itemHeight // 2 then
    -- moving downwards
    { item | topLeft = Position item.topLeft.x (item.topLeft.y - itemBoxHeight) }
  else
    item



-- VIEW


(=>) : String -> String -> ( String, String )
(=>) =
  (,)


itemHeight : Int
itemHeight =
  40


itemSpacing : Int
itemSpacing =
  2


itemBoxHeight : Int
itemBoxHeight =
  itemHeight + itemSpacing


view : Model -> Html Msg
view model =
  let
    items =
      case model.draggedItem of
        Just ( id, item, _, _ ) ->
          (List.map (todo styles False) (Dict.toList model.items)) ++ [ todo styles True ( id, item ) ]

        Nothing ->
          (List.map (todo styles False) (Dict.toList model.items))

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
              , div [ style [ "position" => "relative", "width" => "100%" ] ] items
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


todo : Styles -> Bool -> ( ID, ViewItem ) -> Html Msg
todo styles dragged ( id, item ) =
  let
    topLeft =
      item.topLeft

    inlineStyles =
      [ "position" => "absolute"
      , "left" => px topLeft.x
      , "top" => px topLeft.y
      , "height" => px itemHeight
      ]

    classes =
      if dragged then
        styles.item ++ " " ++ styles.dragged
      else
        styles.item
  in
    div [ dataItemId id, onMouseDown, class classes, style inlineStyles ]
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


px : Int -> String
px amount =
  (toString amount) ++ "px"
