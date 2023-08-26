module UtilTests exposing (filesViewTests, errorMessageTests, toDictTests, inputDateTests, dateFromStringTests, secsFromDateTests, dateViewTests, toTwoDigitMonthTests, intToMonthTests)
import Expect exposing (..)
import Fuzz exposing (intRange, int)
import Util exposing (..)
import Test exposing (..)
import Time exposing (Month(..))
import Util exposing (ViewMode(..))
import Clock exposing (Time)
import Calendar as Calendar exposing(Date)
import Accessibility.Styled as Html exposing (Html)
import Html.Attributes as Attributes
import Test.Html.Query as Query
import Test.Html.Event as Event
import Test.Html.Selector exposing (attribute, tag, text, containing)
import Css exposing (contain)
import Dict
import Http exposing (Expect)
import Nri.Ui.Message.V3 as Message
import Css exposing (true)
import StudentPage.AssignmentContent.FilesContent exposing(Msg(..))
import FileInfo exposing (FileInfo)
import Nri.Ui.Modal.V11 as Modal
import FuzzerHelper exposing (fileInfoFuzzer, listOfFilesFuzzer)
import File.Select exposing (files)


type Msg
    = StartDate String
    | EndDate String
    | Dismiss

filesViewTests = 
      describe "files View" 
      [test "check number of buttons" <|
      \_ ->
            let files = [FileInfo 1 True "file.txt",
                         FileInfo 2 False "file2.txt"
                        ]
            in
               files
               |> filesView ({isActive = True, 
                              editAttached = False, 
                              downloadMsg = DownloadFile,  
                              editMsg = OpenModal { startFocusOn = Modal.closeButtonId, returnFocusTo = "" }}) 
               |> Html.toUnstyled
               |> Query.fromHtml
               |> Query.findAll [ tag "button" ]
               |> Query.count (Expect.equal 3),
           
      test "check click event" <|
      \_ ->
            let files = [FileInfo 1 True "file.txt",
                         FileInfo 2 False "file2.txt"
                        ]
                file = FileInfo 1 True "file.txt"
            in
               files
               |> filesView ({isActive = True, 
                              editAttached = False, 
                              downloadMsg = DownloadFile,  
                              editMsg = OpenModal { startFocusOn = Modal.closeButtonId, returnFocusTo = "" }}) 
               |> Html.toUnstyled
               |> Query.fromHtml
               |> Query.findAll [ tag "div",
                               containing [
                                          tag "h5",
                                          containing [text "file.txt" ]
                                          ]
                             ]
               |> Query.first
               |> Query.findAll [tag "button"]
               |> Query.first
               |> Event.simulate Event.click
               |> Event.expect (DownloadFile file)
      ]


errorMessageTests = 
      describe "show error message"
      [test "check message" <|
      \_ -> 
            errorMessage Dismiss
            |> Html.toUnstyled
            |> Query.fromHtml
            |> Query.has [ text "Došlo je do neočekivane greške 😞"]
      ]

toDictTests = 
      describe "from list to dict" 
      [test "check keys" <|
      \_ -> 
            toDict [{name = "ana", id = 1}, {name = "johndoe", id = 2}]
            |> Dict.keys
            |> Expect.equal [1, 2],
      
      test "check values" <|
      \_ -> 
            toDict [{name = "ana", id = 1}, {name = "johndoe", id = 2}]
            |> Dict.values
            |> Expect.equal [{name = "ana", id = 1}, {name = "johndoe", id = 2}]    
      ]

inputDateTests = 
      describe "input date view" 
      [test "id is nothing" <|
      \_ -> 
            inputDate { label_ = "label", msg = StartDate, id_ = Nothing, value = "value" }
            |> Html.toUnstyled
            |> Query.fromHtml
            |> Query.find [ attribute <| Attributes.type_ "date" ]
            |> Query.has [ attribute <| Attributes.value "value" ],

       test "id is Just String" <|
       \_ -> 
            inputDate {label_ = "nesto", msg = EndDate, id_ = Just "nekiId", value = "1.1.2023."}
            |> Html.toUnstyled
            |> Query.fromHtml
            |> Query.find [ attribute <| Attributes.type_ "date" ]
            |> Query.has [ attribute <| Attributes.id "nekiId"],

       test "onInput it sends a message" <|
       \_ -> 
            inputDate {label_ = "nesto", msg = EndDate, id_ = Just "nekiId", value = "1.1.2023."}
            |> Html.toUnstyled
            |> Query.fromHtml
            |> Query.find [ attribute <| Attributes.type_ "date" ]
            |> Event.simulate (Event.input "15.1.2023.")
            |> Event.expect (EndDate "15.1.2023.")
      ]

secsFromDateTests = 
      describe "return time from date in secs"
      [test "for 1.1.1970." <|
      \_ ->
            secsFromDate (Calendar.fromPosix (Time.millisToPosix 0))
            |> Expect.equal 0
      ] 

