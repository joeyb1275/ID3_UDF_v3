#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include-once
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <ListboxConstants.au3>
#Include <GuiStatusBar.au3>
#Include <GuiListView.au3>
#Include <File.au3>
#Include <Sound.au3>
#Include "ID3_v3.2.au3"
#Include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <GDIPlus.au3>

#cs #ID3_Example_GUI.au3 UDF Example Latest Changes.......: ;====================================================================
	Release 3.1 - 20120519
		-Added _GDIPlus functions to handle png file in the ID3v2 APIC Tag Frame
		-Fixed _ID3v2_SaveTag_button_Pressed() when writing ID3v2 UFID, had wrong notation
#ce ;========================================================================================================



;Need this to show .png image files in the picturebox
_GDIPlus_Startup()

Dim $Gui_Width = 850-265-65, $Gui_Height = 550
$ID3Gui_H = GUICreate("ID3 Example GUI", $Gui_Width, $Gui_Height)
;Check for GUI Icon
If Not FileExists(@TempDir & "\id3v22.ico") Then
	InetGet("http://www.id3.org/Developer_Information?action=AttachFile&do=get&target=id3v2.ico", @TempDir & "\id3v22.ico")
EndIf
GUISetIcon(@TempDir & "\id3v22.ico")
TraySetIcon(@TempDir & "\id3v22.ico")
$ProgDir = @WorkingDir & "\"

$StatusBar = _GUICtrlStatusBar_Create($ID3Gui_H, -1, -1)
_GUICtrlStatusBar_SetText($StatusBar , "Status")

$FileOpen_button = GUICtrlCreateButton("Open", 10, 20, 50, 20, $BS_DEFPUSHBUTTON)
$File_input = GUICtrlCreateInput("", 65, 20, 400, 20)
$FilePlay_button = GUICtrlCreateButton("Play", 470, 20, 40, 20)

$FileSize_label = GUICtrlCreateLabel("FileSize:", 400, 50, 50, 20)
$FileSize_input = GUICtrlCreateInput("", 449, 45, 60, 20)



$tab = GUICtrlCreateTab(10,50,500,470)
$ID3_tab = GUICtrlCreateTabitem ("ID3 Data")
$hID3v2Group = GUICtrlCreateGroup("ID3v2",20,74,480,275)
$ID3v2_RemoveTag_button = GUICtrlCreateButton("Remove ID3v2", 100, 90, 85, 20)
$ID3v2_SaveTag_button = GUICtrlCreateButton("Save ID3v2", 190, 90, 70, 20)
$Title_label = GUICtrlCreateLabel("Title (TIT2)", 40, 110, 150, 20)
$Title_input = GUICtrlCreateInput("", 40, 125, 220, 20)
$Artist_label = GUICtrlCreateLabel("Artist (TPE1)", 40, 100+30+20, 150, 20)
$Artist_input = GUICtrlCreateInput("", 40, 100+45+20, 220, 20)
$Album_label = GUICtrlCreateLabel("Album (TALB)", 40, 150+20+20, 150, 20)
$Album_input = GUICtrlCreateInput("", 40, 150+35+20, 220, 20)
$Track_label = GUICtrlCreateLabel("Track (TRCK)", 40, 210+20, 70, 20)
$Track_input = GUICtrlCreateInput("", 40, 200+25+20, 65, 20)
$Length_label = GUICtrlCreateLabel("Length (TLEN)", 118, 210+20, 70, 20)
$Length_input = GUICtrlCreateInput("", 118, 200+25+20, 65, 20)
$Year_label = GUICtrlCreateLabel("Year (TYER)", 195, 210+20, 70, 20)
$Year_input = GUICtrlCreateInput("", 195, 200+25+20, 65, 20)
$Genre_label = GUICtrlCreateLabel("Genre (TCON)", 40, 245+20, 150, 20)
$Genre_input = GUICtrlCreateInput("", 40, 240+20+20, 220, 20)
$COMM_label = GUICtrlCreateLabel("Comment (COMM)", 40, 285+20, 220, 20)
$COMM_input = GUICtrlCreateInput("", 40, 300+20, 220, 20)
$COMM_inputUD = GUICtrlCreateUpdown($COMM_input)


