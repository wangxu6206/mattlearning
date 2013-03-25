<cfcomponent output="false">


<cffunction name="distinguishHTMLFormat" access="public" retrurntype="numeric">
	<cfargument name="inputHTMLString" required="true" type="string" />
	<cfset var inputHTMLString = arguments.inputHTMLString>
	<cfset var htmlDOM = "">
	<cfset var rootNode = "">
	<cfset var HTML_CASE = 0>
	<cfset var validHtmlRootNodeList = "p,ul,ol,table,br">
	<cfset var headingList = "h1,h2,h3,h4,h5,h6" >
	<cfset var validHtmlRootTagsRegx = "(<\s*p.*?>|<\s*ul.*?>|<\s*table.*?>|<\s*ol.*?>)">
	<cfset var validHtmlRootTags = "">
	<cfset var tempXML = "">

	<cfif isXML(inputHTMLString)>

		<cfset htmlDOM = xmlParse(inputHtmlString) >
		<cfset  rootNode = htmlDOM.xmlRoot >
		<cfif listfind(validHtmlRootNodeList, rootNode.xmlName)>
				<!--- singe paragraph/list/table like : <p>xxxxxxxxx</p> or <ul><li>xxxxx</li></ul> or <table>xxxx</table>etc --->
				<cfset HTML_CASE = 1 >
		<cfelseif listfind(headingList, rootNode.xmlName)>
				<cfset HTML_CASE = 4 >
		<cfelse>
				<!--- content inside of a paragraph like : <strong>xxxx</strong> --->
				<cfset HTML_CASE = 2 >
		</cfif>

	<cfelse>

		<cfset validHtmlRootTags = REMatchNoCase(validHtmlRootTagsRegx, inputHtmlString)>
		<cfif arrayLen(validHtmlRootTags)>
			<cfset tempXML = "<tempRoot>" & inputHtmlString & "</tempRoot>">
			<cfif isXML(tempXML)>
				<!--- multiple paragraphs or lists like: <p>xxxxxxxx</p><ul><li>xxxxx</li></ul> --->
				<cfset HTML_CASE = 4>
			<cfelse>
				<!--- there is invaild xml characters or invalid xhtml markup exist in the content --->
				<cfset HTML_CASE = 5>
			</cfif>
		<cfelse>
			<!--- single paragraph content or just plain text or empty string like: xxxxxxxx<strong>xxxxx</strong>xxxx  --->
			<cfset HTML_CASE = 3>
		</cfif>

	</cfif>

	<cfreturn HTML_CASE />
</cffunction>


<cffunction name="getOutmostTag" access="public" returntype="Struct" output="false" hint="travel the xml Node Dom and render it into string">
	<cfargument name="xmlNode" required="true" type="xml" />

	<cfset var xmlRootNode = arguments.xmlNode.xmlRoot>
	<cfset var attributesArray="">
	<cfset var attributesList = "">
	<cfset var attributesString = "">
	<cfset var attrIndex = 1>
	<cfset var startTag = "">
	<cfset var endTag = "">
	<cfset var stReturn = {}>

	<cfset attributesArray = StructKeyArray(xmlRootNode.xmlAttributes)>
    <cfloop array="#attributesArray#" index="attrIndex">
			 <cfset attributesString = attributesString & " " & attrIndex & "=" & chr(34) & xmlRootNode.xmlAttributes['#attrIndex#'] & chr(34)>
	</cfloop>

	<cfset startTag = "<" & xmlRootNode.xmlName & attributesString & ">">
	<cfset endTag = "</" & xmlRootNode.xmlName & ">">

	<cfset stReturn.startTag = startTag>
	<cfset stReturn.endTag = endTag>

	<cfreturn stReturn>
</cffunction>


