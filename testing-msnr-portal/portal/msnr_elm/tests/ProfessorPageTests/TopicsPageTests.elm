module ProfessorPageTests.TopicsPageTests exposing (..)
import Expect exposing (Expectation, err)
import Fuzz exposing (Fuzzer, string, bool, intRange)
import Test exposing (..)
import FuzzerHelper exposing (httpErrorFuzzer)
import ProfessorPage.TopicsPage as TopicsPage exposing (Msg(..), Model)
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, tag, text, containing)
import Test.Html.Event as Event
import Accessibility.Styled as Html exposing (Html)
import Route exposing (Route(..))
import Html.Attributes as Attributes
import Session exposing (Token)
import Nri.Ui.Modal.V11 as Modal exposing (Msg(..))
import Time
import StudentPage exposing (Msg(..))

topicPageModelFuzzer : Fuzzer Model 
topicPageModelFuzzer = 
    Fuzz.map6 Model
        (Fuzz.list (FuzzerHelper.topicFuzzer))
        bool 
        string 
        bool 
        bool 
        bool 

updateTests = 
    describe "TopicsPage update" 
    [fuzz2 string topicPageModelFuzzer "Title msg sets the title" <|
    \title model ->
        getInput 
        |> TopicsPage.update (Title title) model
        |> Tuple.first
        |> .topicTitle 
        |> Expect.equal title,
    
    fuzz topicPageModelFuzzer "AddTopic msg sets loadingTopics" <|
    \model ->
        getInput 
        |> TopicsPage.update AddTopic model
        |> Tuple.first
        |> .loadingTopics
        |> Expect.equal True,

    fuzz topicPageModelFuzzer "Dismiss msg sets dismissedMsg" <|
    \model ->
        getInput 
        |> TopicsPage.update Dismiss model
        |> Tuple.first
        |> .dismissedMsg
        |> Expect.equal True,

    fuzz topicPageModelFuzzer "Dismiss msg sets hasProcessingError" <|
    \model ->
        getInput 
        |> TopicsPage.update Dismiss model
        |> Tuple.first
        |> .hasProcessingError
        |> Expect.equal False,

    fuzz2 httpErrorFuzzer topicPageModelFuzzer "AddedTopic Error sets hasprocessingError" <|
    \error model ->
        getInput 
        |> TopicsPage.update (AddedTopic (Result.Err error)) model
        |> Tuple.first
        |> .hasProcessingError
        |> Expect.equal True,

    fuzz2 FuzzerHelper.topicFuzzer topicPageModelFuzzer "AddedTopic Ok sets topic list" <|
    \topic model ->
        getInput 
        |> TopicsPage.update (AddedTopic (Result.Ok topic)) model
        |> Tuple.first
        |> Expect.equal 
            (Model (topic :: model.topics) False "" model.hasProcessingError model.isInitialized model.dismissedMsg),

    fuzz2 httpErrorFuzzer topicPageModelFuzzer "TopicsLoaded Error sets hasprocessingError" <|
    \error model ->
        getInput 
        |> TopicsPage.update (TopicsLoaded (Result.Err error)) model
        |> Tuple.first
        |> .hasProcessingError
        |> Expect.equal True,

    fuzz2 (Fuzz.list FuzzerHelper.topicFuzzer) topicPageModelFuzzer "TopicsLoaded Ok sets topic list" <|
    \topics model ->
        getInput 
        |> TopicsPage.update (TopicsLoaded (Result.Ok topics)) model
        |> Tuple.first
        |> Expect.equal 
            (Model topics False model.topicTitle model.hasProcessingError True model.dismissedMsg), 

    fuzz2 (intRange 1 5) topicPageModelFuzzer "DeleteTopic msg removes topic" <|
    \id model ->
        getInput 
        |> TopicsPage.update (DeleteTopic id) model
        |> Tuple.first
        |> Expect.equal 
            (Model (List.filter (\t -> t.id /= id) model.topics) True model.topicTitle model.hasProcessingError model.isInitialized model.dismissedMsg),

    fuzz2 httpErrorFuzzer topicPageModelFuzzer "DeletedTopic Error sets hasprocessingError" <|
    \error model ->
        getInput 
        |> TopicsPage.update (DeletedTopic (Result.Err error)) model
        |> Tuple.first
        |> .hasProcessingError
        |> Expect.equal True,

    fuzz topicPageModelFuzzer "DeletedTopic Ok returns model" <|
    \model ->
        getInput 
        |> TopicsPage.update (DeletedTopic (Result.Ok ())) model
        |> Tuple.first
        |> .loadingTopics
        |> Expect.equal False
    

    ]

getToken : Token 
getToken = "lalalllal"

getInput = {accessToken = getToken,
            currentSemesterId = 1,
            apiBaseUrl = "url" }