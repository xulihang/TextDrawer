B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.8
@EndOfDesignText@
Sub Class_Globals
	#if b4j
	Private fx As JFX
	#End If
	Private previousText As String
	Private previousLines As List
	Private MapOfCharAndImage As Map
	Private presetRotationRules As String = "[…—~]"
	Private presetZeroWordspaceRules As String = "[—]"
	Private presetRightAlignRules As String = "[\.,。，、]"
	Private presetCenterAlignRules As String = "[\!\?！？⁉‼…—~⋮0-9a-zA-Z]"
	Private presetReplaceJSON As String = $"{"（":"︵","）":"︶","「":"﹁","」":"﹂","『":"﹃","』":"﹄"}"$
	Private mRotationRules As String
	Private mZeroWordspaceRules As String
	Private mRightAlignRules As String
	Private mCenterAlignRules As String
	Private mFirstCharToMoveUpRules As String
	Private mFreeHeightRules As String
	Private mReplacingMap As Map
	Private upscaleRatioForRotation As Double = 1.414
	Private iv As ImageView
	Type VerticalTextEngineChar (text As String,rect As B4XRect,zeroWordspace As Boolean)
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	MapOfCharAndImage.Initialize
	mRotationRules = presetRotationRules
	mRightAlignRules = presetRightAlignRules
	mCenterAlignRules = presetCenterAlignRules
	mZeroWordspaceRules = presetZeroWordspaceRules
	Dim json As JSONParser
	json.Initialize(presetReplaceJSON)
	mReplacingMap = json.NextObject
End Sub

Public Sub Draw(parent As B4XView,text As String,f As B4XFont,fontname As String,color As Int,bold As Boolean,italic As Boolean,wordspace As Int,linespace As Double,padding As Int,wrap As Boolean,boxWidth As Int,boxHeight As Int, left2right As Boolean, style As String,rotation As Int) As B4XBitmap
	Dim bitmap As B4XBitmap = Draw2(parent,text,f,fontname,color,bold,italic,wordspace,linespace,padding,wrap,boxWidth,boxHeight,left2right,rotation)
	If style <> "" Then
		Dim xIv As B4XView
		Dim iv As ImageView
		iv.Initialize("")
		#if b4j
		iv.SetImage(bitmap)
		If style<>"" Then
			iv.Style = style
		End If
		#End If
	    #if b4a
		iv.Bitmap = bitmap	
	    #End If
		parent.AddView(iv,0,0,-1,-1)
		
		xIv = iv

		If rotation <> 0 Then
			xIv.Rotation = rotation
		End If
		Dim img As B4XBitmap = xIv.Snapshot
		xIv.RemoveViewFromParent
		If rotation <> 0 Then
			img = img.Resize(img.Width/upscaleRatioForRotation,img.Height/upscaleRatioForRotation,True)
		End If
		Return img
	Else
		If rotation <> 0 Then
			Dim xIv As B4XView
			Dim iv As ImageView
			iv.Initialize("")
			#if b4j
			iv.SetImage(bitmap)
			#End If
			#if b4a
			iv.Bitmap = bitmap
			#End If
			xIv = iv
			parent.AddView(xIv,0,0,-1,-1)
			xIv.Rotation = rotation
			Dim img As B4XBitmap = xIv.Snapshot
			xIv.RemoveViewFromParent
			img = img.Resize(img.Width/upscaleRatioForRotation,img.Height/upscaleRatioForRotation,True)
			Return img
		Else
			Return bitmap
		End If
	End If
End Sub

