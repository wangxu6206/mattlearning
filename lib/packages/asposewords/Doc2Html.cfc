<cfcomponent displayname="Doc2Html" output="false">

	<cfset variables.instance = {}>

	<cffunction name="init" access="public" output="false" returnType="any" hint="initialize the AsposeConversion library classes to implement the conversion from Word to (X)Html">

		<cfreturn this>
	</cffunction>


	<cffunction name="config" access="public" output="false" hint="config the options for customizing the conversion">
		<cfargument name="imageSaveDirectory" type="string" required="false" default="#expandPath('./')#" hint="specific the directory for saving images">
		<cfargument name="formatOutput" type="boolean" required="false" default=true hint="Whether to add tabs/linefeeds etc to html output or not">
		<cfargument name="classFlag" type="boolean" required="false" default=true hint="set the class attribute for html element or not">
		<cfargument name="classChange" type="boolean" required="false" default=true hint="change the list class from ul|ol tag to li tag">
		<cfargument name="includeBodyTags" type="boolean" required="false" default=true hint="set to wrapp the content with <body></body> or not">
		<cfargument name="asposewordsPath" type="string" required="false" default="#expandPath('./')#asposewords.jar" hint="specific the path of asposewords jar file">
		<cfargument name="jerichohtmlPath" type="string" required="false" default="#expandPath('./')#jerichohtml.jar" hint="specific the path of jerichohtml jar file">

		<cfset variables.instance.imagedirectory = arguments.imageSaveDirectory>
		<cfset variables.instance.formatOutput = arguments.formatOutput>
		<cfset variables.instance.classFlag = arguments.classFlag>
		<cfset variables.instance.classChange = arguments.classChange>
		<cfset variables.instance.includeBodyTags = arguments.includeBodyTags>
		<cfset variables.instance.paths.asposewords = arguments.asposewordsPath>
		<cfset variables.instance.paths.jerichohtml = arguments.jerichohtmlPath>
		<cfset variables.instance.ptstopixelratio = 1.25>
		<cfset variables.instance.imageCounter=0>

	</cffunction>


	<cffunction name="createImageDirectory" access="private" output="false" returnType="string"  hint="function to create the image directory for saving the images extracted from doc">

		<cfset var imageDirectory = "">
		<cfset var preImageDirectory = "">
		<cfset var dirName = "">

		<cfset preImageDirectory = variables.instance.imagedirectory>
		<cfset imageDirectory = replace(preImageDirectory, " ", "_", "All")>

		<cfif !DirectoryExists(imageDirectory)>
			<cfdirectory action = "create" directory = "#imageDirectory#" >
		</cfif>

		<cfreturn imageDirectory>
	</cffunction>


	<cffunction name="createDOCDOM" access="public" output="false" returnType="struct" hint="Function reads a doc file, parses it into a DOM structure">
		<cfargument name="body" type="any" required="true">

		<cfset var oParagraph = "">
		<cfset var itemProcessed = false>
		<cfset var type = "">
		<cfset var styleName = "">
		<cfset var content = "">
		<cfset var para = {}>
		<cfset var item = {}>
		<cfset var DOM = []>
		<cfset var ListIDFlag = -1>
		<cfset var ListFlag = false>
		<cfset var listCounter = 0>
		<cfset var nodeIndex = 0>
		<cfset var tempRow = "">
		<cfset var node = "">
		<cfset var nodeType = "">
		<cfset var headingPara = "">
		<cfset var stageListArray = "">
		<cfset var innerNode = "">
		<cfset var listPara = "">
		<cfset var paraPara = "">
		<cfset var table = "">
		<cfset var tablePara = "">
		<cfset var shape = "">
		<cfset var shapePara = "">
		<cfset var shapeStruct = "">
		<cfset var unknownPara = "">
		<cfset var listCursor1 = 0>
		<cfset var nodeList = body.getChildNodes()>

		<cfloop condition="#nodeIndex LTE nodeList.getCount()-1#">
			<cfset node = nodeList.get(nodeIndex)>
			<cfset nodeType = node.getNodeType()>

			<cfif nodeType EQ 8>
				<cfset oParagraph = node>
				<cfset itemProcessed = false>

				<cfif  NOT itemProcessed AND oParagraph.getParagraphFormat().isHeading()>
					<cfset itemProcessed = true>
					<cfset headingPara = createHeadingStructure(oParagraph)>
					<cfset arrayAppend(DOM,headingPara)>
				</cfif>

				<cfif NOT itemProcessed AND oParagraph.getParagraphFormat().isListItem()>
					<cfset itemProcessed = true>
					<cfset stageListArray = []>
					<cfloop from="#nodeIndex#" to="#nodeList.getCount()-1#" index="listCursor1">
					    <cfset innerNode = nodeList.get(listCursor1)>
						<cfif innerNode.getNodeType() EQ 8>
							<cfif innerNode.getParagraphFormat().isListItem() AND (NOT innerNode.getParagraphFormat().isHeading())>
							  	<cfset arrayAppend(stageListArray,innerNode)>
							<cfelse>
								<cfbreak>
							</cfif>
						<cfelse>
							<cfbreak>
						</cfif>
						<cfset nodeIndex = listCursor1>
					</cfloop>
					<cfset listPara = createListStructure(stageListArray)>
					<cfset arrayAppend(DOM, listPara)>
				</cfif>

				<cfif NOT itemProcessed>
					<cfset itemProcessed = true>
					<cfset paraPara = createParagraphStructure(oParagraph)>
					<cfset arrayAppend(DOM, paraPara)>
				</cfif>
			<cfelseif nodeType EQ 5>
				<cfset table = node>
				<cfset tablePara = createTableStructure(table)>
				<cfset arrayAppend(DOM, tablePara)>
			<cfelseif nodeType EQ 12>
				<cfset shape = node>
				<cfset shapeStruct = createShapeStructure(shape)>
				<cfset shapePara = {}>
				<cfset shapePara.pType = shapeStruct.type>
				<cfset shapepara.styleName = "shape">
				<cfset shapePara.struct = shapeStruct>
				<cfset arrayAppend(DOM, shapePara)>
			<cfelse>
				<cfset unknownPara = createUnknownStructure(node)>
				<cfset arrayAppend(DOM,unknownPara)>
			</cfif>

			<cfset nodeIndex = nodeIndex + 1>
	    </cfloop>

		<cfset struc = {}>
		<cfset struc.DOM = DOM>
		<cfreturn struc>
	</cffunction>


	<cffunction name="createHeadingStructure" access="private" output="false" returnType="struct" hint="create the data structure for headings in Word">
		<cfargument name="oParagraph" type="any" required="true" hint="paragraph node object parsed by asposewords">

		<cfset var para = "">
		<cfset var headingSize = "">

		<cfset para = {}>
		<cfset para.ptype = "Heading">
		<cfset headingSize = #oParagraph.getParagraphFormat().getStyle().getStyleIdentifier()#>
		<cfset para.styleName = replace(oParagraph.getParagraphFormat().getStyleName()," ","_","All")>
		<cfset para.text = oParagraph.getText()>
		<cfset para.TRNumber = oParagraph.getChildNodes().getCount()>
		<cfset para.TRArray = []>
		<cfset para.shapeList = []>
		<cfset para.TRNumber = setAttribute(para.TRArray, para.TRNumber, oParagraph, para.shapeList)>

		<cfreturn para>
	</cffunction>


	<cffunction name="createParagraphStructure" access="private" output="false" returnType="struct" hint="create the data structure for paragraphs in Word">
		<cfargument name="oParagraph" type="any" required="true" hint="paragraph node object parsed by asposewords">

		<cfset var para = "">
		<cfset var NodeType = "">
		<cfset var shapes = "">
		<cfset var shape = "">
		<cfset var imageType = "">
		<cfset var image = "">
		<cfset var shapesArray = "">
		<cfset var shape = "">
		<cfset var shapeIndex = "">
		<cfset para = {}>
		<cfset para.ptype = "Paragraph">
		<cfset para.styleName = replace(oParagraph.getParagraphFormat().getStyleName()," ","_","All")>
		<cfset para.text = oParagraph.getText()>
		<cfset para.TRNumber = oParagraph.getChildNodes().getCount()>
		<cfset para.TRArray = []>
		<cfset para.shapeList = []>
		<cfset para.TRNumber = setAttribute(para.TRArray, para.TRNumber, oParagraph, para.shapeList)>

		<cfreturn para>
	</cffunction>


	<cffunction name="createListStructure" access="private" output="false" returnType="struct" hint="create the data structure for list element">
		<cfargument name="stagelistArray" type="array" required="true" hint="array of paragraph node object in list parsed by asposewords">

		<cfset var para = "">
		<cfset var listItemNode = "">
		<cfset var currentListID = "">
		<cfset var currentListLevel = "">
		<cfset var currentListIdentifier = "">
		<cfset var item = "">
		<cfset var listCursor2 = "">
		<cfset var m = "">
		<cfset var itemCusor = "">
		<cfset var itemFlag = "">
		<cfset para = {}>
		<cfset para.ptype = "List">
		<cfset para.styleName = "List">
		<cfset para.listItemNum = 0>
		<cfset para.ListItemArray = []>

		<cfloop from="1" to="#arrayLen(stageListArray)#" index="listCursor2">
			<cfset listItemNode = stageListArray[listCursor2]>
			<cfset currentListID = listItemNode.getListFormat().getList().getListId()>
			<cfset currentListLevel = listItemNode.getListFormat().getListLevelNumber()>
			<cfset currentListIdentifier = listItemNode.getListFormat().getList().getListLevels().get(0).getNumberStyle()>

			<cfset item = {}>
			<cfset item.styleName = replace(listItemNode.getParagraphFormat().getStyleName()," ","_","All")>
			<cfset item.text = listItemNode.getText()>
			<cfset item.levelPosition = listItemNode.getListFormat().getListLevel().getNumberPosition()>
			<cfset item.ID_Flag = currentListID>
			<cfset item.level_Flag = currentListLevel>
			<cfif currentListIdentifier EQ 23 >
				<cfset item.style = "unordered">
			<cfelse>
				<cfset item.style = "ordered">
			</cfif>

			<!---************ caculate the list level starts************ --->
			<cfif listCursor2 EQ 1>
				<cfset item.itemLevel = 0>
			<cfelse>
				<cfset itemFlag = false>
				<cfloop from="1" to="#arrayLen(para.ListItemArray)#" index="m">
					<cfset itemCusor = para.ListItemArray[m]>
					<cfif (currentListID EQ itemCusor.ID_Flag) && (currentListLevel EQ itemCusor.level_Flag) OR (item.levelPosition EQ itemCusor.levelPosition)>
						<cfset item.itemLevel = itemCusor.itemLevel>
						<cfset itemFlag = true>
					</cfif>
				</cfloop>
				<cfif NOT itemFlag>
					<cfset item.itemLevel = para.ListItemArray[arrayLen(para.ListItemArray)].itemLevel+1>
				</cfif>
			</cfif>
			<!---************ caculate the list level ends************ --->

			<cfset item.itemTRNumber = listItemNode.getChildNodes().getCount()>
			<cfset item.itemTRArray = []>
			<cfset item.shapeArray = []>
			<cfset item.itemTRNumber = setAttribute(item.itemTRArray, item.itemTRNumber, listItemNode, item.shapeArray)>
			<cfset arrayAppend(para.ListItemArray,item)>
		</cfloop>

		<cfreturn para>
	</cffunction>


	<cffunction name="createTableStructure" access="private" output="false" returnType="struct" hint="create the data structure for table in Word">
		<cfargument name="tableNode" type="any" required="true" hint="table node object parsed by asposewords">

		<cfset var para = {}>
		<cfset var cellChildIndex = 0>
		<cfset var tempRow = "">
		<cfset var rowNode = "">
		<Cfset var tempCell = "">
		<cfset var cellNode = "">
		<cfset var cellChildrenList = "">
		<cfset var cellChildNode = "">
		<cfset var cellParagraph = "">
		<cfset var itemProcessed = "">
		<cfset var headingpara = "">
		<cfset var stageListArray = "">
		<cfset var innerNode = "">
		<cfset var headingPara = "">
		<cfset var listPara = "">
		<cfset var paraPara = "">
		<cfset var innertable = "">
		<cfset var cellTablePara = "">
		<cfset var innerShape = "">
		<cfset var shapePara = "">
		<cfset var r = 0>
		<cfset var c = 0>

		<cfset para.ptype = "Table">
		<cfset para.styleName = "Table">
		<cfset para.rowList = []>

		<cfloop from="0" to="#tableNode.getRows().getCount()-1#" index="r">
			<cfset tempRow = tableNode.getRows().get(r)>
			<cfset rowNode = {}>
			<cfset rowNode.attributes = []>
			<cfset rowNode.cellList = []>

			<cfloop from="0" to="#tempRow.getCells().getCount()-1#" index="c">
				<cfset tempCell = tempRow.getCells().get(c)>
				<cfset cellNode = {}>
				<cfset cellNode.attributes = []>
				<cfset cellNode.text = tempCell.getText()>
				<cfset cellNode.childList = []>
				<cfset cellNode.cellWidth = tempCell.getCellFormat().getwidth()>
				<cfset cellChildrenList = tempCell.getChildNodes()>

				<cfloop condition="#cellChildIndex LTE cellChildrenList.getCount()-1#">
					<cfset cellItemProcessed = false>
					<cfset cellChildNode = cellChildrenList.get(cellChildIndex)>
					<cfif (cellChildNode.getNodeType() EQ 8)>
						<cfset cellParagraph = cellChildNode>
						<cfset itemProcessed = false>

						<cfif  NOT itemProcessed AND cellParagraph.getParagraphFormat().isHeading()>
							<cfset itemProcessed = true>
							<cfset headingPara=createHeadingStructure(cellParagraph)>
							<cfset arrayAppend(cellNode.childList,headingPara)>
						</cfif>

						<cfif  NOT itemProcessed AND cellParagraph.getParagraphFormat().isListItem()>
							<cfset itemProcessed = true>
							<cfset stageListArray = []>
							<cfloop from="#cellChildIndex#" to="#cellChildrenList.getCount()-1#" index="listCursor1">
							    <cfset innerNode = cellChildrenList.get(listCursor1)>
								<cfif innerNode.getNodeType() EQ 8>

									<cfif innerNode.getParagraphFormat().isListItem() AND (NOT innerNode.getParagraphFormat().isHeading())>
									  	<cfset arrayAppend(stageListArray,innerNode)>
									<cfelse>
										<cfbreak>
									</cfif>
								<cfelse>
									<cfbreak>
								</cfif>
								<cfset cellChildIndex = listCursor1>
							</cfloop>
							<cfset listPara = createListStructure(stageListArray)>
							<cfset arrayAppend(cellNode.childList,listPara)>
						</cfif>

						<cfif NOT itemProcessed>
							<cfset itemProcessed = true>
							<cfset paraPara = createParagraphStructure(cellParagraph)>
							<cfset arrayAppend(cellNode.childList,paraPara)>
						</cfif>

					<cfelseif (cellChildNode.getNodeType() EQ 5)>
						<cfset innertable = cellChildNode>
						<cfset cellTablePara = createTableStructure(innertable)>
						<cfset arrayAppend(cellNode.childList,cellTablePara)>
					<cfelseif (cellChildNode.getNodeType() EQ 12)>
						<cfset innerShape = cellChildNode>
						<cfset shapeStruct = createShapeStructure(innerShape)>
						<cfset shapePara = {}>
						<cfset shapePara.pType = shapeStruct.type>
						<cfset shapePara.struct = shapeStruct>
						<cfset arrayAppend(cellNode.childList,shapePara)>
					<cfelse>
						<cfset innerShape = cellChildNode>
						<cfset shapeStruct = createShapeStructure(innerShape)>
						<cfset shapePara = {}>
						<cfset shapePara.pType = shapeStruct.type>
						<cfset shapePara.struct = shapeStruct>
						<cfset arrayAppend(cellNode.childList,shapePara)>
					</cfif>

					<cfset cellChildIndex = cellChildIndex + 1>
				</cfloop>
				<cfset cellChildIndex = 0>
				<cfset arrayAppend(rowNode.cellList,cellNode)>
			</cfloop>
			<cfset arrayAppend(para.rowList,rowNode)>
		</cfloop>

		<cfreturn para>
	</cffunction>


	<cffunction name="createShapeStructure" access="private" output="false" returnType="struct" hint="create the data structure for shape in Word">
			<cfargument name="shapeNode" type="any" required="true" hint="shape node object parsed by asposewords">

			<cfset var shapeArray = []>
			<cfset var NodeType = createObject("java", "com.aspose.words.NodeType", variables.instance.paths.asposewords)>
			<cfset var shapes = "">
			<cfset var shape = "">
			<cfset var shapeStruct = "">
			<cfset var imageData = "">
			<cfset var image = "">
			<cfset var MessageFormat = "">
			<cfset var imageFileName = "">
			<cfset var shapeIndex = "">
			<cfset var imageType = "">
			<cfset var RenderedImage = "">
			<cfset var BAIStream = "">
			<cfset var shape=arguments.shapeNode>

			<cfset shapeStruct={}>
			<cfset shapeStruct.type="shape">
			<cfset shapeStruct.imageList=[]>
			<cfset shapeStruct.shapeHeight=shape.getHeight()>
			<cfset shapeStruct.shapeWidth=shape.getWidth()>
			<cfif shape.hasImage()>
				<cfset imageData=shape.getImageData()>

				<cfswitch expression="#imageData.getImageType()#">
					<cfcase value="0">
						<cfset imageType="NO_IMAGE">
					</cfcase>
					<cfcase value="1">
						<cfset imageType="unknown">
					</cfcase>
					<cfcase value="2">
						<cfset imageType="emf">
					</cfcase>
					<cfcase value="3">
						<cfset imageType="wmf">
					</cfcase>
					<cfcase value="4">
						<cfset imageType="pict">
					</cfcase>
					<cfcase value="5">
						<cfset imageType="jpeg">
					</cfcase>
					<cfcase value="6">
						<cfset imageType="png">
					</cfcase>
					<cfcase value="7">
						<cfset imageType="bmp">
					</cfcase>
					<cfdefaultcase>
					</cfdefaultcase>
				</cfswitch>
				<cfset image = {}>
				<cfset image.type = imageType>
				<cfset image.heightPoints = imageData.getImageSize().getHeightPoints()>
				<cfset image.widthPoints = imageData.getImageSize().getWidthPoints()>
				<cfset image.heightPixels = imageData.getImageSize().getHeightPixels()>
				<cfset image.widthPixels = imageData.getImageSize().getWidthPixels()>
				<cfset image.horizontalResolution = imageData.getImageSize().getHorizontalResolution()>
				<cfset image.verticalResolution = imageData.getImageSize().getVerticalResolution()>

				<!--- save the image into the specific directory --->
				<cfset imageFileName = "image_" & #variables.instance.imageCounter# & "." & #imageType#>
				<cfset imageDirectory = createImageDirectory()>
				<cfset imageData.save(imageDirectory & imageFileName)>
				<cfset image.imagePath = imageDirectory & imageFileName>
				<cfset arrayAppend(shapeStruct.imageList,image)>
			</cfif>

			<cfset variables.instance.imageCounter = variables.instance.imageCounter+1>

		<cfreturn shapeStruct>
	</cffunction>


	<cffunction name="createTextRunStruct" access="private" output="false" returnType="struct" hint="Function to create data structure for text run in every paragraph ">
		<cfargument name="textRunNode" type="any" required="true" hint="text run node object parsed by asposewords">
		<cfargument name="textRunString" type="string" required="true" hint="text of text run node">

		<cfset var textString = "">
		<cfset var i = 0>
		<cfset var newTRNumber = 0>
		<cfset var paraChild = "">
		<cfset var textString = "">
		<cfset var textRun = "">

		<cfscript>
			textString = arguments.textRunString;

			textRun = {};
			textRun.text = textString;
			textRun.TRStyleName = arguments.textRunNode.getFont().getStyleName();
			textRun.type = "textrun";
			textRun.attributes = {};
			textRun.attributes.isBold = arguments.textRunNode.getFont().getBold();
			textRun.attributes.isItalic = arguments.textRunNode.getFont().getItalic();
			textRun.attributes.isStrikeThrough = arguments.textRunNode.getFont().getStrikeThrough();
			textRun.attributes.isHyperlink = false;
			if(arguments.textRunNode.getFont().getUnderline() EQ 1)
			{
				textRun.attributes.isUnderlined = true;
			}
			else
			{
				textRun.attributes.isUnderlined = false;
			}

			if(arguments.textRunNode.getFont().getSubscript())
			{
				textRun.attributes.isSubScript = true;
			}
			else
			{
				textRun.attributes.isSubScript = false;
			}
			if(arguments.textRunNode.getFont().getSuperscript())
			{
				textRun.attributes.isSuperScript = true;
			}
			else
			{
				textRun.attributes.isSuperScript = false;
			}

			//add more style judging attributes here...
		</cfscript>

		<cfreturn textRun>
	</cffunction>


	<cffunction name="createUnhandledStructure" access="private" output="false" returnType="struct" hint="create the data structure for unhandled element in Word">
		<cfargument name="unhandledNode" type="any" required="true">

		<cfset para = {}>
		<cfset para.ptype ="Unhandled">
		<cfset para.styleName = "Unhandled">
		<cfset para.text = "Unhandled elememt skipped">
		<cfset para.TRNumber = 0>
		<cfset para.TRArray = []>

		<cfreturn para>
	</cffunction>


	<cffunction name="renderHTML" access="public" output="false" returnType="string" hint="Function to parse the DOM and render content into html ">
		<cfargument name="aDOM" type="array" required="true" hint="the complete DOM struct parsed from Word">

  	   	<cfset var DOM = arguments.aDOM>
		<cfset var htmlOutput = createObject( "java", "java.lang.StringBuffer" ).init()>
		<cfset var headingHtml ="">
		<cfset var paragraphHtml ="">
		<cfset var listHtml ="">
		<cfset var tableHtml ="">
		<cfset var unhandledHtml="">

		<cfif variables.instance.includeBodyTags >
			<cfset htmlOutput.append("<body>")>
		</cfif>

		<cfloop index="i" from="1" to="#ArrayLen(DOM)#">
			<cfif DOM[i].pType EQ "Heading">
				<cfset headingHtml = renderHeadingToHtml(DOM[i], false)>
				<cfset htmlOutput.append(headingHtml)>
			</cfif>

			<cfif DOM[i].pType EQ "paragraph">
				<cfset paragraphHtml = renderParagraphToHtml(DOM[i], false)>
				<cfset htmlOutput.append(paragraphHtml)>
			</cfif>

			<cfif DOM[i].pType EQ "list">
				<cfset listHtml = renderListToHtml(DOM[i], false, variables.instance.classChange)>
				<cfset htmlOutput.append(listHtml)>
			</cfif>

			<cfif #DOM[i].pType# EQ "Table">
				<cfset tableHtml = renderTableToHtml(DOM[i], false)>
				<cfset htmlOutput.append(tableHtml)>
			</cfif>

			<cfif #DOM[i].pType# EQ "Unhandled">
				<cfset unhandledHtml = renderUnhandledToHtml(DOM[i], false)>
				<cfset htmlOutput.append(unhandledHtml)>
			</cfif>
		</cfloop>

		<cfif variables.instance.includeBodyTags >
			<cfset htmlOutput.append("</body>")>
		</cfif>

		<cfreturn htmlOutput>

	</cffunction>


	<cffunction name="renderHeadingToHtml" access="private" output="false" returnType="string" hint="Function to render heading element from Doc DOM into html">
		<cfargument name="DomNode" type="any" required="true">
		<cfargument name="cellHeadingFlag" type="boolean" required="true">

		<cfset var headingOutput = createObject( "java", "java.lang.StringBuffer" ).init()>
		<cfset var delimTab = chr(9)>
		<cfset var delimLinefeed = chr(10)>
		<cfset var delimIndent = "   ">
		<cfset var delimStartTag = delimLinefeed & delimTab>
		<cfset var tableIndentDelim = delimTab&delimIndent&delimIndent>
		<cfset var headingFlag = false>
		<cfset var headingSize = #GetToken(arguments.DomNode.styleName, 2, "_")#>

		<cfif NOT variables.instance.formatOutput>
			<cfset delimTab = "">
			<cfset delimLinefeed = "">
			<cfset delimIndent = "">
			<cfset delimStartTag = delimLinefeed & delimTab>
			<cfset tableIndentDelim ="">
		</cfif>

		<cfif variables.instance.classFlag>
			<cfif cellHeadingFlag>
				<cfset headingOutput.append(tableIndentDelim & delimTab)>
			<cfelse>
				<cfset headingOutput.append(delimStartTag)>
			</cfif>

			<cfset headingOutput.append("<h" & headingSize & " class=" & chr(34) & #arguments.DomNode.styleName# & chr(34) & ">")>
			<cfset headingOutput.append(renderHtmlStyle(arguments.DomNode.TRArray, true))>
			<cfset headingOutput.append("</h" & headingSize & ">")>
			<cfset headingOutput.append(delimLinefeed)>
		<cfelse>
			<cfif cellHeadingFlag>
				<cfset headingOutput.append(tableIndentDelim & delimTab)>
			<cfelse>
				<cfset headingOutput.append(delimStartTag)>
			</cfif>
			<cfset headingOutput.append("<h" & headingSize & ">")>
			<cfset headingOutput.append(renderHtmlStyle(arguments.DomNode.TRArray, true))>
			<cfset headingOutput.append("</h" & headingSize & ">")>
			<cfset headingOutput.append(delimLinefeed)>
		</cfif>

		<cfreturn headingOutput>
	</cffunction>


	<cffunction name="renderParagraphToHtml" access="private" output="false" returnType="string" hint="Function to render paragraph element from Doc DOM into html">
			<cfargument name="DomNode" type="any" required="true">
			<cfargument name="cellParagraphFlag" type="boolean" required="true">

			<cfset var paragraphOutput = createObject( "java", "java.lang.StringBuffer" ).init()>
			<cfset var delimTab = chr(9)>
			<cfset var delimLinefeed = chr(10)>
			<cfset var delimIndent = "   ">
			<cfset var delimStartTag = delimLinefeed & delimTab>
			<cfset var tableIndentDelim = delimTab&delimIndent&delimIndent>
			<cfset var headingFlag = false>

			<cfif NOT variables.instance.formatOutput>
				<cfset delimTab = "">
				<cfset delimLinefeed = "">
				<cfset delimIndent = "">
				<cfset delimStartTag = delimLinefeed & delimTab>
				<cfset tableIndentDelim = "">
			</cfif>
			<cfif (len(trim(arguments.DomNode.text)) NEQ 0) OR (arrayLen(DomNode.TRArray) NEQ 0)>
				<cfif variables.instance.classFlag>
					<cfif arguments.cellParagraphFlag>
						<cfset paragraphOutput.append(tableIndentDelim & delimTab)>
					<cfelse>
						<cfset paragraphOutput.append(delimStartTag)>
					</cfif>
					<cfset paragraphOutput.append("<p class=" & chr(34) & arguments.DomNode.styleName & chr(34) & ">")>
					<cfset paragraphOutput.append(renderHtmlStyle(arguments.DomNode.TRArray, headingFlag))>
					<cfset paragraphOutput.append("</p>")>

					<cfset paragraphOutput.append(delimLinefeed)>
				<cfelse>
					<cfif arguments.cellParagraphFlag>
						<cfset paragraphOutput.append(tableIndentDelim & delimTab)>
					<cfelse>
						<cfset paragraphOutput.append(delimStartTag)>
					</cfif>
					<cfset paragraphOutput.append("<p>")>
					<cfset paragraphOutput.append(renderHtmlStyle(arguments.DomNode.TRArray, headingFlag))>
					<cfset paragraphOutput.append("</p>")>

					<cfset paragraphOutput.append(delimLinefeed)>
				</cfif>
			</cfif>
			<cfreturn paragraphOutput>
	</cffunction>


	<cffunction name="renderListToHtml" access="private" output="false" returnType="string" hint="Function to render list element from Doc DOM into html">
			<cfargument name="DomNode" type="any" required="true">
			<cfargument name="cellListFlag" type="boolean" required="true">
			<cfargument name="classChange" type="boolean" required="true">

			<cfset var listOutput = createObject( "java", "java.lang.StringBuffer" ).init()>
			<cfset var listItemNum = "">
			<cfset var listHeight = "">
			<cfset var tempLevel = "">
			<cfset var tempText = "">
			<cfset var tempItemTRArray = "">
			<cfset var tempShapeArray ="">
			<cfset var tempStyle = "">
			<cfset var tempStylename = "">
			<cfset var counterTemp = "">
			<cfset var delimTab = chr(9)>
			<cfset var delimLinefeed = chr(10)>
			<cfset var delimIndent = "   ">
			<cfset var delimStartTag = delimLinefeed & delimTab>
			<cfset var tableIndentDelim = "">
			<cfset var headingFlag = false>
			<cfset var endListTagArray = []>
			<cfset var counter = -1>
			<cfset var index1 = "">
			<cfset var index2 = "">
			<cfset var index3 = "">
			<cfset var index4 = "">
			<cfset var indentIndex1 = "">
			<cfset var indentIndex2 = "">
			<cfset var indentIndex3 = "">
			<cfset var indentIndex4 = "">
			<cfset var indentIndex5 = "">
			<cfset var listType = "">

			<cfif NOT variables.instance.formatOutput>
				<cfset delimTab = "">
				<cfset delimLinefeed = "">
				<cfset delimIndent ="">
				<cfset delimStartTag = delimLinefeed & delimTab>
				<cfset tableIndentDelim = "">
			</cfif>

			<cfif arguments.cellListFlag>
				<cfset tableIndentDelim=delimTab&delimIndent&delimIndent>
			<cfelse>
				<cfset tableIndentDelim="">
			</cfif>

			<cfset listItemNum = arguments.DomNode.listItemNum>
			<cfloop from="1" to="#ArrayLen(arguments.DomNode.listItemArray)#" index="index1">
				<cfset tempLevel = arguments.DomNode.listItemArray[index1].itemLevel>
				<cfset tempText = arguments.DomNode.listItemArray[index1].text>
				<cfset tempItemTRArray = arguments.DomNode.listItemArray[index1].itemTRArray>
				<cfset tempShapeArray = arguments.DomNode.listItemArray[index1].shapeArray>
				<cfset tempStyle = arguments.DomNode.listItemArray[index1].style>
				<cfset tempStylename = arguments.DomNode.listItemArray[index1].styleName>

				<cfif counter LT tempLevel>
					<cfset counter = tempLevel>
					<cfset listOutput.append(delimLinefeed)>

					<cfset listOutput.append(tableIndentDelim)><!--- cell list indent --->
					<cfloop from="0" to="#counter#" index="indentIndex1">
						<cfset listOutput.append(delimTab)>
					</cfloop>
					<cfif tempStyle EQ "unordered">
						<cfif variables.instance.classFlag AND NOT classChange>
							<cfset listOutput.append("<ul class=" & chr(34) & tempStyleName & chr(34) & ">")>
							<cfset listOutput.append(delimLinefeed)>
						<cfelse>
							<cfset listOutput.append("<ul>")>
							<cfset listOutput.append(delimLinefeed)>
						</cfif>
						<cfset arrayAppend(endListTagArray,"</ul>")>
					</cfif>
					<cfif tempStyle EQ "ordered">
						<cfif variables.instance.classFlag AND NOT classChange>
							<cfset listOutput.append("<ol class=" & chr(34) & tempStyleName & chr(34) & ">")>
							<cfset listOutput.append(delimLinefeed)>
						<cfelse>
							<cfset listOutput.append("<ol>")>
							<cfset listOutput.append(delimLinefeed)>
						</cfif>
						<cfset arrayAppend(endListTagArray,"</ol>")>
					</cfif>

					<cfset listOutput.append(tableIndentDelim)><!--- cell list indent --->
					<cfloop from="0" to="#counter#" index="indentIndex2">
						<cfset listOutput.append(delimTab)>
					</cfloop>
					<cfif classChange>
						<cfset listOutput.append(delimIndent & "<li class=" & chr(34) & tempStyleName & chr(34) & " level=" & chr(34) & tempLevel & chr(34) & " listType=" & chr(34) & tempStyle & chr(34) & ">")>
					<cfelse>
						<cfset listOutput.append(delimIndent & "<li>")>
					</cfif>
					<cfset listOutput.append(renderHtmlStyle(tempItemTRArray, headingFlag))>

				<cfelseif counter EQ tempLevel>
					<cfset listOutput.append("</li>" & delimLinefeed)>

					<cfset listOutput.append(tableIndentDelim)><!--- cell list indent --->
					<cfloop from="0" to="#counter#" index="indentIndex1">
						<cfset listOutput.append(delimTab)>
					</cfloop>
					<cfif classChange>
						<cfset listOutput.append(delimIndent & "<li class=" & chr(34) & tempStyleName & chr(34) & " level=" & chr(34) & tempLevel & chr(34) & " listType=" & chr(34) & tempStyle & chr(34) & ">" & renderHtmlStyle(tempItemTRArray, headingFlag ))>
					<cfelse>
						<cfset listOutput.append(delimIndent & "<li>" & renderHtmlStyle(tempItemTRArray, headingFlag ))>
					</cfif>
				<cfelse>
					<cfset listOutput.append("</li>" & delimLinefeed)>
					<cfset endIndex = counter-tempLevel>
					<cfloop from="#arrayLen(endListTagArray)#" to="#arrayLen(endListTagArray)-endIndex+1#" index="index2" step="-1">
						<cfset listOutput.append(tableIndentDelim)><!--- cell list indent --->
						<cfloop from="0" to="#counter#" index="indentIndex1">
							<cfset listOutput.append(delimTab)>
						</cfloop>
						<cfset tempEndTag = endListTagArray[index2]>
						<cfset listOutput.append(tempEndTag & delimLinefeed)>
						<cfset arrayDeleteAt(endListTagArray,arrayLen(endListTagArray))>

						<cfset listOutput.append(tableIndentDelim)><!--- cell list indent --->
						<cfloop from="0" to="#counter-1#" index="indentIndex2">
							<cfset listOutput.append(delimTab)>
						</cfloop>
						<cfset listOutput.append(delimIndent & "</li>" & delimLinefeed)>
						<cfset counter = #counter#-1>
					</cfloop>

					<cfset listOutput.append(tableIndentDelim)><!--- cell list indent --->
					<cfloop from="0" to="#counter#" index="indentIndex3">
							<cfset listOutput.append(delimTab)>
					</cfloop>
					<cfif classChange>
						<cfset listOutput.append(delimIndent & "<li class=" & chr(34) & tempStyleName & chr(34) & " level=" & chr(34) & tempLevel & chr(34) & " listType=" & chr(34) & tempStyle & chr(34) & ">" & renderHtmlStyle(tempItemTRArray, headingFlag ))>

					<cfelse>
						<cfset listOutput.append(delimIndent & "<li>" & renderHtmlStyle(tempItemTRArray, headingFlag ))>
					</cfif>
				</cfif>

			</cfloop>

			<cfif counter NEQ 0>
				<cfset counterTemp = #counter#>
				<cfset listOutput.append("</li>" & delimLinefeed)>
				<cfloop from="#arrayLen(endListTagArray)#" to="2" index="index3" step="-1">

					<cfset listOutput.append(tableIndentDelim)><!--- cell list indent --->
					<cfloop from="0" to="#counterTemp#" index="indentIndex4">
						<cfset listOutput.append(delimTab)>
					</cfloop>
					<cfset tempEndTag = endListTagArray[index3]>
					<cfset listOutput.append(tempEndTag & delimLinefeed)>
					<cfset arrayDeleteAt(endListTagArray,arrayLen(endListTagArray))>

					<cfset listOutput.append(tableIndentDelim)><!--- cell list indent --->
					<cfloop from="0" to="#counterTemp-1#" index="indentIndex5">
						<cfset listOutput.append(delimTab)>
					</cfloop>
					<cfset listOutput.append(delimIndent & "</li>" & delimLinefeed)>
					<cfset counterTemp = #counterTemp#-1>
				</cfloop>
				<cfloop from="#arrayLen(endListTagArray)#" to="1" index="index4" step="-1">
					<cfset lasttempEndTag = endListTagArray[index4]>

					<cfset listOutput.append(tableIndentDelim)><!--- cell list indent --->
				    <cfset listOutput.append(delimTab & lasttempEndTag)>

				    	<cfset listOutput.append(delimLinefeed)>

					<cfset arrayDeleteAt(endListTagArray,arrayLen(endListTagArray))>
				</cfloop>
			<cfelse>
				<cfset listOutput.append("</li>" & delimLinefeed)>
				<cfloop from="#arrayLen(endListTagArray)#" to="1" index="index3" step="-1">
					<cfset lasttempEndTag = endListTagArray[index3]>

					<cfset listOutput.append(tableIndentDelim)><!--- cell list indent --->
					<cfset listOutput.append(delimTab & lasttempEndTag)>

				    <cfset listOutput.append(delimLinefeed)>
				</cfloop>
			</cfif>

			<cfreturn listOutput>
	</cffunction>


	<cffunction name="renderTableToHtml" access="private" output="false" returnType="string" hint="Function to render table element from Doc DOM into html">
			<cfargument name="DomNode" type="any" required="true">
			<cfargument name="cellTableFlag" type="boolean" required="true">

			<cfset var tableOutput = createObject( "java", "java.lang.StringBuffer" ).init()>
			<cfset var tempStyle = "">
			<cfset var Stylename = arguments.DomNode.styleName>
			<cfset var counterTemp = "">
			<cfset var delimTab = chr(9)>
			<cfset var delimLinefeed = chr(10)>
			<cfset var delimIndent = "   ">
			<cfset var delimStartTag = delimLinefeed & delimTab>
			<cfset var tableIndentDelim = delimTab&delimIndent&delimIndent>
			<cfset var headingFlag = false>
			<cfset var endListTagArray = []>
			<cfset var counter = -1>
			<cfset var index1 = "">
			<cfset var index2 = "">
			<cfset var index3 = "">
			<cfset var index4 = "">
			<cfset var tableRowList = "">
			<cfset var rowIndex = "">
			<cfset var rowCellList = "">
			<cfset var cell = "">
			<cfset var cellWidth = "">
			<cfset var cellSegment = "">
			<cfset var cellIndex = "">
			<cfset var cellTxtIndex = "">
			<cfset var listFlag = "">

			<cfif NOT variables.instance.formatOutput>
				<cfset delimTab = "">
				<cfset delimLinefeed = "">
				<cfset delimIndent ="">
				<cfset delimStartTag = delimLinefeed & delimTab>
				<cfset tableIndentDelim = "">
			</cfif>

			<cfif variables.instance.classFlag>
				<cfif arguments.cellTableFlag>
					<cfset tableOutput.append(delimLinefeed & tableIndentDelim & delimTab)>
				<cfelse>
					<cfset tableOutput.append(delimLinefeed & delimTab)>
				</cfif>
				<cfset tableOutput.append("<table border=" & chr(34) & "1" & chr(34) & " class=" & chr(34) & Stylename & chr(34) & ">")>
				<cfset tableOutput.append(delimLinefeed)>
			<cfelse>
				<cfif arguments.cellTableFlag>
					<cfset tableOutput.append(delimLinefeed & tableIndentDelim & delimTab)>
				<cfelse>
					<cfset tableOutput.append(delimLinefeed & delimTab)>
				</cfif>
				<cfset tableOutput.append("<table border=" & chr(34) & "1" & chr(34) & ">")>
				<cfset tableOutput.append(delimLinefeed)>
			</cfif>

			<cfset tableRowList=arguments.DomNode.rowList>
			<cfloop from="1" to="#arrayLen(tableRowList)#" index="rowIndex">
				<cfif arguments.cellTableFlag>
					<cfset tableOutput.append(tableIndentDelim & delimTab & delimIndent)>
					<cfset tableOutput.append("<tr>")>
					<cfset tableOutput.append(delimLinefeed)>
				<cfelse>
					<cfset tableOutput.append(delimTab & delimIndent)>
					<cfset tableOutput.append("<tr>")>
					<cfset tableOutput.append(delimLinefeed)>
				</cfif>

				<cfset rowCellList=tableRowList[rowIndex].cellList>
				<cfloop from="1" to="#arrayLen(rowCellList)#" index="cellIndex">
					<cfset cell=rowCellList[cellIndex]>
					<cfset cellWidth=cell.cellWidth>
					<cfif arguments.cellTableFlag>
						<cfset tableOutput.append(tableIndentDelim & tableIndentDelim)>
					<cfelse>
						<cfset tableOutput.append(tableIndentDelim)>
					</cfif>
					<cfif ((len(trim(cell.text)) NEQ 0) OR ((len(trim(cell.text)) EQ 0) AND cell.childList[1].pType NEQ "Paragraph"))>
						<cfset tableOutput.append("<td colspan=" & chr(34) & 2 & chr(34) & " width=" & chr(34) & cellWidth*variables.instance.ptstopixelratio & chr(34) & ">" )>
					<cfelse>
						<cfset tableOutput.append("<td width=" & chr(34) & cellWidth*variables.instance.ptstopixelratio & chr(34) & ">")>
					</cfif>
					<cfset listFlag=false>

					<cfloop from="1" to="#arrayLen(cell.childList)#" index="cellTxtIndex">
						<cfset cellSegment = cell.childList[cellTxtIndex]>
						<cfif cellSegment.pType EQ "heading">
							<cfset tableOutput.append(delimLinefeed)>
							<cfif arguments.cellTableFlag>
								<cfset tableOutput.append(tableIndentDelim)>
							</cfif>
							<cfset tableOutput.append(renderHeadingToHtml(cellSegment, true))>
						<cfelseif cellSegment.pType EQ "paragraph">
							<cfset tableOutput.append(delimLinefeed)>
							<cfif arguments.cellTableFlag>
								<cfset tableOutput.append(tableIndentDelim)>
							</cfif>
							<cfset tableOutput.append(renderParagraphToHtml(cellSegment,true))>
						<cfelseif cellSegment.pType EQ "list">
							<cfset listFlag = true>
							<cfif arguments.cellTableFlag>
								<cfset tableOutput.append(tableIndentDelim)>
							</cfif>
							<cfset tableOutput.append(renderListToHtml(cellSegment,true,variables.instance.classChange))>
						<cfelseif cellSegment.pType EQ "table">
							<cfif arguments.cellTableFlag>
								<cfset tableOutput.append(tableIndentDelim)>
							</cfif>
							<cfset tableOutput.append(renderTableToHtml(cellSegment, true))>
						<cfelse>

						</cfif>
					</cfloop>

					<cfif listFlag>
						<cfif arguments.cellTableFlag>
							<cfset tableOutput.append(tableIndentDelim)>
						</cfif>
						<cfset tableOutput.append(delimTab & delimIndent & delimIndent & "</td>" & delimLinefeed)>
					<cfelse>
						<cfif arguments.cellTableFlag>
							<cfset tableOutput.append(tableIndentDelim)>
						</cfif>
						<cfset tableOutput.append(tableIndentDelim & "</td>" & delimLinefeed)>
					</cfif>
				</cfloop>
				<cfif arguments.cellTableFlag>
					<cfset tableOutput.append(tableIndentDelim)>
				</cfif>
				<cfset tableOutput.append(delimTab & delimIndent & "</tr>" & delimLinefeed)>
			</cfloop>
			<cfif arguments.cellTableFlag>
				 <cfset tableOutput.append(tableIndentDelim)>
			</cfif>
			<cfset tableOutput.append(delimTab &  "</table>" )>
			<cfif NOT arguments.cellTableFlag>
				<cfset tableOutput.append(delimLinefeed)>
			</cfif>
			<cfreturn tableOutput>
	</cffunction>


	<cffunction name="renderUnhandledToHtml" access="private" output="false" returnType="string" hint="Function to render unhandled element from Doc DOM into html">
		<cfargument name="DomNode" type="any" required="true">
		<cfargument name="cellHeadingFlag" type="boolean" required="true">

		<cfset var unhandledOutput = createObject( "java", "java.lang.StringBuffer" ).init()>
		<cfset var delimTab = chr(9)>
		<cfset var delimLinefeed = chr(10)>
		<cfset var delimIndent = "   ">
		<cfset var delimStartTag = delimLinefeed & delimTab>
		<cfset var tableIndentDelim = delimTab&delimIndent&delimIndent>

		<cfif NOT variables.instance.formatOutput>
			<cfset delimTab = "">
			<cfset delimLinefeed = "">
			<cfset delimIndent = "">
			<cfset delimStartTag = delimLinefeed & delimTab>
			<cfset tableIndentDelim = "">
		</cfif>

		<cfset unhandledOutput.append(delimStartTag & "<p style=" & chr(34) & "color:red;" & chr(34) & ">")>
		<cfset unhandledOutput.append(arguments.DomNode.text & "</p>" & delimLinefeed)>

		<cfreturn >
	</cffunction>


	<cffunction name="renderHtmlStyle" access="private" output="false" returnType="string" hint="function to set the text run style in the process of rendering html">
		<cfargument name="TRArray" type="array" required="true">
		<cfargument name="headingFlag" type="boolean" required="true">

		<cfset var i = 0>
		<cfset var j = 0>
		<cfset var tempAttr = "">
		<cfset var tempText = "">
		<cfset var EndTagList = "">
		<cfset var oHeadingFlag=arguments.headingFlag>
		<cfset var output = createObject( "java", "java.lang.StringBuffer" ).init()>
		<cfset var hyperlinkName = "">
		<cfset var hyperlinkInfo = "">
		<cfset var hyperlinkURL="">
		<cfset var StringBuffer="">
		<cfset var TRStyleName="">
		<cfset var shape="">
		<cfset var shapeType = createObject("java", "com.aspose.words.ShapeType", variables.instance.paths.asposewords)>
		<cfset var WrapType = createObject("java", "com.aspose.words.WrapType", variables.instance.paths.asposewords)>
		<cfset var imgIndex=1>
		<cfset var image="">
		<cfset var latexContent1="">
		<cfset var latexContent="">
		<cfset var latexImagePath="">
		<cfset var LatexShape="">
		<cfset var latexImage="" >
		<cfset var latexImageHeight="">
		<cfset var latexImageWidth="">

		<cfscript>

			for(i=1; i LTE ArrayLen(TRArray); i=i+1)
			{
				if(TRArray[i].type EQ "textrun")
				{
					tempAttr=TRArray[i].attributes;
					TRStyleName=TRArray[i].TRStyleName;
					tempText=TRArray[i].text;
					EndTagList=ArrayNew(1);

					if((NOT oHeadingFlag) AND (len(trim(TRArray[i].text)) NEQ 0))
					{

						if ((variables.instance.classFlag) AND (TRStyleName NEQ "Absatz-Standardschriftart") AND (TRStyleName NEQ "Default Paragraph Font"))
						{
							TRStyleName=replace(TRStyleName,chr(32),"_","All");
							output.append("<span ");
							output.append("class=" &chr(34)&TRStyleName&chr(34)& ">");
							ArrayAppend(EndTagList,"</span>");

						}
						else
						{
							if(tempAttr.isBold)
							{
								output.append("<strong>");
								ArrayAppend(EndTagList,"</strong>");

							}
							if(tempAttr.isItalic)
							{
								output.append("<em>");
								ArrayAppend(EndTagList,"</em>");

							}
							if(tempAttr.isStrikeThrough)
							{
								output.append("<strike>");
								ArrayAppend(EndTagList,"</strike>");

							}
							if(tempAttr.isUnderlined)
							{
								output.append("<u>");
								ArrayAppend(EndTagList,"</u>");

							}
							if(tempAttr.isSubScript)
							{
								output.append("<sub>");
								ArrayAppend(EndTagList,"</sub>");

							}
							if(tempAttr.isSuperScript)
							{
								output.append("<sup>");
								ArrayAppend(EndTagList,"</sup>");

							}

						}
					}

					if(tempAttr.isHyperlink)
					{
						hyperlinkName=TRArray[i].attributes.HyperlinkName;
					    hyperlinkInfo=TRArray[i].attributes.linkInfo;
						hyperlinkURL = replace(GetToken(hyperlinkInfo, 2), '"','', "All");
						output.append("<a href="  & chr(34) & xmlformat(hyperlinkURL) & chr(34));
						tempText=hyperlinkName;
						output.append(">");
						ArrayAppend(EndTagList,"</a>");
					}

					tempText=specialCharacterReplace(tempText);
					output.append(tempText);

					for(j=ArrayLen(EndTagList);j GTE 1;j=j-1)
					{
						output.append(EndTagList[j]);
					}

				}
				else if(TRArray[i].type EQ "shape")
				{
					shape = TRArray[i];
					for(imgIndex=1; imgIndex LTE arrayLen(shape.imageList);imgIndex=imgIndex+1)
					{
						image=shape.imageList[imgIndex];
						output.append("<img src=" & chr(34)&xmlformat(image.imagePath)&chr(34) & " height=" & chr(34)&shape.shapeHeight*2&chr(34) & " width=" & chr(34)&shape.shapeWidth*2&chr(34));
						output.append(" alt="&chr(34)&"shape_image"&chr(34));
						output.append("/>");
					}

				}

			}
			return output.toString();
		 </cfscript>

	</cffunction>


	<cffunction name="setAttribute" access="private" output="false" returnType="numeric" hint="function to set the text run styles in building the data model">
		<cfargument name="TRArray" type="array" required="true">
		<cfargument name="TRNumber" type="string" required="true">
		<cfargument name="oParagraph" type="string" required="true">
		<cfargument name="shapeArray" type="array" required="true">

		<cfset var paraChildIndex = 0>
		<cfset var i = 0>

		<cfset var hyperlink = "">
		<cfset var newTRNumber = 0>
		<cfset var paraChild = "">
		<cfset var textString = "">

		<cfset var latexIndex=0>
		<cfset var shapeStruct="">
		<cfset var foundLatex="">
		<cfset var latexString="">
		<cfset var textRunString="">
		<cfset var latexStringStruct="">
		<cfset var textRunStruct="">

		<cfset var hyperlinkFlag = false>
		<cfset var hyperlinkData="">
		<cfset var hyperlinkIndex=0>
		<cfset var hyperlinkNode="">
		<cfset var hyperString="">
		<cfset var FieldType = createObject("java", "com.aspose.words.FieldType", variables.instance.paths.asposewords)>
		<cfset var fieldStart="">
		<cfset var fieldEnd="">

		<cfscript>

			while(paraChildIndex LTE oParagraph.getChildNodes().getCount()-1)
			{
				paraChild = oParagraph.getChildNodes().get(paraChildIndex);
				 //searching the hyperlinks by detecting the hyperlink fieldStart (node type = 16) and fieldEnd	(node type = 18)
				if(paraChild.getNodeType() EQ 16)
				{
			 		fieldStart = paraChild;
			 		if(fieldStart.getFieldType() EQ FieldType.FIELD_HYPERLINK)
			 		{
		 				hyperlinkData = {};
			 		 	hyperlinkData.linkInfo = "";
				 		hyperlinkData.linkName = "";

					 	for(hyperlinkIndex=paraChildIndex;hyperlinkIndex LTE oParagraph.getChildNodes().getCount();hyperlinkIndex=hyperlinkIndex+1)
					 	{
			 				hyperlinkNode = oParagraph.getChildNodes().get(hyperlinkIndex);
	 						if(hyperlinkNode.getNodeType() EQ 15)
	 						{
		 						hyperString = hyperlinkNode.getText();
		 						if(find("HYPERLINK",hyperString) NEQ 0)
		 						{
		 							hyperlinkData.linkInfo = hyperString;
		 						}
		 						else
		 						{
		 							hyperlinkData.linkName = hyperString;
		 						}
			 				}
			 				if(hyperlinkNode.getNodeType() EQ 18)
			 				{
			 					fieldEnd = hyperlinkNode;
	 							if(fieldEnd.getFieldType() EQ FieldType.FIELD_HYPERLINK)
	 							{
			 						break;
			 					}
			 				}
						}

					 	textRunStruct = {};
						textRunStruct.text = hyperlinkData.linkInfo & hyperlinkData.linkName;
						textRunStruct.TRStyleName = paraChild.getFont().getStyleName();
						textRunStruct.type = "textrun";
						textRunStruct.attributes = {};
						textRunStruct.attributes.isBold = false;
						textRunStruct.attributes.isItalic = false;
						textRunStruct.attributes.isStrikeThrough = false;
				        textRunStruct.attributes.isSubScript = false;
				        textRunStruct.attributes.isSuperScript = false;
						textRunStruct.attributes.linkinfo = hyperlinkData.linkInfo;
						textRunStruct.attributes.HyperlinkName = hyperlinkData.linkName;
						textRunStruct.attributes.isHyperlink = true;
					    textRunStruct.attributes.isUnderlined = false;

					    arrayAppend(TRArray, textRunStruct);
						newTRNumber = newTRNumber+1;
						arguments.TRNumber = newTRNumber;

					 	paraChildIndex = hyperlinkIndex+1;

			 		}
			 		else
			 		{
			 			paraChildIndex = paraChildIndex+1;
			 		}

				 }else{

				 	// processing the regular character runs which may contains the latex string starts and ends with '$$'
				 	 if(paraChild.getNodeType() EQ 15)
				 	 {
				 		textString = paraChild.getText();
						textRunStruct = createTextRunStruct(paraChild,textString);
						arrayAppend(TRArray, textRunStruct);
					 // identify the shape inside the paragraph
					 }
					 else if(paraChild.getNodeType() EQ 12)
					 {
						shapeStruct = createShapeStructure(paraChild);
						arrayAppend(TRArray, shapeStruct);
						newTRNumber = newTRNumber+1;
					 }
				 	 paraChildIndex = paraChildIndex+1;
				}

			}
			arguments.TRNumber = newTRNumber;
			return arguments.TRNumber;
		</cfscript>
	</cffunction>


	<cffunction name="specialCharacterReplace" access="private" output="false" returnType="string" hint="Function to display special character properly ">
		<cfargument name="text" type="string" required="true">

		<cfset var i = 0>
		<cfset var text = arguments.text>
		<cfscript>
			text = Replace(text, Chr(11), "<br/>", "All");
			text = Replace(text, Chr(30), "&##8209;", "All");
			text = Replace(text, Chr(32), " ", "All");
		</cfscript>
		<cfreturn text>
	</cffunction>


</cfcomponent>