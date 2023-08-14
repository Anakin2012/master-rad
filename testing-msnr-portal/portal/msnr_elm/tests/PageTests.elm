module PageTests exposing (pageTests)
import Expect exposing (Expectation, err)
import Fuzz exposing (Fuzzer, string, bool)
import FuzzerHelper exposing (professorSubrouteFuzzer)
import Test exposing (..)
import Page exposing(..)
import Route
import LoginPage
import SetPasswordPage
import RegistrationPage
import StudentPage 
import ProfessorPage
import Html.Styled.Attributes exposing (for)


pageTests = 
    describe "For Route get Page" 
    [test "Get Home Page" <|
    \_ -> 
        forRoute Route.Home "api"
        |> Expect.equal HomePage,
    
    test "Get Login Page" <|
    \_ -> 
        forRoute Route.Login "api"
        |> Expect.equal (LoginPage (LoginPage.init "api")),

    test "Get SetPassword Page" <|
    \_ -> 
        forRoute (Route.SetPassword "uuid") "api" 
        |> Expect.equal (SetPasswordPage (SetPasswordPage.init "api" "uuid")),

    test "Get Registration Page" <|
    \_ -> 
        forRoute Route.Registration "api" 
        |> Expect.equal (RegistrationPage (RegistrationPage.init "api")),

    fuzz professorSubrouteFuzzer "Get Professor Page" <|
    \subroute -> 
        forRoute (Route.Professor subroute) "api"
        |> Expect.equal ProfessorPage,

    test "Get Student Page" <| 
    \_ -> 
        forRoute Route.Student "api" 
        |> Expect.equal StudentPage,

    test "Not found Page" <|
    \_ -> 
        forRoute Route.NotFound "api" 
        |> Expect.equal NotFoundPage

    ]

   