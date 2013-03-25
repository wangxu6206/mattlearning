<cfcomponent displayname="Html2Doc" output="false">

	<cfset variables.instance = {}>

	<cffunction name="init" access="public" output="false" returnType="any" hint="initialize the AsposeConversion library classes to implement the conversion from (X)Html to Word">
		<cfset variables.instance.listLevelCounter = 0>
		<cfset variables.instance.elementNodeID = 0>
		<cfset variables.instance.listTemplateArray = []>
		<cfset variables.instance.BulletList = "">
		<cfset variables.instance.NumberList = "">
		<cfset variables.instance.listItemNumber = 0>
		<cfset variables.instance.listItemCounter = 0>
		<cfset variables.instance.lastLevelItemIDArray = []>
		<cfset variables.instance.docFileName = "">
		<cfset variables.instance.impageCounter = 0>
		<cfset variables.instance.tableFlag = false>
		<cfset variables.instance.svg2pngResolution = 500>
		<cfset variables.instance.svg2pngRatio = 5>
		<cfset variables.instance.tableRowCounter = 0>
		<cfset variables.instance.tableColumnCounter = 0>
		<cfset variables.instance.MaxColumnNumber = 0>
		<cfset variables.instance.TableStyle = "">
		<cfset variables.instance.replaceWithNBHyphen = false>
		<cfset variables.instance.replaceWithNBSpace = false>
		<cfset variables.instance.renderImage = true>
		<cfset variables.instance.nestedListNumber = -1>
		<cfset variables.instance.isInlist = false>
		<cfreturn this>
	</cffunction>


	<cffunction name="config" access="public" output="false" hint="config the options for customizing the conversion">
		<cfargument name="asposewordsPath" type="string" required="false" default="#expandPath('./')#asposewords.jar" hint="specific the path of asposewords jar file">
		<cfargument name="jerichohtmlPath" type="string" required="false" default="#expandPath('./')#jerichohtml.jar" hint="specific the path of jerichohtml jar file">

		<cfset variables.instance.paths.asposewords = arguments.asposewordsPath>
		<cfset variables.instance.paths.jerichohtml = arguments.jerichohtmlPath>
	</cffunction>


	<cffunction name="convertSVG2PNG" access="private" returnType="struct" hint="Funtion to input the included svg image and generate the PNG file" >
			<cfargument name="svgFile" type="string" required="true">
			<cfargument name="resolution" default="90" required="false">
			<cfargument name="outputDir" default = "./" required="true">

			<cfset var svgFileName = arguments.svgFile>
			<cfset var height = "">
			<cfset var width = "">
			<cfset var outputPNGImage = {}>
			<cfset var imageDirectory = "">
			<cfset var pngFileName = hash(arguments.svgFile & arguments.resolution)>

			<cfif !FileExists(arguments.outputDir & pngFileName & ".png")>
				<cftry>
					<!--- convert the svg file into png using the inkscape --->
					<cfexecute	timeout="5" variable="svg2png"
						name="#variables.instance.inkscapeCommand#"
						arguments="-z -D -d #arguments.resolution# --export-background=##ffffff --export-png=#arguments.outputDir#/#pngFileName#.png  #arguments.svgFile#"
					/>
				<cfcatch type="any">
						<cflog text="asposewords.Html2Doc.convertSVG2PNG()--Error at convert svg image into png image: #cfcatch.message#" type="error" file="#application.applicationName#">
				</cfcatch>
				</cftry>
			</cfif>

			<cfset outputPNGImage.outputDir = arguments.outputDir>
			<cfset outputPNGImage.fileName = pngFileName>

			<cfreturn outputPNGImage>
	</cffunction>


	<cffunction name="createImageDirectory" access="private" output="false" returnType="string"  hint="function to create the image directory for saving the images extracted from doc">

		<cfset var imageDirectory = "">
		<cfset var preImageDirectory = "">

		<cfset preImageDirectory = #variables.instance.imagedirectory# & "svg2pngImages/">
		<cfset imageDirectory = replace(preImageDirectory, " ", "_", "All")>

		<cfif ! DirectoryExists(imageDirectory)>
			<cfdirectory action = "create" directory = "#imageDirectory#" >
		</cfif>

		<cfreturn imageDirectory>
	</cffunction>


	<cffunction name="createHtmlDOM" access="private" output="false" returntype="struct" hint="recursive fuction to building the DOM structure">
		<cfargument name="root" type="any" required="true" hint="HTML node from Jericho">
		<cfargument name="inputStruct" type="struct" required="true" hint="Attributes structure for a DOM node">

		<cfset var tempRoot = arguments.root>
		<cfset var sourceStruct = arguments.inputStruct>
		<cfset var tempDOM = sourceStruct.htmlDOM>
		<cfset var styleArray = []>
		<cfset var contentSegments = "">
		<cfset var NodeList = []>
		<cfset var childrenList = []>
		<cfset var i = 0>
		<cfset var preIndex = 0>
		<cfset var counter = 0>
		<cfset var childNode = "">
		<cfset var element = {}>
		<cfset var realChild = "">
		<cfset var firstChr = "">
		<cfset var secondChr = "">
		<cfset var tempStruct = "">

		<cfscript>

			//how to set childList as I need here
			contentSegments = tempRoot.getContent();
			NodeList = createSegmentList(contentSegments);

			//set childList according to NodeList
			childrenList = tempRoot.getChildElements();
			//find out all the child element and call rescursive function to set the whole tree

			for(i=1;i LTE NodeList.size();i=i+1)
			{
				childNode = NodeList[i];
				element = {};
				if(childNode.type EQ "textNode")
				{
					element.name = childNode.name;
					element.type = childNode.type;
					element.text = childNode.value;
					arrayAppend(tempDOM.childrenList,element);
				}
				else
				{
					element.name = childNode.name;
					variables.instance.elementNodeID = variables.instance.elementNodeID+1;
					element.elementNodeID = variables.instance.elementNodeID;
					element.type = childNode.type;
					element.attributes = childNode.attributes;
					element.childrenList = [];

					arrayAppend(tempDOM.childrenList,element);
					realChild = childrenList.get(counter);
					//call the function itself recursively to loop the entire html DOM tree.
					tempStruct = {};

					tempStruct.htmlDOM = tempDOM.childrenList[i];

					createHtmlDOM(realChild,tempStruct);
					counter = counter+1;
				}
			}

		</cfscript>

		<cfreturn sourceStruct>
	</cffunction>


	<cffunction name="createSegmentList" access="private" output="false" returntype="array" hint="recursive fuction to set up data for building the DOM structure">
		<cfargument name="RawSegment" type="any" required="true">

		<cfset var contentSegments = arguments.RawSegment.getNodeIterator()>
		<cfset var segmentList = []>
		<cfset var mergedSegmentList = []>
		<cfset var startTag = "">
		<cfset var endTag = "">
		<cfset var plainText = "">
		<cfset var attributeList = "">
		<cfset var attrIndex = 0>
		<cfset var tempAttribute = "">
		<cfset var attributeNode = "">
		<cfset var startTagNode = "">
		<cfset var endTagNode = "">
		<cfset var selfEndTagNode = "">
		<cfset var textNode = "">
		<cfset var processStack = "">
		<cfset var finalNodelList = []>
		<cfset var i = 1>
		<cfset var node = "">
		<cfset var peekNode = "">
		<cfset var finalTxtNode = "">
		<cfset var bottomTagName = "null">
		<cfset var tagName = "">
		<cfset var traceNode = "">
		<cfset var finalElementNode = "">
		<cfset var merIndex = 1>
		<cfset var innerIndex = 0>
		<cfset var mergeContent = "">
		<cfset var innerNode = "">
		<cfset var mergedTextNode = "">
		<cfset var cursorNode = "">
		<cfset var className = "">

		<!---********** break every html element into segments and create segment node for building the html DOM **********--->
		<cfloop collection=#contentSegments# item="cellSegment">

			<cfset className = cellSegment.getClass().getName()>

			<cfif className EQ "net.htmlparser.jericho.StartTag">

				<cfset startTag = cellSegment>
				<cfset attributeList = []>
				<cfloop from="1" to="#arrayLen(startTag.getAttributes())#" index="attrIndex">
					<cfset tempAttribute = startTag.getAttributes()[attrIndex]>
					<cfset attributeNode = {}>
					<cfset attributeNode.name = tempAttribute.getName() >
					<cfset attributeNode.value = tempAttribute.getValue() >
					<cfset arrayAppend(attributeList,attributeNode) >
				</cfloop>
				<cfif startTag.isSyntacticalEmptyElementTag()>
					<cfset selfEndTagNode = {}>
					<cfset selfEndTagNode.type = "selfEnd_Tag" >
					<cfset selfEndTagNode.value = startTag.getName() >
					<cfset selfEndTagNode.attributes = attributeList >
					<cfset arrayAppend(segmentList,selfEndTagNode) >
				<cfelse>
					<cfset startTagNode = {}>
					<cfset startTagNode.type = "start_Tag" >
					<cfset startTagNode.value = startTag.getName()>
					<cfset startTagNode.attributes = attributeList>
					<cfset arrayAppend(segmentList,startTagNode)>
				</cfif>

			<cfelseif className EQ "net.htmlparser.jericho.EndTag">

				<cfset endTag = cellSegment >
				<cfset endTagNode = {}>
				<cfset endTagNode.type = "end_Tag" >
				<cfset endTagNode.value = endTag.getName()>
				<cfset arrayAppend(segmentList,endTagNode)>

			<cfelse>
				<cfset plainText = cellSegment.toString()>
				<cfset textNode = {}>
				<cfset textNode.type = "text">
				<cfset textNode.value = plainText>
				<cfset arrayAppend(segmentList,textNode)>
			</cfif>
		</cfloop>

		<cfscript>
			/********** merge the special entity text nodes with other text nodes for Latex conversion **********/
			while(merIndex LTE arrayLen(segmentList))
			{
				cursorNode = segmentList[merIndex];
				if(cursorNode.type EQ "text")
				{
					mergeContent = createObject("java","java.lang.StringBuffer").init();
					for(innerIndex=merIndex;innerIndex LTE arrayLen(segmentList);innerIndex=innerIndex+1)
					{
						innerNode =  segmentList[innerIndex];
						if(innerNode.type EQ "text")
						{
							mergeContent.append(innerNode.value);
						}
						else
						{
							break;
						}
					}

					mergedTextNode = {};
					mergedTextNode.type = "text";
					mergedTextNode.value = mergeContent.toString();
					arrayAppend(mergedSegmentList,mergedTextNode);

					merIndex = innerIndex;

				}
				else
				{
					arrayAppend(mergedSegmentList,cursorNode);
					merIndex = merIndex+1 ;
				}
			}

			/********using stack to filter out the inner html element node and keep the text node and element nodes at the top level**********/
			processStack = createObject("java","java.util.Stack").init();
			for(i;i LTE arrayLen(mergedSegmentList);i=i+1)
			{
				node = mergedSegmentList[i];
				if(processStack.empty())
				{
					processStack.push(node);
					peekNode = processStack.peek();
					if(peekNode.type EQ "text")
					{
						popNode = processStack.pop();
						finalTxtNode = {};
						finalTxtNode.name = "TEXT";
						finalTxtNode.type = "textNode";
						finalTxtNode.value = popNode.value;
						arrayAppend(finalNodelList,finalTxtNode);
					}
					if(peekNode.type EQ "selfEnd_Tag")
					{
						popNode = processStack.pop();
						finalTxtNode = structNew();
						finalTxtNode.name = popNode.value;
						finalTxtNode.type = "elementNode";
						finalTxtNode.attributes = popNode.attributes;
						arrayAppend(finalNodelList,finalTxtNode);
					}

				}
				else
				{
					processStack.push(node);
				    peekNode = processStack.peek();
					if(peekNode.type EQ "end_Tag")
					{
						bottomTagName = "null";
						tagName = processStack.pop().value;
						if(not processStack.empty())
						{
							while(true)
							{
							    traceNode = processStack.pop();
								if((traceNode.value EQ tagName) && (traceNode.type EQ "start_Tag"))
								{
									bottomTagName = traceNode.value;
									if(processStack.empty())
									{
										finalElementNode = {};
										finalElementNode.name = bottomTagName;
										finalElementNode.type = "elementNode";
										finalElementNode.attributes = traceNode.attributes;
										arrayAppend(finalNodelList,finalElementNode);
									}
									break;
								}
								else
								{
									continue;
								}
							}
						}

					}

				}

			}

		</cfscript>

		<cfreturn finalNodelList>
	</cffunction>


	<cffunction name="html2docDeMoronize" access="private" output="false" returnType="string" hint="Function to convert special character from Html entity to character ">
		<cfargument name="text" type="string" required="true">

		<cfset var i = 0>
		<cfscript>
			//text = Replace(text, "-", Chr(30), "All");
			text = Replace(text, "&##32;", " ",  "All");
			text = Replace(text, "&##34;", Chr(34),  "All");
			text = Replace(text, "&quot;", Chr(34),  "All");
			text = Replace(text, "&##38;", Chr(38),  "All");
			text = Replace(text, "&amp;", Chr(38),  "All");
			text = Replace(text, "&##39;", Chr(39),  "All");
			text = Replace(text, "&apos;", Chr(39),  "All");
			text = Replace(text, "&##60;", Chr(60),  "All");
			text = Replace(text, "&lt;", Chr(60),  "All");
			text = Replace(text, "&##62;", Chr(62),  "All");
			text = Replace(text, "&gt;", Chr(62),  "All");
			text = Replace(text, "&##47;", Chr(47),  "All");
			text = Replace(text, "&##126;", Chr(126), "All");
			text = Replace(text, "&##130;", Chr(130), "All");
			text = Replace(text, "&##131;", Chr(131),  "All");
			text = Replace(text, "&##132;", Chr(132),  "All");
			text = Replace(text, "&##133;", Chr(133),  "All");
			text = Replace(text, "&##136;", Chr(136),  "All");
			text = Replace(text, "&##139;", Chr(139),  "All");
			text = Replace(text, "&##140;", Chr(140),  "All");
			text = Replace(text, "&##145;", Chr(145),  "All");
			text = Replace(text, "&##146;", Chr(146),  "All");
			text = Replace(text, "&##147;", Chr(147),  "All");
			text = Replace(text, "&##148;", Chr(148),  "All");
			text = Replace(text, "&##149;", Chr(149),  "All");
			text = Replace(text, "&##150;", Chr(150),  "All");
			text = Replace(text, "&##151;", Chr(151),  "All");
			text = Replace(text, "&##152;", Chr(152),  "All");
			text = Replace(text, "&##153;", Chr(153),  "All");
			text = Replace(text, "&##155;", Chr(155),  "All");
			text = Replace(text, "&##156", Chr(156),  "All");
			text = Replace(text, "&##160;", Chr(160), "All");
			text = Replace(text, "&##163;", Chr(163), "All");
			text = Replace(text, "&##165;", Chr(165),  "All");
			text = Replace(text, "&##169;", Chr(169), "All");
			text = Replace(text, "&##171;", Chr(171),  "All");
			text = Replace(text, "&##187;", Chr(187),  "All");
			text = Replace(text, "&##8211;", Chr(8211), "All");
			text = Replace(text, "&##8212;", Chr(8212),  "All");
			text = Replace(text, "&##8216;", "`", "All");
			text = Replace(text, "&##8217;", "'", "All");
			text = Replace(text, "&##8220;", Chr(8220),  "All");
			text = Replace(text, "&##8221;", Chr(8221),  "All");
			text = Replace(text, "&##8226;", Chr(8226),  "All");
			text = Replace(text, "&##8230;", Chr(8230),  "All");
			text = Replace(text, "&##8364;", Chr(8364), "All");

			return text;

		 </cfscript>
	</cffunction>


	<cffunction name="parseHTMLFile" access="public" output="false" returntype="struct" hint="parse (x)html into a specific DOM structure">
		<cfargument name="htmlString" type="string" required="false">

		<cfset var oHtmlString = "">
		<cfset var DOM = {}>
		<cfset var inputStruct = {}>
		<cfset var inputHtmlFileString = "">
		<cfset var inputStream = "">
		<cfset var htmlSource = "">
		<cfset var oHtmlString = arguments.htmlString>
		<cfset var elementList = "">
		<cfset var outputStruct = "">

		<!--- Aspose needs well formatted html so we wrap the html snippet inside body tags --->
		<!--- <cfset oHtmlString="<body>"&preprocessHTMLString(oHtmlString)&"</body>"> --->
		<cfset oHtmlString = "<body>"&oHtmlString&"</body>">

		<cfset inputStream = createObject("java","java.io.ByteArrayInputStream").init(oHtmlString.getBytes("UTF-16"))>

		<cfset htmlSource = createObject("java", "net.htmlparser.jericho.Source", variables.instance.paths.jerichohtml).init(inputStream)>

		<cfset elementList = htmlSource.getChildElements()>

		<cfif (arrayLen(elementList) NEQ 0 )>
			<cfset root = elementList.get(0)>
			<cfset DOM = {}>
			<cfset DOM.name = root.getName()>
			<cfset DOM.type = "elementNode">
			<cfset DOM.attributes = []>
			<cfset DOM.childrenList = []>
			<cfset inputStruct.htmlDOM = DOM>
			<cfset outputStruct = createHtmlDOM(root, inputStruct)>

			<cfreturn outputStruct.htmlDOM>
		<cfelse>
			<cfset DOM = {}>
			<cfset DOM.name = "source Document">
			<cfset DOM.type = "elementNode">
			<cfset DOM.attributes = []>
			<cfset DOM.childrenList = []>
			<cfset inputStruct.htmlDOM = DOM>

			<cfreturn inputStruct.htmlDOM>
		</cfif>
	</cffunction>


	<cffunction name="preprocessHTMLString" access="private" returnType="string" hint="Funtion to loop through the input html string and process macros/shortcodes [[include:]] and [[image:]]" >
		<cfargument name="htmlContent" type="string" required="true">

		<!--- A whitespace is the delimiter to extract the included file path --->
		<cfset var preFilterHtmlString = arguments.htmlContent>
		<!--- variable decleration for processing [[include:]] --->
		<cfset var includeIndex1 = 1>
		<cfset var foundIncludedHtml = "">
		<cfset var orginalString1 = "">
		<cfset var rawIncludeString1 = "">
		<cfset var includedHtmlFile = "">
		<cfset var filteredHtmlString1 = createObject( "java", "java.lang.StringBuffer" ).init()>
		<!--- variable decleration for processing [[image:]] --->
		<cfset var includeIndex2 = 1>
		<cfset var foundIncludedImage ="">
		<cfset var orginalString2 = "">
		<cfset var rawIncludeString2 = "">
		<cfset var includedImageFile = "">
		<cfset var pngOutputPath = "">
		<cfset var filteredHtmlString2 = createObject( "java", "java.lang.StringBuffer" ).init()>

		 <!--- import the html content from the "[[include ../../includedHtml.html]]" and merge with the origianl html--->
		<cfloop condition="includeIndex1 LTE #len(preFilterHtmlString)#">
			<cfset foundIncludedHtml = REFindNoCase('\[\[\include(.*?)\]\]', preFilterHtmlString, includeIndex1, true)>
			<cfif foundIncludedHtml.pos[1] GT 0>
				<cfset orginalString1 = mid(preFilterHtmlString, includeIndex1, (foundIncludedHtml.pos[1])-includeIndex1 )>
				<cfset filteredHtmlString1.append(orginalString1)>
				<cfset rawIncludeString = REReplace(mid(preFilterHtmlString, foundIncludedHtml.pos[1], foundIncludedHtml.len[1]),"[|[|]|]","","ALL")>
				<cfset includedHtmlFile = html2docDeMoronize(getToken(trim(rawIncludeString),2," "))>
				<cfif fileExists(includedHtmlFile)>
					<cffile action = "read" file = "#includedHtmlFile#" variable = "includeHtmlString">
					<cflog file="#application.applicationname#" text="#includeHtmlString#">
					<cfif len(trim(includeHtmlString)) EQ 0>
						<cflog file="#application.applicationname#" text="Included html file is empty !">
					<cfelse>
						<cfset filteredHtmlString1.append(includeHtmlString)>
					</cfif>
				<cfelse>
					<cflog file="#application.applicationname#" text="Included html file doesn't exist! #includedHtmlFile#">
				</cfif>
			<cfelse>
				<cfset orginalString1 = mid(preFilterHtmlString,includeIndex1, len(preFilterHtmlString)-includeIndex1+1)>
				<cfset filteredHtmlString1.append(orginalString1)>
			</cfif>

			<cfset includeIndex1 = foundIncludedHtml.pos[1] + foundIncludedHtml.len[1]>
			<cfif includeIndex1 LTE 0>
				<cfbreak>
			</cfif>
		</cfloop>

		<!--- import the html content from the "[[image ../../image.svg]]" and merge with the origianl html--->
		<cfloop condition="includeIndex2 LTE #len(filteredHtmlString1)#">
			<cfset foundIncludedImage = REFindNoCase('\[\[\image(.*?)\]\]', filteredHtmlString1, includeIndex2, true)>
			<cfif foundIncludedImage.pos[1] GT 0>
				<cfset orginalString2 = mid(filteredHtmlString1, includeIndex2, (foundIncludedImage.pos[1])-includeIndex2 )>
				<cfset filteredHtmlString2.append(orginalString2)>
				<cfset rawIncludeString1 = REReplace(mid(filteredHtmlString1, foundIncludedImage.pos[1], foundIncludedImage.len[1]),"[|[|]|]","","ALL")>
				<cfset includedImageFile = html2docDeMoronize(getToken(trim(rawIncludeString1),2," "))>

				<cfif fileExists(includedImageFile)>
					<cfset pngOutputPath = createImageDirectory()>
					<!--- start convert the included svg image into png image and replace the "[[image ../..image.svg]]" with <img />--->
					<cfset svgpngStruct = convertSVG2PNG(includedImageFile, variables.instance.svg2pngResolution, pngOutputPath)>
					<cfset filteredHtmlString2.append("<img src=")>
					<cfset filteredHtmlString2.append(chr(34) & #svgpngStruct.outputDir# & "/" & #svgpngStruct.fileName# & ".png" & chr(34))>
					<cfset filteredHtmlString2.append(" alt=" & chr(34) & "included_image" & chr(34))>
					<cfset filteredHtmlString2.append("/>")>
				</cfif>
			<cfelse>
				<cfset orginalString2 = mid(filteredHtmlString1,includeIndex2, len(filteredHtmlString1)-includeIndex2+1)>
				<cfset filteredHtmlString2.append(orginalString2)>
			</cfif>

			<cfset includeIndex2 = foundIncludedImage.pos[1] +foundIncludedImage.len[1]>
			<cfif includeIndex2 LTE 0>
				<cfbreak>
			</cfif>
		</cfloop>

		<cfset arguments.htmlContent = filteredHtmlString2>

		<cfreturn arguments.htmlContent>
	</cffunction>


	<cffunction name="renderElement" access="public" output="false" returntype="void" hint="Function to recursively traverse the html DOM tree structure and initialize rendering functions">
		<cfargument name="domNode" type="any" required="true">
		<cfargument name="docBuilder" type="any" required="true">

		<!--- Used to store data for this iteration of renderElement --->
		<cfset var itemData = "">
		<!--- If no children are allowed for element or parent node handles all child nodes, then set this to true and it will skip processing of child nodes --->
		<cfset var skipChildren = false>
		<cfset var i = 0>
		<cfset var linkName = "">
		<cfset var aIndex = "">
		<cfset var StyleIdentifier = "">
		<cfset var font = "">
		<cfset var hyperlink = "">
		<cfset var BreakType = "">
		<cfset var extraDebugInfo = "">

		<cftry>

			<cfif domNode.type EQ "textNode">
				<cfset renderTextToDoc(arguments.domNode,arguments.docBuilder)>
				<cfreturn>
			</cfif>

			<!--- set up to start rendering html element into doc --->
			<cfswitch expression="#arguments.domNode.name#">
				<cfcase value = "h1,h2,h3,h4,h5,h6">
					<cfset startRenderHeadingToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "hr">
					<cfset startRenderHorizontalLineToDoc(arguments.domNode, arguments.docBuilder)>
				</cfcase>

				<cfcase value = "br">
					<cfset BreakType = createObject("java", "com.aspose.words.BreakType", variables.instance.paths.asposewords)>
					<cfset arguments.docBuilder.insertBreak(BreakType.LINE_BREAK)>
				</cfcase>

				<cfcase value = "a">
					<cfset startRenderHyperLinkToDoc(arguments.domNode,arguments.docBuilder)>
					<cfset skipChildren = true>
				</cfcase>

				<cfcase value = "p">
					<cfset startRenderParagraphToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "ul">
					<cfset startRenderListToDoc(arguments.domNode,arguments.docBuilder,"unordered")>
				</cfcase>

				<cfcase value = "font">
					<cfset startRenderFontToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "ol">
					<cfset startRenderListToDoc(arguments.domNode,arguments.docBuilder,"ordered")>
				</cfcase>

				<cfcase value = "li">
					<cfset startRenderListItemToDoc(domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "table">
					<cfset startRenderTableToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "tr">
					<cfset startRenderTableRowToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "td,th">
					<cfset startRenderTableCellToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "img">
					<cfset startRenderImageToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "span">
					<cfset startRenderClassStyleToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "div">
					<cfset startRenderBreakToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "strong,b,em,i,strike,sub,sup,u">
					<cfset startRenderTextFontStyle(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfdefaultcase>
					<cflog text = "asposewords.Html2Doc.renderElement()--Start Unhandled element type: #arguments.domNode.name#" file="debug">
				</cfdefaultcase>
			</cfswitch>

			<!--- recursively render html dom node --->
			<cfif NOT skipChildren>
				<cfloop from="1" to="#arrayLen(arguments.domNode.childrenList)#" index="i">
					<cfset renderElement(arguments.domNode.childrenList[i],arguments.docBuilder)>
				</cfloop>
			</cfif>

			<cfswitch expression="#arguments.domNode.name#">
				<cfcase value = "h1,h2,h3,h4,h5,h6">
					<cfset endRenderHeadingToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "hr">
					<cfset endRenderHorizontalLineToDoc(arguments.domNode, arguments.docBuilder)>
				</cfcase>

				<cfcase value="br">
				</cfcase>

				<cfcase value = "a">
					<cfset endRenderHyperLinkToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "p">
					<cfset endRenderParagraphToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "ul">
					<cfset endRenderListToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "font">
					<cfset endRenderFontToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "ol">
					<cfset endRenderListToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "li">
					<cfset endRenderListItemToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "tr">
					<cfset endRenderTableRowToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "td,th">
					<cfset endRenderTableCellToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "table">
					<cfset endRenderTableToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "img">
					<cfset endRenderImageToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "span">
					<cfset endRenderClassStyleToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "div">
					<cfset endRenderBreakToDoc(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfcase value = "strong,b,em,i,strike,sub,sup,u">
					<cfset endRenderTextFontStyle(arguments.domNode,arguments.docBuilder)>
				</cfcase>

				<cfdefaultcase>
					<cflog text="asposewords.Html2Doc.renderElement()--End Unhandled element type: #arguments.domNode.name#" file="debug">
				</cfdefaultcase>
			</cfswitch>

			<!--- Catch invalid markup --->
			<cfcatch type="java.lang.IllegalStateException">
				<cfif arguments.domNode.type EQ "elementNode">
					<cfset extraDebugInfo = "element Node: " & #arguments.domNode.childrenList[1].name# & " caused an error" >
				</cfif>
				<cfthrow type="custom.markup.invalid" message="#cfcatch.message# | Node type = #arguments.domNode.name#" detail="#htmlEditFormat(extraDebugInfo)#">
			</cfcatch>
		</cftry>
	</cffunction>


	<cffunction name="renderCssStyleToDoc" access="public" output="false" returntype="void" hint="Function to get the builder to render css style into Word document">
		<cfargument name="docBuilder" type="any" required="true">
		<cfargument name="cssValueString" type="string" required="true">

		<cfset var font = "">
		<cfset var cssUtil = createObject("component", "CSSRule").init()>
		<cfset var fontColor = "">
		<cfset var Color = "">
		<cfset var i = "">
		<cfset var backgroundColor = "">
		<cfset var cssDataMap = "">
		<cfset var renderedColor = "">

		<cfscript>

			font = arguments.docBuilder.getFont();

			cssUtil.AddCSS(arguments.cssValueString);

			cssDataMap = cssUtil.GetPropertyMap();

			for(i IN cssDataMap)
			{
				if(len(trim(cssDataMap[i])))
				{
					switch(i){
						case "color":
							Color = createObject("java","java.awt.Color");
							renderedColor = trim(cssUtil.GetProperty('color'));
							fontColor = cssUtil.getAwtColor(colorValue=renderedColor);
							font.setColor(fontColor);
							break;
						case "background-color":
							renderedColor = trim(cssUtil.GetProperty('background-color'));
							backgroundColor = cssUtil.getAwtColor(colorValue=renderedColor);
							font.setHighlightColor(backgroundColor);
							break;
						case "width":

							break;
						case "height":

							break;
						case "font-family":

							break;
						case "font-size":

							break;
						default:
							break;
					}

				}
			}

		</cfscript>

	</cffunction>



	<cffunction name="setHeaderFooter" access="public" output="false" hint="Using Aspose.Word to set the header and footer">
		<cfargument name="docBuilder" type="any" required="true">
		<cfargument name="HFContent" type="string" required="false" default="PAGE">

		<!--- set up the paper property --->
		<cfset var ps = arguments.docBuilder.getPageSetup() >
		<cfset var document = arguments.docBuilder.getDocument()>
		<cfset var HeaderFooterType = createObject("java", "com.aspose.words.HeaderFooterType", variables.instance.paths.asposewords) >
		<cfset var ParagraphAlignment = createObject("java", "com.aspose.words.ParagraphAlignment", variables.instance.paths.asposewords) >
		<cfset var style = "">

		<!--- set the page number into footer --->
		<cfset arguments.docBuilder.moveToSection(0)>
		<cfset ps.setRestartPageNumbering(true)>
		<cfset ps.setPageStartingNumber(1)>
		<cfset arguments.docBuilder.moveToHeaderFooter(HeaderFooterType.FOOTER_PRIMARY)>
		<cfset arguments.docBuilder.getParagraphFormat().setAlignment(ParagraphAlignment.CENTER)>

		<cfset style = document.getStyles().get("Footer")>
		<cfif len(trim(style))>
			<cfset arguments.docBuilder.getParagraphFormat().setStyle(style)>
		</cfif>

		<cfset arguments.docBuilder.write(arguments.HFContent)>
		<!--- add 9 spaces before the page number --->
		<cfset arguments.docBuilder.write("         ")>
		<!--- add the page number  --->
		<cfset arguments.docBuilder.insertField("PAGE", "")>
		<cfset arguments.docBuilder.moveToDocumentStart()>

		<!--- set the default language as English (AUS) which the refernece code is 3081, the original English (US) reference code is 1033--->
		<cfset arguments.docBuilder.getFont().setLocaleId(3081)>
	</cffunction>


	<cffunction name="setupPaper" access="public" output="false" hint="Using Aspose.Word to set up the paper size and set the margins of the new word file">
		<cfargument name="docBuilder" type="any" required="true">
		<cfargument name="setting" type="struct" required="false">
		<cfargument name="orientation" type="string" required="false">

		<!--- set up the paper property --->
		<cfset var ps = arguments.docBuilder.getPageSetup() >
		<cfset var PaperSize = createObject("java", "com.aspose.words.PaperSize", variables.instance.paths.asposewords)>
		<cfset var Orientation = createObject("java", "com.aspose.words.Orientation", variables.instance.paths.asposewords)>
		<cfset var ConvertUtil = createObject("java", "com.aspose.words.ConvertUtil", variables.instance.paths.asposewords)>

		<cfif arguments.orientation == "landscape">
			<cfset ps.setOrientation(Orientation.LANDSCAPE)>
		<cfelse>
			<cfset ps.setOrientation(Orientation.PORTRAIT)>
		</cfif>

		<cfif structKeyExists(arguments, "setting")>
			<cfset ps.setPaperSize(PaperSize.A4)>
			<cfset ps.setTopMargin(ConvertUtil.millimeterToPoint(val(arguments.setting.margintop)))>
			<cfset ps.setBottomMargin(ConvertUtil.millimeterToPoint(val(arguments.setting.marginBottom)))>
			<cfset ps.setLeftMargin(ConvertUtil.millimeterToPoint(val(arguments.setting.marginLeft)))>
			<cfset ps.setRightMargin(ConvertUtil.millimeterToPoint(val(arguments.setting.marginRight)))>
		<cfelse>
			<cfset ps.setPaperSize(PaperSize.CUSTOM)>
			<cfset ps.setTopMargin(ConvertUtil.inchToPoint(0.8))>
			<cfset ps.setBottomMargin(ConvertUtil.inchToPoint(0.8))>
			<cfset ps.setLeftMargin(ConvertUtil.inchToPoint(0.8))>
			<cfset ps.setRightMargin(ConvertUtil.inchToPoint(0.8))>
		</cfif>
	</cffunction>


	<cffunction name="startRenderTextFontStyle"  access="private" output="false" hint="Function to start rendering the text font style into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset arguments.docBuilder.pushFont()>
		<cfset var font = arguments.docBuilder.getFont()>
		<cfset var classExist = false>
		<cfset var styleName = "">

		<cfswitch expression="#arguments.domNode.name#">

			<cfcase value = "strong,b">
				<cfset font.setBold(true)>
			</cfcase>
			<cfcase value = "em,i">
				<cfset font.setItalic(true)>
			</cfcase>
			<cfcase value = "strike">
				<cfset font.setStrikeThrough(true)>
			</cfcase>
			<cfcase value = "u">
				<cfset font.setUnderline(1)>
			</cfcase>
			<cfcase value = "sub">
				<cfset font.setSubscript(true)>
			</cfcase>
			<cfcase value = "sup">
				<cfset font.setSuperscript(true)>
			</cfcase>

		</cfswitch>
	</cffunction>


	<cffunction name="startRenderHeadingToDoc" access="private" output="false" hint="Function to start rendering the headings into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var headingSize = "">
		<cfset var itemData = "">

		<cfset arguments.docBuilder.getParagraphFormat().clearFormatting()>
		<cfset headingSize = mid(arguments.domNode.name,2,1)>
		<cfset itemData = arguments.docBuilder.getCurrentParagraph().getParagraphFormat().getStyleName() >
		<cfset arguments.docBuilder.getCurrentParagraph().getParagraphFormat().setStyleName("Heading "&headingSize)>
	</cffunction>


	<cffunction name="startRenderParagraphToDoc" access="private" output="false" hint="Function to start rendering the paragraphs into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var classExist = false>
		<cfset var styleName = "">
		<cfset var StyleIdentifier = createObject("java", "com.aspose.words.StyleIdentifier", variables.instance.paths.asposewords)>
		<cfset var i = "">
		<cfset var font = "">
		<cfset var document = arguments.docBuilder.getDocument()>
		<cfset var style= "">

		<cfloop from="1" to="#arrayLen(domNode.attributes)#" index="attributIndex">
			<cfif domNode.attributes[attributIndex].name EQ "class" >
				<cfset styleName = domNode.attributes[attributIndex].value>
				<cfset classExist = true>
			</cfif>
		</cfloop>
		<cfif classExist>
			<cftry>
				<cfset style = document.getStyles().get(styleName)>
				<cfset arguments.docBuilder.getParagraphFormat().setStyle(style)>
				<cfcatch type="any">
					<!--- <cflog text="asposewords.Html2Doc.startRenderParagraphToDoc()--paragraph style: #styleName# was not found in the word template" type="error" file="#application.applicationName#"> --->
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset startRenderTextFontStyle( domNode,arguments.docBuilder)>
		</cfif>
	</cffunction>


	<cffunction name="startRenderHorizontalLineToDoc" access="private" output="false" hint="Function to start rendering the Horizontal line into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var document = arguments.docBuilder.getDocument()>
		<cfset arguments.docBuilder.insertHTML("<hr/>")>

	</cffunction>


	<cffunction name="startRenderHyperLinkToDoc" access="private" output="false" hint="Function to start rendering the Hyperlinks into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var StyleIdentifier = createObject("java", "com.aspose.words.StyleIdentifier", variables.instance.paths.asposewords)>
		<cfset var font = "">
		<cfset var hyperlink = "">
		<cfset var linkName = "">
		<cfset var aIndex = "">
		<cfset var i = 1>

		<cfscript>
			try{
				font = arguments.docBuilder.getFont();
				arguments.docBuilder.pushFont();
				font.setStyleIdentifier(StyleIdentifier.HYPERLINK);
				for(i; i <= arrayLen(arguments.domNode.attributes); i++)
				{
					if(arguments.domNode.attributes[i].name=="href")
						hyperlink = arguments.domNode.attributes[1].value;
				}

				linkName = createObject( "java", "java.lang.StringBuffer" ).init();
				for(aIndex=1;aIndex LTE arrayLen(domNode.childrenList);aIndex=aIndex+1)
				{
					if(domNode.childrenList[aIndex].type EQ "textNode")
					{
						linkName.append(domNode.childrenList[aIndex].text);
					}
				}
				arguments.docBuilder.insertHyperlink(html2docDeMoronize(linkName),hyperlink, false);
				arguments.docBuilder.popFont();
			}
			catch(any e)
			{
				writeLog(text="asposewords.Html2Doc.startRenderHyperLinkToDoc()--error message:#e.message#", type="error", file=application.applicationName);
			}
		</cfscript>
	</cffunction>


	<cffunction name="startRenderImageToDoc" access="private" output="false" hint="Function to start rendering the images into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var imageAttr = "">
		<cfset var imageHeight = 0>
		<cfset var imageWidth = 0>
		<cfset var imageURL = "">
		<cfset var imageAlt = "default">
		<cfset var imgIndex = "">
		<cfset var shape = "">
		<cfset var imageInsertManner = "Normal">
		<cfset var Color = createObject("java","java.awt.Color")>
		<cfset var imageFileName = "">
		<cfset var imageStyleName = "">
		<cfset var imageClassExist = false>
		<cfset var document = arguments.docBuilder.getDocument()>
		<cfset var imageCategory = "">

		<cfscript>

			for(imgIndex=1;imgIndex LTE arrayLen(arguments.domNode.attributes);imgIndex=imgIndex+1)
			{
  			 	imageAttr = arguments.domNode.attributes[imgIndex];
  			 	if(imageAttr.name EQ "height")
  			 	{
  			 		imageHeight = imageAttr.value;
  			 	}
  			 	if(imageAttr.name EQ "width")
  			 	{
  			 		imageWidth = imageAttr.value;
  			 	}
  			 	if(imageAttr.name EQ "src")
  			 	{
  			 		imageURL = html2docDeMoronize(imageAttr.value);
  			 	}
  			 	if(imageAttr.name EQ "alt")
  			 	{
  			 		imageAlt = imageAttr.value;
  			 	}
  			 	if(imageAttr.name EQ "class")
  			 	{
  			 		imageStyleName = imageAttr.value;
  			 		imageClassExist = true;
  			 	}
	  		 }

	  		 if(fileExists(imageURL))
	  		 {
  		 		imageFileName = listlast(imageURL,"/");
    			arguments.docBuilder.pushFont();

    			try
				{
					if(imageClassExist)
					{
						arguments.docBuilder.getFont().setStyle(document.getStyles().get(imageStyleName));
					}
				}
    			catch(any e)
				{
					/* writeLog(text="asposewords.Html2Doc.startRenderImageToDoc()--character style:#imageStyleName# was not found in the word template", type="error", file=application.applicationName); */
				}

  				// insert the included image into the output doc file
				shape = arguments.docBuilder.insertImage(imageURL);
				if(imageHeight NEQ 0 AND imageWidth NEQ 0)
				{
					shape.setHeight(imageHeight);
					shape.setWidth(imageWidth);
				}

	  		  }
	  		  else
	  		  {
	  		  	// write the message when the target images are missing
  				arguments.docBuilder.getFont().setColor(Color.RED);
  				arguments.docBuilder.write("Image not found");
  				arguments.docBuilder.getFont().clearFormatting();
	  		  }

		</cfscript>
	</cffunction>


	<cffunction name="startRenderClassStyleToDoc" access="private" output="false" hint="Function to start rendering the class style into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var spanClassExist = false>
		<cfset var cssStyleExist = false>
		<cfset var cssStyleAttributeValue = "">
		<cfset var spanStyleName = "">
		<cfset var attributIndex = "">
		<cfset var document = arguments.docBuilder.getDocument()>
		<cfset var style = "">

		<cfloop from="1" to="#arrayLen(domNode.attributes)#" index="attributIndex">
			<cfif arguments.domNode.attributes[attributIndex].name EQ "class" >
				<cfset spanStyleName = domNode.attributes[attributIndex].value>
				<cfset spanClassExist = true>
			</cfif>
			<cfif arguments.domNode.attributes[attributIndex].name EQ "style" >
				<cfset cssStyleAttributeValue = domNode.attributes[attributIndex].value>
				<cfset cssStyleExist = true>
			</cfif>
		</cfloop>

		<cfif spanClassExist>
			<cfset arguments.docBuilder.pushFont()>
			<cftry>

				<cfset style = document.getStyles().get(spanStyleName)>
				<cfset arguments.docBuilder.getFont().setStyle(style)>

				<cfcatch type="any">
					<!--- <cflog text="asposewords.Html2Doc.startRenderClassStyleToDoc()--character style:#spanStyleName# was not found in the word template: #cfcatch.message#" type="error" file="#application.applicationName#"> --->
				</cfcatch>
			</cftry>
		</cfif>

		<cfif cssStyleExist>
			<cfset arguments.docBuilder.pushFont()>
			<cfset renderCssStyleToDoc(docBuilder=arguments.docBuilder, cssValueString=cssStyleAttributeValue)>
		</cfif>

	</cffunction>


	<cffunction name="startRenderFontToDoc"  access="private" output="false" hint="Function to start rendering the text font style into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var Color = createObject("java","java.awt.Color")>
		<cfset var Integer = createObject("java","java.lang.Integer")>
		<cfset var spanClassExist = false>
		<cfset var spanStyleName = "">
		<cfset var attributIndex = "">
		<cfset var tempAttribute = "">
		<cfset var font = "">

		<cfset arguments.docBuilder.pushFont()>
		<cfset font = arguments.docBuilder.getFont()>
		<cftry>
			<cfloop from="1" to="#arrayLen(domNode.attributes)#" index="attributIndex">
				<cfset tempAttribute = arguments.domNode.attributes[attributIndex]>
				<cfswitch expression="#tempAttribute.name#">
					<cfcase value = "color">
						<cfset font.setColor(Color.decode(tempAttribute.value))>
					</cfcase>
					<cfcase value = "size">
						<cfset font.setSize(Integer.valueOf(trim(tempAttribute.value)))>
					</cfcase>
					<cfcase value = "face">
						<cfset font.setName(trim(tempAttribute.value))>
					</cfcase>
				</cfswitch>
			</cfloop>

			<cfcatch type = "any">
				<!--- <cflog text="asposewords.Html2Doc.startRenderFontToDoc()--Error occured in rendering font on text.  Error: #cfcatch.detail#" type="error" file="#application.applicationName#"> --->
			</cfcatch>
		</cftry>

	</cffunction>


	<cffunction name="startRenderListToDoc" access="private" output="false" hint="Function to start rendering the list into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">
		<cfargument name="listType" required="true">

		<cfset var ListTemplate = createObject("java", "com.aspose.words.ListTemplate", variables.instance.paths.asposewords)>
		<cfset var BulletList = arguments.docBuilder.getDocument().getLists().add(ListTemplate.BULLET_DEFAULT)>
		<cfset var NumberList = arguments.docBuilder.getDocument().getLists().add(ListTemplate.NUMBER_DEFAULT)>
		<cfset var templateList = "">
		<cfset var listLevel = "">
		<cfset var listLevelIndex = 0>
		<cfset var appliedStyle = "">
		<cfset var document = arguments.docBuilder.getDocument()>
		<cfset var styleName = "">
		<cfset classExist = false>

		<cfloop from="1" to="#arrayLen(arguments.domNode.attributes)#" index="attributIndex">
			<cfif arguments.domNode.attributes[attributIndex].name EQ "class" >
				<cfset styleName = arguments.domNode.attributes[attributIndex].value>
				<cfset classExist = true>
			</cfif>
		</cfloop>

		<cfif classExist>
			<cftry>
				<cfset appliedStyle = document.getStyles().get(styleName)>
				<cfset templateList =  arguments.docBuilder.getDocument().getLists().add(appliedStyle)>
				<cfcatch type = "any">
					<!--- <cflog text="asposewords.startRenderListToDoc()--list style: #styleName# was not found in the word template.  Error: #cfcatch.detail#" type="error" file="#application.applicationName#"> --->
				</cfcatch>
			</cftry>
		</cfif>

		<cfif arguments.listType EQ "unordered">
			<cfset templateList = BulletList>
		<cfelse>
			<cfset templateList = NumberList>
		</cfif>

		<cfset variables.instance.nestedListNumber ++>

		<cfif variables.instance.nestedListNumber == 0>
			<cfset arguments.docBuilder.getListFormat().setList(templateList)>
			<cfset variables.instance.isInlist = true>
		<cfelse>
			<!--- <cfset arguments.docBuilder.writeln()> --->
			<cfset arguments.docBuilder.getListFormat().listIndent()>
		</cfif>

	</cffunction>


	<cffunction name="startRenderListItemToDoc" access="private" output="false" hint="Function to start rendering the list item into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var classExist = false>
		<cfset var styleName = "">
		<cfset var document = arguments.docBuilder.getDocument()>

		<cfloop from="1" to="#arrayLen(domNode.attributes)#" index="attributIndex">
			<cfif domNode.attributes[attributIndex].name EQ "class" >
				<cfset styleName=domNode.attributes[attributIndex].value>
				<cfset classExist = true>
			</cfif>
		</cfloop>

		<cfif classExist>
			<cftry>
				<cfset arguments.docBuilder.getParagraphFormat().setStyle(document.getStyles().get(styleName))>
				<cfcatch type="any">
					<!--- <cflog text="asposewords.Html2Doc.startRenderListItemToDoc()--paragraph style: #styleName# on list item was not found in the word template: #cfcatch.message#" type="error" file="#application.applicationName#"> --->
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset startRenderTextFontStyle(arguments.domNode,arguments.docBuilder)>
		</cfif>

	</cffunction>


	<cffunction name="startRenderTableToDoc" access="private" output="false" hint="Function to start rendering the table into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var table = "">
		<cfset var document = arguments.docBuilder.getDocument()>

		<cfset table = arguments.docBuilder.startTable()>
		<cfset variables.instance.tableFlag = true>

	</cffunction>


	<cffunction name="startRenderTableRowToDoc" access="private" output="false" hint="Function to start rendering the table row into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var colIndex = 1>
		<cfset var childNode = "">

		<cfloop from="1" to="#arrayLen(arguments.domNode.childrenList)#" index="colIndex">
			<cfset childNode = arguments.domNode.childrenList[colIndex]>
			<cfif (childNode.type EQ "elementNode")>
				<cfset variables.instance.tableColumnCounter ++>
			</cfif>
		</cfloop>
		<cfif variables.instance.tableColumnCounter GT variables.instance.MaxColumnNumber>
			<cfset variables.instance.MaxColumnNumber = variables.instance.tableColumnCounter >
		</cfif>
	</cffunction>


	<cffunction name="startRenderTableCellToDoc" access="private" output="false" hint="Function to start rendering the table cell into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var document = arguments.docBuilder.getDocument()>
		<cfset var pageSetup = "">
		<cfset var pageWidth = 0>
		<cfset var BorderType = createObject("java", "com.aspose.words.BorderType", variables.instance.paths.asposewords)>
		<cfset var LineStyle = createObject("java", "com.aspose.words.LineStyle", variables.instance.paths.asposewords)>
		<cfset var Color = createObject("java","java.awt.Color")>
		<cfset var cellNodeWidth = 0>
		<cfset var cellNodeHeight = 0>
		<cfset var i = 1>
		<cfset var cellNodeAttr = "">
		<cfset var finalCellWidth = 0>

		<cfscript>
			pageSetup = arguments.docBuilder.getPageSetup();
			pageWidth = pageSetup.getPageWidth()-200; // set -100 is to add some padding around the table

			for(i;i LTE arrayLen(arguments.domNode.attributes);i++)
			{
				cellNodeAttr = arguments.domNode.attributes[i];
				if(cellNodeAttr.name EQ "width")
				{
					cellNodeWidth = cellNodeAttr.value;
				}
				if(cellNodeAttr.name EQ "height")
				{
					cellNodeHeight = cellNodeAttr.value;
				}
			}

			//keep the old default setting for building table
			arguments.docBuilder.getCellFormat().getBorders().setLineStyle(LineStyle.SINGLE);
			arguments.docBuilder.getCellFormat().getBorders().setColor(Color.BLACK);
			arguments.docBuilder.insertCell();
			finalCellWidth = pageWidth/variables.instance.MaxColumnNumber;
			arguments.docBuilder.getCellFormat().setFitText(true);
			arguments.docBuilder.getCellFormat().setWidth(finalCellWidth);
		</cfscript>
	</cffunction>


	<cffunction name="startRenderBreakToDoc" access="private" output="false" hint="Function to start rendering the breaks into doc ">
			<cfargument name="domNode" required="true">
			<cfargument name="docBuilder" required="true">

			<cfset var BreakType = createObject("java", "com.aspose.words.BreakType", variables.instance.paths.asposewords)>
			<cfset var divClassExist = false>
			<cfset var breakName = "">
			<cfset var attributIndex = "">
			<cfset var document = arguments.docBuilder.getDocument()>

			<cfloop from="1" to="#arrayLen(arguments.domNode.attributes)#" index="attributIndex">
				<cfif arguments.domNode.attributes[attributIndex].name EQ "class" >
					<cfset breakName = domNode.attributes[attributIndex].value>
					<cfset divClassExist = true>
				</cfif>
			</cfloop>
			<cfif divClassExist>
				<cftry>
					<cfif breakName EQ "pagebreak">
						<cfset arguments.docBuilder.insertBreak(BreakType.PAGE_BREAK)>
					</cfif>
					<cfcatch type="any">
						<!--- <cflog text="asposewords.Html2Doc.startRenderBreaktoDoc()--Error occured in inserting the page break into doc: #cfcatch.message#" type="error" file="#application.applicationName#"> --->
					</cfcatch>
				</cftry>
			</cfif>

	</cffunction>


	<cffunction name="renderTextToDoc" access="private" output="false" hint="Function to start rendering the text into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var textContent=arguments.domNode.text>
		<cfset var document = arguments.docBuilder.getDocument()>

		<cfscript>
			textContent = Replace(textContent, Chr(9), "", "All");
			textContent = Replace(textContent, Chr(7), "", "All");
			textContent = Replace(textContent, Chr(10), "", "All");
			textContent = Replace(textContent, Chr(11), "", "All");
			textContent = Replace(textContent, Chr(13), "", "All");
			textContent = Replace(textContent, "&quot;", Chr(34), "All");
			textContent = Replace(textContent, "&amp;", Chr(38), "All");
			textContent = Replace(textContent, "&lt;", Chr(60), "All");
			textContent = Replace(textContent, "&gt;", Chr(62), "All");

			arguments.docBuilder.write(textContent);
		</cfscript>
	</cffunction>


	<cffunction name="endRenderTextFontStyle" access="private" output="false" hint="Function to finish rendering the text font style into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset arguments.docBuilder.popFont()>
	</cffunction>


	<cffunction name="endRenderHeadingToDoc" access="private" output="false" hint="Function to finish rendering the headings into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset arguments.docBuilder.writeln()>
		<cfset arguments.docBuilder.getCurrentParagraph().getParagraphFormat().setStyleName("Normal")>
	</cffunction>


	<cffunction name="endRenderParagraphToDoc" access="private" output="false" hint="Function to finish rendering the paragraphs into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var classExist = false>
		<cfset var StyleIdentifier = createObject("java", "com.aspose.words.StyleIdentifier", variables.instance.paths.asposewords)>
		<cfset var breakType = createObject("java", "com.aspose.words.BreakType", variables.instance.paths.asposewords)>
		<cfset var font = "">

		<cfloop from="1" to="#arrayLen(arguments.domNode.attributes)#" index="attributIndex">
			<cfif domNode.attributes[attributIndex].name EQ "class" >
				<cfset classExist = true>
			</cfif>
		</cfloop>

		<!--- <cfif NOT variables.instance.tableFlag > --->
			  <cfset arguments.docBuilder.insertBreak(breakType.PARAGRAPH_BREAK)>
		<!--- </cfif> --->

		<cfif classExist>
			<cfset arguments.docBuilder.getCurrentParagraph().getParagraphFormat().clearFormatting()>
		<cfelse>
			<cfset endRenderTextFontStyle(arguments.domNode,arguments.docBuilder)>
		</cfif>

	</cffunction>


	<cffunction name="endRenderHorizontalLineToDoc" access="private" output="false" hint="Function to start rendering the Horizontal line into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

	</cffunction>


	<cffunction name="endRenderHyperLinkToDoc" access="private" output="false" hint="Function to finish rendering the hyperLinks into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

	</cffunction>


	<cffunction name="endRenderImageToDoc" access="private" output="false" hint="Function to finish rendering the images into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var imageClassExist = false>
		<cfset var attributIndex = 1>
		<cfset var imageURL = "">

		<cfloop from="1" to="#arrayLen(domNode.attributes)#" index="attributIndex">
			<cfif arguments.domNode.attributes[attributIndex].name EQ "class" >
				<cfset imageClassExist = true>
			</cfif>
			<cfif arguments.domNode.attributes[attributIndex].name EQ "src">
				<cfset imageURL = html2docDeMoronize(arguments.domNode.attributes[attributIndex].value)>
			</cfif>
		</cfloop>
		<cfif fileExists(imageURL)>
			<cfset arguments.docBuilder.popFont()>
		</cfif>
	</cffunction>


	<cffunction name="endRenderClassStyleToDoc" access="private" output="false" hint="Function to finish rendering the class style into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var spanClassExist = false>
		<cfset var cssStyleExist = false>
		<cfset var attributIndex = "">

		<cfloop from="1" to="#arrayLen(domNode.attributes)#" index="attributIndex">
			<cfif arguments.domNode.attributes[attributIndex].name EQ "class" >
				<cfset spanClassExist = true>
			</cfif>
			<cfif arguments.domNode.attributes[attributIndex].name EQ "style" >
				<cfset cssStyleExist = true>
			</cfif>
		</cfloop>

		<cfif spanClassExist || cssStyleExist>
			<cfset arguments.docBuilder.popFont()>
		</cfif>

		<cfset variables.instance.replaceWithNBHyphen = false>
		<cfset variables.instance.replaceWithNBSpace = false>

	</cffunction>


	<cffunction name="endRenderListItemToDoc" access="private" output="false" hint="Function to finish rendering the list item into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var breakType =createObject("java", "com.aspose.words.BreakType", variables.instance.paths.asposewords)>

		<cfset endRenderTextFontStyle(arguments.domNode,arguments.docBuilder)>

		<cfif NOT variables.instance.listEnd>
			<cfset arguments.docBuilder.insertBreak(breakType.PARAGRAPH_BREAK)>
		</cfif>

		<cfset variables.instance.listEnd = false>

	</cffunction>


	<cffunction name="endRenderListToDoc" access="private" output="false" hint="Function to finish rendering the list into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset var classExist = false>
		<cfset var attributIndex = "">
		<cfset var breakType = createObject("java", "com.aspose.words.BreakType", variables.instance.paths.asposewords)>

		<cfloop from="1" to="#arrayLen(domNode.attributes)#" index="attributIndex">
			<cfif arguments.domNode.attributes[attributIndex].name EQ "class" >
				<cfset classExist = true>
			</cfif>
		</cfloop>

		<cfif variables.instance.nestedListNumber == 0>
			<cfset arguments.docBuilder.getListFormat().removeNumbers()>
			<cfset variables.instance.isInlist = false>
			<cfset variables.instance.nestedListNumber = -1>
		<cfelse>
			<cfset variables.instance.listEnd = true>
			<cfset arguments.docBuilder.getListFormat().listOutdent()>
			<cfset variables.instance.nestedListNumber -->
		</cfif>

	</cffunction>


	<cffunction name="endRenderFontToDoc"  access="private" output="false" hint="Function to start rendering the text font style into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset arguments.docBuilder.popFont()>

	</cffunction>


	<cffunction name="endRenderTableToDoc" access="private" output="false" hint="Function to finish rendering the table into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset arguments.docBuilder.endTable()>
		<cfset variables.instance.tableFlag = false>
		<cfset variables.instance.MaxColumnNumber = 0>
		<cfset arguments.docBuilder.writeln()>
	</cffunction>


	<cffunction name="endRenderTableRowToDoc" access="private" output="false" hint="Function to finish rendering the table row into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

		<cfset variables.instance.tableColumnCounter = 0>
		<cfset variables.instance.MaxColumnNumber = 0 >
		<cfset arguments.docBuilder.endRow()>
	</cffunction>


	<cffunction name="endRenderTableCellToDoc" access="private" output="false" hint="Function to finish rendering the table cell into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

	</cffunction>


	<cffunction name="endRenderBreakToDoc" access="private" output="false" hint="Function to start rendering the breaks into doc ">
		<cfargument name="domNode" required="true">
		<cfargument name="docBuilder" required="true">

	</cffunction>


</cfcomponent>