$APIC_pic = -1
$APIC_picBKGlabel = GUICtrlCreateLabel("",285, 95, 200, 200)
GUICtrlSetBkColor($APIC_picBKGlabel, 0xffffff) ; White
$APIC_label = GUICtrlCreateLabel("AlbumArt (APIC)", 285, 305, 170, 20)
$APIC_input = GUICtrlCreateInput("",285,320,200,20)
$APIC_inputUD = GUICtrlCreateUpdown($APIC_input)
$APIC_PNGTOJPEG_Encoder = _GDIPlus_EncodersGetCLSID("JPG")
$APIC_GDIPlusImage = -1
GUICtrlSetLimit($APIC_inputUD, 20,0)
Dim $aAPIC_PictureTypes[19]
$aAPIC_PictureTypes[0] = "Other"
$aAPIC_PictureTypes[1] = "32x32 pixels 'file icon'"
$aAPIC_PictureTypes[2] = "Other file icon"
$aAPIC_PictureTypes[3] = "Cover (front)"
$aAPIC_PictureTypes[4] = "Cover (back)"
$aAPIC_PictureTypes[5] = "Leaflet page"
$aAPIC_PictureTypes[6] = "Media (e.g. lable side of CD)"
$aAPIC_PictureTypes[7] = "Lead artist/lead performer/soloist"
$aAPIC_PictureTypes[8] = "Artist/performer"
$aAPIC_PictureTypes[9] = "Conductor"
$ID3v2_AddAPIC_button = GUICtrlCreateButton("+", 450, 301, 18, 18)
$ID3v2_RemoveAPIC_button = GUICtrlCreateButton("-", 468, 301, 18, 18)

$hID3v1Group = GUICtrlCreateGroup("ID3v1",20, 355 ,480,155)
$TitleV1_label = GUICtrlCreateLabel("Title:", 40, 375, 50, 20)
$TitleV1_input = GUICtrlCreateInput("", 40, 390, 220, 20)
$ArtistV1_label = GUICtrlCreateLabel("Artist:", 40, 415, 50, 20)
$ArtistV1_input = GUICtrlCreateInput("", 40, 430, 220, 20)
$AlbumV1_label = GUICtrlCreateLabel("Album:", 40, 455, 50, 20)
$AlbumV1_input = GUICtrlCreateInput("", 40, 470, 220, 20)
$TrackV1_label = GUICtrlCreateLabel("Track", 280, 375, 50, 20)
$TrackV1_input = GUICtrlCreateInput("", 280, 390, 30, 20)
$YearV1_label = GUICtrlCreateLabel("Year", 340, 375, 50, 20)
$YearV1_input = GUICtrlCreateInput("", 340, 390, 40, 20)
$GenreV1_label = GUICtrlCreateLabel("Genre", 280, 415, 50, 20)
$GenreV1_input = GUICtrlCreateInput("", 280, 430, 200, 20)
$CommentV1_label = GUICtrlCreateLabel("Comment", 280, 455, 50, 20)
$CommentV1_input = GUICtrlCreateInput( "", 280, 470, 200, 20)
$ID3v1_SaveTag_button = GUICtrlCreateButton("Save ID3v1", 395, 368, 85, 20)
$ID3v1_RemoveTag_button = GUICtrlCreateButton("Remove ID3v1", 395, 390, 85, 20)

GUICtrlCreateTabItem(""); end tabitem definition


$ID3v2_tab = GUICtrlCreateTabitem ("ID3v2 More")
$ID3v2Size_label = GUICtrlCreateLabel("Tag Size:", 40, 90, 100, 20)
$ID3v2Size_input = GUICtrlCreateInput("", 40, 105, 50, 20)
$ZPADSize_label = GUICtrlCreateLabel("Zero Padding:", 130, 90, 100, 20)
$ZPADSize_input = GUICtrlCreateInput("", 130, 105, 50, 20)
$Encoder_label = GUICtrlCreateLabel("Encoder (TSSE)", 40, 130, 100, 20)
$Encoder_input = GUICtrlCreateInput("", 40, 145, 220, 20)
$Publisher_label = GUICtrlCreateLabel("Publisher (TPUB)", 40, 150+20, 150, 20)
$Publisher_input = GUICtrlCreateInput("", 40, 150+35, 220, 20)
$UFID_label = GUICtrlCreateLabel("Unique File ID (UFID)", 40, 210, 220, 20)
$UFID_input = GUICtrlCreateInput("", 40, 225, 220, 20)
$Composer_label = GUICtrlCreateLabel("Composer (TCOM)", 40, 250, 150, 20)
$Composer_input = GUICtrlCreateInput("", 40, 265, 220, 20)
$Band_label = GUICtrlCreateLabel("Band/Orchestra/Accompaniment (TPE2)", 40, 290, 220, 20)
$Band_input = GUICtrlCreateInput("", 40, 305, 220, 20)
$WCOM_label = GUICtrlCreateLabel("Commerical Info URL (WCOM)", 280, 90, 200, 20)
$WCOM_input = GUICtrlCreateInput("", 280, 105, 200, 20)
$WXXX_label = GUICtrlCreateLabel("User Defined URL (WXXX)", 280, 130, 200, 20)
$WXXX_input = GUICtrlCreateInput("", 280, 145, 200, 20)
$WOAR_label = GUICtrlCreateLabel("Official artist/performer URL (WOAR)", 280, 170, 200, 20)
$WOAR_input = GUICtrlCreateInput("", 280, 185, 200, 20)
$POPM_label = GUICtrlCreateLabel("Popularimeter (POPM)", 280, 210, 200, 20)
$POPM_input = GUICtrlCreateInput("", 280, 225, 200, 20)
$TXXX_label = GUICtrlCreateLabel("User-Defined Text (TXXX)", 280, 250, 200, 20)
$TXXX_input = GUICtrlCreateInput("", 280, 265, 200, 20)
$TXXX_inputUD = GUICtrlCreateUpdown($TXXX_input)
$Lyrics_label = GUICtrlCreateLabel("Lyrics (USLT)", 40, 355, 150, 20)
$Lyrics_edit = GUICtrlCreateEdit( "", 40, 370, 440, 140)