Private Sub Draw2(parent As B4XView,text As String,f As B4XFont,fontname As String,color As Int,bold As Boolean,italic As Boolean,wordspace As Int,linespace As Double,padding As Int,wrap As Boolean,boxWidth As Int,boxHeight As Int, left2right As Boolean,rotation As Int) As B4XBitmap
	Dim cvs1 As B4XCanvas
	cvs1.Initialize(parent)
	If rotation <> 0 Then
		Dim xui As XUI
		f = xui.CreateFont2(f,f.Size*upscaleRatioForRotation)
		boxWidth = boxWidth * upscaleRatioForRotation
		boxHeight = boxHeight * upscaleRatioForRotation
		linespace = linespace * upscaleRatioForRotation
		wordspace = wordspace * upscaleRatioForRotation
		padding = padding * upscaleRatioForRotation
	End If
	Dim lines As List

	If text=previousText And text<>"" Then
		lines=previousLines
	Else
		MapOfCharAndImage.Clear
		lines.Initialize
		Dim runs As List
		Dim useRichText As Boolean = Utils.getSetting("richtext",False)
		If useRichText Then
			Dim parser As SimpleBBCodeParser
			parser.Initialize
			runs = parser.Parse(text)
		Else
			runs.Initialize
			Dim run As TextRun
			run.Initialize
			run.text = text
			runs.Add(run)
		End If
		Dim textImages As List
		textImages.Initialize
		Dim totalTextSB As StringBuilder
		totalTextSB.Initialize
		For Each run As TextRun In runs
			totalTextSB.Append(run.text)
		Next
		Dim totalText As String = totalTextSB.ToString
		
		Dim offsetIndex As Int
		For Each run As TextRun In runs
			Dim fixedRectForRun As B4XRect
			fixedRectForRun.Initialize(0,0,f.Size,f.Size)
			Dim offsetX,offsetY As Double
			Dim horizontal As Boolean
			Dim font As B4XFont
			Dim runColor As Int = color
			Dim size As Double = f.Size
			If useRichText Then
				offsetX = run.offsetX * upscaleRatioForRotation
				offsetY = run.offsetY * upscaleRatioForRotation
				run.fontsize = run.fontsize * upscaleRatioForRotation
				horizontal = run.horizontal
				If run.color <> "" Then
					Dim r,g,b As Int
					r=Regex.Split(",",run.color)(0)
					g=Regex.Split(",",run.color)(1)
					b=Regex.Split(",",run.color)(2)
					Dim xui As XUI
					runColor = xui.Color_RGB(r,g,b)
				End If
				If bold = True And run.bold = False Then
					run.bold = True
				End If
				If italic = True And run.italic = False Then
					run.italic = True
				End If
				Dim name As String
				If run.fontname <> "" Then
					name = run.fontname
				Else
					name = fontname
				End If
				If run.fontsize <> 0 And run.fontsize <> f.Size Then
					size = run.fontsize
					fixedRectForRun.Initialize(0,0,run.fontsize,run.fontsize)
				End If
				#if b4j 
				font = fx.CreateFont(name,size,run.bold,run.italic)
				#End If
				#if b4a
				font = xui.CreateDefaultFont(size)
				#End If
			Else
				font = f
			End If
			If horizontal Then
				Dim c As String = Replace(run.text)
				Dim hte As TextDrawer
				hte.Initialize(parent)
				Dim options As TextDrawingOptions
				options.Initialize
				options.defaultFont = font
				options.defaultColor = runColor
				options.horizontal = True
				Dim textImage As B4XBitmap = hte.Draw(c,fixedRectForRun.Width,fixedRectForRun.Height,options)
				textImages.Add(textImage)
				Dim charItem As VerticalTextEngineChar
				charItem.Initialize
				charItem.text = c
				charItem.rect = fixedRectForRun
				MapOfCharAndImage.Put(textImages.Get(textImages.Size-1),charItem)
			Else
				For i=0 To run.text.Length-1
					Dim c As String=run.text.CharAt(i)
					If Regex.IsMatch("\n",c) Then
						lines.Add(textImages)
						Dim textImages As List
						textImages.Initialize
					Else
						c = Replace(c)
						Dim charItem As VerticalTextEngineChar
						charItem.Initialize
						charItem.text = c
						charItem.rect = fixedRectForRun
						If IsZeroWordspaceChar(c) Then
							Dim previousCharIndex As Int = offsetIndex + i - 1
							If previousCharIndex >= 0 Then
								Dim previousChar As String = totalText.CharAt(previousCharIndex)
								If previousChar == c Then
									charItem.zeroWordspace = True
								End If
							End If
						End If
						Dim textImage As B4XBitmap
						If CharIsFreeHeight(c) Then
							textImage = Text2Image(parent,charItem,font,runColor,wordspace,False,True,fixedRectForRun,padding,offsetX,offsetY)
						Else
							textImage = Text2Image(parent,charItem,font,runColor,wordspace,True,True,fixedRectForRun,padding,offsetX,offsetY)
						End If
						'Dim out As OutputStream = File.OpenOutput(File.DirApp,i&".png",False)
						'textImage.WriteToStream(out,100,"PNG")
						'out.Close
						textImages.Add(textImage)
						MapOfCharAndImage.Put(textImages.Get(textImages.Size-1),charItem)
					End If
				Next
			End If
			offsetIndex = offsetIndex + run.text.Length
		Next
		If textImages.Size > 0 Then 'last line
			lines.Add(textImages)
		End If
		previousLines=lines
		previousText=text
	End If
	
	If wrap Then
		lines=WrapText(lines,boxHeight,wordspace)
		previousLines=lines
	End If

	Dim width,height As Double
	Dim WHs As List
	Dim result As Map=GetWidthAndHeight(lines,wordspace,linespace)
	width=result.Get("width")
	height=result.Get("height")
	WHs=result.Get("WHs")
	Dim bc As BitmapCreator
	bc.Initialize(width,height)
	Dim lineIndex As Int=0
	Dim previousWidth As Double
	For Each textImages As List In lines
		Dim WH As Map=WHs.Get(lineIndex)
		Dim lineWidth As Double = WH.Get("width")
		Dim lineSpaceOffset As Double = 0
		If lineIndex <> lines.Size - 1 Then
			lineSpaceOffset = lineWidth*(linespace-1)
		End If
		lineIndex=lineIndex+1
		If textImages.Size = 0 Then
			previousWidth=previousWidth+WH.Get("width")+lineSpaceOffset
			Continue
		End If
		Dim offsetY As Double = 0
		Dim firstChar As VerticalTextEngineChar = MapOfCharAndImage.Get(textImages.Get(0))
		If CharMovingUpNeeded(firstChar.text) Then
			Dim canvas1 As B4XCanvas
			canvas1.Initialize(parent)
			Dim fr As B4XRect=canvas1.MeasureText(firstChar.text,f)
			'offset = Max(Abs(fr.CenterY),fr.Height) - fixedRect.Height + wordspace
			offsetY = fr.Height - firstChar.rect.Height - fr.CenterY + wordspace
			If offsetY > 0 Then
				offsetY = 0
			End If
		End If
		
		Dim X As Double
		If left2right Then
			X = previousWidth
		Else
			X = previousWidth + lineSpaceOffset
		End If
		
		Dim Y As Double=offsetY
		Dim index As Int=0
		For Each img As B4XBitmap In textImages
			Dim charItem As VerticalTextEngineChar = MapOfCharAndImage.get(img)
			If left2right == False Then
				X = width-(previousWidth+WH.Get("width"))
				If img.Width <> WH.Get("width")  Then
					X = X + WH.Get("width")/2 - img.Width/2
				End If
			Else
				X = previousWidth
				If img.Width <> WH.Get("width")  Then
					X = X + WH.Get("width")/2 - img.Width/2
				End If
			End If
			
			Dim rect As B4XRect
			rect.Initialize(X,Y,X+img.Width,Y+img.Height)

			bc.DrawBitmap(img,rect,True)
			Y = Y + img.Height
			index=index+1
		Next
		
		previousWidth=previousWidth+WH.Get("width")+lineSpaceOffset
	Next
	Return bc.Bitmap
