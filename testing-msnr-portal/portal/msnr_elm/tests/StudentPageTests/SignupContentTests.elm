module StudentPageTests.SignupContentTests exposing (viewTests, updateTests)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, bool, int, string, map6, intRange, maybe, bool, triple)
import Test exposing (..)
import StudentPage.AssignmentContent.SignupContent as SC exposing(Msg(..))
import FuzzerHelper exposing (httpErrorFuzzer)
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, tag, text, containing)
import Test.Html.Event as Event
import Accessibility.Styled as Html exposing (Html)
import Html.Attributes as Attributes

signupModelFuzzer : Fuzzer SC.Model
signupModelFuzzer = 
    Fuzz.map4 SC.Model
        bool 
        bool
        bool
        bool

updateTests = 
    describe "update Signup Content" 
    [fuzz signupModelFuzzer "Update Signup msg" <|
    \model -> 
        {token = "token", apiBaseUrl = "apibase"}
        |> SC.update (UpdateSignup 1 True) model
        |> Tuple.first
        |> .processingRequest
        |> Expect.equal True, 

    fuzz signupModelFuzzer "Update Signup msg error is false" <|
    \model -> 
        {token = "token", apiBaseUrl = "apibase"}
        |> SC.update (UpdateSignup 1 True) model
        |> Tuple.first
        |> .hasProcessingError 
        |> Expect.equal False, 

    fuzz signupModelFuzzer "SignupUpdated msg" <|
    \model -> 
        let
          value = model.isSignedUp  
        in
            {token = "token", apiBaseUrl = "apibase"}
            |> SC.update (SignupUpdated (Ok ())) model
            |> Tuple.first
            |> .isSignedUp
            |> Expect.equal (not value),

    fuzz signupModelFuzzer "SignupUpdated msg set processing request" <|
    \model -> 
        {token = "token", apiBaseUrl = "apibase"}
        |> SC.update (SignupUpdated (Ok ())) model
        |> Tuple.first
        |> .processingRequest
        |> Expect.equal False,

    fuzz2 httpErrorFuzzer signupModelFuzzer "SignupUpdated msg with error result" <|
    \error model -> 
        {token = "token", apiBaseUrl = "apibase"}
        |> SC.update (SignupUpdated (Err error)) model
        |> Tuple.first
        |> .hasProcessingError
        |> Expect.equal True,

    fuzz signupModelFuzzer "Dismiss msg" <|
    \model -> 
        {token = "token", apiBaseUrl = "apibase"}
        |> SC.update Dismiss model
        |> Tuple.first
        |> .dismissedMsg
        |> Expect.equal True
    ]

viewTests = 
    describe "Signup Content view" 
    [fuzz FuzzerHelper.assignmentFuzzer "check when isSignup and no processing request" <|
    \assignment ->
        SC.init True
        |> SC.view assignment  
        |> Html.toUnstyled
        |> Query.fromHtml
        |> Query.has [tag "h5",
                      containing [text "Prijavljani ste za ovu aktivnost"]],

    fuzz FuzzerHelper.assignmentFuzzer "check button" <|
    \assignment -> 
        SC.init True 
        |> SC.view assignment 
        |> Html.toUnstyled
        |> Query.fromHtml
        |> Query.find [tag "button",
                      containing [text "Odjavi se"]]
        |> Event.simulate Event.click
        |> Event.expect (UpdateSignup assignment.id False),


    fuzz FuzzerHelper.assignmentFuzzer "check when not isSignup and no processing request" <|
    \assignment ->
        SC.init False
        |> SC.view assignment  
        |> Html.toUnstyled
        |> Query.fromHtml
        |> Query.has [tag "h5",
                      containing [text "Trenutno niste prijavljeni za ovu aktivnost"]],

    fuzz FuzzerHelper.assignmentFuzzer "check button when not signed up" <|
    \assignment -> 
        SC.init False 
        |> SC.view assignment 
        |> Html.toUnstyled
        |> Query.fromHtml
        |> Query.find [tag "button",
                      containing [text "Prijavi se"]]
        |> Event.simulate Event.click
        |> Event.expect (UpdateSignup assignment.id True)

    
            
    ]   