GUICtrlCreateTabItem(""); end tabitem definition

$APEv2_tab = GUICtrlCreateTabitem ("APEv2")
$APEv2Version_label = GUICtrlCreateLabel("APE Version:", 40, 90, 70, 20)
$APEv2Version_input = GUICtrlCreateInput("", 40, 105, 70, 21)
$APEv2TagSize_label = GUICtrlCreateLabel("Tag Size:", 125, 90, 70, 20)
$APEv2TagSize_input = GUICtrlCreateInput("", 125, 105, 70, 21)
$APEv2ItemCount_label = GUICtrlCreateLabel("Item Count:", 210, 90, 70, 20)
$APEv2ItemCount_input = GUICtrlCreateInput("", 210, 105, 70, 21)
$APEv2_RemoveTag_button = GUICtrlCreateButton("Remove Tag", 300, 104, 90, 23)
$APEv2_SaveTag_button = GUICtrlCreateButton("Save Tag", 400, 104, 90, 23)
GUICtrlSetState(-1, $GUI_DISABLE)
$APEv2ItemValue_label = GUICtrlCreateLabel("Item Value:", 210, 140, 200, 20)
$APEv2ItemValue_input = GUICtrlCreateInput("", 210, 155, 280, 20)
$APEv2ItemValue_inputUD = GUICtrlCreateUpdown($APEv2ItemValue_input)
$APEv2_label = GUICtrlCreateLabel("APEv2 Item Keys:", 40, 140, 100, 20)
$APEv2_ItemList = GUICtrlCreateList("", 40, 155, 155, 320)
$APEv2_AddItem_button = GUICtrlCreateButton("Add Item", 40, 480, 70, 23)
GUICtrlSetState(-1, $GUI_DISABLE)
$APEv2_RemoveItem_button = GUICtrlCreateButton("Remove Item", 117, 480, 80, 23)
GUICtrlSetState(-1, $GUI_DISABLE)
$APEv2_pic = -1
$APEv2_picBKGlabel = GUICtrlCreateLabel("",210, 190, 284, 284)
GUICtrlSetBkColor($APEv2_picBKGlabel, 0xffffff) ; White

GUICtrlCreateTabItem(""); end tabitem definition

$MPEGInfo_tab = GUICtrlCreateTabitem ("MPEG")
$MPEGFrameHeader_label = GUICtrlCreateLabel("MPEG Frame Header:", 40, 110, 125, 20)
$MPEGFrameHeader_input = GUICtrlCreateInput("", 40, 125, 125, 20)
$MPEGVersion_label = GUICtrlCreateLabel("Version:", 40, 100+30+20, 80, 20)
$MPEGVersion_input = GUICtrlCreateInput("", 40, 100+45+20, 125, 20)
$MPEGLayer_label = GUICtrlCreateLabel("Layer:", 40, 150+20+20, 80, 20)
$MPEGLayer_input = GUICtrlCreateInput("", 40, 150+35+20, 125, 20)
$MPEGBitRate_label = GUICtrlCreateLabel("Bitrate:", 40, 210+20, 80, 20)
$MPEGBitRate_input = GUICtrlCreateInput("", 40, 200+25+20, 80, 20)
$MPEGSampleRate_label = GUICtrlCreateLabel("SampleRate:", 40, 210+20+40, 80, 20)
$MPEGSampleRate_input = GUICtrlCreateInput("", 40, 200+25+20+40, 80, 20)
$MPEGChannelMode_label = GUICtrlCreateLabel("ChannelMode:", 40, 210+20+80, 80, 20)
$MPEGChannelMode_input = GUICtrlCreateInput("", 40, 200+25+20+80, 80, 20)
GUICtrlCreateTabItem(""); end tabitem definition


