module FlakerInfo exposing (FlakerInfo, createFlakerTable, viewFlakerInfo, viewFlakerInfoList)

import Duration
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html exposing (..)
import Html.Attributes exposing (..)
import List
import String
import Time
import TimeUtil


{-| All the information needed to keep track of a flaker.
-}
type alias FlakerInfo =
    { name : String
    , lastFlakeTime : Time.Posix
    }


{-| Returns a unit of time with its respective value

        displayTimeComponent ( 33, "minute" ) == "33 minutes"

-}
displayTimeComponent : ( Int, String ) -> String
displayTimeComponent ( rawTime, timePart ) =
    if rawTime == 1 then
        String.fromInt rawTime ++ " " ++ timePart

    else
        String.fromInt rawTime ++ " " ++ timePart ++ "s"


{-| Returns a detailed view of FlakerInfo for the given time.
-}
viewFlakerInfo : FlakerInfo -> Time.Posix -> Html a
viewFlakerInfo flakerInfo currentTime =
    let
        flakeDuration =
            Duration.from flakerInfo.lastFlakeTime currentTime

        cumulativeDurations =
            TimeUtil.cumulativeDurations flakeDuration
    in
    div
        []
        [ h1 [] [ Html.text <| "Time since " ++ flakerInfo.name ++ " last flaked:" ]
        , h1 [] [ Html.text <| displayTimeComponent ( cumulativeDurations.weeks, "week" ) ]
        , h1 [] [ Html.text <| displayTimeComponent ( cumulativeDurations.days, "day" ) ]
        , h1 [] [ Html.text <| displayTimeComponent ( cumulativeDurations.hours, "hour" ) ]
        , h1 [] [ Html.text <| displayTimeComponent ( cumulativeDurations.minutes, "minute" ) ]
        , h1 [] [ Html.text <| displayTimeComponent ( cumulativeDurations.seconds, "second" ) ]
        ]


{-| Returns a detailed view of FlakerInfo for the given time, using elm-ui components.
-}
viewFlakerInfoElmUI : FlakerInfo -> Time.Posix -> Element a
viewFlakerInfoElmUI flakerInfo currentTime =
    let
        flakeDuration =
            Duration.from flakerInfo.lastFlakeTime currentTime

        cumulativeDurations =
            TimeUtil.cumulativeDurations flakeDuration
    in
    Element.column
        [ paddingXY 5 2
        , Element.width fill
        , Border.widthEach { bottom = 1, top = 0, left = 1, right = 1 }
        , spacingXY 0 2
        ]
        [ Element.el [] (Element.text <| displayTimeComponent ( cumulativeDurations.weeks, "week" ))
        , Element.el [] (Element.text <| displayTimeComponent ( cumulativeDurations.days, "day" ))
        , Element.el [] (Element.text <| displayTimeComponent ( cumulativeDurations.hours, "hour" ))
        , Element.el [] (Element.text <| displayTimeComponent ( cumulativeDurations.minutes, "minute" ))
        , Element.el [] (Element.text <| displayTimeComponent ( cumulativeDurations.seconds, "second" ))
        ]


{-| Flips the first two arguments of a function.
-}
flip : (a -> b -> c) -> b -> a -> c
flip f y x =
    f x y


{-| Returns a detailed view of the List FlakerInfo for the given time.
-}
viewFlakerInfoList : List FlakerInfo -> Time.Posix -> Html a
viewFlakerInfoList flakerInfos currentTime =
    ul
        []
        (List.map
            (li [] << List.singleton << flip viewFlakerInfo currentTime)
            flakerInfos
        )


{-| Returns a table view of the List FlakerInfo for the given time.
-}
createFlakerTable : List FlakerInfo -> Time.Posix -> Element msg
createFlakerTable flakerInfos currentTime =
    Element.table
        []
        { data = flakerInfos
        , columns =
            [ { header =
                    Element.el
                        [ Font.bold
                        , paddingXY 5 5
                        , rgb255 92 99 118 |> Background.color
                        , rgb255 255 255 2555 |> Font.color
                        ]
                        (Element.text "Flaker Name")
              , width = fill
              , view =
                    \flaker ->
                        Element.el
                            [ rgb255 20 20 20 |> Border.color
                            , paddingXY 5 5
                            , Element.height (px 113)
                            , Border.widthEach { bottom = 1, top = 0, left = 1, right = 0 }
                            ]
                            (Element.text flaker.name)
              }
            , { header =
                    Element.el
                        [ Font.bold
                        , paddingXY 5 5
                        , rgb255 255 99 118 |> Background.color
                        , rgb255 255 255 2555 |> Font.color
                        ]
                        (Element.text "Time Since Last Flaked")
              , width = fill
              , view =
                    flip viewFlakerInfoElmUI
                        currentTime
              }
            ]
        }
