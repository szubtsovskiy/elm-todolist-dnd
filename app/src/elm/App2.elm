module App2 exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, on, keyCode)
import Html.Keyed as Keyed
import Json.Decode as Json
import Mouse exposing (Position)
import String
import Html.CssHelpers as CssHelpers
import Styles


main : Program Never Model Msg
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


type alias ID =
  Int


type alias Item =
  { dragged : Bool
  , id : ID
  , title : String
  }


type alias Model =
  { items : List Item
  , newItemTitle : String
  }


type Msg
  = SetNewItemTitle String
  | KeyDown Int
  | DragStart ID
  | DragOver ID


init : ( Model, Cmd Msg )
init =
  let
    items =
      [ "First", "Second", "Third", "Fourth", "Fifth" ]
        |> List.indexedMap (Item False)

    model =
      { items = items
      , newItemTitle = ""
      }
  in
    model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    SetNewItemTitle value ->
      { model | newItemTitle = value } ! []

    KeyDown code ->
      case code of
        13 ->
          if String.length model.newItemTitle > 0 then
            let
              itemCount =
                List.length model.items

              newItem =
                Item False itemCount model.newItemTitle
            in
              { model | newItemTitle = "", items = model.items ++ [ newItem ] } ! []
          else
            model ! []

        27 ->
          { model | newItemTitle = "" } ! []

        _ ->
          model ! []

    DragStart id ->
      let
        markDragged item =
          if item.id == id then
            { item | dragged = True }
          else
            item
      in
        { model | items = List.map markDragged model.items } ! []

    DragOver id ->
      let
        target =
          List.filter (\item -> item.id == id) model.items
            |> List.head

        dragged =
          List.filter (\item -> item.dragged) model.items
            |> List.head

        items =
          case ( target, dragged ) of
            ( Just target, Just dragged ) ->
              let
                f item acc =
                  if item.id == target.id then
                    acc ++ [ dragged ]
                  else if item.id == dragged.id then
                    acc ++ [ target ]
                  else
                    acc ++ [ item ]
              in
                List.foldl f [] model.items

            _ ->
              model.items
      in
        { model | items = items } ! []



-- VIEW


{ id, class, classList } =
  CssHelpers.withNamespace ""


(=>) : a -> b -> ( a, b )
(=>) =
  (,)


view : Model -> Html Msg
view model =
  let
    items =
      List.map todo model.items
  in
    div [ class [ Styles.Container ] ]
      [ div [ class [ Styles.ContentWrapper ] ]
          [ fieldset []
              [ legend [] [ text "Week 47" ]
              , input
                  [ type_ "text"
                  , class [ Styles.NewItemInput ]
                  , placeholder "To do..."
                  , onInput SetNewItemTitle
                  , onKeyDown KeyDown
                  , value model.newItemTitle
                  ]
                  []
              , div [ class [ Styles.Group ] ]
                  [ groupTitle model
                  , Keyed.node "div" [ style [ "position" => "relative", "width" => "100%" ] ] items
                  ]
              ]
          ]
      ]


groupTitle : Model -> Html Msg
groupTitle model =
  div [ class [ Styles.GroupTitle ] ] [ text "Monday" ]


todo : Item -> ( String, Html Msg )
todo item =
  let
    inlineStyles =
      [ "height" => "40px"
      , "margin-bottom" => "2px"
      ]

    classes =
      [ Styles.Item => True
      , Styles.Dragged => item.dragged
      ]
  in
    ( toString item.id
    , div [ dataItemId item.id, classList classes, style inlineStyles, draggable "true", onDragStart item.id, onDragOver item.id ]
        [ span [] [ text item.title ]
        ]
    )


onKeyDown : (Int -> action) -> Attribute action
onKeyDown tagger =
  on "keydown" (Json.map tagger keyCode)


onDragStart : ID -> Attribute Msg
onDragStart id =
  on "dragstart" (Json.succeed (DragStart id))


onDragOver : ID -> Attribute Msg
onDragOver id =
  on "dragover" (Json.succeed (DragOver id))


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
