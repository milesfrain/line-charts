module Docs.Dots.Example4 exposing (main)

import Browser
import Html
import Html.Attributes exposing (class)
import LineChart
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Colors as Colors
import LineChart.Container as Container
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk
import LineChart.Legends as Legends
import LineChart.Line as Line


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { hovering : Maybe Data }


init : Model
init =
    { hovering = Nothing }



-- UPDATE


type Msg
    = Hover (Maybe Data)


update : Msg -> Model -> Model
update msg model =
    case msg of
        Hover hovering ->
            { model | hovering = hovering }



-- VIEW


view : Model -> Html.Html Msg
view model =
    Html.div
        [ class "container" ]
        [ chart model ]


chart : Model -> Html.Html Msg
chart model =
    LineChart.viewCustom
        { y = Axis.default 450 "Weight" .weight
        , x = Axis.default 700 "Age" .age
        , container = Container.default "line-chart-1"
        , interpolation = Interpolation.default
        , intersection = Intersection.default
        , legends = Legends.default
        , events = Events.hoverOne Hover
        , junk = Junk.default
        , grid = Grid.default
        , area = Area.default
        , line = Line.default
        , dots = customDotsConfig
        }
        [ LineChart.line Colors.pink Dots.triangle "Chuck" chuck
        , LineChart.line Colors.cyan Dots.circle "Bobby" bobby
        , LineChart.line Colors.purple Dots.diamond "Alice" alice
        ]


customDotsConfig : Dots.Config Data
customDotsConfig =
    let
        styleLegend _ =
            Dots.full 7

        styleIndividual datum =
            Dots.full <| (datum.height - 1) * 12
    in
    Dots.customAny
        { legend = styleLegend
        , individual = styleIndividual
        }



-- DATA


type alias Data =
    { age : Float
    , weight : Float
    , height : Float
    , income : Float
    }


alice : List Data
alice =
    [ Data 10 34 1.34 0
    , Data 16 42 1.62 3000
    , Data 25 73 1.73 25000
    , Data 43 83 1.75 40000
    ]


bobby : List Data
bobby =
    [ Data 10 38 1.32 0
    , Data 17 69 1.75 2000
    , Data 25 78 1.87 32000
    , Data 43 77 1.87 52000
    ]


chuck : List Data
chuck =
    [ Data 10 42 1.35 0
    , Data 15 72 1.72 1800
    , Data 25 89 1.83 85000
    , Data 43 95 1.84 120000
    ]