<cffunction name="processImageTag" output="true" returntype="string" access="public">
		<cfargument name="htmlcontent" type="string">
		<cfargument name="imagePaths" type="struct">
		<cfargument name="ratio" type="string">
		<cfargument name="renderIcon" type="string">

		<cfset var inputHtml = arguments.htmlcontent>
		<cfset var stReturnHTML = "">
		<cfset var outputString = "">
		<cfset var contentDOM = "">
		<cfset var searchedImageNodes = "">
		<cfset var imageNode = "">
		<cfset var imageSrc = "">
		<cfset var imagePath = "">
		<cfset var imageSrcListLen = 0>
		<cfset var imageFileName = "">
		<cfset var image="">
		<cfset var imageWidth = 0>
		<cfset var imageHeight = 0>
		<cfset var invalidXmlflag = false>
		<cfset var anchorNode = "">
		<cfset var aNode = "">
		<cfset var isRender = false>
		<cfset var isVaildXML = true>
		<cfset var imgRegExpr = "<img[^>]*>">
		<cfset var imageIndex = 1>
		<cfset var imagePostion = "">
		<cfset var imageHTML = "">
		<cfset var imageNode = "">
		<cfset var imageSrc = "">
		<cfset var imageFileName = "">
		<cfset var imageCode ="">
		<cfset var iconPath = "">

		<cftry>
			<cfif NOT isXML(inputHtml)>
				<cfset inputHTML = "<tempRoot>" & inputHtml & "</tempRoot>">
				<cfset invalidXmlflag = true>
			</cfif>

			<cfset contentDOM = xmlParse(inputHtml)>
			<cfcatch type="org.xml.sax.SAXException">
				<!--- Invalid xml found, throw further up the stack --->
				<cfset isVaildXML = false>
				<cfthrow detail="#cfcatch.detail#" message="#cfcatch.message#" type="custom.xml.invalid">
			</cfcatch>
		</cftry>

		<cfif isVaildXML>
			<cfset searchedImageNodes = xmlSearch(contentDOM, "//img")>

			<cfloop from="1" to="#arrayLen(searchedImageNodes)#" index="imgIndex">

			       <cfset imageNode = searchedImageNodes[imgIndex]>
				   <cfset imageSrc = imageNode.xmlAttributes.src>
				   <cfset imagePath = arguments.imagePaths.imageBasePath & imageSrc>
				   <cfset iconPath = arguments.imagePaths.iconsBasePath & imageSrc>

				   <cfif fileExists(imagePath)>
				   		<cfset imageNode.xmlAttributes.src = imagePath>
				   		<cfset imageSrcListLen = listLen(imageSrc, "/")>
					    <cfset imageFileName = listGetAt(imageSrc, imageSrcListLen, "/")>

					    <cfset image = imageNew(imagePath)>
						<cfif structKeyExists(imageNode.xmlAttributes, "width")>
							<cfif NOT len(trim(imageNode.xmlAttributes.width))>
								<cfset imageNode.xmlAttributes.width = 0>
							</cfif>
							<cfset imageNode.xmlAttributes.width = imageNode.xmlAttributes.width * arguments.ratio>
						<cfelse>
							<cfset StructInsert(imageNode.xmlAttributes, "width", image.width * arguments.ratio)>
						</cfif>

						<cfif structKeyExists(imageNode.xmlAttributes, "height")>
							<cfif NOT len(trim(imageNode.xmlAttributes.height))>
								<cfset imageNode.xmlAttributes.height = 0>
							</cfif>
							<cfset imageNode.xmlAttributes.height = imageNode.xmlAttributes.height * arguments.ratio>
						<cfelse>
							<cfset StructInsert(imageNode.xmlAttributes, "height", image.height * arguments.ratio)>
						</cfif>
				   <cfelseif fileExists(iconPath)>
						<cfset imageNode.xmlAttributes.src = iconPath>
						<cfif arguments.renderIcon EQ "code">
							<cfif structKeyExists(imageNode.xmlAttributes, "alt")>
								<cfset imageNode.xmlAttributes.alt &= '_code' >
							<cfelse>
								<cfset StructInsert(imageNode.xmlAttributes, "alt", '_code')>
							</cfif>
						</cfif>
				   <cfelse>
				   		<cfset imageNode.xmlAttributes.src = imagePath>
				   		<cflog text="Image not found in XmlUtil.processImageTag()" file="#application.applicationName#" type="Error">
				   </cfif>

			</cfloop>

			<cfset anchorNodes = xmlSearch(contentDOM, "//a")>

			<cfloop from="1" to="#arrayLen(anchorNodes)#" index="aIndex">
			       <cfset aNode = anchorNodes[aIndex]>
				   <cfif structKeyExists(aNode.xmlAttributes, "name") AND (len(trim(aNode.xmlText)) EQ 0)>
						<cfset aNode.xmlText = ' '>
				   </cfif>
			</cfloop>

			<cftry>
				<cfset stReturnHTML = xmlToString(contentDOM.xmlRoot, outputString)>

				<cfcatch type="any">
					<cflog text="Invalid XML in XmlUtil.processImageTag()" file="#application.applicationName#" type="Error">
					<cfrethrow>
				</cfcatch>
			</cftry>

			<cfif invalidXmlflag>
					<cfset stReturnHTML = Replace(stReturnHTML, "<tempRoot>", "", "All")>
					<cfset stReturnHTML = Replace(stReturnHTML, "</tempRoot>", "", "All")>
			</cfif>
		</cfif>

		<cfreturn stReturnHTML />
	</cffunction>



