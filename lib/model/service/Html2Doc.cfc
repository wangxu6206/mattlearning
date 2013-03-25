component extends="lib.packages.asposewords.Html2Doc"
{

	public any function init()
	{
		super.init();
	}



	public void function config(required String asposewordsPath, required String jerichohtmlPath)
	{
		variables.instance.paths.asposewords = arguments.asposewordsPath;
		variables.instance.paths.jerichohtml = arguments.jerichohtmlPath;
		variables.instance.paper.marginTop = 20;
		variables.instance.paper.marginBottom = 20;
		variables.instance.paper.marginLeft = 25;
		variables.instance.paper.marginRight = 25;
		variables.instance.isScopeTable = false;
		variables.instance.nestedListNumber = -1;
		variables.instance.listEnd = false;
		variables.instance.anchorMap = {};
		variables.instance.bookmarkNumber = 1;
	}



	public void function customizeTableCellStyle(required any docBuilder, required String StyleName)
	{
		var BorderType = createObject("java", "com.aspose.words.BorderType", variables.instance.paths.asposewords);
		var LineStyle=createObject("java", "com.aspose.words.LineStyle", variables.instance.paths.asposewords);
		var Color=createObject("java","java.awt.Color");
		var LeftBoarder = arguments.docBuilder.getCellFormat().getBorders().getByBorderType(BorderType.LEFT);
		var RightBoarder = arguments.docBuilder.getCellFormat().getBorders().getByBorderType(BorderType.RIGHT);
		var TopBoarder = arguments.docBuilder.getCellFormat().getBorders().getByBorderType(BorderType.TOP);

		switch (arguments.StyleName)
		{
			case "term_table_title":
				arguments.docBuilder.getCellFormat().getBorders().setLineStyle(LineStyle.THICK);
				//arguments.docBuilder.getCellFormat().getBorders().setLineWidth(2);
				arguments.docBuilder.getCellFormat().getBorders().setColor(Color.LIGHT_GRAY);
				arguments.docBuilder.getCellFormat().setTopPadding(5);
				arguments.docBuilder.getCellFormat().setBottomPadding(5);
				LeftBoarder.setLineStyle(LineStyle.NONE);
				RightBoarder.setLineStyle(LineStyle.NONE);
				TopBoarder.setLineStyle(LineStyle.NONE);
				break;
			default
				break;
		}
	}



	private void function endRenderTableToDoc(required any domNode, required any docBuilder)
	{
		var AutoFitBehavior = createObject("java", "com.aspose.words.AutoFitBehavior", variables.instance.paths.asposewords);
		var NodeType = createObject("java", "com.aspose.words.NodeType", variables.instance.paths.asposewords);
		var table = arguments.docBuilder.endTable();
		var rowIndex = 1;
		var cellIndex = 1;
		var rows = "";
		var currentRow = "";
		var rowNumber = 0;
		var currentCellsInRow = "";
		var currentCell = "";
		var cellNumber = 0;
		var lastParagraph = "";
		var currentPara = "";
		var paraIndex = 1;
		var cellParas = "";

		rows = table.getRows().toArray()
		rowNumber = arrayLen(rows);

		for(rowIndex; rowIndex LTE rowNumber; rowIndex++)
		{
			currentRow = rows[rowIndex];

			currentCellsInRow = currentRow.getCells();
			cellNumber = arrayLen(currentCellsInRow.toArray());
			for(cellIndex=1; cellIndex LTE cellNumber; cellIndex++)
			{
				currentCell = currentCellsInRow.toArray()[cellIndex];
				/* remove the empty paragraph at each cell */
				lastParagraph = currentCell.getLastParagraph();
				if(lastParagraph.isEndOfCell() && !lastParagraph.hasChildNodes())
				{
					currentCell.removeChild(lastParagraph);
				}

				/* set a table to stay together on the same page */
				if(variables.instance.isScopeTable)
				{
					cellParas = currentCell.getParagraphs().toArray();
					for(paraIndex=1;paraIndex LTE arrayLen(cellParas);paraIndex++)
					{
						currentPara = cellParas[paraIndex];
						if(!(currentCell.getParentRow().isLastRow() && currentPara.isEndOfCell()))
						{
							currentPara.getParagraphFormat().setKeepWithNext(true);
						}
					}
					currentRow.getRowFormat().setAllowBreakAcrossPages(false);
				}
				else
				{
					currentRow.getRowFormat().setAllowBreakAcrossPages(true);
				}
			}
		}

		table.autoFit(AutoFitBehavior.FIXED_COLUMN_WIDTHS);
		variables.instance.MaxColumnNumber = 0;
		variables.instance.tableFlag = false;
		arguments.docBuilder.writeln();
	}



	private void function endRenderClassStyleToDoc(required any domNode, required any docBuilder)
	{
		var spanClassExist = false;
		var cssStyleExist = false;
		var i = 1;
		var j = 1;
		var classStyleName = "";
		var bookmarkName = "";
		var nodePlainText = "";

		for(i;i <= arrayLen(arguments.domNode.attributes); i++)
		{
			if(arguments.domNode.attributes[i].name == "class")
			{
				classStyleName = arguments.domNode.attributes[i].value;
				spanClassExist = true;
			}
			if(arguments.domNode.attributes[i].name == "style")
			{
				cssStyleExist = true;
			}
		}

		for(j=1; j <= arrayLen(arguments.domNode.childrenList); j++)
		{
			if(arguments.domNode.childrenList[j].type == "textNode")
				nodePlainText &= arguments.domNode.childrenList[j].text;
		}

		switch(classStyleName)
		{
			case "unit_title":
				if(structKeyExists(variables.instance.anchorMap, '#nodePlainText#'))
				{
					bookmarkName = variables.instance.anchorMap['#nodePlainText#'];
					arguments.docBuilder.endBookmark(bookmarkName);
				}
				break;
		}

		if(spanClassExist || cssStyleExist)
		{
			arguments.docBuilder.popFont();
		}

		variables.instance.replaceWithNBHyphen = false;
		variables.instance.replaceWithNBSpace = false;
	}



	public void function renderTextToDoc(required any domNode, required any docBuilder)
	{
		var textContent=arguments.domNode.text;
		var document = arguments.docBuilder.getDocument();

		textContent = Replace(textContent, Chr(9), "", "All");
		textContent = Replace(textContent, Chr(7), "", "All");
		textContent = Replace(textContent, Chr(10), "", "All");
		textContent = Replace(textContent, Chr(11), "", "All");
		textContent = Replace(textContent, Chr(13), "", "All");
		textContent = Replace(textContent, "-tab-", chr(9), "All");
		textContent = Replace(textContent, "&quot;", Chr(34), "All");
		textContent = Replace(textContent, "&apos;", Chr(39), "All");
		textContent = Replace(textContent, "&amp;", Chr(38), "All");
		textContent = Replace(textContent, "&lt;", Chr(60), "All");
		textContent = Replace(textContent, "&gt;", Chr(62), "All");
		textContent = Replace(textContent, "&nbsp;", Chr(32), "All");

		// add the non-breaking hyphen in syllabus outcome code
		if(variables.instance.replaceWithNBHyphen)
		{
			textContent = Replace(textContent, "-", chr(30), "All");
		}
		//replace all the white spaces with non breaking space
		if(variables.instance.replaceWithNBSpace)
		{
			textContent = Replace(textContent, Chr(32), chr(160), "All");
		}

		//arguments.docBuilder.getFont().setName("Arial");
		//arguments.docBuilder.getFont().setName("Arial Unicode MS");
		arguments.docBuilder.write(textContent);
	}



	public void function setbasePageSpanNumber(required numeric baseScopePageSpanNumber, required numeric baseUnitPageSpanNumber)
	{
		variables.instance.baseScopePageSpanNumber = arguments.baseScopePageSpanNumber;
		variables.instance.baseUnitPageSpanNumber = arguments.baseUnitPageSpanNumber;
	}


	/* public void function setHeaderFooter(required any docBuilder, required string HFContent)
	{
		var ps = arguments.docBuilder.getPageSetup();
		var document = arguments.docBuilder.getDocument();
		var HeaderFooterType = createObject("java", "com.aspose.words.HeaderFooterType", variables.instance.paths.asposewords);
		var ControlChar = createObject("java", "com.aspose.words.ControlChar", variables.instance.paths.asposewords);
		var ParagraphAlignment = createObject("java", "com.aspose.words.ParagraphAlignment", variables.instance.paths.asposewords);
		var style = "";
		var styleName = "";
		var footerData = "";
		var i = 1;
		var footerDataItem = "";
		var pageNumberStyle = "";
		try
		{
			arguments.docBuilder.moveToSection(0)

			ps.setDifferentFirstPageHeaderFooter(false)
			ps.setOddAndEvenPagesHeaderFooter(false)

			arguments.docBuilder.moveToHeaderFooter(HeaderFooterType.FOOTER_PRIMARY)
			arguments.docBuilder.getParagraphFormat().setAlignment(ParagraphAlignment.LEFT)

			if(isXML(arguments.HFContent))
				footerData = xmlSearch(arguments.HFContent, "//p");

			for(i; i <= arrayLen(footerData); i++)
			{
				if(structKeyExists(footerData[i].xmlAttributes, 'class'))
				{
					styleName = footerData[i].xmlAttributes.class;
					style = document.getStyles().get(styleName);

					if(len(trim(style)))
					{
						arguments.docBuilder.getFont().setStyle(style);
					}

					if(i == arrayLen(footerData))
						arguments.docBuilder.write(footerData[i].xmlText);
					else
						arguments.docBuilder.writeln(footerData[i].xmlText);
				}
			}

			//add 9 spaces before the page number
			ps.setRestartPageNumbering(true)
			ps.setPageStartingNumber(1)

			arguments.docBuilder.write(ControlChar.Tab & "      ");

			pageNumberStyle = document.getStyles().get("footerpart3");
			if(len(trim(pageNumberStyle)))
			{
				arguments.docBuilder.getFont().clearFormatting();
				arguments.docBuilder.getFont().setStyle(pageNumberStyle);
			}

			//add the page number
			arguments.docBuilder.insertField("PAGE", "");
			arguments.docBuilder.moveToDocumentStart();

			//set the default language as English (AUS) which the refernece code is 3081, the original English (US) reference code is 1033
			arguments.docBuilder.getFont().setLocaleId(3081)
		}
		catch(any e)
		{
			//writeLog(text='Export_lib.services.export.Html2Doc.setHeaderFooter()--Error occured when render style:#classStyleName# on character run from <span> tag: #e.message#', type="error", file=application.applicationName);
		}
	} */


	private void function startRenderClassStyleToDoc(required any domNode, required any docBuilder)
	{
		var spanClassExist = false;
		var cssStyleExist = false;
		var classStyleName = "";
		var cssStyleAttributeValue = "";
		var cssStyleAttributeName = "";
		var attributIndex = "";
		var document = arguments.docBuilder.getDocument();
		var BreakType = createObject("java", "com.aspose.words.BreakType", variables.instance.paths.asposewords);
		var style = "";
		var i = 1;
		var Color = "";
		var Integer = "";
		var fontColor = "";
		var backgroundColor = "";
		var cssUtil = "";
		var cssVar = "";
		var rgbValue = "";
		var r = "";
		var g = "";
		var b = "";
		var anchorName = "";
		var bookmarkName = "";
		var j = 1;
		var nodePlainText = "";
		var skipGetStyle = false;

		for(i;i <= arrayLen(arguments.domNode.attributes); i++)
		{
			if(arguments.domNode.attributes[i].name == "class")
			{
				classStyleName = arguments.domNode.attributes[i].value;
				spanClassExist = true;
			}
			if(arguments.domNode.attributes[i].name == "style")
			{
				cssStyleAttributeValue = arguments.domNode.attributes[i].value;
				cssStyleExist = true;
			}
		}

		for(j=1; j <= arrayLen(arguments.domNode.childrenList); j++)
		{
			if(arguments.domNode.childrenList[j].type == "textNode")
				nodePlainText &= arguments.domNode.childrenList[j].text;
		}

		if(spanClassExist)
		{
			arguments.docBuilder.pushFont();

			try
			{
				switch(classStyleName)
				{
					case "outcomecode":
						variables.instance.replaceWithNBHyphen = true;
						break;
					case "nowrap":
						variables.instance.replaceWithNBSpace = true;
						break;
					case "anchor":
						if(!structKeyExists(variables.instance.anchorMap, nodePlainText))
						{
							anchorName = "unit" & variables.instance.bookmarkNumber & ": " & nodePlainText;
							variables.instance.bookmarkNumber ++;
							structInsert(variables.instance.anchorMap, nodePlainText, anchorName);
						}
						else
						{
							anchorName = variables.instance.anchorMap['#nodePlainText#'];
						}
						arguments.docBuilder.insertHyperlink(nodePlainText, anchorName, true);
						arrayClear(arguments.domNode.childrenList);
						skipGetStyle = true;
						break;
					case "unit_title":
						if(structKeyExists(variables.instance.anchorMap, nodePlainText))
						{
							bookmarkName = variables.instance.anchorMap['#nodePlainText#'];
							arguments.docBuilder.startBookmark(bookmarkName);
						}
						break;
					case "line_break":
						arguments.docBuilder.insertBreak(BreakType.LINE_BREAK);
						break;
					default:
						skipGetStyle = false;
						break;
				}

				style = document.getStyles().get(classStyleName);
				if(!skipGetStyle && len(trim(style)))
				{
					arguments.docBuilder.getFont().setStyle(style);
				}

			}
			catch(any e)
			{
				/* writeLog(text='Export_lib.services.export.Html2Doc.startRenderClassStyleToDoc()--Error occured when render style:#classStyleName# on character run from <span> tag: #e.message#', type="error", file=application.applicationName); */
			}
		}

		if(cssStyleExist)
		{
			arguments.docBuilder.pushFont();
			renderCssStyleToDoc(docBuilder=arguments.docBuilder, cssValueString=cssStyleAttributeValue);
		}

	}



	private void function startRenderImageToDoc(required any domNode, required any docBuilder)
	{
		var imageAttr="";
		var imageHeight=0;
		var imageWidth=0;
		var imageURL="";
		var imageAlt="default";
		var imgIndex="";
		var shapeType=createObject("java", "com.aspose.words.ShapeType", variables.instance.paths.asposewords);
		var shape = "";
		var imageInsertManner="Normal";
		var Color=createObject("java","java.awt.Color");
		var imageFileName = "";
		var imageStyleName = "";
		var imageClassExist=false;
		var document=arguments.docBuilder.getDocument();
		var imageCategory = "";

		for(imgIndex=1;imgIndex LTE arrayLen(arguments.domNode.attributes);imgIndex=imgIndex+1)
		{
			imageAttr=arguments.domNode.attributes[imgIndex];
			if(imageAttr.name EQ "height")
			{
			imageHeight=imageAttr.value;
			}
			if(imageAttr.name EQ "width")
			{
			imageWidth=imageAttr.value;
			}
			if(imageAttr.name EQ "src")
			{
			imageURL=html2docDeMoronize(imageAttr.value);
			}
			if(imageAttr.name EQ "alt")
			{
			imageAlt=imageAttr.value;
			}
			if(imageAttr.name EQ "class")
			{
			imageStyleName=imageAttr.value;
			imageClassExist = true;
			}
		}

		if(fileExists(imageURL))
		{
			imageFileName = listlast(imageURL,"/");
			arguments.docBuilder.pushFont();

			if(imageClassExist)
			{
				if(imageStyleName EQ "ccc")
				{
					imageCategory = "icon";
				}
				else if(imageStyleName.startsWith("latex"))
				{
					imageCategory = "latex";
				}
				else
				{
					imageCategory = "normal";
				}
			}
			else
			{
			imageCategory = "normal";
			}

			try
			{
				switch (imageCategory)
				{
					case "icon":
					case "latex":
						arguments.docBuilder.getFont().setStyle(document.getStyles().get(imageStyleName));
						break;
					case "normal":
						arguments.docBuilder.getFont().setStyle(document.getStyles().get("syllabus image"));
						break;
					default:
						arguments.docBuilder.getFont().setStyle(document.getStyles().get("syllabus image"));
						break;
				}
			}
			catch(any e)
			{
				/* writeLog(text="Export_lib.services.export.Html2Doc.startRenderImageToDoc()--Error occured when render style:#imageStyleName# on character run from img tag", type="error", file=application.applicationName); */
			}

			shape = arguments.docBuilder.insertImage(imageURL);
			if(imageHeight NEQ 0 AND imageWidth NEQ 0)
			{
				shape.setHeight(imageHeight);
				shape.setWidth(imageWidth);
			}
		}
		else
		{
		arguments.docBuilder.getFont().setColor(Color.RED);
		arguments.docBuilder.write("Image not found");
		arguments.docBuilder.getFont().clearFormatting();
		}
	}



    private void function startRenderListToDoc(required any domNode, required any docBuilder, required any listType)
	{
		var templateList = "";
		var listLevel = "";
		var listLevelIndex = 0;
		var appliedStyle = "";
		var document = arguments.docBuilder.getDocument();

		if(arguments.listType EQ "unordered")
		{
			appliedStyle = document.getStyles().get("unordered_list");
		    templateList =  arguments.docBuilder.getDocument().getLists().add(appliedStyle);
		}
		else
		{
			appliedStyle = document.getStyles().get("ordered_list");
			templateList =  arguments.docBuilder.getDocument().getLists().add(appliedStyle);
		}

		variables.instance.nestedListNumber ++;

		if(variables.instance.nestedListNumber == 0)
		{
			arguments.docBuilder.getListFormat().setList(templateList);
			variables.instance.isInlist = true;
		}
		else
		{
			arguments.docBuilder.writeln();
			arguments.docBuilder.getListFormat().listIndent();
		}
	}



	private void function startRenderTableToDoc(required any domNode, required any docBuilder)
	{
		var document = arguments.docBuilder.getDocument();
		var table = "";
		var tableClass = "";
		var taIndex = 1;

		variables.instance.tableFlag = true;

		for(taIndex; taIndex LTE arrayLen(arguments.domNode.attributes); taIndex++)
		{
			if(arguments.domNode.attributes[taIndex].name == "class")
			{
				tableClass = arguments.domNode.attributes[taIndex].value;
				if(tableClass == "scope")
				{
					variables.instance.isScopeTable = true;
				}
				else
				{
					variables.instance.isScopeTable = false;
				}
			}
		}

		table = arguments.docBuilder.startTable();
	}



	private void function startRenderTableCellToDoc(required any domNode, required any docBuilder)
	{
		var document = arguments.docBuilder.getDocument();
		var pageSetup = arguments.docBuilder.getPageSetup();
		var PreferredWidth = createObject("java", "com.aspose.words.PreferredWidth", variables.instance.paths.asposewords);
		var BorderType = createObject("java", "com.aspose.words.BorderType", variables.instance.paths.asposewords);
		var LineStyle=createObject("java", "com.aspose.words.LineStyle", variables.instance.paths.asposewords);
		var Color=createObject("java","java.awt.Color");
		var widthSpan = "";
		var spanNumber = 0;
		var pageWidth = 0;
		var cellWidthRatio = 1;
		var cellWidth = 0;
		var i = 1;
		var cellNodeAttr = "";
		var currentCell = "";
		var cellClass = "";
		var cellBgColor = "";


		pageWidth = pageSetup.getPageWidth()-160; // set -100 is to add some padding around the table

		for(i;i LTE arrayLen(arguments.domNode.attributes);i++)
		{
			cellNodeAttr = arguments.domNode.attributes[i];

			if(cellNodeAttr.name EQ "width")
			{
				widthSpan = cellNodeAttr.value;
			}
			if(cellNodeAttr.name EQ "class")
			{
				cellClass = cellNodeAttr.value;
			}
			if(cellNodeAttr.name EQ "bg_color")
			{
				cellBgColor = cellNodeAttr.value;
			}
		}

		spanNumber = widthSpan * 2;
		if(variables.instance.isScopeTable)
		{
			cellWidthRatio = spanNumber/variables.instance.baseScopePageSpanNumber;
		}
		else
		{
			cellWidthRatio = spanNumber/variables.instance.baseUnitPageSpanNumber;
		}

		cellWidth = pageWidth * cellWidthRatio;

		if(cellClass=="body")
			arguments.docBuilder.getRowFormat().setHeadingFormat(true);
		else
			arguments.docBuilder.getRowFormat().setHeadingFormat(false);

		currentCell = arguments.docBuilder.insertCell();

		if(cellClass == "term_table_title")
		{
			currentCell.getCellFormat().getBorders().getByBorderType(BorderType.LEFT).setLineStyle(LineStyle.NONE);
			currentCell.getCellFormat().getBorders().getByBorderType(BorderType.RIGHT).setLineStyle(LineStyle.NONE);
			currentCell.getCellFormat().getBorders().getByBorderType(BorderType.TOP).setLineStyle(LineStyle.NONE);
		}
		else
		{
			currentCell.getCellFormat().getBorders().getByBorderType(BorderType.LEFT).setLineStyle(LineStyle.SINGLE);
			currentCell.getCellFormat().getBorders().getByBorderType(BorderType.RIGHT).setLineStyle(LineStyle.SINGLE);
			currentCell.getCellFormat().getBorders().getByBorderType(BorderType.TOP).setLineStyle(LineStyle.SINGLE);
		}

		if(len(cellBgColor))
		{
			arguments.docBuilder.getCellFormat().getShading().setBackgroundPatternColor(Color.decode(cellBgColor));
		}
		else
		{
			arguments.docBuilder.getCellFormat().getShading().clearFormatting();
		}

		arguments.docBuilder.getCellFormat().setFitText(false);
		arguments.docBuilder.getCellFormat().setPreferredWidth(PreferredWidth.fromPoints(cellWidth));
	}


}