module LineChart.Dots exposing
  ( Shape, none
  , circle, triangle, square, diamond, plus, cross
  , Config, default, custom, customAny, hoverOne, hoverMany
  , Style, empty, disconnected, aura, full
  )

{-|

# Shapes
@docs Shape

## Selection
Hopefully, these are selfexplanatory.
<img alt="Legends" width="610" style="margin-top: 10px; margin-left: -10px" src="https://github.com/terezka/lines/blob/master/images/shapes.png?raw=true"></src>

@docs none, circle, triangle, square, diamond, plus, cross

# Styles
@docs Config, default

## Hover styles
@docs hoverOne, hoverMany

## Customization
@docs custom, customAny

### Selection
@docs Style, full, empty, disconnected, aura


-}

import Internal.Dots as Dots



-- QUICK START


{-|

**Change the shape of your dots**

The shape type changes the shape of your dots.

    humanChart : Html msg
    humanChart =
      LineChart.view .age .income
        [ LineChart.line Colors.gold Dots.circle  "Alice" alice
        --                           ^^^^^^^^^^^
        , LineChart.line Colors.blue Dots.square  "Bobby" bobby
        --                           ^^^^^^^^^^^
        , LineChart.line Colors.pink Dots.diamond "Chuck" chuck
        --                           ^^^^^^^^^^^^
        ]

_See full example [here](https://ellie-app.com/9mFnMYLnba1/1)._


**What is a dot?**

Dots denote where your data points are on your line.
They can be different shapes (circle, square, etc.) for each line.

-}
type alias Shape =
  Dots.Shape


{-| -}
none : Shape
none =
  Dots.None


{-| -}
circle : Shape
circle =
  Dots.Circle


{-| -}
triangle : Shape
triangle =
  Dots.Triangle


{-| -}
square : Shape
square =
  Dots.Square


{-| -}
diamond : Shape
diamond =
  Dots.Diamond


{-| -}
plus : Shape
plus =
  Dots.Plus


{-| -}
cross : Shape
cross =
  Dots.Cross


{-|

**Change the style of your dots**

Use in the `LineChart.Config` passed to `LineChart.viewCustom`.

    chartConfig : LineChart.Config Data Msg
    chartConfig =
      { ...
      , dots = Dots.default
      , ...
      }


**What is a dot style?**

The style of the dot includes the size of the dot and various other qualities
like whether it has a border or not. See your options under _Styles_.

-}
type alias Config data =
  Dots.Config data


{-| Draws a white outline around all your dots.
-}
default : Config data
default =
  Dots.default



-- CONFIG


{-| Change the style of _all_ your dots.

    dotsConfig : Dots.Config data
    dotsConfig =
      Dots.custom (Dots.full 5)

-}
custom : Style -> Config data
custom =
  Dots.custom


{-| Change the style of _any_ of your dots. Particularly useful
for hover states, but it can also be used for creating another dimension for
your chart by varying the size of your dots based on some property.


**Extra dimension example**

    customConfig : Dots.Config Info
    customConfig =
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

_See full example [here](https://ellie-app.com/bX2JmhZ6qa1/1)._


**Hover state example**

    customConfig : Maybe Info -> Dots.Config Info
    customConfig maybeHovered =
      let
        styleLegend _ =
          Dots.disconnected 10 2

        styleIndividual datum =
          if Just datum == maybeHovered
            then Dots.aura 7 6 0.4
            else Dots.disconnected 10 2
      in
      Dots.customAny
        { legend = styleLegend
        , individual = styleIndividual
        }

_See full example [here](https://ellie-app.com/9n8tBnxV5a1/1)._


-}
customAny :
  { legend : List data -> Style
  , individual : data -> Style
  }
  -> Config data
customAny =
  Dots.customAny


{-| Adds a hover effect on the given dot!

    dotsConfig : Maybe Data -> Dots.Config Info
    dotsConfig hovered =
      Dots.hoverOne hovered

_See full example [here](https://ellie-app.com/9psJRRS2ja1/1)._

-}
hoverOne : Maybe data -> Config data
hoverOne maybeHovered =
  let
    styleLegend _ =
      disconnected 10 2

    styleIndividual datum =
      if Just datum == maybeHovered
        then aura 7 6 0.4
        else disconnected 10 2
  in
  Dots.customAny
    { legend = styleLegend
    , individual = styleIndividual
    }


{-| Adds a hover effect on several given dots!

    dotsConfig : List Data -> Dots.Config Info
    dotsConfig hovered =
      Dots.hoverMany hovered

_See full example [here](https://ellie-app.com/bCrgZfVKVa1/1)._

-}
hoverMany : List data -> Config data
hoverMany hovered =
  let
    styleLegend _ =
      disconnected 10 2

    styleIndividual datum =
      if List.any ((==) datum) hovered
        then aura 7 6 0.4
        else disconnected 10 2
  in
  Dots.customAny
    { legend = styleLegend
    , individual = styleIndividual
    }



-- STYLES


{-| -}
type alias Style =
  Dots.Style


{-| Makes dots plain and solid.

Pass the radius.

<img alt="Legends" width="540" src="https://github.com/terezka/lines/blob/master/images/dots1.png?raw=true"></src>


-}
full : Float -> Style
full =
  Dots.full


{-| Makes dots with a white core and a colored border.

Pass the radius and the width of the border.

<img alt="Legends" width="540" src="https://github.com/terezka/lines/blob/master/images/dots3.png?raw=true"></src>

-}
empty : Float -> Int -> Style
empty =
  Dots.empty


{-| Makes dots with a colored core and a white border.

Pass the radius and the width of the border.

<img alt="Legends" width="540" src="https://github.com/terezka/lines/blob/master/images/dots4.png?raw=true"></src>

-}
disconnected : Float -> Int -> Style
disconnected =
  Dots.disconnected


{-| Makes dots with a colored core and a less colored, transparent "aura".

Pass the radius, the width of the aura, and the opacity of the
aura (A number between 0 and 1).

<img alt="Legends" width="540" src="https://github.com/terezka/lines/blob/master/images/dots2.png?raw=true"></src>


-}
aura : Float -> Int -> Float -> Style
aura =
  Dots.aura
