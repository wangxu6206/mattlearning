component
{
	variables.instance = {};
	variables.cfcs = {};

	public any function init(required string asposewordsLicensePath)
	{

		variables.cfcs.asposeword = New lib.packages.asposewords.AsposeConversion(
			pathLicense = arguments.asposewordsLicensePath
		);
		variables._Logging = application.cfcs.Logging;
		return this;
	}


	/**
	* @hint: export a single unit html data into Word document
	*/
	public void function exportDocument(required string htmlString, required struct config, string downloadDir="")
	{
		var Html2docClass = new lib.model.service.Html2Doc();
		var tempPath = Len(arguments.downloadDir) ? GetTempDirectory() & createUUID() & '/' : "";
		var filename = sanitiseFileName(arguments.config.exportFileName);

		try
		{
			stDownload = variables.cfcs.asposeword.startHtml2Doc(
																htmlString = arguments.htmlString,
																html2doc = Html2docClass,
																template = arguments.config.template,
																footerlabel = arguments.config.footerlabel,
																exportFileName = filename,
																orientation = arguments.config.orientation,
																format = arguments.config.format,
																downloadDir = tempPath
															);
		}
		catch (java.util.EmptyStackException e)
		{
			_Logging.write(text="Export_lib.model.services.export.ExportManager.exportDocument()_EmptyStackException--"&e.message);
			throw(type="export.html2doc", message="Export failed. The input html string may contain invalid markup or characters");
			writeDump(e);abort();
		}
		catch(any e)
		{
			_Logging.write(text="Export_lib.model.services.export.ExportManager.exportDocument()--"&e.message);
			throw(type="export.html2doc", message="Export failed. A problem occured on the conversion from html to word through asposewords");
			writeDump(e);abort();
		}

		if (Len(arguments.downloadDir)){
			_Logging.write(text='Export_lib.model.services.export.ExportManager.exportDocument() : Move "#filename#" to "#arguments.downloadDir#" ', type="Information", group="export");
			FileMove(tempPath  & filename & '.' & arguments.config.format, arguments.downloadDir  );
			writeDump(e);abort();
		}
	}


	/**
	* @hint: add the style class attribute into the certain html element such as p, li for export with the template
	*/
	public string function getHTMLWithStyleClass(required string htmlString, required string styleName)
	{
		var returnHTML="";
		var xmlDOM = "";
		var blackList = "h2,h3,h4,h5";
		var newHTMLString = "";
		var newhtmlDOM = "";
		var childIndex = 1;
		var contentNodes = "";
		var contentItemNode = "";
		var newContentItemNode = "";
		var newSpanNode = "";
		var newParaNode = "";
		var xmlDoc = "";
		var addClassIndex = 1;
		var html_case = 1;
		var listChangeStyleName = "";
		var pNodes = "";
		var pindex = 1;
		var xmlUtil = New lib.model.utils.XmlUtil();
		var string = New lib.model.utils.String();

		html_case = xmlUtil.distinguishHTMLFormat(arguments.htmlString);

		switch (html_case)
        {
			case 1:
			    /*add class = "style" into root node attributes list*/
			    xmlDOM = xmlparse(arguments.htmlString);

				if(structKeyExists(xmlDOM.xmlRoot.XmlAttributes, "class"))
		  	    {
			  	   xmlDOM.xmlRoot.XmlAttributes.class =  arguments.styleName;
		  	    }
		  	    else
		  	    {
			  	   StructInsert(xmlDOM.xmlRoot.XmlAttributes, "class", arguments.styleName);
		  	    }
				returnHTML = xmlUtil.xmlToString(xmlDOM.xmlRoot, returnHTML);

				break;
			case 2:
			case 3:
				/*wrapp the content with <p class="style">....</p>*/

				returnHTML = "<p class=" & chr(34) & arguments.styleName & chr(34) & ">" & arguments.htmlString & "</p>";

				break;
			case 4:
				/*add class="style" into all the vaild html root node's attribute list*/
				/*as for case of <h3>xxxxx</h3><p>xxxxxx</p><p>xxxxxxxx</p>, need to replace <h3>xxxx</h3> with <p><span class="h3">xxxx</span></p>*/
			    newHTMLString = "<tempRoot>" & arguments.htmlString & "</tempRoot>";

			 	newhtmlDOM = xmlParse(newHTMLString);

			 	//if there is a table in introduction, background or language section, needs to add introduction, langeuage or backgroundinfo style to all the paragrahs inside of the table
			 		pNodes = xmlSearch(newhtmlDOM, "//p");
			 		for(pindex; pindex LTE arrayLen(pNodes); pindex++)
				{
				 	if(structKeyExists(pNodes[pindex].XmlAttributes, "class"))
			  	    {
		  	  	  	pNodes[pindex].XmlAttributes.class =  arguments.styleName;
			  	    }
			  	    else
			  	    {
		  	  	   StructInsert(pNodes[pindex].XmlAttributes, "class", arguments.styleName);
			  	    }
				}

			 	/*search the h1,h2,h3... tag and replace them with <p><span class='style'>xxxx</span></p>*/
			 	contentNodes= newhtmlDOM.xmlRoot.xmlChildren;
				for(childIndex; childIndex LTE arrayLen(contentNodes); childIndex++)
				{
			  		contentItemNode = contentNodes[childIndex];
				  	if( listFind(blackList, contentItemNode.xmlName))
				  	{
		  				//eg, change <h3>xxxx</h3> into <p class="h3">xxxx</p>
						newParaNode = XMLElemNew(newhtmlDOM, "p");
			  	  		StructInsert(newParaNode.XmlAttributes, "class", contentItemNode.xmlName & " para");
			  	  		StructUpdate(newParaNode, 'xmlChildren', duplicate(contentItemNode['xmlChildren']) );
			  	  		StructUpdate(newParaNode, 'xmlText', duplicate(contentItemNode['xmlText']));
			  	  		ArrayDeleteAt(newhtmlDOM.xmlRoot.xmlChildren, childIndex);
			  	  		ArrayInsertAt(newhtmlDOM.xmlRoot.xmlChildren, childIndex, newParaNode);
			  	    }
			  	    else
			  	    {
			  	    	if(structKeyExists(contentItemNode.XmlAttributes, "class"))
			  	  	    {
			  	  	        contentItemNode.XmlAttributes.class =  arguments.styleName;
			  	  	    }
			  	  	    else
			  	  	    {
			  	  	  	    StructInsert(contentItemNode.XmlAttributes, "class", arguments.styleName);
			  	  	    }
			  	    }

			    }

			    returnHTML = xmlUtil.xmlToString(newhtmlDOM.xmlRoot, returnHTML);
				returnHTML = replace(returnHTML, "<tempRoot>", "", "All");
				returnHTML = replace(returnHTML, "</tempRoot>", "", "All");

				break;
			case 5:
				/*using the jtidy to correct the invalid html into valid xhtml*/
				returnHTML = string.cleanHTML(arguments.htmlString);
				returnHTML = "<p>" & xmlFormat(returnHTML) & "</p>";
				break;
			default:
				break;
        }

		return returnHTML;
	}


	/**
	* @hint: use jTidy to validate and correct the invalid html into xhtml
	*/
	public string function jtidyCleanUp(required string htmlString)
	{
		var retrunValidHtml = "";
		var jtidy = New lib.packages.jtidy.jtidy();

		// If this has issues, suggest using apache commons
		//var strEscape = createObject("java", "org.apache.commons.lang.StringEscapeUtils");
		//retrunValidHtml = strEscape.unescapeHTML(arguments.htmlString);

		retrunValidHtml =jtidy.makexHTMLValid(arguments.htmlString);
		retrunValidHtml = Replace(retrunValidHtml, "<br />", "", "All");
		retrunValidHtml = Replace(retrunValidHtml, "<div>", "", "All");
		retrunValidHtml = Replace(retrunValidHtml, "</div>", "", "All");
		retrunValidHtml = Replace(retrunValidHtml, "&nbsp;", " ", "All");

		//writeLog(text="jtidyCleanUp() took #getTickCount()-startTime#ms to run", type="information", file=application.applicationName);

		return trim(retrunValidHtml);
	}


	/**
	* @hint: change the image size for export into word document properly
	*/
	public string function processImageTag(required string htmlcontent, required struct imagePaths, required string ratio, required string colWidth, required string renderIcon, required string level)
	{
		var stReturnHTML = "";
		var outputString = "";
		var contentDOM = "";
		var searchedImageNodes = "";
		var imageNode = "";
		var imageSrc = "";
		var imagePath = "";
		var imageSrcListLen = 0;
		var imageFileName = "";
		var image="";
		var imgWidth = 0;
		var imgHeight = 0;
		var invalidXmlflag = false;
		var anchorNode = "";
		var aNode = "";
		var isVaildXML = true;
		var imageNode = "";
		var imageSrc = "";
		var imageFileName = "";
		var iconPath = "";
		var i = 1;
		var j = 1;
		var xmlUtil = New lib.model.utils.XmlUtil();
		var newImageSize = "";
		var contentImageData = "";

		try
		{
			if(!isXML(arguments.htmlcontent))
			{
				arguments.htmlcontent = "<tempRoot>" & arguments.htmlcontent & "</tempRoot>";
				invalidXmlflag = true;
			}

			contentDOM = xmlParse(arguments.htmlcontent)
		}
		catch(org.xml.sax.SAXException e)
		{
			isVaildXML = false;
			_Logging.write(text="ExportManager.processImageTag()--custom.xml.invalid--#cfcatch.message#", type="Error", group="export");
		}

		if(isVaildXML)
		{
			searchedImageNodes = xmlSearch(contentDOM, "//img");

			for(i;i <= arrayLen(searchedImageNodes);i++)
			{
				imageNode = searchedImageNodes[i];
			    imageSrc = imageNode.xmlAttributes.src;
			    imagePath = arguments.imagePaths.imageBasePath & imageSrc;
			    iconPath = arguments.imagePaths.iconsBasePath & imageSrc;

			    if(fileExists(imagePath))
			    {
			    	imageNode.xmlAttributes.src = imagePath;
			   		imageSrcListLen = listLen(imageSrc, "/");
				    imageFileName = listGetAt(imageSrc, imageSrcListLen, "/");

				    image = imageNew(imagePath);
				    imgWidth = image.width * arguments.ratio;
					imgHeight = image.height * arguments.ratio;

					contentImageData = {
				    	name = imageFileName,
				    	path = imagePath,
				    	width = imgWidth*1.5,
				    	height = imgHeight*1.5
				    }
				    arrayAppend(variables.instance.contentImageData, contentImageData);

					newImageSize = shrinkImageToFitTable(indentLevel=arguments.level, tableColumnWidth=arguments.colWidth, imageWidth=imgWidth, imageHeight=imgHeight);

				    if(structKeyExists(imageNode.xmlAttributes, "width"))
				    {
				    	if(!len(trim(imageNode.xmlAttributes.width)))
				    	{
				    		imageNode.xmlAttributes.width = 0;
				    	}
				    	imageNode.xmlAttributes.width = newImageSize.width;
				    }
				    else
				    {
				    	StructInsert(imageNode.xmlAttributes, "width", newImageSize.width);
				    }

				    if(structKeyExists(imageNode.xmlAttributes, "height"))
				    {
				    	if(!len(trim(imageNode.xmlAttributes.height)))
				    	{
				    		imageNode.xmlAttributes.height = 0;
				    	}
				    	imageNode.xmlAttributes.height = newImageSize.height;
				    }
				    else
				    {
				    	StructInsert(imageNode.xmlAttributes, "height", newImageSize.height);
				    }

			    }
			    else if(fileExists(iconPath))
			    {
			    	imageNode.xmlAttributes.src = iconPath;
			    	if(arguments.renderIcon EQ "code")
			    	{
			    		if(structKeyExists(imageNode.xmlAttributes, "alt"))
			    		{
			    			imageNode.xmlAttributes.alt &= '_code';
			    		}
			    		else
			    		{
			    			StructInsert(imageNode.xmlAttributes, "alt", '_code');
			    		}
			    	}
			    }
			    else
			    {
			    	imageNode.xmlAttributes.src = imagePath;
			    	_Logging.write(text="ExportManager.processImageTag()--Image not found", type="Error", group="export");
			    }
			}

			anchorNodes = xmlSearch(contentDOM, "//a");
			for(j;j<=arrayLen(anchorNodes);j++)
			{
				aNode = anchorNodes[aIndex];
				if(structKeyExists(aNode.xmlAttributes, "name") AND (len(trim(aNode.xmlText)) EQ 0))
				{
					aNode.xmlText = ' ';
				}
			}

			try
			{
				stReturnHTML = xmlUtil.xmlToString(contentDOM.xmlRoot, outputString);
			}
			catch(any e)
			{
				_Logging.write(text="ExportManager.processImageTag()--Invalid XML", type="Error", group="export");
				rethrow;
			}

			if(invalidXmlflag)
			{
				stReturnHTML = Replace(stReturnHTML, "<tempRoot>", "", "All");
				stReturnHTML = Replace(stReturnHTML, "</tempRoot>", "", "All");
			}

		}

		return stReturnHTML;
	}



	/**
	* @hint: replace the list item <li>...</li> with <p>...</p>
	*/
	public string function replaceListWithPara(required string htmlString, required string styleName)
	{
		var returnString = arguments.htmlString;
		var listTagRegx = "(\<(ul[^>]*)\>|\<\/(ul)\>|\<(ol[^>]*)\>|\<\/(ol)\>)";
		var listItemContentRegx = "\<(li[^>]*)\>(.*?)\<\/(li)\>";
		var listItemTagRegx = "(\<(li[^>]*)\>|\<\/(li)\>)";
		var invalidListTag = "<li/>";
		var foundLists = "";
		var listItem = "";
		var listItemString = "";
		var listItemContent = "";
		var newParaContent = "";
		var string = New lib.model.utils.String();

		returnString = string.cleanIndentCharacters(returnString);
		returnString = REReplace(returnString, invalidListTag, "","all");
		foundListItems = REMatchNoCase(listItemContentRegx, returnString);
		for(listItem in foundListItems)
		{
			listItemString = listItem;
			listItemContent =  REReplace(listItemString, listItemTagRegx, "","all");
			newParaContent = "<p class=" & chr(34) & arguments.styleName & chr(34) & ">" & listItemContent & "</p>"
			returnString = replace(returnString, listItemString, newParaContent, "all" );
			returnString =  REReplace(returnString, listTagRegx, "","all");
		}

		return returnString;
	}


	/**
	* @hint: sanitise the export file name with certain rules:
	* 1, lower case of file name
	* 2, replace the whitespaces with underscore
	* 3, append the date to the file name
	*/
	public string function sanitiseFileName(required string fileName)
	{
		var cleanFileName = "";
		var fileNameWithNoSpecialChar = "";
		var lcaseName = "";
		var noSpaceName = "";
		var dateSuffixName = "";
		var currentDate = DateFormat(now(), "yyyy-mm-dd");
		var string = New lib.utils.String();

		fileNameWithNoSpecialChar = string.cleanSpecialCharactersInFileName(arguments.fileName);

		lcaseName = lcase(trim(fileNameWithNoSpecialChar));

		noSpaceName = replace(lcaseName, " ", "_", "All");

		dateSuffixName = noSpaceName & "_" & currentDate;

		cleanFileName = dateSuffixName;

		return cleanFileName;
	}


	/**
	* @hint: calculate the shrink ratio for export images to fit the different table column width in word document
	*/
	public struct function shrinkImageToFitTable(required numeric indentLevel, required numeric tableColumnWidth, required numeric imageWidth, required numeric imageHeight )
	{
		var newImageSize = {
			width = 0,
			height = 0
		};
		var i = 1;
		var PAGE_WIDTH = 682;
		var SPAN_WIDTH = PAGE_WIDTH/6; // about 124
		var INDENT_AT_LEVEL = {
			level1 = 0,
			level2 = 34,
			level3 = 49,
			level4 = 68
		};
		var shrinkRatio = 1;
		var currentLevelIndent = INDENT_AT_LEVEL['level#arguments.indentLevel#'];
		var imgTotalFitWidth = 0;
		var tableColWidthInPixel = SPAN_WIDTH * arguments.tableColumnWidth;

		for(i; i > 0; i=i-0.1)
		{
			imgTotalFitWidth = currentLevelIndent + (arguments.imageWidth * i);
			if(imgTotalFitWidth>=tableColWidthInPixel)
			{
				continue;
			}
			else
			{
				shrinkRatio = i;
				break;
			}
		}

		newImageSize.width = arguments.imageWidth * shrinkRatio;
		newImageSize.height = arguments.imageHeight * shrinkRatio;

		return newImageSize;
	}



	/**
	* @hint: validate the html data before passing to asposewords library to generate the Word document
	*/
	public string function validateHTML(required string htmlString, required string identifier)
	{
		var retrunValidHtml = "";
		var jtidyProcessedHTML = "";
		var string = New lib.model.utils.String();
		var plainText = "";
		var errorMessage = "";
		var xmlUtil = New lib.model.utils.XmlUtil();
		var html_case = 0;

		if(isXML(arguments.htmlString))
		{
			retrunValidHtml = arguments.htmlString;
		}
		else
		{
			html_case = xmlUtil.distinguishHTMLFormat(arguments.htmlString);
			/* html_case = 5 means there is invaild xml characters or invalid xhtml markup exist in the content */
			if(html_case == 5)
			{
				/* write the invalid xhtml content found error into the application log file */
				errorMessage = "Export_lib.model.services.export.ExportManager.validateHTML()--" & arguments.identifier & " contains invalid invalid xhtml markup or characters. Jtidy is triggered to clean up";
				_Logging.write(text=errorMessage, type="Information", group="export");

				/* call the jtidy to do the clean up */
				jtidyProcessedHTML = jtidyCleanUp(arguments.htmlString);

				if(isXML(jtidyProcessedHTML))
				{
					retrunValidHtml = jtidyProcessedHTML;
				}
				else
				{
					html_case = xmlUtil.distinguishHTMLFormat(jtidyProcessedHTML);
					/*html_case = 5 means there still are invaild xml characters or invalid xhtml markup exist in the content */
					if(html_case == 5)
					{
						errorMessage = "Export_lib.model.services.export.ExportManager.validateHTML()--" & arguments.identifier & " contains invalid xhtml after jtidy cleanup, so the content is converted into plain text and wrapped with <p></p>."
						_Logging.write(text=errorMessage);

						/* if the html processed after jtidy is still invalid xhtml, we strip it into plain text and wrap it by <p></p> */
						plainText = string.cleanHTML(jtidyProcessedHTML);
						retrunValidHtml = "<p>" & plainText & "</p>";
					}
					else
					{
						retrunValidHtml = jtidyProcessedHTML
					}
				}
			}
			else
			{
				retrunValidHtml = arguments.htmlString;
			}
		}

		return retrunValidHtml;
	}

}