$RawTag_tab = GUICtrlCreateTabitem ("Raw Data")
$TAGINFO_label = GUICtrlCreateLabel("TAG_INFO:", 25, 90, 100, 20)
$TAGINFO_edit = GUICtrlCreateEdit( "", 25, 105, 465, 90)
$ID3v2INFO_label = GUICtrlCreateLabel("ID3v2_INFO", 25, 205, 225, 20)
$ID3v2INFO_edit = GUICtrlCreateEdit("", 25, 220, 225, 285)
$APEv2INFO_label = GUICtrlCreateLabel("APEv2_INFO", 265, 205, 225, 20)
$APEv2INFO_edit = GUICtrlCreateEdit("", 265, 220, 225, 285)


GUICtrlCreateTabItem(""); end tabitem definition


Dim $szDrive, $szDir, $szFName, $szExt, $Filename

GUISetState()
While 1
	$msg = GUIGetMsg()
	Switch $msg
		Case $FileOpen_button
			_FileOpen_button_Pressed()
		Case $FilePlay_button
			_FilePlay_button_Pressed()
		Case $APIC_inputUD
			_APIC_inputUD_Pressed()
		Case $TXXX_inputUD
			_TXXX_inputUD_Pressed()
		Case $COMM_inputUD
			_COMM_inputUD_Pressed()
		Case $ID3v1_RemoveTag_button
			_ID3v1_RemoveTag_button_Pressed()
		Case $ID3v2_RemoveTag_button
			_ID3v2_RemoveTag_button_Pressed()
		Case $APEv2_RemoveTag_button
			_APEv2_RemoveTag_button_Pressed()
		Case $ID3v1_SaveTag_button
			_ID3v1_SaveTag_button_Pressed()
		Case $ID3v2_SaveTag_button
			_ID3v2_SaveTag_button_Pressed()
		Case $ID3v2_AddAPIC_button
			_ID3v2_AddAPIC_button_Pressed()
		Case $ID3v2_RemoveAPIC_button
			_ID3v2_RemoveAPIC_button_Pressed()
		Case $APEv2_ItemList
			_APEv2_ItemList_list_Pressed()
		Case $APEv2ItemValue_inputUD
			_APEv2ItemValue_inputUD_Pressed()
		Case $GUI_EVENT_CLOSE
			_GUI_EVENT_CLOSE_Pressed()
			ExitLoop
	EndSwitch
WEnd

_GDIPlus_Shutdown()



Func _FileOpen_button_Pressed()
	If StringInStr(GUICtrlRead($FilePlay_button),"Stop") <> 0 Then
		SoundPlay("")
		GUICtrlSetData($FilePlay_button,"Play")
	EndIf
	_ResetAll()
	_GUICtrlStatusBar_SetText( $StatusBar , "Reading Tags...")

	$Filename = FileOpenDialog("Select MP3 File", "", "MP3 (*.mp3)", 1 + 4 )

	Dim $TimeToReadTags = 0
	If Not(@error) Then
		FileChangeDir($ProgDir)
		_PathSplit($Filename, $szDrive, $szDir, $szFName, $szExt)
		GUICtrlSetData($File_input, $szFName & $szExt)
		GUICtrlSetData($FileSize_input, Round(FileGetSize($Filename)/1048576,2) & " MB")




		Local $begin = TimerInit()
		Local $TAGINFO = _ID3ReadTag($Filename)
		Local $iTAGsFound = @extended
;~ 		MsgBox(0,"@extended",@extended)
;~ 		MsgBox(0,"$TAGINFO",$TAGINFO)
		$TimeToReadTags = TimerDiff($begin)
		GUICtrlSetData($TAGINFO_edit,$TAGINFO)
		GUICtrlSetData($ID3v2INFO_edit,$ID3v2_TagFrameString)
		GUICtrlSetData($APEv2INFO_edit,$APEv2_TagFrameString)

;~ 		Dim $Test = _ID3v2Tag_GetHeaderFlags()
;~ 		MsgBox(0,"Header Flags",$Test)


		;Get ID3v1 Tag
		;_ID3v1Tag_ReadFromFile($Filename)
		GUICtrlSetData($hID3v1Group,"ID3v1." & _ID3v1Tag_GetVersion())
		GUICtrlSetData($TitleV1_input, _ID3v1Field_GetString("Title"))
		GUICtrlSetData($ArtistV1_input, _ID3v1Field_GetString("Artist"))
		GUICtrlSetData($AlbumV1_input, _ID3v1Field_GetString("Album"))
		GUICtrlSetData($TrackV1_input, _ID3v1Field_GetString("Track"))
		GUICtrlSetData($YearV1_input, _ID3v1Field_GetString("Year"))
		GUICtrlSetData($GenreV1_input, _ID3v1Field_GetString("Genre"))
		GUICtrlSetData($CommentV1_input, _ID3v1Field_GetString("Comment"))

		;Get ID3v2 Tag
		;_ID3v2Tag_ReadFromFile($Filename)
		;_ID3v2Tag_GetFrameIDs()
		GUICtrlSetData($hID3v2Group,"ID3v2." & _ID3v2Tag_GetVersion())
		GUICtrlSetData($Title_input, _ID3v2Frame_GetFields("TIT2"))
		GUICtrlSetData($Artist_input, _ID3v2Frame_GetFields("TPE1"))
		GUICtrlSetData($Album_input, _ID3v2Frame_GetFields("TALB"))
		GUICtrlSetData($Track_input, _ID3v2Frame_GetFields("TRCK"))
		GUICtrlSetData($Year_input, _ID3v2Frame_GetFields("TYER"))
		GUICtrlSetData($Genre_input, _ID3v2Frame_GetFields("TCON"))
		GUICtrlSetData($Length_input, _ID3v2Frame_GetFields("TLEN"))


		;Get Album Art
