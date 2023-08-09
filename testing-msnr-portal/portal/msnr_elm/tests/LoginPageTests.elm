module LoginPageTests exposing (updateTests, updateErrorTests, viewTests)
import Expect exposing (Expectation, err)
import Fuzz exposing (Fuzzer, string, bool)
import Test exposing (..)
import FuzzerHelper exposing (httpErrorFuzzer)
import LoginPage exposing (Msg(..), Model, update, updateError)
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, tag, text, containing)
import Test.Html.Event as Event
import Accessibility.Styled as Html exposing (Html)
import Route exposing (Route(..))
import Html.Attributes as Attributes


loginModelFuzzer  : Fuzzer Model
loginModelFuzzer = 
    Fuzz.map6 Model 
        string 
        string
        string
        bool 
        (Fuzz.maybe httpErrorFuzzer)
        bool

testModel : Model 
testModel = 
    { apiBaseUrl = "someapi"
    , email = "email@gmail.com"
    , password = "password"
    , showPassword = False
    , error = Nothing
    , processing = False
    }

updateTests = 
    describe "LoginPage update" 
    [fuzz2 string loginModelFuzzer "Email msg sets the email" <|
    \email model -> 
        model
        |> update (Email email)
        |> Tuple.first 
        |> .email 
        |> Expect.equal email,

    fuzz2 string loginModelFuzzer "Password msg sets the password" <|
    \password model -> 
        model
        |> update (Password password)
        |> Tuple.first 
        |> .password
        |> Expect.equal password,

    fuzz2 bool loginModelFuzzer "SetShowPassword msg sets the showPassword" <|
    \showPassword model -> 
        model 
        |> update (SetShowPassword showPassword)
        |> Tuple.first 
        |> .showPassword
        |> Expect.equal showPassword,

    fuzz loginModelFuzzer "SubmittedForm msg sets error" <|
    \model -> 
        model
        |> update SubmittedForm 
        |> Tuple.first
        |> .error 
        |> Expect.equal Nothing,

    fuzz loginModelFuzzer "SubmittedForm msg sets processing" <|
    \model -> 
        model
        |> update SubmittedForm
        |> Tuple.first 
        |> .processing 
        |> Expect.equal True
    ]

updateErrorTests = 
    describe "updateError tests" 
    [fuzz2 loginModelFuzzer httpErrorFuzzer "fuzzer checking error field" <|
     \model error -> 
        error
        |> updateError model 
        |> .error 
        |> Expect.equal (Just error),

     fuzz2 loginModelFuzzer httpErrorFuzzer "fuzzer checking processing field" <|
     \model error -> 
        error
        |> updateError model
        |> .processing 
        |> Expect.equal False
    ]


viewTests= 
    describe "view tests" 
    [fuzz loginModelFuzzer "Correctly renders text in DOM" <|
     \model ->
        model
        |> LoginPage.view 
        |> Html.toUnstyled
        |> Query.fromHtml
        |> Query.has [ text "Prijava korisnika" ],

    fuzz loginModelFuzzer "Password field is of the right type and on input returns Password msg" <|
    \model ->
        model
        |> LoginPage.view 
        |> Html.toUnstyled
        |> Query.fromHtml
        |> Query.find [ attribute <| Attributes.placeholder "Password" ]
        |> Event.simulate (Event.input "somepass")
        |> Event.expect (Password "somepass"),

    fuzz loginModelFuzzer "Email field is of the right type and on input returns Email msg" <|
    \model ->
        model
        |> LoginPage.view 
        |> Html.toUnstyled
        |> Query.fromHtml
        |> Query.find [ attribute <| Attributes.placeholder "Email" ]
        |> Event.simulate (Event.input "someemail@gmail.com")
        |> Event.expect (Email "someemail@gmail.com"),
    
    fuzz loginModelFuzzer "Email field value matches model email field" <|
    \model -> 
        LoginPage.view model
        |> Html.toUnstyled
        |> Query.fromHtml
        |> Query.has [ attribute <| Attributes.value model.email],

    fuzz loginModelFuzzer "Password field value matches model password field" <|
    \model -> 
        LoginPage.view model
        |> Html.toUnstyled
        |> Query.fromHtml
        |> Query.has [ attribute <| Attributes.value model.password],

    test "Click on login button returns SubmittedForm message" <|
    \_ -> 
        LoginPage.view testModel
        |> Html.toUnstyled
        |> Query.fromHtml
        |> Query.find
            [ tag "button"
            , containing [ text "Prijavi se" ]
            ]
        |> Event.simulate Event.click
        |> Event.expect SubmittedForm
    ]
    

