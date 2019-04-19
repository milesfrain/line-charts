module Selection2 exposing (main)

import Html
import Html.Attributes
import LineChart
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis.Line as AxisLine
import LineChart.Axis.Range as Range
import LineChart.Axis.Ticks as Ticks
import LineChart.Axis.Title as Title
import LineChart.Colors as Colors
import LineChart.Container as Container
import LineChart.Coordinate as Coordinate
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk
import LineChart.Legends as Legends
import LineChart.Line as Line
import Random
import Svg
import Svg.Attributes


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }



-- MODEL


type alias Model =
    { data : Data
    , hovered : Maybe Float
    , selection : Maybe Selection
    , dragging : Bool
    , hinted : Maybe Coordinate.Point
    }


type alias Selection =
    { start : Float
    , end : Float
    }


type alias Data =
    { alice : List Coordinate.Point
    , bobby : List Coordinate.Point
    , chuck : List Coordinate.Point
    }



-- INIT


init : ( Model, Cmd Msg )
init =
    ( { data = Data [] [] []
      , hovered = Nothing
      , selection = Nothing
      , dragging = False
      , hinted = Nothing
      }
    , getNumbers
    )


getNumbers : Cmd Msg
getNumbers =
    let
        genNumbers =
            Random.list 200 (Random.float 0 20)
    in
    Random.map3 (,,) genNumbers genNumbers genNumbers
        |> Random.generate RecieveNumbers



-- API


setData : ( List Float, List Float, List Float ) -> Model -> Model
setData ( n1, n2, n3 ) model =
    { model | data = Data (toData n1) (toData n2) (toData n3) }


toData : List Float -> List Coordinate.Point
toData numbers =
    List.indexedMap (\i -> Coordinate.Point (toFloat i)) numbers


setSelection : Maybe Selection -> Model -> Model
setSelection selection model =
    { model | selection = selection }


setDragging : Bool -> Model -> Model
setDragging dragging model =
    { model | dragging = dragging }


setHovered : Maybe Float -> Model -> Model
setHovered hovered model =
    { model | hovered = hovered }


setHint : Maybe Coordinate.Point -> Model -> Model
setHint hinted model =
    { model | hinted = hinted }


getSelectionStart : Float -> Model -> Float
getSelectionStart hovered model =
    case model.selection of
        Just selection ->
            selection.start

        Nothing ->
            hovered



-- UPDATE


type Msg
    = RecieveNumbers ( List Float, List Float, List Float )
      -- Chart 1
    | Hold Coordinate.Point
    | Move Coordinate.Point
    | Drop Coordinate.Point
    | LeaveChart Coordinate.Point
    | LeaveContainer Coordinate.Point
      -- Chart 2
    | Hint (Maybe Coordinate.Point)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RecieveNumbers numbers ->
            model
                |> setData numbers
                |> addCmd Cmd.none

        Hold point ->
            model
                |> setSelection Nothing
                |> setDragging True
                |> addCmd Cmd.none

        Move point ->
            if model.dragging then
                let
                    start =
                        getSelectionStart point.x model

                    newSelection =
                        Selection start point.x
                in
                model
                    |> setSelection (Just newSelection)
                    |> setHovered (Just point.x)
                    |> addCmd Cmd.none

            else
                model
                    |> setHovered (Just point.x)
                    |> addCmd Cmd.none

        Drop point ->
            if point.x == getSelectionStart point.x model then
                model
                    |> setSelection Nothing
                    |> setDragging False
                    |> addCmd Cmd.none

            else
                model
                    |> setDragging False
                    |> addCmd Cmd.none

        LeaveChart point ->
            model
                |> setHovered Nothing
                |> addCmd Cmd.none

        LeaveContainer point ->
            model
                |> setDragging False
                |> setHovered Nothing
                |> addCmd Cmd.none

        Hint point ->
            model
                |> setHint point
                |> addCmd Cmd.none


addCmd : Cmd Msg -> Model -> ( Model, Cmd Msg )
addCmd cmd model =
    ( model, Cmd.none )



-- VIEW