;~ 		$Test = _ID3v2Frame_GetFields("APIC",1, 1)
;~ 		_ArrayDisplay($Test)

		$AlbumArtFile = _ID3v2Frame_GetFields("APIC")
		Dim $NumAPIC = @extended
;~ 		MsgBox(0,"$AlbumArtFile",$AlbumArtFile)
		If FileExists($AlbumArtFile) Then

			;Added this to handle APIC tags with png files
			If StringInStr($AlbumArtFile,".png") Then
				$APIC_GDIPlusImage = _GDIPlus_ImageLoadFromFile($AlbumArtFile)
				$AlbumArtFile = StringReplace($AlbumArtFile,".png",".jpg")
				_GDIPlus_ImageSaveToFileEx($APIC_GDIPlusImage,$AlbumArtFile, $APIC_PNGTOJPEG_Encoder)
				_GDIPlus_ImageDispose($APIC_GDIPlusImage)
			EndIf

			Dim $PicTypeIndex = StringInStr($AlbumArtFile,chr(0))
			If _ID3v2Tag_GetVersion() == "2.0" Then
				GUICtrlSetData($APIC_input,$aAPIC_PictureTypes[0])
			Else
				GUICtrlSetData($APIC_input,$aAPIC_PictureTypes[Number(StringMid($AlbumArtFile,$PicTypeIndex+1))])
			EndIf

			If $APIC_pic == -1 Then
				GUISwitch($ID3Gui_H,$ID3_tab)
				$APIC_pic = GUICtrlCreatePic($AlbumArtFile,285,95, 200, 200)
				GUICtrlCreateTabItem(""); end tabitem definition
			EndIf
			GUICtrlSetState($APIC_pic, $GUI_SHOW)
			GUICtrlSetImage($APIC_pic, $AlbumArtFile)
			GUICtrlSetData($APIC_label,"AlbumArt (APIC 1 of " & $NumAPIC & ")")
		EndIf


		;Get Stuff with multiple FrameIDs
		;TXXX
		Dim $TXXX = _ID3v2Frame_GetFields("TXXX",1,1) ;return array
		Dim $NumTXXX = @extended
;~ 		_ArrayDisplay($TXXX)
;~ 		MsgBox(0,"$NumTXXX",$NumTXXX)
		If $NumTXXX > 0 Then
			GUICtrlSetLimit($TXXX_inputUD, $NumTXXX + 1,1)
			GUICtrlSetData($TXXX_input,$TXXX[2] & ":" & $TXXX[1])
			GUICtrlSetData($TXXX_label,"User-Defined Text (TXXX 1 of " & $NumTXXX & ")")
		EndIf
		;COMM
		Dim $COMM = _ID3v2Frame_GetFields("COMM",1) ;return simple string
		Dim $NumCOMM = @extended
;~ 		MsgBox(0,"$NumCOMM",$NumCOMM)
		If $NumCOMM > 0 Then
			GUICtrlSetLimit($COMM_inputUD, $NumCOMM + 1,1)
			GUICtrlSetData($COMM_input,$COMM)
			GUICtrlSetData($COMM_label,"Comment (COMM 1 of " & $NumCOMM & ")")
		EndIf


		;Get More Stuff
		GUICtrlSetData($POPM_input, _ID3v2Frame_GetFields("POPM"))
		GUICtrlSetData($Encoder_input, _ID3v2Frame_GetFields("TSSE"))
		GUICtrlSetData($Publisher_input, _ID3v2Frame_GetFields("TPUB"))
		GUICtrlSetData($Composer_input, _ID3v2Frame_GetFields("TCOM"))
		GUICtrlSetData($UFID_input, _ID3v2Frame_GetFields("UFID"))
		GUICtrlSetData($Band_input,_ID3v2Frame_GetFields("TPE2"))
		GUICtrlSetData($WCOM_input, _ID3v2Frame_GetFields("WCOM"))
		GUICtrlSetData($WXXX_input, _ID3v2Frame_GetFields("WXXX"))
		GUICtrlSetData($WOAR_input, _ID3v2Frame_GetFields("WOAR"))
		$LyricsFile = _ID3v2Frame_GetFields("USLT")
		GUICtrlSetData($Lyrics_edit,  FileRead($LyricsFile))
		GUICtrlSetData($ZPADSize_input, _ID3v2Tag_GetZPAD())
		GUICtrlSetData($ID3v2Size_input, _ID3v2Tag_GetTagSize())


