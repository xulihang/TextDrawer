B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region

'Ctrl + click to export as zip: ide://run?File=%B4X%\Zipper.jar&Args=%PROJECT_NAME%.zip

Sub Class_Globals
	Private Root As B4XView
	Private xui As XUI
	Private ImageView1 As ImageView
	Private Label1 As Label
End Sub

Public Sub Initialize
'	B4XPages.GetManager.LogEvents = True
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("MainPage")
	#if b4a
	Dim p As Panel
	p.Initialize("")
	Root1.AddView(p,0,0,150dip,150dip)
	#End If
	#if b4j
	Dim p As Pane
	p.Initialize("")
	#End If

	Dim options As TextDrawingOptions
	options.Initialize
	options.defaultColor = xui.Color_Black
	'options.defaultStrokeColor = xui.Color_Blue
	options.horizontal = True
	
	options.kerningEnabled = True
	If options.horizontal Then
		options.wordspace = -1
	Else
		options.wordspace = 5
	End If
	options.linespace = -1
	options.wordwrap = True
	options.defaultFont = xui.CreateDefaultFont(50)
	options.fitText = True
	options.maxFontSize = 100
	options.minFontSize = 15
	options.alignment = 2
    Dim drawer As TextDrawer
	drawer.Initialize(p)
	Dim bm As B4XBitmap = drawer.Draw("I love this country.",150dip,200dip,options)
	Log(bm.Width)
	Log(bm.Height)
	
	#if b4a
	ImageView1.Bitmap = bm
	ImageView1.SetLayout(ImageView1.Left,ImageView1.Top,bm.Width,bm.Height)

	#End If
	#if b4j
	ImageView1.SetImage(bm)
	Sleep(0)
	ImageView1.SetSize(bm.Width,bm.Height)
	#End If
End Sub

Private Sub SetShadow(View As B4XView, Radius As Float, dx As Float, dy As Float, Color As Int)
	View.As(JavaObject).RunMethod("setShadowLayer", Array(Radius, dx, dy, Color))
End Sub

'You can see the list of page related events in the B4XPagesManager object. The event name is B4XPage.

Private Sub Button1_Click
	xui.MsgboxAsync("Hello world!", "B4X")
End Sub