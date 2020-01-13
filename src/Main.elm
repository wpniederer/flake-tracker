-- Show how many hours have passed since the last time Jack has flaked.


module Main exposing (LoadedModel, Model, Msg(..), init, main, showLoadedModel, subscriptions, update, view)

import Browser
import Duration exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import String
import Task
import Time exposing (..)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { maybeCurrentTime : Maybe Time.Posix
    , lastFlakeTime : Time.Posix
    }


type alias LoadedModel =
    { currentTime : Time.Posix
    , lastFlakeTime : Time.Posix
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Nothing (millisToPosix 1578254400000), Cmd.none )



-- UPDATE


type Msg
    = Tick Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | maybeCurrentTime = Just newTime }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- VIEW


loadingMessage : Html a
loadingMessage =
    h1 [] [ text "Loading..." ]


view : Model -> Html Msg
view model =
    case model.maybeCurrentTime of
        Nothing ->
            loadingMessage

        Just currentTime ->
            showLoadedModel (LoadedModel currentTime model.lastFlakeTime)


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


{-| Returns a unit of time with its respective value

        displayTimeComponent ( 33, "minutes" ) == "33 minutes"

-}
displayTimeComponent : ( Int, String ) -> String
displayTimeComponent ( rawTime, timePart ) =
    String.fromInt rawTime ++ " " ++ timePart


showLoadedModel : LoadedModel -> Html a
showLoadedModel loadedModel =
    let
        flakeDuration =
            from loadedModel.lastFlakeTime loadedModel.currentTime

        ( weeksSince, leftoverWeeks ) =
            flakeDuration
                |> inWeeks
                |> wholeAndFractional

        ( dayz, leftoverDays ) =
            leftoverWeeks
                |> weeks
                |> inDays
                |> wholeAndFractional

        ( hourz, leftoverHours ) =
            leftoverDays
                |> days
                |> inHours
                |> wholeAndFractional

        ( minutez, leftoverMinutes ) =
            leftoverHours
                |> hours
                |> inMinutes
                |> wholeAndFractional

        ( secondz, _ ) =
            leftoverMinutes
                |> minutes
                |> inSeconds
                |> wholeAndFractional
    in
    div
        []
        [ h1 [] [ text "Time since Jack last flaked:" ]
        , h1 [] [ text (displayTimeComponent ( weeksSince, "weeks" )) ]
        , h1 [] [ text (displayTimeComponent ( dayz, "days" )) ]
        , h1 [] [ text (displayTimeComponent ( hourz, "hours" )) ]
        , h1 [] [ text (displayTimeComponent ( minutez, "minutes" )) ]
        , h1 [] [ text (displayTimeComponent ( secondz, "seconds" )) ]
        ]