End Sub

Private Sub Replace(character As String) As String
	If mReplacingMap.IsInitialized Then
		If mReplacingMap.ContainsKey(character) Then
			Return mReplacingMap.Get(character)
		End If
	End If
	Return character
End Sub

Public Sub getText As String
	Dim sb As StringBuilder
	sb.Initialize
	For Each textImages As List In previousLines
		For Each img As B4XBitmap In textImages
			Dim charItem As VerticalTextEngineChar = MapOfCharAndImage.get(img)
			sb.Append(charItem.text)
		Next
		sb.Append(CRLF)
	Next
	Return sb.ToString.Trim
End Sub

Sub GetWidthAndHeight(lines As List,wordspace As Int,linespace As Double) As Map
	Dim lineSpaceAdded As Double
	Dim result As Map
	result.Initialize
	Dim width,height As Double
	Dim WHs As List
	WHs.Initialize
	Dim index As Int = 0
	Dim maxLineWidth As Double
	For Each textImages As List In lines
		Dim WH As Map
		WH.Initialize
		Dim lineHeight As Double
		Dim lineWidth As Double
		If textImages.Size > 0 Then
			For Each textImage As B4XBitmap In textImages
				lineHeight=lineHeight+textImage.Height
				Dim charItem As VerticalTextEngineChar = MapOfCharAndImage.get(textImage)
				If charItem.zeroWordspace Then
					lineHeight = lineHeight + wordspace
				End If
				lineWidth=Max(lineWidth,textImage.Width)
			Next
		End If
		width=width+Ceil(lineWidth)
		height=Max(lineHeight,height)
		maxLineWidth = Max(lineWidth,maxLineWidth)
		WH.Put("width",lineWidth)
		WH.Put("height",lineHeight)
		WHs.Add(WH)
		If index <> lines.Size -1 Then
			lineSpaceAdded = lineSpaceAdded + Ceil((linespace-1) * lineWidth)
		End If
		index = index + 1
	Next
	Dim index As Int
	For Each WH As Map In WHs
		Dim lineWidth As Double = WH.Get("width")
		If lineWidth = 0 Then 'empty text line
			WH.put("width",maxLineWidth)
			width = width + maxLineWidth
			If index <> lines.Size -1 Then
				lineSpaceAdded = lineSpaceAdded + Ceil((linespace-1) * maxLineWidth)
			End If
		End If
		index = index + 1
	Next
	width = width + lineSpaceAdded
	result.Put("width",width)
	result.Put("height",height)
	result.Put("WHs",WHs)
	Return result