;~ 		MsgBox(0,"TOAL",_ID3v2Frame_GetFields("TOAL"))


		;Get APEv2 Tag
		;_APEv2Tag_ReadFromFile($Filename)
		If BitAND($iTAGsFound,4) Then
			GUICtrlSetData($APEv2TagSize_input, _APEv2Tag_GetTagSize())
			GUICtrlSetData($APEv2Version_input, _APEv2Tag_GetVersion())
			GUICtrlSetData($APEv2ItemCount_input, _APEv2Tag_GetItemCount())
			GUICtrlSetData($APEv2_ItemList, _APEv2_GetItemKeys("|"))
		EndIf



		;TODO Add more to MPEG Tab
;~ 		Local $MPEGbegin = TimerInit()
		Local $bMPEG = _MPEG_GetFrameHeader($Filename)
;~ 		$MPEGTimeToReadTags = TimerDiff($MPEGbegin)
;~ 		MsgBox(0,"$MPEGTimeToReadTags",Round($MPEGTimeToReadTags,2) & " ms")
		GUICtrlSetData($MPEGFrameHeader_input, $bMPEG)
		GUICtrlSetData($MPEGVersion_input, _MPEG_GetVersion($bMPEG))
		GUICtrlSetData($MPEGLayer_input, _MPEG_GetLayer($bMPEG))
		GUICtrlSetData($MPEGBitRate_input, _MPEG_GetBitRate($bMPEG))
		GUICtrlSetData($MPEGSampleRate_input, _MPEG_GetSampleRate($bMPEG))
		GUICtrlSetData($MPEGChannelMode_input, _MPEG_GetChannelMode($bMPEG))


		_ID3DeleteFiles()

	EndIf
	_GUICtrlStatusBar_SetText ( $StatusBar , "Status: Last Tag was read in " & Round($TimeToReadTags,2) & " ms")
EndFunc
Func _FilePlay_button_Pressed()
	If StringInStr(GUICtrlRead($FilePlay_button),"Play") <> 0 Then
		SoundPlay($Filename)
		GUICtrlSetData($FilePlay_button,"Stop")
	Else
		SoundPlay("")
		GUICtrlSetData($FilePlay_button,"Play")
	EndIf
EndFunc




Func _ID3v1_SaveTag_button_Pressed()
	_GUICtrlStatusBar_SetText( $StatusBar , "Writing ID3v1 Tags...")
	_ID3v1Field_SetString("Title",GUICtrlRead($TitleV1_input),0) ;force pad with 0x00
	_ID3v1Field_SetString("Artist",GUICtrlRead($ArtistV1_input))
	_ID3v1Field_SetString("Album",GUICtrlRead($AlbumV1_input))
	_ID3v1Field_SetString("Track",GUICtrlRead($TrackV1_input))
	_ID3v1Field_SetString("Year",GUICtrlRead($YearV1_input))
	_ID3v1Field_SetString("Genre",GUICtrlRead($GenreV1_input))
	_ID3v1Field_SetString("Comment",GUICtrlRead($CommentV1_input),0)
	Local $begin = TimerInit()
	_ID3v1Tag_WriteToFile($Filename)
	$TimeToReadTags = TimerDiff($begin)
	_GUICtrlStatusBar_SetText( $StatusBar , "Completed Last Tag Write in " & Round($TimeToReadTags,2) & " ms")
EndFunc
Func _ID3v2_SaveTag_button_Pressed()
	_GUICtrlStatusBar_SetText( $StatusBar , "Writing ID3v2 Tags...")
	_ID3v2Frame_SetFields("TIT2",GUICtrlRead($Title_input))
;~ 	_ID3v2Tag_RemoveFrame("TXXX",1)
	_ID3v2Frame_SetFields("TYER",GUICtrlRead($Year_input))
	_ID3v2Frame_SetFields("TPE1",GUICtrlRead($Artist_input))
;~ 	_ID3v2Frame_SetFields("COMM",GUICtrlRead($COMM_input))
;~ 	_ID3v2Frame_SetFields("WOAR",GUICtrlRead($WOAR_input))
;~ 	_ID3v2Frame_SetFields("USLT","SongLyrics.txt")
;~ 	_ID3v2Tag_RemoveFrame("WOAR")
	Local $begin = TimerInit()
	_ID3v2Tag_WriteToFile($Filename)
	$TimeToReadTags = TimerDiff($begin)
	_GUICtrlStatusBar_SetText( $StatusBar , "Completed Last Tag Write in " & Round($TimeToReadTags,2) & " ms")
