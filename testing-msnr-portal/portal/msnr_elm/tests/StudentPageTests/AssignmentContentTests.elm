module StudentPageTests.AssignmentContentTests exposing (..)

import Expect exposing (Expectation, err)
import Fuzz exposing (Fuzzer, string, bool)
import Test exposing (..)
import FuzzerHelper exposing (listOfAssignmentsFuzzer)
import StudentPage.AssignmentContent exposing (Msg(..))
import StudentPage.Model as SPM
import StudentPage.AssignmentContent.Model as ACM
import ActivityType as AT
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, tag, text, containing)
import Test.Html.Event as Event
import Accessibility.Styled as Html exposing (Html)
import Html.Attributes as Attributes
import Array
import Session exposing (Token)
import Time
import RegistrationPage exposing (Msg(..))

someTest = 
    test "some test" <|
    \_ -> Expect.pass