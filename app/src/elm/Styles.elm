module Styles exposing (..)

import Css exposing (..)
import Css.Elements exposing (body, li, fieldset, legend)
import Css.Namespace exposing (namespace)


type Class
  = Container
  | Group
  | Title


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
                        , property "user-select" "none"
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
                , property "user-select" "none"
                ]
            ]
        ]
    ]



-- TODO: how to port .item { &.dragged {} }?
-- TODO: form-control from Bootstrap


lightGray : Color
lightGray =
  hex "#d3d3d3"


darkGray : Color
darkGray =
  hex "a9a9a9"


white : Color
white =
  hex "#fff"
