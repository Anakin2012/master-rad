module StudentPageTests.FilesContentTests exposing (uploadFilesViewTests, updateTests)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, bool, int, string, map6, intRange, maybe, bool, triple)
import Test exposing (..)
import StudentPage.AssignmentContent.FilesContent as FilesContent exposing (Msg(..))
import FuzzerHelper exposing (httpErrorFuzzer)
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, tag, text, containing)
import Test.Html.Event as Event
import Accessibility.Styled as Html exposing (Html)
import Html.Attributes as Attributes
import File exposing (File)
import Dict
import File.Select
import Nri.Ui.Modal.V11 as Modal

updateTests = 
    describe "Files Content update" 
    [test "SelectedFiles msg" <|
    \_ -> 
        2
        |> Expect.equal 2,
    -- TODO -> kako File? 
    test "Upload msg" <|
    \_ -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update (Upload 1) (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .processingFiles 
        |> Expect.equal True,

    fuzz FuzzerHelper.listOfFilesFuzzer "UploadedFiles msg" <|
    \uploadList -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update (UploadedFiles (Ok (uploadList))) (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .files
        |> Expect.equal uploadList,

    fuzz httpErrorFuzzer "UploadedFiles msg Error" <|
    \error -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update (UploadedFiles (Err error)) (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .hasProcessingError
        |> Expect.equal True,

    fuzz FuzzerHelper.fileInfoFuzzer "DownloadFIle msg" <|
    \fileInfo -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update (DownloadFile fileInfo) (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .processingFiles
        |> Expect.equal True,

    fuzz httpErrorFuzzer "DownloadedFIle msg" <|
    \error -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update (DownloadedFile "name" (Err error)) (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .hasProcessingError
        |> Expect.equal True,

    fuzz httpErrorFuzzer "LoadedFiles msg Error" <|
    \error -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update (LoadedFiles (Err error)) (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .hasProcessingError
        |> Expect.equal True,

    fuzz FuzzerHelper.listOfFilesFuzzer "LoadedFiles msg Ok" <|
    \loadedList -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update (LoadedFiles (Ok loadedList)) (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .files 
        |> Expect.equal loadedList,

    fuzz FuzzerHelper.listOfFilesFuzzer "LoadedFiles msg Ok check filesLoaded" <|
    \loadedList -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update (LoadedFiles (Ok loadedList)) (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .filesLoaded 
        |> Expect.equal True,

    fuzz FuzzerHelper.fileInfoFuzzer "OpenModal msg" <|
    \fileInfo -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update (OpenModal ({startFocusOn = "", returnFocusTo = ""}) fileInfo) (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .modalFileInfo 
        |> Expect.equal (Just fileInfo),

    fuzz FuzzerHelper.fileInfoFuzzer "OpenModal msg modalState check" <|
    \fileInfo -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update (OpenModal ({startFocusOn = "", returnFocusTo = ""}) fileInfo) (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .modalState
        |> Expect.equal 
            (Tuple.first (Modal.open 
                            ({startFocusOn = "", returnFocusTo = ""}))),
{- TODO MODAL MSG IMPORT???
    fuzz FuzzerHelper.fileInfoFuzzer "ModalMsg msg" <|
    \fileInfo -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update (ModalMsg Modal.EscOrOverlayClicked) (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .modalFileInfo 
        |> Expect.equal Tuple.first 
                (Modal.update { dismissOnEscAndOverlayClick = False } Modal.CloseButtonClicked Modal.init)
-}

    -- TO SelectModalFile, UpdateFile --> Kako file?

    fuzz httpErrorFuzzer "UpdatedFile msg error" <|
    \error -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update (UpdatedFile (Err error)) (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .hasProcessingErrorModal
        |> Expect.equal True,

    fuzz FuzzerHelper.fileInfoFuzzer "UpdatedFile msg Ok" <|
    \fileInfo -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update (UpdatedFile (Ok fileInfo)) (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .modalState
        |> Expect.equal (Tuple.first (Modal.close Modal.init)),

    fuzz FuzzerHelper.fileInfoFuzzer "UpdatedFile msg Ok check selected file" <|
    \fileInfo -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update (UpdatedFile (Ok fileInfo)) (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .modalSelectedFile
        |> Expect.equal Nothing,

    fuzz FuzzerHelper.fileInfoFuzzer "UpdatedFile msg Ok check modal file info" <|
    \fileInfo -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update (UpdatedFile (Ok fileInfo)) (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .modalFileInfo
        |> Expect.equal Nothing,

    test "Dismiss msg" <|
    \_ -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update Dismiss (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .hasProcessingError
        |> Expect.equal False,

    test "Dismiss modal msg" <|
    \_ -> 
        {token = "token", apiBaseUrl = "url"}
        |> FilesContent.update DismissModal (FilesContent.init [{name = "ime", extension = "txt"}])
        |> Tuple.first
        |> .hasProcessingErrorModal
        |> Expect.equal False
    ]


uploadFilesViewTests = 
    describe "UploadFiles view" 
    [test "test text in DOM" <|
    \_ -> 
        let model = FilesContent.init [{name = "name", extension = "txt"}]

        in 
            model 
            |> FilesContent.uploadFilesView 1 
            |> Html.toUnstyled
            |> Query.fromHtml
            |> Query.has [tag "h4", containing [text "Otpremanje datoteka"]],

    test "test button" <|
    \_ -> 
        let model = FilesContent.init [{name = "name", extension = "txt"}]

        in 
            model 
            |> FilesContent.uploadFilesView 1 
            |> Html.toUnstyled
            |> Query.fromHtml
            |> Query.find [tag "button", containing [text "Otpremi"]]
            |> Event.simulate Event.click 
            |> Event.expect (Upload 1),

    test "test if button is disabled" <|
    \_ -> 
        let model = FilesContent.init [{name = "name", extension = "txt"}]

        in 
            model 
            |> FilesContent.uploadFilesView 1 
            |> Html.toUnstyled
            |> Query.fromHtml
            |> Query.find [tag "button", containing [text "Otpremi"]]
            |> Query.has [attribute <| Attributes.disabled True] 

  --  test "test if button is enabled" <|  FILEEEEE
    
            
    ]