<cffunction name="removeHyperlinkTag" access="public" output="false" returetype="string" >
	<cfargument name="htmlString" type="string" required="true">
	<cfset var returnString = arguments.htmlString>
	<cfset var hyperlinkRegx = "\<(a[^>]*)\>(.*?)\<\/a\>">
	<cfset var hyperlinkTagRegx = "(\<(a[^>]*)\>|\<\/a\>)" >
	<cfset var foundHyperlink = "">
	<cfset var item = "">
	<cfset var hyperlinkname = "">
	<cfscript>

		foundHyperlinks = REMatchNoCase(hyperlinkRegx, returnString);
		for(item in foundHyperlinks)
		{
			hyperlinkname =  REReplace(item, hyperlinkTagRegx, "","all");
			returnString = replace(returnString, item, hyperlinkname, "all" );
		}

	</cfscript>
	<cfreturn returnString>
</cffunction>


<cffunction name="stripOutmostTag" access="public" returntype="any" output="false" hint="travel the xml Node Dom and render it into string">
	<cfargument name="xmlNode" required="true" type="xml" />
	<cfargument name="outputString" required="true" type="string" />
	<cfargument name="rootCount" required="false" type="numeric" default=0/>

	<cfset var currentNode = arguments.xmlNode>
	<cfset var returnOutput = arguments.outputString>
	<cfset var childrenNodes = XMLSearch(arguments.xmlNode, './node()')>

    <cfset var childIndex= 1>
	<cfset var childNode = "">
	<cfset var textNodeContent = "">
	<cfset var attributesArray="">
	<cfset var attributesList = "">
	<cfset var attributesString = "">
	<cfset var attrIndex = 1>
	<cfset var self_closing_tag_list = "br,hr,img,input,link,area,base,col,param">
	<cfset var levelCount = arguments.rootCount>
	<cfset var cleanedText = "">
	<cfif XmlGetNodeType(currentNode) EQ 'ELEMENT_NODE'>
		    <cfset levelCount++>
		    <cfif levelCount NEQ 1>
			    <cfset attributesArray = StructKeyArray(currentNode.xmlAttributes)>
			    <cfloop array="#attributesArray#" index="attrIndex">
						 <cfset attributesString = attributesString & " " & attrIndex & "=" & chr(34) & currentNode.xmlAttributes['#attrIndex#'] & chr(34)>
				</cfloop>

			    <cfif listFind(self_closing_tag_list, currentNode.xmlName)>
				        <cfset returnOutput = returnOutput & "<" & currentNode.xmlName & attributesString >
				<cfelse>
					   <cfset returnOutput = returnOutput & "<" & currentNode.xmlName & attributesString & ">">
				</cfif>
			    <cfset attributesString = "">
			</cfif>
			<cfloop index="childIndex" from="1" to="#ArrayLen(childrenNodes)#" step="1">
			    	<cfset childNode = childrenNodes[childIndex]>
		    		<cfset returnOutput = stripOutmostTag(childNode, returnOutput, levelCount)>
		    </cfloop>

		    <cfif levelCount NEQ 1>
				<cfif listFind(self_closing_tag_list, currentNode.xmlName)>
				       <cfset returnOutput = returnOutput & "/>">
				<cfelse>
					   <cfset returnOutput = returnOutput & "</" & currentNode.xmlName & ">">
				</cfif>
			</cfif>
	<cfelseif XmlGetNodeType(currentNode) EQ 'TEXT_NODE'>
			<cfset cleanedText = Replace(currentNode.xmlValue, Chr(60), "&lt;", "All")>
			<cfset cleanedText = Replace(cleanedText, Chr(62), "&gt;", "All")>
			<cfset returnOutput = returnOutput & cleanedText>
	</cfif>

	<cfreturn returnOutput>
