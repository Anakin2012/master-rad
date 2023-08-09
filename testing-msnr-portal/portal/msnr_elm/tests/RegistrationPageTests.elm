module RegistrationPageTests exposing (updateTests, viewTests)
import Expect exposing (Expectation, err)
import Fuzz exposing (Fuzzer, string, bool)
import Test exposing (..)
import FuzzerHelper exposing (httpErrorFuzzer)
import RegistrationPage exposing (FormState(..), Msg(..), Model)
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, tag, text, containing)
import Test.Html.Event as Event
import Accessibility.Styled as Html exposing (Html)
import Route exposing (Route(..))
import Html.Attributes as Attributes
import Result as Result exposing(..)
import Http exposing(..)

registrationModelFuzzer : Fuzzer Model
registrationModelFuzzer = 
    Fuzz.map7 Model 
        string 
        string 
        string 
        string 
        string 
        formStateFuzzer
        bool 

formStateFuzzer : Fuzzer FormState
formStateFuzzer = 
    Fuzz.oneOfValues
    [
        Init, 
        Loading,
        CreatedRequest "Uspešno ste podneli prijavu! 👍", 
        Error "Došlo je do neočekivane greške 😞"
    ]

updateTests = 
    describe "RegistrationPage update"
    [fuzz2 string registrationModelFuzzer "Email msg sets the email" <|
    \email model -> 
        model
        |> RegistrationPage.update (Email email)
        |> Tuple.first 
        |> .email 
        |> Expect.equal email,

    fuzz2 string registrationModelFuzzer "FirstName msg sets the first name" <|
    \firstName model -> 
        model
        |> RegistrationPage.update (FirstName firstName)
        |> Tuple.first 
        |> .firstName
        |> Expect.equal firstName,

    fuzz2 string registrationModelFuzzer "LastName msg sets the last name" <|
    \lastName model -> 
        model
        |> RegistrationPage.update (LastName lastName)
        |> Tuple.first 
        |> .lastName
        |> Expect.equal lastName,

    fuzz2 string registrationModelFuzzer "IndexNumber msg sets the index number" <|
    \indexNumber model -> 
        model
        |> RegistrationPage.update (IndexNumber indexNumber)
        |> Tuple.first 
        |> .indexNumber 
        |> Expect.equal indexNumber,
    
    fuzz registrationModelFuzzer "Dismiss msg sets the dismissedMsg" <|
    \model -> 
        model
        |> RegistrationPage.update Dissmis
        |> Tuple.first 
        |> .dismissedMsg 
        |> Expect.equal True,

    fuzz registrationModelFuzzer "SubmittedForm msg sets the state" <|
    \model ->
        model
        |> RegistrationPage.update SubmittedForm
        |> Tuple.first
        |> .state 
        |> Expect.equal Loading,

    fuzz2 httpErrorFuzzer registrationModelFuzzer "GotRegistrationResult Error sets the dismissedMsg" <|
    \error model -> 
        model
        |> RegistrationPage.update (GotRegistrationResult (Result.Err error))
        |> Tuple.first 
        |> .state
        |> Expect.equal (Error "Došlo je do neočekivane greške 😞"),

    fuzz registrationModelFuzzer "GotRegistrationResult Ok sets new model with state created" <|
    \model -> 
        model 
        |> RegistrationPage.update (GotRegistrationResult (Result.Ok ()))
        |> Tuple.first 
        |> Expect.equal (Model model.apiBaseUrl "" "" "" "" (CreatedRequest "Uspešno ste podneli prijavu! 👍") False)
    ]

viewTests = 
    describe "RegistrationPage view" 
    [fuzz registrationModelFuzzer "Correctly renders text in DOM" <|
     \model ->
        model
        |> RegistrationPage.view 
        |> Html.toUnstyled
        |> Query.fromHtml
        |> Query.has [ text "Zahtev za registraciju korisnika" ],
    
    fuzz registrationModelFuzzer "Email field has value email" <|
    \model -> 
        model 
        |> RegistrationPage.view 
        |> Html.toUnstyled
        |> Query.fromHtml
        |> Query.find [ attribute <| Attributes.placeholder "Email" ]
        |> Query.has [ attribute <| Attributes.value model.email],

    test "Click on register button returns SubmittedForm message" <|
    \_ -> 
        RegistrationPage.view (RegistrationPage.init "someurl")
        |> Html.toUnstyled
        |> Query.fromHtml
        |> Query.find
            [ tag "button"
            , containing [ text "Podnesi prijavu" ]
            ]
        |> Event.simulate Event.click
        |> Event.expect SubmittedForm
    
    ]