dateFromStringTests = 
      describe "returns a date for the given string"
      [test "return Just 1.1.1970" <|
      \_ -> 
            dateFromString "1970-01-01"
            |> Expect.equal (Calendar.fromRawParts { year = 1970, month = Jan, day = 1 }),

       test "returns Nothing if invalid input" <|
       \_ -> 
            dateFromString "01.01.1970" 
            |> Expect.equal Nothing
      ]

dateViewTests = 
      describe "Date view" 
      [test "expect 1970-01-01 if 0 seconds" <|
      \_ -> 
            dateView EditMode Time.utc 0
            |> Expect.equal "1970-01-01",

       test "expect 01.01.1970 if 10 seconds" <|
      \_ -> 
            dateView DisplayMode Time.utc 10 
            |> Expect.equal "01.01.1970.",

      test "expect 2023-08-10" <|
      \_ -> 
            dateView EditMode Time.utc 1691694835
            |> Expect.equal "2023-08-10",

      test "expect 10.8.2023." <|
      \_ -> 
            dateView DisplayMode Time.utc 1691694835
            |> Expect.equal "10.08.2023."
      ]


toTwoDigitMonthTests = 
    describe "ToDigitMonth" 
        [test "output is 01 when input is Jan" <|
        \_ -> toTwoDigitMonth Jan
              |> Expect.equal "01", 
         test "output is 02 when the input is Feb" <|
         \_  -> toTwoDigitMonth Feb
                |> Expect.equal "02",
        test "output is 03 when the input is Mar" <|
         \_  -> toTwoDigitMonth Mar
                |> Expect.equal "03",
        test "output is 04 when the input is Apr" <|
         \_  -> toTwoDigitMonth Apr
                |> Expect.equal "04",
        test "output is 05 when the input is May" <|
         \_  -> toTwoDigitMonth May
                |> Expect.equal "05",
        test "output is 06 when the input is Jun" <|
         \_  -> toTwoDigitMonth Jun
                |> Expect.equal "06",
        test "output is 07 when the input is Jul" <|
         \_  -> toTwoDigitMonth Jul
                |> Expect.equal "07",
        test "output is 08 when the input is Aug" <|
         \_  -> toTwoDigitMonth Aug
                |> Expect.equal "08",
        test "output is 09 when the input is Sep" <|
         \_  -> toTwoDigitMonth Sep
                |> Expect.equal "09",
        test "output is 10 when the input is Oct" <|
         \_  -> toTwoDigitMonth Oct
                |> Expect.equal "10",
        test "output is 11 when the input is Nov" <|
         \_  -> toTwoDigitMonth Nov
                |> Expect.equal "11",
        test "output is 12 when the input is Dec" <|
         \_  -> toTwoDigitMonth Dec
                |> Expect.equal "12"
        ]

intToMonthTests =
        describe "intToMonth"
        [test "output is Jan when input is 1" <|
        \_ -> intToMonth 1
              |> Expect.equal (Just Jan),
        test "output is Feb when input is 2" <|
        \_ -> intToMonth 2
              |> Expect.equal (Just Feb),
        test "output is Mar when input is 3" <|
        \_ -> intToMonth 3
              |> Expect.equal (Just Mar),
        test "output is Apr when input is 4" <|
        \_ -> intToMonth 4
              |> Expect.equal (Just Apr),
        test "output is May when input is 5" <|
        \_ -> intToMonth 5
              |> Expect.equal (Just May),
        test "output is Jun when input is 6" <|
        \_ -> intToMonth 6
              |> Expect.equal (Just Jun),
        test "output is Jul when inuput is 7" <|
        \_ -> intToMonth 7
              |> Expect.equal (Just Jul),
        test "output is Aug when input is 8" <|
        \_ -> intToMonth 8
              |> Expect.equal (Just Aug),
        test "output is Sep when input is 9" <|
        \_ -> intToMonth 9
              |> Expect.equal (Just Sep),
        test "output is Oct when input is 10" <|
        \_ -> intToMonth 10
              |> Expect.equal (Just Oct),
        test "output is Nov when input is 11" <|
        \_ -> intToMonth 11
              |> Expect.equal (Just Nov),
        test "output is Dec when input is 12" <|
        \_ -> intToMonth 12
              |> Expect.equal (Just Dec),
        test "output is Nothing if input is 0" <|
        \_ -> intToMonth 0 
              |> Expect.equal Nothing,
        fuzz (intRange -50 -1) "output is Nothing if input < 0" <|
        \month -> intToMonth month
              |> Expect.equal Nothing, 
        fuzz (intRange 13 50) "output is Nothing if input > 12" <|
        \month -> intToMonth month
              |> Expect.equal Nothing
        ]