module FlakerInfo exposing (FlakerInfo, createFlakerTable, viewFlakerInfo, viewFlakerInfoList)

import Duration
import Element exposing (..)
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

Currently only returns the time since last flake in seconds

-}
viewFlakerInfoElmUI : FlakerInfo -> Time.Posix -> Element a
viewFlakerInfoElmUI flakerInfo currentTime =
    let
        flakeDuration =
            Duration.from flakerInfo.lastFlakeTime currentTime

        cumulativeDurations =
            TimeUtil.cumulativeDurations flakeDuration
    in
    Element.el
        []
        (Duration.inSeconds flakeDuration
            |> floor
            |> String.fromInt
            |> Element.text
        )


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
            [ { header = Element.text "Flaker Name"
              , width = fill
              , view =
                    \flaker ->
                        Element.text flaker.name
              }
            , { header = Element.text "Time Since Last Flaked"
              , width = fill
              , view =
                    flip viewFlakerInfoElmUI
                        currentTime
              }
            ]
        }