</cffunction>


<cffunction name="xmlDOMToString" access="public" returntype="any" output="false" hint="travel the xml Node Dom and render it into string">
	<cfargument name="xmlNode" required="true" type="xml" />
	<cfargument name="outputString" required="true" type="string" />

	<cfset var currentNode = arguments.xmlNode>
	<cfset var returnOutput = arguments.outputString>
	<cfset var childrenNodes = XMLSearch(arguments.xmlNode, './node()')>

    <cfset var childIndex= 1>
	<cfset var childNode = "">
	<cfset var textNodeContent = "">
	<cfset var attributesList = "">
	<cfset var attributesString = "">
	<cfset var attrIndex = 1>
	<cfset var self_closing_tag_list = "br,hr,img,input,link,area,base,col,param">
	<cfset var jsoup = New lib.packages.jsoup.jsoup()>

	<cfif XmlGetNodeType(currentNode) EQ 'ELEMENT_NODE'>

		    <cfset attributesArray = StructKeyArray(currentNode.xmlAttributes)>
		    <cfloop array="#attributesArray#" index="attrIndex">
					 <cfset attributesString = attributesString & " " & attrIndex & "=" & chr(34) & currentNode.xmlAttributes['#attrIndex#'] & chr(34)>
			</cfloop>

		    <cfif listFind(self_closing_tag_list, currentNode.xmlName)>
			        <cfset returnOutput = returnOutput & "<" & currentNode.xmlName & attributesString >
			<cfelse>
				   <cfset returnOutput = returnOutput & "<" & currentNode.xmlName & attributesString & ">">
			</cfif>
		    <cfset attributesString = "">

			<cfloop index="childIndex" from="1" to="#ArrayLen(childrenNodes)#" step="1">
			    	<cfset childNode = childrenNodes[childIndex]>
		    		<cfset returnOutput = xmlDOMToString(childNode, returnOutput)>
		    </cfloop>

			<cfif listFind(self_closing_tag_list, currentNode.xmlName)>
			       <cfset returnOutput = returnOutput & "/>">
			<cfelse>
				   <cfset returnOutput = returnOutput & "</" & currentNode.xmlName & ">">
			</cfif>

	<cfelseif XmlGetNodeType(currentNode) EQ 'TEXT_NODE'>

			<!--- <cfset returnOutput = returnOutput & doc2htmlDeMoronize(currentNode.xmlValue)> --->
			<cfset returnOutput = returnOutput & jsoup.tidy(currentNode.xmlValue) />

	</cfif>

	<cfreturn returnOutput>
</cffunction>


<cffunction name="xmlGetDoc" access="public" returntype="any" output="false" hint="I get the XML document reference that contains the given XML node.">

	<cfargument name="node" type="any" required="true" hint="I am the XML node for which we are getting the parent XML document." />
 	<cfset var xmlDocNodes = xmlSearch( arguments.node, "/*/.." ) />
 	<cfreturn xmlDocNodes[ 1 ] />

</cffunction>


<cffunction name="xmlUpdateNodeName" access="public" returntype="any" output="false" description="return a new element with new node name">

	<cfargument name="node" type="any" required="true">
	<cfargument name="newname" type="string" required="true">
	<cfset var xmldoc = xmlGetDoc(arguments.node)>
	<cfset var newelem = XMLElemNew(xmldoc, arguments.newname)>

	<cfset StructUpdate(newelem, 'xmlText', duplicate(arguments.node['xmlText']) )>
	<cfset StructUpdate(newelem, 'xmlAttributes', duplicate(arguments.node['xmlAttributes']) )>
	<cfset StructUpdate(newelem, 'xmlChildren', duplicate(arguments.node['xmlChildren']) )>
	<cfreturn newelem>

</cffunction>


