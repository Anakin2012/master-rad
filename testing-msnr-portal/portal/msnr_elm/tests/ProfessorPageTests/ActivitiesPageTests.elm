module ProfessorPageTests.ActivitiesPageTests exposing (updateTests, viewTests)
import Expect exposing (Expectation, err)
import Fuzz exposing (Fuzzer, string, bool, intRange)
import Test exposing (..)
import FuzzerHelper exposing (httpErrorFuzzer)
import ProfessorPage.ActivitiesPage as ActivitiesPage exposing (Msg(..), Model, ModalAction(..))
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, tag, text, containing)
import Test.Html.Event as Event
import Accessibility.Styled as Html exposing (Html)
import Route exposing (Route(..))
import Html.Attributes as Attributes
import Session exposing (Token)
import Nri.Ui.Modal.V11 as Modal exposing (Msg(..))
import Time
import Activity exposing (Activity)
import ActivityType exposing (ActivityType)


updateTests = 
    describe "ActivitiesPage update" 
    [fuzz string "StartDate msg sets the start date" <|
    \date -> 
        let model = ActivitiesPage.init
            input = getInput 
        in input 
           |> ActivitiesPage.update (StartDate date) model
           |> Tuple.first 
           |> .startDate 
           |> Expect.equal date,
    
    fuzz string "EndDate msg sets the end date" <|
    \date -> 
        let model = ActivitiesPage.init
            input = getInput 
        in input 
           |> ActivitiesPage.update (EndDate date) model
           |> Tuple.first 
           |> .endDate 
           |> Expect.equal date,

    test "Dismiss msg sets the hasProcessingError" <|
    \_ -> 
        let model = ActivitiesPage.init
            input = getInput 
        in input 
           |> ActivitiesPage.update Dismiss model
           |> Tuple.first 
           |> .hasProcessingError 
           |> Expect.equal False,

    fuzz (intRange 1 5) "ActivityTypeSelected msg sets selectedActivityTypeId" <|
    \id -> 
        let model = ActivitiesPage.init
            input = getInput 
        in input 
           |> ActivitiesPage.update (ActivityTypeSelected id) model
           |> Tuple.first 
           |> .selectedActivityTypeId
           |> Expect.equal (Just id),

    fuzz bool "SwitchSingup msg sets isSignup" <|
    \isSignup -> 
        let model = ActivitiesPage.init
            input = getInput 
        in input 
           |> ActivitiesPage.update (SwitchSingup isSignup) model
           |> Tuple.first 
           |> .isSignup
           |> Expect.equal isSignup,

    test "SaveActivity msg sets processingActivity" <|
    \_ -> 
        let model = ActivitiesPage.init 
            input = getInput 
        in input 
           |> ActivitiesPage.update SaveActivity model 
           |> Tuple.first
           |> .processingActivity 
           |> Expect.equal True,

    test "SaveActivity msg sets hasProcessingError" <|
    \_ -> 
        let model = ActivitiesPage.init 
            input = getInput 
        in input 
           |> ActivitiesPage.update SaveActivity model 
           |> Tuple.first
           |> .hasProcessingError 
           |> Expect.equal False, 

    fuzz (intRange 0 100) "Points msg sets points" <|
    \points -> 
        let model = ActivitiesPage.init 
            input = getInput 
        in input 
           |> ActivitiesPage.update (Points (Just points)) model 
           |> Tuple.first
           |> .points
           |> Expect.equal points,

    test "Points Nothing sets points" <|
    \_ -> 
        let model = ActivitiesPage.init 
            input = getInput 
        in input 
           |> ActivitiesPage.update (Points Nothing) model 
           |> Tuple.first
           |> .points
           |> Expect.equal 0,

    test "OpenModal New sets everything" <|
    \_ -> 
        let model = ActivitiesPage.init 
            input = getInput
            ( modalState, cmd ) = Modal.open {startFocusOn = "", returnFocusTo = ""}
            newModel = Model False False modalState New Nothing False "" "" 0

        in input 
           |> ActivitiesPage.update (OpenModal New {startFocusOn = "", returnFocusTo = ""}) model 
           |> Tuple.first
           |> Expect.equal newModel,

    fuzz FuzzerHelper.activityFuzzer "OpenModal Edit sets points from activity" <| 
    \activity -> 
        let model = ActivitiesPage.init 
            input = getInput
            ( modalState, cmd ) = Modal.open {startFocusOn = "", returnFocusTo = ""}
            
        in input 
           |> ActivitiesPage.update (OpenModal (Edit activity) {startFocusOn = "", returnFocusTo = ""}) model 
           |> Tuple.first
           |> .points
           |> Expect.equal activity.points,

    fuzz FuzzerHelper.activityFuzzer "OpenModal Edit sets activityTypeId from activity" <| 
    \activity -> 
        let model = ActivitiesPage.init 
            input = getInput
            ( modalState, cmd ) = Modal.open {startFocusOn = "", returnFocusTo = ""}
            
        in input 
           |> ActivitiesPage.update (OpenModal (Edit activity) {startFocusOn = "", returnFocusTo = ""}) model 
           |> Tuple.first
           |> .selectedActivityTypeId
           |> Expect.equal (Just activity.activityTypeId)
    
    ]


viewTests = 
    describe "ActivitiesPage view" 
    [fuzz2 fuzzerList1 fuzzerList2 "Check text in DOM" <|
    \activities activityTypes -> 
        let input = { zone = Time.utc, activities = activities, activityTypes = activityTypes, loading = False }
            model = ActivitiesPage.init

            htmlContent = model
                          |> ActivitiesPage.view input
                          |> Html.toUnstyled
                          |> Query.fromHtml
        in
            htmlContent |> Query.has [text "Trenutne aktivnosti"]

                                 
    ]

fuzzerList1 : Fuzzer (List Activity)
fuzzerList1 = 
    Fuzz.listOfLength 4 FuzzerHelper.activityFuzzer

fuzzerList2 = 
    Fuzz.listOfLength 3 FuzzerHelper.activityTypeFuzzer


viewInput = 
    {
        zone = Time.utc, 
        activities = [], 
        activityTypes = [], 
        loading = False
    }

getToken : Token 
getToken = "lalalllal"

getInput = {accessToken = getToken,
            zone = Time.utc,
            currentSemesterId = 1,
            apiBaseUrl = "url" }



  --  = StartDate String
  --  | EndDate String
  --  | ActivityTypeSelected Int
   -- | SwitchSingup Bool
  --  | Points (Maybe Int)
   -- | SaveActivity
   -- | SavedActivity (Result Http.Error Activity)
    --| OpenModal ModalAction { startFocusOn : String, returnFocusTo : String }
   -- | ModalMsg Modal.Msg
  --  | Focus String
   -- | Dismiss

 --   processingActivity : Bool
  --  , hasProcessingError : Bool
 --   , modalState : Modal.Model
 --   , modalAction : ModalAction
 --   , selectedActivityTypeId : Maybe Int
 --   , isSignup : Bool
 --   , startDate : String
 --   , endDate : String
 --   , points : Int