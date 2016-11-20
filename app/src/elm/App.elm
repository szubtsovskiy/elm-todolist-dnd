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


type alias ViewItem =
  { id : ID
  , title : String
  , topLeft : Position
  }


type alias Model =
  { items : List ViewItem
  , draggedItem : Maybe ( ViewItem, Position, Position )
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
      [ ViewItem 1 "First" (Position 0 2)
      , ViewItem 2 "Second" (Position 0 44)
      , ViewItem 3 "Third" (Position 0 86)
      ]

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
      let
        _ =
          Debug.log "DragStart" (toString ( id, xy ))

        findItem id item ( items, found ) =
          if item.id == id then
            ( items, Just ( item, item.topLeft, xy ) )
          else
            ( items ++ [ item ], found )

        ( items, draggedItem ) =
          List.foldl (findItem id) ( [], Nothing ) model.items
      in
        { model | items = items, draggedItem = draggedItem } ! [ Cmd.none ]

    DragAt xy ->
      case model.draggedItem of
        Just ( item, orig, dragStarted ) ->
          let
            newY =
              orig.y + xy.y - dragStarted.y

            newTopLeft =
              if newY > (List.length model.items) * 42 + 2 then
                Position orig.x ((List.length model.items) * 42 + 2)
              else if newY >= 2 then
                Position orig.x newY
              else
                Position orig.x 2

            newItem =
              { item | topLeft = newTopLeft }

            items =
              List.map
                (\i ->
                  if newTopLeft.y < i.topLeft.y + 20 then
                    let
                      _ =
                        Debug.log "Time to shift this one" (toString i.id)
                    in
                      i
                  else if newTopLeft.y < i.topLeft.y + 40 then
                    let
                      _ =
                        Debug.log "Just over" (toString i.id)
                    in
                      i
                  else
                    i
                )
                model.items
          in
            { model | draggedItem = Just ( newItem, orig, dragStarted ) } ! [ Cmd.none ]

        Nothing ->
          model ! [ Cmd.none ]

    DragEnd xy ->
      case model.draggedItem of
        Just ( item, dragStarted, draggedTo ) ->
          { model | items = model.items ++ [ item ], draggedItem = Nothing } ! [ Cmd.none ]

        Nothing ->
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
      case model.draggedItem of
        Just ( item, dragStarted, draggedTo ) ->
          model.items ++ [ item ]

        Nothing ->
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
              , div [ style [ "position" => "relative", "width" => "100%" ] ]
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
    topLeft =
      item.topLeft

    inlineStyles =
      [ "position" => "absolute"
      , "left" => px topLeft.x
      , "top" => px topLeft.y
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
