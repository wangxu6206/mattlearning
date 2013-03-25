<cfcomponent displayname="AsposeConversion" output="false" hint="Converts content from doc(x) to xhtml and from the xhtml to doc(x) using Aspose.Word library">

	<cfset variables.instance = {}>

	<cffunction name="init" access="public" output="false" returnType="any" hint="initialize the interface to access the AsposeConversion library">
		<cfargument name="pathPackages" type="string" required="false" default="lib.packages" hint="The path to the project packages directory">
		<cfargument name="pathLicense" type="string" required="false" default="#getDirectoryFromPath(getCurrentTemplatePath())#">
		<cfargument name="formatOutput" type="boolean" required="false" default="false" hint="Whether to add tabs/linefeeds etc to html output">
		<cfargument name="includeBodyTags" type="boolean" required="false" default="false" hint="Do we want to include html body tags in the doc to html conversion?">
		<cfargument name="classFlag" type="boolean" required="false" default="false" hint="set the class attribute for html element">
		<cfargument name="svgpngcommand" type="string" required="false" default="/Applications/Inkscape.app/Contents/Resources/bin/inkscape" hint="Path to svgpng command on the system">
		<cfargument name="classChange" type="boolean" required="false" default="false" hint="receive the uploaded file name ">
		<cfargument name="docImageSavePath" type="string" required="false" default="#expandPath('./')#" hint="path of saving the images parsed from word document" >

		<cfset var oLicense = "">
		<cfset var paths = "">

		<cfset variables.instance.inkscapeCommand = arguments.svgpngcommand>
		<cfset variables.instance.formatOutput = arguments.formatOutput>
		<cfset variables.instance.includeBodyTags = arguments.includeBodyTags>
		<!--- classFlag is used to receive the status of enable or disable of rendering class attribute in element tags if the content is under certain style --->
		<cfset variables.instance.classFlag = arguments.classFlag>
		<cfset variables.instance.classChange = arguments.classChange>
		<cfset variables.instance.docImageSavePath = arguments.docImageSavePath>

		<!--- set up the paper size --->
		<cfset variables.instance.paper = {}>
		<cfset variables.instance.paper.marginTop = 22>
		<cfset variables.instance.paper.marginBottom = 20>
		<cfset variables.instance.paper.marginLeft = 30>
		<cfset variables.instance.paper.marginRight = 30>

		<cfset variables.instance.paths = {
			"asposewords" = expandPath("/#replace(arguments.pathPackages, '.', '/', 'all')#/asposewords/lib/asposewords.jar"),
			"jerichohtml" = expandPath("/#replace(arguments.pathPackages, '.', '/', 'all')#/asposewords/lib/jerichohtml.jar")
		}>

		<!--- Set the license key for Aspose.Words --->
		<cftry>
			<cfset oLicense = createObject("java", "com.aspose.words.License", variables.instance.paths.asposewords).init()>
			<cfset oLicense.setLicense("#arguments.pathLicense#Aspose.Words.lic")>
			<cfcatch type="any">
				<cfoutput>Error setting license key ("#arguments.pathLicense#Aspose.Words.lic"): #cfcatch.message#</cfoutput>
				<cflog text="Error setting license key - #cfcatch.message#" type="error" file="#application.applicationName#">
				<cfrethrow>
			</cfcatch>
		</cftry>

		<cfreturn this>
	</cffunction>


	<cffunction name="getTemplateStyles" access="public" output="false" returnType="any" hint="Retrieve any customized styles in the Word document (paragraph or character etc)">
		<cfargument name="filepath" type="string" required="true" hint="Filepath to a Word document to parse">

		<cfset var style = createObject("java", "com.aspose.words.Style", variables.instance.paths.asposewords)>
		<cfset var isBuiltInStyle = false>
		<cfset var styleType = "">
		<cfset var tempStyle = "">
		<cfset var inputStream = "">
		<cfset var wordDocument = "">
		<cfset var styleCollection = "">
		<cfset var styleIterator = "">
		<cfset var user_define_styles = []>
		<cfset var styleData = "">

		<cfif len(trim(arguments.filepath))>
			<cfset inputStream = createObject("java", "java.io.FileInputStream").init( trim(arguments.filepath) )>
			<cfset wordDocument = createObject("java", "com.aspose.words.Document", variables.instance.paths.asposewords).init( inputStream )>
			<cfset styleCollection = wordDocument.getStyles()>
			<cfset styleIterator = styleCollection.iterator()>
			<cfloop condition="styleIterator.hasNext()">
			  	<cfset tempStyle = styleIterator.next()>
			  	<cfset isBuiltInStyle = tempStyle.getBuiltIn()>

			  	<cfif !isBuiltInStyle>
					<cfset styleData = {
						name = tempStyle.getName(),
						type = ""
					}>
					<cfswitch expression="#tempStyle.getType()#">
						<cfcase value="1">
							<cfset styleData.type = "paragraph">
						</cfcase>
						<cfcase value="2">
							<cfset styleData.type = "character">
						</cfcase>
						<cfcase value="3">
							<cfset styleData.type = "table">
						</cfcase>
						<cfcase value="4">
							<cfset styleData.type = "list">
						</cfcase>
					</cfswitch>
				  	<cfset arrayAppend(user_define_styles, styleData)>
				</cfif>
			</cfloop>
			<cfset inputStream.close()>
		<cfelse>
			<cfthrow type="error" message="File not found, please check path">
		</cfif>

		<cfreturn user_define_styles>
	</cffunction>


	<cffunction name="readWordInfo" access="public" output="false" returnType="struct"  hint="read the word document and retrieve the file information such as page number, file size etc">
		<cfargument name="filepath" type="string" required="true" hint="Filepath to a Word document to parse">

		<cfset var info = {
			pageNumber = 0
		}>

		<cfset var inputStream = createObject("java", "java.io.FileInputStream").init( arguments.filepath )>
		<cfset var document = createObject("java", "com.aspose.words.Document", variables.instance.paths.asposewords).init( inputStream )>
		<cfset info.pageNumber = document.getPageCount()>
		<cfset inputStream.close()>

		<cfreturn info>
	</cffunction>


	<cffunction name="startDoc2Html" access="public" output="false" returnType="struct"  hint="Main controller function for converting a MS Word document into valid (x)html">
		<cfargument name="filepath" type="string" required="true" hint="Filepath to a Word document to parse">
		<cfargument name="doc2html" type="any" required="false" default="#createObject("component", "Doc2Html").init()#" hint="Class to manage the conversion from Word document to html">

		<cfset var stResult = "">
		<cfset var aDOMStruct ={}>
		<cfset var inputStream = "">
		<cfset var document = "">
		<cfset var sectionList = "">
		<cfset var sectionDOM = []>
		<cfset var domCursor = "">
		<cfset var domNode = "">
		<cfset var oD2H = "">
		<cfset var j = "">
		<cfset var section = "">
		<cfset var body = "">
		<cfset var domLen = 0>

		<cfsetting requesttimeout="10000">
		<cfset stResult = {
			status = true
		}>

		<cftry>
			<cfset inputStream = createObject("java", "java.io.FileInputStream").init( arguments.filepath)>
			<cfset document = createObject("java", "com.aspose.words.Document", variables.instance.paths.asposewords).init( inputStream )>
			<cfset oD2H = arguments.doc2html>
			<cfset oD2H.config(
								imageSaveDirectory = variables.instance.docImageSavePath,
								formatOutput = variables.instance.formatOutput,
								includeBodyTags = variables.instance.includeBodyTags,
								classFlag = variables.instance.classFlag,
								classChange = variables.instance.classChange,
								asposewordsPath = variables.instance.paths.asposewords,
							 	jerichohtmlPath = variables.instance.paths.jerichohtml
						        )>

			<cfset sectionList = document.getSections()>
			<cfloop from="0" to="#sectionList.getCount()-1#" index="j">
				<cfset section = sectionList.get(j)>
				<cfset body = section.getBody()>
				<cfset aDOMStruct = oD2H.createDOCDOM(body)>
				<cfset domLen = arrayLen(aDOMStruct.DOM)>
				<cfloop from="1" to="#domLen#" index="domCursor">
					<cfset domNode = aDOMStruct.DOM[domCursor]>
					<cfset arrayAppend(sectionDOM, domNode)>
				</cfloop>
			</cfloop>

			<cfset stResult.DOM = sectionDOM>
			<cfset stResult.output = oD2H.renderHTML(sectionDOM)>
			<cfset inputStream.close()>

			<cfcatch type="any">
				<cfset stResult.status = false>
				<cfset stResult.error = cfcatch>
				<cfdump var="#stResult#" expand="false"><cfabort>
			</cfcatch>
		</cftry>

		<cfreturn stResult>
	</cffunction>


	<cffunction name="startHtml2Doc" access="public" output="false" returnType="struct"  hint="Generate a MS Word document from (x)html with customized configurations . From there you may generate a PDF or epub">
		<cfargument name="htmlString" type="string" required="true">
		<cfargument name="html2doc" type="any" required="true" hint="Class to manage html conversion to Word doc">
		<cfargument name="exportFileName" type="string" required="true" hint="file name of the export document">
		<cfargument name="template" type="string" required="false" default="" hint="file path of the Word template">
		<cfargument name="coverPage" type="string" required="false" default="" hint="file path of the Word cover page">
		<cfargument name="format" type="string" required="false" default="doc" hint="doc|pdf|epub or any combination of them to generate them at the same time">
		<cfargument name="downloadDir" type="string" required="false" default="" hint="the directory of saving the generated document">
		<cfargument name="footerlabel" type="string" required="false" default="" hint="the  content of footer in generated document">
		<cfargument name="toc" type="boolean" required="false" default=false hint="set the table of content">
		<cfargument name="fontName" type="string" required="false" default="" hint="the name of the font used in the generated document such as Arial|Trade Gothic LT Std Cn">
		<cfargument name="fontSourcePath" type="string" required="false" default="" hint="the directory of true type font source file">
		<cfargument name="orientation" type="string" required="false" default="" hint="set the paper orientation as landscape or protrait">

		<cfset var FontSettings = createObject("java", "com.aspose.words.FontSettings", variables.instance.paths.asposewords)>
		<cfset var ImportFormatMode = createObject("java", "com.aspose.words.ImportFormatMode", variables.instance.paths.asposewords)>
		<cfset var oH2D = "">
		<cfset var stResult = {}>
		<cfset var wordDoc = "">
		<cfset var outputFileName = "">
		<cfset var inputStream ="">
		<cfset var i =1>
		<cfset var tempFormat = "">
		<cfset var templateFileName = "">
		<cfset var FooterKeyword = "">
		<cfset var fullFileNameForSave = "">
		<cfset var coverpage = "">
		<cfset var coverpageStream = "">
		<cfset var coverPageDocument = "">
		<cfset var paperMargins = "">
		<cfset var outputDocument = "">
		<cfset var isDownloadFileOnPage = true>

		<cfset stResult.status = true>

		<cfset oH2D = arguments.html2doc>

		<cfset oH2D.config(
						   asposewordsPath = variables.instance.paths.asposewords,
					 	   jerichohtmlPath = variables.instance.paths.jerichohtml
						  )>

		<cfset stResult.htmlDOM = oH2D.parseHTMLFile(arguments.htmlString)>

		<!--- If using a custom template then load it here --->
		<cfif len(arguments.template) && fileExists(arguments.template)>
			<cfset inputStream = createObject("java", "java.io.FileInputStream").init( arguments.template )>
			<cfset wordDoc = createObject("java", "com.aspose.words.Document", variables.instance.paths.asposewords).init( inputStream )>
			<cfset wordDoc.removeAllChildren()>
			<cfset inputStream.close()>
		<cfelse>
			<!--- Create a new blank template --->
			<cfset wordDoc = CreateObject("java", "com.aspose.words.Document", variables.instance.paths.asposewords).init()>
		</cfif>

		<cfset wordDocBuilder = CreateObject("java","com.aspose.words.DocumentBuilder", variables.instance.paths.asposewords).init(wordDoc)>

		<!--- set up the page size and margin for the exported document --->
		<cfset oH2D.setupPaper(docBuilder=wordDocBuilder, setting=variables.instance.paper, orientation=arguments.orientation)>

		<!--- set up the footer and page index --->
		<cfset oH2D.setHeaderFooter(docBuilder=wordDocBuilder, HFContent=arguments.footerLabel)>

		<!--- set up the table of content --->
		<cfif arguments.toc>
			<cfset wordDocBuilder.getCurrentParagraph().getParagraphFormat().setStyleName("Heading 1")>
			<cfset wordDocBuilder.writeln("contents")>
			<cfset wordDocBuilder.getCurrentParagraph().getParagraphFormat().setStyleName("Normal")>
			<cfset wordDocBuilder.insertTableOfContents("\\o \'1-3\' \\h \\z \\u")>
		</cfif>

		<!--- render the content into the document --->
		<cfset oH2D.renderElement(stResult.htmlDOM, wordDocBuilder)>

		<!--- update the table of content after rendering the document content --->
		<cfif arguments.toc>
			<cfset wordDoc.updateFields()>
		</cfif>

		<cfif len(arguments.fontSourcePath) && DirectoryExists(arguments.fontSourcePath)>
			 <cfset FontSettings.setFontsFolder(arguments.fontSourcePath, true)>
		</cfif>

		<cfif len(arguments.fontName)>
			<cfset FontSettings.setDefaultFontName(arguments.fontName)>
		</cfif>

		<!--- set up the cover page --->
		<cfif len(arguments.coverpage) && fileExists(arguments.coverpage)>
			<cfset coverpageStream = createObject("java", "java.io.FileInputStream").init(arguments.coverpage)>
			<cfset coverPageDocument = createObject("java", "com.aspose.words.Document", variables.instance.paths.asposewords).init( coverpageStream )>
			<cfset coverPageDocument.appendDocument(wordDoc, ImportFormatMode.KEEP_SOURCE_FORMATTING)>
			<cfset outputDocument = coverPageDocument>
		<cfelse>
			<cfset outputDocument = wordDoc>
		</cfif>

		<!--- if the file download directory is specified, it will not download the file into download directory, otherwise it will download on the page--->
		<cfif len(trim(arguments.downloadDir)) && directoryExists(arguments.downloadDir)>
			<cfset isDownloadFileOnPage = false>
		<cfelse>
			<cfset arguments.downloadDir = getTempDirectory()>
		</cfif>

		<!--- save the content as different format such doc,odt,pdf and epub --->
		<cfloop from="1" to="#listLen(arguments.format)#" index="i">
	 		<cfset tempFormat = listGetAt(arguments.format, i)>
	 		<cfset outputFileName = arguments.exportFilename & "." & tempFormat>
	 		<cfset fullFileNameForSave = arguments.downloadDir & outputFileName>

	 		<cfset outputDocument.save(fullFileNameForSave)>

			<cfif isDownloadFileOnPage>
				<cfheader name="Content-Disposition" value='attachment;filename="#outputFileName#"'>
				<cfswitch expression="#tempFormat#">
					<cfcase value="doc,odt">
						<cfcontent type="application/msword" file="#fullFileNameForSave#">
					</cfcase>
					<cfcase value="pdf">
						<cfcontent type="application/pdf" file="#fullFileNameForSave#">
					</cfcase>
					<cfcase value="epub">
						<cfcontent type="application/epub" file="#fullFileNameForSave#">
					</cfcase>
				</cfswitch>
			</cfif>
		</cfloop>

		<cfreturn stResult>
	</cffunction>

</cfcomponent>