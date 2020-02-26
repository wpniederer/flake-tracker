-- Show how many hours have passed since the last time Jack has flaked.


module Main exposing (main)

import Browser
import FlakerInfo exposing (FlakerInfo)
import Html exposing (..)
import Html.Attributes exposing (..)
import List
import String
import Task
import Time



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
    , flakerInfos : List FlakerInfo
    }


type alias LoadedModel =
    { currentTime : Time.Posix
    , flakerInfos : List FlakerInfo
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model
        Nothing
        [ { name = "Jack Pfieffer", lastFlakeTime = Time.millisToPosix 1578254400000 }
        , { name = "Jason Kim", lastFlakeTime = Time.millisToPosix 1582270200000 }
        ]
    , Cmd.none
    )



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
            viewLoadedModel (LoadedModel currentTime model.flakerInfos)


{-| View a LoadedModel.
-}
viewLoadedModel : LoadedModel -> Html a
viewLoadedModel loadedModel =
    FlakerInfo.viewFlakerInfoList loadedModel.flakerInfos loadedModel.currentTime
