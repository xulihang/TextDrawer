B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private mBase As B4XView
	Private BBCodeView1 As BBCodeView
	Private engine As BCTextEngine
	Private vte As VerticalTextEngine
	Type TextDrawingOptions (defaultFont As B4XFont, defaultColor As Int, fontname As String, horizontal As Boolean, wordspace As Int, linespace As Double, kerningEnabled As Boolean, RTL As Boolean, wordwrap As Boolean)
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(p As B4XView)
	mBase = p
End Sub

Public Sub Draw(text As String, width As Double,height As Double,options As TextDrawingOptions) As B4XBitmap
	If options.horizontal Then
		If BBCodeView1.IsInitialized = False Then
			BBCodeView1.Initialize(Me,"")
			Dim xLbl As B4XView
			Dim lbl As Label
			lbl.Initialize("")
			xLbl = lbl
			Dim props As Map
			props.Initialize
			BBCodeView1.DesignerCreateView(mBase,xLbl,props)
			engine.Initialize(mBase)
			BBCodeView1.TextEngine = engine
			BBCodeView1.LazyLoading = False
			BBCodeView1.mBase.Visible = False
			'mBase.AddView(BBCodeView1.mBase,0,0,-1,-1)
		End If
		Dim parStyle As BCParagraphStyle
		parStyle = engine.CreateStyle
		parStyle.LineSpacingFactor = options.linespace
		parStyle.WordWrap = options.wordwrap
		
		If options.wordspace <> -1 Then
			engine.SpaceBetweenCharacters = options.wordspace
		End If
		engine.KerningEnabled = options.kerningEnabled
		BBCodeView1.RTL = options.RTL
		BBCodeView1.mBase.Width = width
		BBCodeView1.Style = parStyle
		If options.defaultFont.IsInitialized Then
			BBCodeView1.ParseData.DefaultFont = options.defaultFont
		End If
		BBCodeView1.ParseData.DefaultColor = options.defaultColor
		BBCodeView1.Text = text
		Dim targetWidth As Int  = BBCodeView1.ForegroundImageView.Width
		Dim targetHeight As Int  = BBCodeView1.ForegroundImageView.Height
		Return BBCodeView1.ForegroundImageView.GetBitmap.Resize(targetWidth,targetHeight,True)
	Else
		If vte.IsInitialized = False Then
			vte.Initialize
		End If
		Dim xui As XUI
		Return vte.Draw(mBase,text,options.defaultFont,options.fontname,options.defaultColor,False,False,options.wordspace,options.linespace,0,options.wordwrap,width,height,False,"",0)
	End If
End Sub
