module StudentPageTests.TopicContentTests exposing (updateTests, viewTests)
import StudentPage.AssignmentContent.TopicContent as TopicContent exposing(Msg(..), ProcessingError(..))
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, bool, int, string, map6, intRange, maybe, bool, triple)
import Test exposing (..)
import FuzzerHelper exposing (httpErrorFuzzer, assignmentFuzzer, topicFuzzer)
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, tag, text, containing)
import Test.Html.Event as Event
import Accessibility.Styled as Html exposing (Html)
import Html.Attributes as Attributes
import Http
import Topic as TopicModule exposing(..)
import Assignment exposing (Assignment)
import Activity exposing (Activity)
import ActivityType exposing (ActivityType, TypeCode(..))
import Css exposing (contain)
import Array
import Array exposing (length)
import StudentPage.AssignmentContent.TopicContent as TopicContent

updateTests = 
    describe "Update Topic Content" 
    [fuzz FuzzerHelper.topicFuzzer "update check selected topic" <|
    \topic-> 
        {token = "token", apiBaseUrl = "url"}
        |> TopicContent.update (SelectTopic topic 1) TopicContent.init
        |> Tuple.first
        |> .selectedTopic
        |> Expect.equal (Just topic),    

    fuzz FuzzerHelper.topicFuzzer "update SelectTopic check processingError" <|
    \topic-> 
        {token = "token", apiBaseUrl = "url"}
        |> TopicContent.update (SelectTopic topic 1) TopicContent.init
        |> Tuple.first
        |> .processingError
        |> Expect.equal Nothing, 

    fuzz FuzzerHelper.topicFuzzer "update SelectTopic check processingRequest" <|
    \topic-> 
        {token = "token", apiBaseUrl = "url"}
        |> TopicContent.update (SelectTopic topic 1) TopicContent.init
        |> Tuple.first
        |> .processingRequest
        |> Expect.equal True, 

    test "update TopicSelected Ok" <|
    \_-> 
        {token = "token", apiBaseUrl = "url"}
        |> TopicContent.update (TopicSelected (Ok ())) TopicContent.init
        |> Tuple.first
        |> .processingRequest
        |> Expect.equal False, 

    test "update TopicSelected Error 422" <|
    \_-> 
        {token = "token", apiBaseUrl = "url"}
        |> TopicContent.update (TopicSelected (Err (Http.BadStatus 422))) TopicContent.init
        |> Tuple.first
        |> .processingError
        |> Expect.equal (Just ReservedTopic),

    test "update TopicSelected Error " <|
    \_-> 
 
        {token = "token", apiBaseUrl = "url"}
        |> TopicContent.update (TopicSelected (Err Http.Timeout)) TopicContent.init
        |> Tuple.first
        |> .processingError
        |> Expect.equal (Just UnexpectedErr),

    test "update Dismiss check dismissed msg" <|
    \_-> 
 
        {token = "token", apiBaseUrl = "url"}
        |> TopicContent.update Dismiss TopicContent.init
        |> Tuple.first
        |> .dismissedMsg
        |> Expect.equal True, 

    test "update Dismiss check processing error" <|
    \_-> 
 
        {token = "token", apiBaseUrl = "url"}
        |> TopicContent.update Dismiss TopicContent.init
        |> Tuple.first
        |> .processingError
        |> Expect.equal Nothing   
    ]


viewTests = 
    describe "view Topic Content" 
    [test "No groupId view" <|
    \_ -> 
        TopicContent.init
        |> TopicContent.view testAssignment testInput
        |> Html.toUnstyled
        |> Query.fromHtml
        |> Query.has [text "Ne možete izabrati temu ukoliko nemate grupu"],

    test "View with groupId but no topic shows available topics and a button" <|
    \_ -> 
        TopicContent.init
        |> TopicContent.view testAssignment {loading = False, topic = Nothing, topics = testTopics, groupId = Just 1}
        |> Html.toUnstyled
        |> Query.fromHtml
        |> Query.findAll [tag "button", containing [text "Odaberi"]]
        |> Query.count (Expect.equal (List.length testTopics)),      

    test "View with groupId and no topic, button click event" <|
    \_ ->
        case List.head testTopics of 
            Nothing -> 
                Expect.pass
            Just t -> 
                TopicContent.init
                |> TopicContent.view testAssignment {loading = False, topic = Nothing, topics = testTopics, groupId = Just 1}
                |> Html.toUnstyled
                |> Query.fromHtml
                |> Query.findAll [tag "button", containing [text "Odaberi"]]
                |> Query.first
                |> Event.simulate Event.click
                |> Event.expect (SelectTopic t 1),

    test "view in case topic is just title" <|
    \_ -> 
        TopicContent.init 
        |> TopicContent.view testAssignment {loading = False, topic = Just (TopicModule.Topic 3 "naslov teme" 3), topics = testTopics, groupId = Just 1}
        |> Html.toUnstyled
        |> Query.fromHtml 
        |> Query.has [text "naslov teme"],

    test "Error message view when reserved" <|
    \_ -> 
        TopicContent.Model Nothing False (Just ReservedTopic) False
        |> TopicContent.view testAssignment {loading = False, topic = Nothing, topics = testTopics, groupId = Just 1}
        |> Html.toUnstyled
        |> Query.fromHtml 
        |> Query.has [text "Temu je u međuvremenu uzeo drugi tim 😞. Probajte sa nekom drugom..."],

    test "Error message view when other" <|
    \_ -> 
        TopicContent.Model Nothing False (Just UnexpectedErr) False
        |> TopicContent.view testAssignment {loading = False, topic = Nothing, topics = testTopics, groupId = Just 1}
        |> Html.toUnstyled
        |> Query.fromHtml 
        |> Query.has [text "Došlo je do neočekivane greške 😞"]
    ]


testTopics : List TopicModule.Topic
testTopics = 
    [TopicModule.Topic 1 "naslov1" 1,
     TopicModule.Topic 2 "naslov2" 2
    ]


testAssignment : Assignment
testAssignment = 
    Assignment 1 Nothing False Nothing (Activity 1 2 12345 1234567 False 10) (ActivityType 1 "seminarski" ActivityType.Topic "opis" False False ActivityType.Empty)

testInput : { loading : Bool, topic : Maybe Topic, topics : List Topic, groupId : Maybe Int }
testInput = {
            loading = False, 
            topic = Nothing,
            topics = testTopics,
            groupId = Nothing
            }