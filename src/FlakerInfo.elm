module FlakerInfo exposing (FlakerInfo)

import String
import Time


{-| All the information needed to keep track of a flaker.
-}
type alias FlakerInfo =
    { name : String
    , lastFlakeTime : Time.Posix
    }