End Sub

Sub WrapText(lines As List,boxHeight As Int,wordspace As Int) As List
	Dim newLines As List
	newLines.Initialize
	For i=0 To lines.Size-1
		Dim textImages As List=lines.Get(i)
		If textImages.Size = 0 Then
			newLines.Add(textImages)
			Continue
		End If
		Dim splitedLines As List
		splitedLines.Initialize
		Dim heightSum As Int
		Dim index As Int=0
		Dim nextlineStartIndex As Int=0
		For Each img As B4XBitmap In textImages 'text line
			Dim imgHeight As Double = img.Height
			Dim charItem As VerticalTextEngineChar = MapOfCharAndImage.get(img)
			If charItem.zeroWordspace Then
				imgHeight = imgHeight + wordspace
			End If
			heightSum=imgHeight+heightSum
			
			If heightSum>boxHeight-imgHeight*2/3 Then
				Dim imgs As List
				imgs.Initialize
				For j=nextlineStartIndex To index
					imgs.Add(textImages.Get(j))
				Next
				splitedLines.Add(imgs)
				nextlineStartIndex=index+1
				heightSum=0
			End If
			index=index+1
		Next
		
		If nextlineStartIndex<=textImages.Size-1 Then
			Dim imgs As List
			imgs.Initialize
			For j=nextlineStartIndex To textImages.Size-1
				imgs.Add(textImages.Get(j))
			Next
			splitedLines.Add(imgs)
		End If
		newLines.AddAll(splitedLines)
	Next
	Return newLines
End Sub