view : Model -> Html.Html Msg
view model =
    Html.div [ Html.Attributes.style [ ( "display", "flex" ) ] ] <|
        case model.selection of
            Nothing ->
                [ chart model ]

            Just selection ->
                [ chart model
                , chartZoom model selection
                ]



-- MAIN CHART


chart : Model -> Html.Html Msg
chart model =
    viewChart model.data
        { range = Range.default
        , junk = junkConfig model
        , legends = Legends.default
        , events =
            Events.custom
                [ Events.onWithOptions "mousedown" (Events.Options True True False) Hold Events.getData
                , Events.onWithOptions "mousemove" (Events.Options True True False) Move Events.getData
                , Events.onWithOptions "mouseup" (Events.Options True True True) Drop Events.getData
                , Events.onWithOptions "mouseleave" (Events.Options True True False) LeaveChart Events.getData
                , Events.onWithOptions "mouseleave" (Events.Options True True True) LeaveContainer Events.getData
                ]
        , dots = Dots.custom (Dots.full 0)
        , id = "line-chart"
        }


junkConfig : Model -> Junk.Config Coordinate.Point msg
junkConfig model =
    Junk.custom <|
        \system ->
            { below = below system model.selection
            , above = above system model.hovered
            , html = []
            }


below : Coordinate.System -> Maybe Selection -> List (Svg.Svg msg)
below system selection =
    case selection of
        Just { start, end } ->
            [ Junk.rectangle system
                [ Svg.Attributes.fill "#b6b6b61a" ]
                start
                end
                system.y.min
                system.y.max
            ]

        Nothing ->
            []


above : Coordinate.System -> Maybe Float -> List (Svg.Svg msg)
above system hovered =
    case hovered of
        Just hovered ->
            [ Junk.vertical system [] hovered ]

        Nothing ->
            []



-- ZOOM CHART


chartZoom : Model -> Selection -> Html.Html Msg
chartZoom model selection =
    viewChart model.data
        { range = xAxisRangeConfig selection
        , junk =
            Junk.hoverOne model.hinted
                [ ( "x", toString << round100 << .x )
                , ( "y", toString << round100 << .y )
                ]
        , events = Events.hoverOne Hint
        , legends = Legends.none
        , dots = Dots.hoverOne model.hinted
        , id = "line-chart-zoom"
        }


xAxisRangeConfig : Selection -> Range.Config
xAxisRangeConfig selection =
    let
        start =
            min selection.start selection.end

        end =
            if selection.start == selection.end then
                selection.start + 1

            else
                max selection.start selection.end
    in
    Range.window start end



-- VIEW CHART


type alias Config =
    { range : Range.Config
    , junk : Junk.Config Coordinate.Point Msg
    , events : Events.Config Coordinate.Point Msg
    , legends : Legends.Config Coordinate.Point Msg
    , dots : Dots.Config Coordinate.Point
    , id : String
    }


viewChart : Data -> Config -> Html.Html Msg
viewChart data { range, junk, events, legends, dots, id } =
    LineChart.viewCustom
        { y = Axis.default 450 "y" .y
        , x =
            Axis.custom
                { title = Title.default "x"
                , variable = Just << .x
                , pixels = 700
                , range = range
                , axisLine = AxisLine.rangeFrame Colors.gray
                , ticks = Ticks.float 5
                }
        , container =
            Container.custom
                { attributesHtml = [ Html.Attributes.style [ ( "font-family", "monospace" ) ] ]
                , attributesSvg = []
                , size = Container.static
                , margin = Container.Margin 30 100 60 50
                , id = "chart-id"
                }
        , interpolation = Interpolation.monotone
        , intersection = Intersection.default
        , legends = legends
        , events = events
        , junk = junk
        , grid = Grid.default
        , area = Area.default
        , line = Line.default
        , dots = dots
        }
        [ LineChart.line Colors.pink Dots.circle "Alice" data.alice
        , LineChart.line Colors.cyan Dots.circle "Bobby" data.bobby
        , LineChart.line Colors.blue Dots.circle "Chuck" data.chuck
        ]



-- UTILS


round100 : Float -> Float
round100 float =
    toFloat (round (float * 100)) / 100
