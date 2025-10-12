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
	Private xui As XUI
	Type TextDrawingOptions (fitText As Boolean,minFontSize As Int, maxFontSize As Int,defaultFont As B4XFont, defaultColor As Int, fontname As String, horizontal As Boolean, wordspace As Int, linespace As Double, kerningEnabled As Boolean, RTL As Boolean, wordwrap As Boolean)
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(p As B4XView)
	mBase = p
End Sub

Public Sub Draw(text As String, width As Double,height As Double,options As TextDrawingOptions) As B4XBitmap
	If options.fitText Then
		Dim data As Map
		data.Initialize
		Dim minFontSize As Int=options.minFontSize
		Dim maxFontSize As Int=options.maxFontSize
		Dim img As B4XBitmap = DrawImpl(text, width,height, options)
		data.Put("img",img)
		AutoAdjustFont(text,data,width,height,options,minFontSize,maxFontSize,"")
		img = data.Get("img")
		
		If Utils.isChinese(text) = False And Utils.isJapanese(text) = False Then
			Dim desiredWidth As Int
			Dim textForCalculation As String = text
			If text.Contains(" ") Then
				textForCalculation = textForCalculation & " "
			End If
			Dim f As B4XFont
			f = options.defaultFont
			desiredWidth = calculateMinimumWidth(textForCalculation,f)
			Do While desiredWidth > width - 10
				If f.Size >= Utils.getSetting("minFontSize",12) Then
					f = xui.CreateFont(options.defaultFont.ToNativeFont,f.Size - 1)
					desiredWidth = calculateMinimumWidth(textForCalculation,f)
				Else
					width = desiredWidth
					Exit
				End If
			Loop
			options.defaultFont = f
			img = DrawImpl(text, width,height, options)
		End If
		
		Return img
	Else
		Return DrawImpl(text, width,height, options)
	End If
End Sub

private Sub calculateMinimumWidth(s As String,f As B4XFont) As Int
	Dim maxWordWidth As Int = 0
	s = Regex.Replace("\[.*?\]",s,"") 'remove bbcode
	Dim c As B4XCanvas
	c.Initialize(mBase)
	For Each word As String In Regex.Split(" ",s)
		maxWordWidth = Max(c.MeasureText(word&" ",f).Width,maxWordWidth)
	Next
	Return maxWordWidth
End Sub

private Sub AutoAdjustFont(text As String,data As Map,width As Int,height As Int,options As TextDrawingOptions,minFontSize As Int,maxFontSize As Int,previousStatus As String)
    Dim img As B4XBitmap = data.Get("img")
	Dim fixedRect As B4XRect
	fixedRect.Initialize(0,0,options.defaultFont.Size,options.defaultFont.Size)
	Dim diff As Int 
	If options.horizontal Then
		diff = Abs(width - img.Width)
	Else
		diff = Abs(height - img.Height)
	End If
	If options.horizontal Then
		If height - img.Height > fixedRect.Height*0.5 Then
			'Log("make it bigger")
			If previousStatus = "shrink" Then
				Return
			End If

			Dim plus As Int = 1

			If diff > fixedRect.Height Then
				plus = 5
				If options.defaultFont.Size + plus > maxFontSize Then
					plus = 1
				End If
			End If
		
			If options.defaultFont.Size + plus > maxFontSize Then
				'Log("will exceed max font size")
				Return
			End If
			img = DrawImpl(text, width, height, options)
			data.Put("img",img)
			If img.Height - height > 0 Then
				Dim newSize As Int = options.defaultFont.Size-plus
				options.defaultFont = xui.CreateFont(options.defaultFont.ToNativeFont,newSize)
				img = DrawImpl(text, width,height, options)
				data.Put("img",img)
				'Log("already exceed height")
				Return
			End If
			Dim newSize As Int = options.defaultFont.Size+plus
			options.defaultFont = xui.CreateFont(options.defaultFont.ToNativeFont,newSize)
			AutoAdjustFont(text,data,width,height,options,minFontSize,maxFontSize,"enlarge")
		else if img.Height - height > 0 Then
			'Log("make it smaller")
			If previousStatus = "enlarge" Then
				Return
			End If

			Dim minus As Int = 1
		
			If diff > fixedRect.Height Then
				minus = 5
				If options.defaultFont.Size  - minus < minFontSize Then
					minus = 1
				End If
			End If

			img = DrawImpl(text, width,height, options)
			data.Put("img",img)
			If options.defaultFont.Size - minus < minFontSize Then
				'Log("will lower than min font size")
				Return
			End If
			Dim newSize As Int = options.defaultFont.Size-minus
			options.defaultFont = xui.CreateFont(options.defaultFont.ToNativeFont,newSize)
			AutoAdjustFont(text,data,width,height,options,minFontSize,maxFontSize,"shrink")
		Else
			'Log("stop")
		End If
	Else
		If width - img.Width > fixedRect.Width*0.5 Then
			'Log("make it bigger")
			If previousStatus = "shrink" Then
				Return
			End If

			Dim plus As Int = 1

			If diff > fixedRect.Width Then
				plus = 5
				If options.defaultFont.Size + plus > maxFontSize Then
					plus = 1
				End If
			End If
		
			If options.defaultFont.Size + plus > maxFontSize Then
				'Log("will bigger than max font size")
				Return
			End If
			img = DrawImpl(text, width,height, options)
			data.Put("img",img)
			If img.Width - width > 0 Then
				Dim newSize As Int = options.defaultFont.Size-plus
				options.defaultFont = xui.CreateFont(options.defaultFont.ToNativeFont,newSize)
				img = DrawImpl(text, width,height, options)
				data.Put("img",img)
				'Log("already exceed width")
				Return
			End If
			Dim newSize As Int = options.defaultFont.Size+plus
			options.defaultFont = xui.CreateFont(options.defaultFont.ToNativeFont,newSize)
			AutoAdjustFont(text,data,width,height,options,minFontSize,maxFontSize,"enlarge")
		else if img.Width - width > 0 Then
			'Log("make it smaller")
			If previousStatus = "enlarge" Then
				Return
			End If

			Dim minus As Int = 1
		
			If diff > fixedRect.Width Then
				minus = 5
				If options.defaultFont.Size  - minus < minFontSize Then
					minus = 1
				End If
			End If

			img = DrawImpl(text, width,height, options)
			data.Put("img",img)
			If options.defaultFont.Size - minus < minFontSize Then
				'Log("will lower than min font size")
				Return
			End If
			Dim newSize As Int = options.defaultFont.Size-minus
			options.defaultFont = xui.CreateFont(options.defaultFont.ToNativeFont,newSize)
			AutoAdjustFont(text,data,width,height,options,minFontSize,maxFontSize,"shrink")
		Else
			'Log("stop")
		End If
	End If
End Sub

Private Sub DrawImpl(text As String, width As Double,height As Double,options As TextDrawingOptions) As B4XBitmap
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
		Dim vte As VerticalTextEngine
		vte.Initialize
		Return vte.Draw(mBase,text,options.defaultFont,options.fontname,options.defaultColor,False,False,options.wordspace,options.linespace,0,options.wordwrap,width,height,False,"",0)
	End If
End Sub