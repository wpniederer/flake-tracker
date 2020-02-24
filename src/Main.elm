-- Show how many hours have passed since the last time Jack has flaked.


module Main exposing (LoadedModel, Model, Msg(..), init, main, showLoadedModel, subscriptions, update, view)

import Browser
import Duration
import FlakerInfo exposing (FlakerInfo)
import Html exposing (..)
import Html.Attributes exposing (..)
import String
import Task
import Time
import TimeUtil



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
    , flakerInfo : FlakerInfo
    }


type alias LoadedModel =
    { currentTime : Time.Posix
    , flakerInfo : FlakerInfo
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Nothing { name = "Jack Pfieffer", lastFlakeTime = Time.millisToPosix 1578254400000 }, Cmd.none )



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
            showLoadedModel (LoadedModel currentTime model.flakerInfo)


{-| Returns a unit of time with its respective value

        displayTimeComponent ( 33, "minute" ) == "33 minutes"

-}
displayTimeComponent : ( Int, String ) -> String
displayTimeComponent ( rawTime, timePart ) =
    if rawTime == 1 then
        String.fromInt rawTime ++ " " ++ timePart

    else
        String.fromInt rawTime ++ " " ++ timePart ++ "s"


showLoadedModel : LoadedModel -> Html a
showLoadedModel loadedModel =
    let
        flakeDuration =
            Duration.from loadedModel.flakerInfo.lastFlakeTime loadedModel.currentTime

        cumulativeDurations =
            TimeUtil.cumulativeDurations flakeDuration
    in
    div
        []
        [ h1 [] [ text <| "Time since " ++ loadedModel.flakerInfo.name ++ " last flaked:" ]
        , h1 [] [ text <| displayTimeComponent ( cumulativeDurations.weeks, "week" ) ]
        , h1 [] [ text <| displayTimeComponent ( cumulativeDurations.days, "day" ) ]
        , h1 [] [ text <| displayTimeComponent ( cumulativeDurations.hours, "hour" ) ]
        , h1 [] [ text <| displayTimeComponent ( cumulativeDurations.minutes, "minute" ) ]
        , h1 [] [ text <| displayTimeComponent ( cumulativeDurations.seconds, "second" ) ]
        ]