EndFunc

Func _ID3v2_AddAPIC_button_Pressed()
	$PIC_Filename = FileOpenDialog("Select JPG File", "", "All (*.*)", 1 + 4 )
	IF Not @error Then
		Local $iPictureType = _ArraySearch($aAPIC_PictureTypes, GUICtrlRead($APIC_input))
;~ 		MsgBox(0,"$iPictureType",$iPictureType)
		_ID3v2Frame_SetFields("APIC",$PIC_Filename & "|" & "" & "|" & String($iPictureType),1,"|")
		GUICtrlSetImage($APIC_pic, $PIC_Filename)
	EndIf
EndFunc
Func _ID3v2_RemoveAPIC_button_Pressed()

EndFunc

Func _APIC_inputUD_Pressed()
	Local $iAPIC_index = GUICtrlRead($APIC_input)
	GUICtrlSetData($APIC_input,$aAPIC_PictureTypes[$iAPIC_index])
EndFunc
Func _TXXX_inputUD_Pressed()
	Local $iTXXX_index = GUICtrlRead($TXXX_input)
	Local $TXXX = _ID3v2Frame_GetFields("TXXX",$iTXXX_index,1)
	Local $NumTXXX = @extended
;~ 	_ArrayDisplay($TXXX)
	GUICtrlSetData($TXXX_input,$TXXX[2] & ":" & $TXXX[1])
	GUICtrlSetData($TXXX_label,"User-Defined Text (TXXX " & $iTXXX_index & " of " & $NumTXXX & ")")
EndFunc
Func _COMM_inputUD_Pressed()
	Local $iCOMM_index = GUICtrlRead($COMM_input)
	Local $COMM = _ID3v2Frame_GetFields("COMM",$iCOMM_index)
	Local $NumCOMM = @extended
	GUICtrlSetData($COMM_input,$COMM)
	GUICtrlSetData($COMM_label,"Comment (COMM " & $iCOMM_index & " of " & $NumCOMM & ")")
EndFunc

Func _APEv2_ItemList_list_Pressed()
	Local $sItemKey = GUICtrlRead($APEv2_ItemList)
;~ 	MsgBox(0,"$APEv2_ItemList",$sItemKey)
	Local $sItemValue = _APEv2_GetItemValueString($sItemKey)
	Dim $NumValues = @extended
;~ 	MsgBox(0,"$NumValues",$NumValues)
	GUICtrlSetLimit($APEv2ItemValue_inputUD, $NumValues,1)
	GUICtrlSetData($APEv2ItemValue_input,$sItemValue)
	GUICtrlSetData($APEv2ItemValue_label,"Item Value: (1 of " & $NumValues & ")")
	If StringInStr($sItemValue, ".jpg") > 0 Then
		If $APEv2_pic == -1 Then
			GUISwitch($ID3Gui_H,$APEv2_tab)
			$APEv2_pic = GUICtrlCreatePic($sItemValue,210, 190, 284, 284)
			GUICtrlCreateTabItem(""); end tabitem definition
		EndIf
		GUICtrlSetState($APEv2_pic, $GUI_SHOW)
		GUICtrlSetImage($APEv2_pic, $sItemValue)
	EndIf
;~ 	MsgBox(0,"$sItemValue",$sItemValue)
EndFunc
Func _APEv2ItemValue_inputUD_Pressed()
	Local $iAPEv2ItemValue_index = Number(GUICtrlRead($APEv2ItemValue_input))
;~ 	MsgBox(0,"$iAPEv2ItemValue_index",$iAPEv2ItemValue_index)
	Local $sItemKey = GUICtrlRead($APEv2_ItemList)
	Local $sItemValue = _APEv2_GetItemValueString($sItemKey,$iAPEv2ItemValue_index)
	Dim $NumValues = @extended
	GUICtrlSetData($APEv2ItemValue_input,$sItemValue)
	GUICtrlSetData($APEv2ItemValue_label,"Item Value: (" & $iAPEv2ItemValue_index & " of " & $NumValues & ")")
;~ 	GUICtrlSetLimit($APEv2ItemValue_inputUD, $NumValues + 1,1)
EndFunc

Func _ID3v1_RemoveTag_button_Pressed()
	_GUICtrlStatusBar_SetText( $StatusBar , "Removing ID3v1 Tags...")
	Local $begin = TimerInit()
	_ID3v1Tag_RemoveTag($Filename)
	$TimeToRemoveTag = TimerDiff($begin)
	_ResetID3v1()
	_GUICtrlStatusBar_SetText( $StatusBar , "Completed Removing ID3v1 Tag in " & Round($TimeToRemoveTag,2) & " ms")
