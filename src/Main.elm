-- Show how many hours have passed since the last time Jack has flaked.


module Main exposing (LoadedModel, Model, Msg(..), init, main, showLoadedModel, subscriptions, update, view)

import Browser
import Duration exposing (from, inSeconds)
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


init : Model
init =
    Model Nothing (millisToPosix 1578254400000)



-- UPDATE


type Msg
    = Tick Time.Posix


update : Msg -> Model -> Model
update msg model =
    case msg of
        Tick newTime ->
            { model | maybeCurrentTime = Just newTime }



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


showLoadedModel : LoadedModel -> Html a
showLoadedModel loadedModel =
    let
        flakeDuration =
            from loadedModel.lastFlakeTime loadedModel.currentTime

        secondsSince =
            flakeDuration
                |> inSeconds
                |> round
                |> String.fromInt
    in
    div
        []
        [ h1 [] [ text "Seconds since Jack's last flaked:" ]
        , h1 [] [ text secondsSince ]
        ]