<cffunction name="xmlToString" access="public" output="false" returnType="string" hint="convert xml into string without indenting characters">
	<cfargument name="xml" type="xml" required="true">
	<cfset var XMLUtil=createObject("java","railo.runtime.text.xml.XMLUtil")>
	<cfset var OutputKeys=createObject("java","javax.xml.transform.OutputKeys")>
	<cfset var StreamResult=createObject("java","javax.xml.transform.stream.StreamResult")>
	<cfset var DOMSource=createObject("java","javax.xml.transform.dom.DOMSource")>
	<cfset var StringWriter=createObject("java","java.io.StringWriter")>
	<cfset var sw=StringWriter.init()>
	<cfset var res=StreamResult.init(sw)>
	<cfset var trans = "">
	<cfset var outputString = "">

	<cfscript>
		try{
			trans = XMLUtil.getTransformerFactory().newTransformer();
			trans.setOutputProperty(OutputKeys.INDENT,"no");
			trans.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION,"yes");
			trans.transform(DOMSource.init(xml), res);
			outputString = sw.getBuffer().toString();
			return outputString;
		}finally{
			sw.close();
		}
	</cfscript>

</cffunction>


<cffunction name="xmlMergeChildNodes" access="public" returntype="void" output="false" description="merge similar html nodes together">

	<cfargument name="node" type="any" required="true" hint="node containings child node to merge">
	<cfargument name="nodenames" type="string" required="false" default="em,i,b,strong,span,a" hint="list of node name that can be merged">

	<cfset var children = arguments.node.xmlChildren >
	<cfset var new = []>
	<cfset var prevnode = ''>
	<cfset var nodes = xmlsearch(arguments.node,"./node()")>
	<cfset var i = 1>
	<cfset var elemnode_index = 0>
	<cfset var isMerged = false>

	<cfif ArrayLen(children) LT 2 or NOT isXMLElem(arguments.node)>
		<cfreturn>
	</cfif>


	<cfloop condition="#i LTE ArrayLen(nodes) #">

		<cfset currentnode = nodes[i]>
		<cfset isMerged = false>


		<cfif XMLGetNodeType(currentnode) is 'ELEMENT_NODE'>
			<cfset elemnode_index++>

			<cfif 	ListFindNoCase(arguments.nodenames, currentnode.xmlname)
					AND isSimilarNode(currentnode, prevnode)
					AND ArrayLen(currentnode.xmlChildren) eq 0 AND ArrayLen(prevnode.xmlChildren) eq 0>

					<cfset prevnode.xmlText &= currentnode.xmlText >
					<cfset ArrayDeleteAt(arguments.node.xmlChildren, elemnode_index)>
					<cfset isMerged = true>

			</cfif>
		</cfif>

		<cfif isMerged>
			<!--- if nodes were merge - reset the loop --->
			<cfset nodes = xmlsearch(arguments.node,"./node()")>
			<cfset i=0>
			<cfset elemnode_index = 0>
			<cfset prevnode = ''>
		<cfelse>
			<cfset prevnode = currentnode>
		</cfif>

		<cfset i++>

	</cfloop>


</cffunction>


<!--- ===================================================== PRIVATE FUNCTIONS ===================================================== --->

<cffunction name="isSimilarNode" access="private" returntype="boolean" description="compare 2 nodes to test if they are the same except text value. This function does not test children nodes">
	<cfargument name="node1" required="true" type="any">
	<cfargument name="node2" required="true" type="any">

	<cfset var i = ''>

	<cfif 	NOT isXMLNode(arguments.node1)
			OR NOT isXMLNode(arguments.node2)
			OR XMLGetNodeType(arguments.node1) neq XMLGetNodeType(arguments.node2)
			OR arguments.node1.xmlName neq arguments.node2.xmlName>
			<cfreturn false>
	</cfif>

	<cfloop collection="#arguments.node1.xmlAttributes#" item="i">
		<cfif NOT StructKeyExists(arguments.node2.xmlAttributes, i)
				OR Compare(arguments.node1.xmlAttributes[i], arguments.node2.xmlAttributes[i]) neq 0>
			<cfreturn false>
		</cfif>
	</cfloop>

	<cfreturn true>

</cffunction>


</cfcomponent>