module Styles exposing (..)

import Css exposing (..)
import Css.Elements exposing (body, li, fieldset, legend)
import Css.Namespace exposing (namespace)


type Class
  = Container
  | Group
  | Title
  | Item
  | Dragged


css : Stylesheet
css =
  (stylesheet)
    [ body
        [ margin2 (px 20) zero
        , backgroundColor (hex "#f3f5f6")
        ]
    , (.) Container
        [ marginTop (px 15)
        , width (px 600)
        , children
            [ fieldset
                [ borderLeft zero
                , borderRight zero
                , borderBottom zero
                , borderTop3 (px 1) solid lightGray
                , width (pct 100)
                , children
                    [ legend
                        [ textTransform uppercase
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
            [ (.) Title
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
    ]



-- TODO: form-control from Bootstrap
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



--transition3 :


zIndex : Int -> Mixin
zIndex i =
  property "z-index" (toString i)