Sub Text2Image(parent As B4XView, c As VerticalTextEngineChar,f As B4XFont,color As Int,wordspace As Int,fixedHeight As Boolean,fixedWidth As Boolean,fixedRect As B4XRect,padding As Double,shiftX As Double,shiftY As Double) As B4XBitmap
	If c.zeroWordspace Then
		wordspace = 0
	End If
	Dim cvs1 As B4XCanvas
	cvs1.Initialize(parent)
	Dim r As B4XRect=cvs1.MeasureText(c.text,f)
	Dim width,height As Double
	If fixedWidth Then
		width=Ceil(fixedRect.Width)
	Else
		width=r.Width
	End If
	If fixedHeight Then
		height=Ceil(fixedRect.Height)
	Else
		height=r.Height
	End If

	Dim offsetX As Double
	offsetX = 0 + shiftX
	Dim X,Y As Double
	X= DipToCurrent(offsetX)
	#if b4a
	Y= DipToCurrent(height) + shiftY - 10*(fixedRect.Height/30)
	#End If
	#if b4j
	Y= DipToCurrent(height) + shiftY - 5*(fixedRect.Height/30)
	#End If
	
    width = DipToCurrent(width)
	height = DipToCurrent(height)
	Dim Canvas1 As B4XCanvas
	Canvas1.Initialize(parent)
	Canvas1.Resize(width,height+wordspace+padding)

	Dim alignment As String="LEFT"
	If CharIsCenterAligned(c.text) Then
		If CharISNumberCharacter(c.text) Then
			X=width/2 + offsetX
			alignment = "CENTER"
		Else
			If r.CenterX >= fixedRect.Width/2 Then
				X = offsetX
			Else
				X = r.CenterX + offsetX
			End If
		End If
	Else if CharIsRightAligned(c.text) Then
		If fixedHeight Then
			X = width - r.Width*2 - r.Left + shiftX
			Y = r.Height + Abs(r.Top) + shiftY
		Else
			X = width - r.Width*2 - r.Left + shiftX
		End If
	End If
	If CharNeedRotation(c.text) Then
		Y=r.Width + r.Left + shiftY
		If CharIsCenterAligned(c.text) Then
			X = offsetX + r.Height
			Y = Y + wordspace + padding
			Canvas1.DrawTextRotated(c.text,X,Y,f,color,"RIGHT",90)
		Else
			Canvas1.DrawTextRotated(c.text,X,Y,f,color,alignment,-90)
		End If
	Else
		If fixedHeight=True And fixedWidth=False Then 'character
			Y=fixedRect.Height + shiftY
			X=offsetX
		End If
		Canvas1.DrawText(c.text,X,y,f,color,alignment)
	End If
	#if b4a
	Dim bm As B4XBitmap = Canvas1.CreateBitmap
	Dim bc As BitmapCreator
	bc.Initialize(bm.Width,bm.Height)
	bc.DrawBitmap(bm,Canvas1.TargetRect,False)
	Canvas1.ClearRect(Canvas1.TargetRect)
	Return bc.Bitmap
	#End If
	#if b4j
	Return Canvas1.CreateBitmap
	#End If
End Sub

Sub IsZeroWordspaceChar(c As String) As Boolean
	Try
		Return Regex.IsMatch(mZeroWordspaceRules,c)
	Catch
		Log(LastException)
		Return False
	End Try
End Sub

Sub CharNeedRotation(c As String) As Boolean
	Try
		Return Regex.IsMatch(mRotationRules,c)
	Catch
		Log(LastException)
		Return Regex.IsMatch(presetRotationRules,c)
	End Try
End Sub

Sub CharIsCenterAligned(c As String) As Boolean
	Try
		Return Regex.IsMatch(mCenterAlignRules,c)
	Catch
		Log(LastException)
		Return Regex.IsMatch(presetCenterAlignRules,c)
	End Try
End Sub

Sub CharMovingUpNeeded(c As String) As Boolean
	If mFirstCharToMoveUpRules = "" Then
		Return False
	End If
	Try
		Return Regex.IsMatch(mFirstCharToMoveUpRules,c)
	Catch
		Return False
	End Try
End Sub

Sub CharISNumberCharacter(c As String) As Boolean
	Return Regex.IsMatch("[⁉0-9a-zA-Z]",c)
End Sub

Sub CharISEnglishPuctuations(c As String) As Boolean
	Return Regex.IsMatch("[\.,!?]",c)
End Sub

Sub CharIsRightAligned(c As String) As Boolean
	Try
		Return Regex.IsMatch(mRightAlignRules,c)
	Catch
		Log(LastException)
		Return Regex.IsMatch(presetRightAlignRules,c)
	End Try
End Sub

private Sub CharIsFreeHeight(c As String) As Boolean
	Try
		Return Regex.IsMatch(mFreeHeightRules,c)
	Catch
		Log(LastException)
	End Try
	Return False
End Sub


Public Sub setFreeHeightRules(rules As String)
	mFreeHeightRules = rules
End Sub

Public Sub setRightAlignRules(rules As String)
	mRightAlignRules = rules
End Sub

Public Sub setCenterAlignRules(rules As String)
	mCenterAlignRules = rules
End Sub

Public Sub setRotationRules(rules As String)
	mRotationRules = rules
End Sub

Public Sub setZeroWordspaceRules(rules As String)
	mZeroWordspaceRules = rules
End Sub

Public Sub setFirstCharToMoveUpRules(rules As String)
	mFirstCharToMoveUpRules = rules
End Sub

Public Sub setReplacingJSON(json As String)
	If json = "" Then
		Return
	End If
	Try
		Dim parser As JSONParser
		parser.Initialize(json)
		mReplacingMap = parser.NextObject
	Catch
		Log(LastException)
	End Try
End Sub
