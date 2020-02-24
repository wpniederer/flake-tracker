module TimeUtil exposing (CumulativeDurations, cumulativeDurations)

import Duration
import Time


{-| Returns the floor of the input value and the input value minus its floor.
Precondition: input value must be positive.

    wholeAndFractional 1.5 == (1, .5)

-}
wholeAndFractional : Float -> ( Int, Float )
wholeAndFractional value =
    let
        floored =
            floor value
    in
    ( floored, value - toFloat floored )


{-| A fine-grained representation of a duration, broken down into incremental
durations starting at weeks and ending at seconds.
days < 7
hours < 24
minutes < 60
seconds < 60

A CumulativeDurations value of

    { weeks = 1
    , days = 1
    , hours = 1
    , minutes = 1
    , seconds = 1
    }

represents an toal duration of 694,861 seconds.

-}
type alias CumulativeDurations =
    { weeks : Int
    , days : Int
    , hours : Int
    , minutes : Int
    , seconds : Int
    }


{-| Breaks a duration into CumulativeDurations.
-}
cumulativeDurations : Duration.Duration -> CumulativeDurations
cumulativeDurations duration =
    let
        ( weeks, leftoverWeeks ) =
            duration
                |> Duration.inWeeks
                |> wholeAndFractional

        ( days, leftoverDays ) =
            leftoverWeeks
                |> Duration.weeks
                |> Duration.inDays
                |> wholeAndFractional

        ( hours, leftoverHours ) =
            leftoverDays
                |> Duration.days
                |> Duration.inHours
                |> wholeAndFractional

        ( minutes, leftoverMinutes ) =
            leftoverHours
                |> Duration.hours
                |> Duration.inMinutes
                |> wholeAndFractional

        ( seconds, _ ) =
            leftoverMinutes
                |> Duration.minutes
                |> Duration.inSeconds
                |> wholeAndFractional
    in
    { weeks = weeks, days = days, hours = hours, minutes = minutes, seconds = seconds }