EndFunc
Func _ID3v2_RemoveTag_button_Pressed()
	_GUICtrlStatusBar_SetText( $StatusBar , "Removing ID3v2 Tags...")
	Local $begin = TimerInit()
	_ID3v2Tag_RemoveTag($Filename)
	$TimeToRemoveTag = TimerDiff($begin)
	_ResetID3v2()
	_GUICtrlStatusBar_SetText( $StatusBar , "Completed Removing ID3v2 Tag in " & Round($TimeToRemoveTag,2) & " ms")
EndFunc
Func _APEv2_RemoveTag_button_Pressed()
	_GUICtrlStatusBar_SetText( $StatusBar , "Removing APEv2 Tags...")
	Local $begin = TimerInit()
	_APEv2_RemoveTag($Filename)
	$TimeToRemoveTag = TimerDiff($begin)
	 _ResetAPEv2()
	_GUICtrlStatusBar_SetText( $StatusBar , "Completed Removing APEv2 Tag in " & Round($TimeToRemoveTag,2) & " ms")
EndFunc


Func _ResetID3v1()
	GUICtrlSetData($TitleV1_input, "")
	GUICtrlSetData($ArtistV1_input, "")
	GUICtrlSetData($AlbumV1_input,"")
	GUICtrlSetData($TrackV1_input, "")
	GUICtrlSetData($YearV1_input, "")
	GUICtrlSetData($GenreV1_input, "")
	GUICtrlSetData($CommentV1_input,"")
	GUICtrlSetData($hID3v1Group,"ID3v1")
EndFunc
Func _ResetID3v2()
	GUICtrlSetData($File_input, "")
	GUICtrlSetData($Title_input, "")
	GUICtrlSetData($Artist_input, "")
	GUICtrlSetData($Album_input, "")
	GUICtrlSetData($Track_input, "")
	GUICtrlSetData($Year_input, "")
	GUICtrlSetData($Length_input, "")
	GUICtrlSetData($Genre_input, "")
	GUICtrlSetState($APIC_pic, $GUI_HIDE)
	GUICtrlSetData($APIC_input, "")
	GUICtrlSetData($APIC_label,"AlbumArt (APIC)")
	GUICtrlSetData($COMM_input, "")
	GUICtrlSetData($COMM_label,"Comment (COMM)")
	GUICtrlSetData($hID3v2Group,"ID3v2")

	GUICtrlSetData($Lyrics_edit, "")
	GUICtrlSetData($Publisher_input, "")
	GUICtrlSetData($UFID_input,"")
	GUICtrlSetData($Composer_input,"")
	GUICtrlSetData($Band_input,"")
	GUICtrlSetData($WXXX_input,"")
	GUICtrlSetData($WOAR_input,"")
	GUICtrlSetData($POPM_input,"")
	GUICtrlSetData($TXXX_input,"")

	GUICtrlSetData($ZPADSize_input,"")
	GUICtrlSetData($ID3V2Size_input,"")
	GUICtrlSetData($Encoder_input,"")
EndFunc
Func _ResetAPEv2()
	GUICtrlSetData($APEv2Version_input, "")
	GUICtrlSetData($APEv2TagSize_input, "")
	GUICtrlSetData($APEv2ItemCount_input, "")

	GUICtrlSetData($APEv2ItemValue_input,"")
	GUICtrlSetData($APEv2ItemValue_label,"Item Value:")
	GUICtrlSetData($APEv2_ItemList, "")
	GUICtrlSetState($APEv2_pic, $GUI_HIDE)
EndFunc
Func _ResetMPEG()
	GUICtrlSetData($MPEGFrameHeader_input, "")
	GUICtrlSetData($MPEGVersion_input, "")
	GUICtrlSetData($MPEGLayer_input, "")
	GUICtrlSetData($MPEGBitRate_input, "")
	GUICtrlSetData($MPEGSampleRate_input, "")
	GUICtrlSetData($MPEGChannelMode_input,"")
EndFunc
Func _ResetAll()

	GUICtrlSetData($FileSize_input, "")

	_ResetID3v1()
	_ResetID3v2()
	_ResetAPEv2()
	_ResetMPEG()

	GUICtrlSetData($TAGINFO_edit,"")
	GUICtrlSetData($ID3v2INFO_edit,"")
	GUICtrlSetData($APEv2INFO_edit,"")
	GUICtrlSetState($APEv2INFO_edit, $GUI_SHOW)
EndFunc

Func _GUI_EVENT_CLOSE_Pressed()
	If StringInStr(GUICtrlRead($FilePlay_button),"Stop") <> 0 Then
		SoundPlay("")
		GUICtrlSetData($FilePlay_button,"Play")
	EndIf
EndFunc
