module Styles exposing (..)

import Css exposing (..)
import Css.Elements exposing (body, li, fieldset, legend)


type Class
  = Container
  | ContentWrapper
  | Group
  | GroupTitle
  | Item
  | Dragged
  | NewItemInput


css : Stylesheet
css =
  stylesheet
    [ everything
        [ boxSizing borderBox
        , before [ boxSizing borderBox ]
        , after [ boxSizing borderBox ]
        ]
    , body
        [ margin2 (px 20) zero
        , backgroundColor (hex "#f3f5f6")
        , fontSize (px 14)
        , fontFamilies [ "Helvetica Neue", "Helvetica", "Arial", "sans-serif" ]
        ]
    , (.) Container
        [ displayFlex
        , property "justify-content" "center"
        ]
    , (.) ContentWrapper
        [ marginTop (px 15)
        , width (px 600)
        , children
            [ fieldset
                [ padding zero
                , margin zero
                , border zero
                , borderTop3 (px 1) solid lightGray
                , width (pct 100)
                , children
                    [ legend
                        [ display block
                        , width (pct 100)
                        , padding zero
                        , marginBottom (px 20)
                        , lineHeight inherit
                        , border zero
                        , borderBottom3 (px 1) solid (hex "#e5e5e5")
                        , textTransform uppercase
                        , textAlign center
                        , color lightGray
                        , fontSize (em 0.75)
                        , userSelect none
                        ]
                    ]
                ]
            ]
        ]
    , (.) Group
        [ margin2 (px 15) zero
        , width (pct 100)
        , children
            [ (.) GroupTitle
                [ backgroundColor darkGray
                , padding (px 5)
                , textTransform uppercase
                , fontWeight bold
                , color white
                , fontSize (em 0.75)
                , letterSpacing (em 0.1)
                , userSelect none
                ]
            ]
        ]
    , (.) Item
        [ backgroundColor white
        , borderBottom3 (px 1) solid lightGray
        , displayFlex
        , property "justify-content" "flex-start"
        , alignItems center
        , padding2 (px 5) (px 15)
        , width (pct 100)
        , cursor move
        , userSelect none
        , property "transition" "top 0.2s ease-out"
        , withClass Dragged
            [ zIndex 2
            , transition none
            ]
        ]
    , (.) NewItemInput
        [ display block
        , boxSizing borderBox
        , width (pct 100)
        , height (px 34)
        , padding2 (px 6) (px 12)
        , margin zero
        , fontSize (px 14)
        , lineHeight (num (20.0 / 14.0))
        , backgroundColor white
        , border3 (px 1) solid (hex "#ccc")
        , borderRadius (px 4)
        , boxShadow5 inset zero (px 1) (px 1) (rgba 0 0 0 0.075)
        , property "transition" "border-color .15s ease-in-out,box-shadow .15s ease-in-out"
        , color (hex "#555")
        ]
    ]



-- COLORS


lightGray : Color
lightGray =
  hex "#d3d3d3"


darkGray : Color
darkGray =
  hex "a9a9a9"


white : Color
white =
  hex "#fff"



-- PROPERTIES


type alias Value a =
  { a
    | value : String
  }


userSelect : Value a -> Mixin
userSelect arg =
  property "user-select" arg.value


transition : Value a -> Mixin
transition arg =
  property "transition" arg.value


zIndex : Int -> Mixin
zIndex i =
  property "z-index" (toString i)
