<cfcomponent displayname="Render" output="false">

	<cfset variables.VALID_MACRO = 'block|widget|macro|glossary'>
	<cfset variables.MACRO_REGEX = '\[\[(#variables.VALID_MACRO#)(.*?)\]\]' >

	<cffunction name="init" access="public" output="false" returnType="Render">
		<cfargument name="dsnro" type="string" required="true">
		<cfargument name="exceptionMode" type="string" required="false" default="quiet" hint="Whether to show exceptions. [quiet|loud]">

		<cfscript>
			variables.instance = {
				dsnro = arguments.dsnro,
				exceptionMode = arguments.exceptionMode
			}

			return this;
		</cfscript>
	</cffunction>


	<cffunction name="executeMacro" access="private" output="false" returnType="string">
		<cfargument name="params" type="struct" required="true">
		<cfargument name="rc" type="any" required="false">

		<cfset var output = "">
		<cfset var blocks = {}>
		<cfset var q = "">
		<cfset var syllabus = "">
		<cfset var syllabus_id = arguments.rc.syllabus_id>
		<cfset var data = "">
		<cfset var i = "">
		<cfset var outcomes = "">
		<cfset var regHTML = "<[^>]*>">

		<cfif arguments.params.macroType EQ "block">

			<cfmodule template="/lib/customtags/macro/block.cfm" ref="#arguments.params.ref#" return="output">

		<cfelseif arguments.params.macroType EQ "macro">
			<cfif structKeyExists(arguments.params, "type")>
				<cfswitch expression="#arguments.params.type#">

					<!--- Displays a list of content group links, with stage and category groupings/headings --->
					<cfcase value="content">
						<cfif structKeyExists(arguments.params, "syllabuscode")>
							<cfif structkeyexists(arguments.params, "render") and lcase(arguments.params.render) eq 'table-stages'>
								<cfmodule template="/lib/customtags/macro/contentsBystages.cfm" syllabuscode="#arguments.params.syllabuscode#" return="output" macro="#arguments.params#">
							<cfelse>
								<cfmodule template="/lib/customtags/macro/content.cfm" syllabuscode="#arguments.params.syllabuscode#" return="output" macro="#arguments.params#">
							</cfif>
						</cfif>
					</cfcase>

					<!--- Displays a full page glossary list for a specific glossary --->
					<cfcase value="glossary">
						<cfmodule template="/lib/customtags/macro/glossary_tables.cfm" syllabus_id="#syllabus_id#" return="output">
					</cfcase>

					<!--- Takes a single outcome code and renders the outcome code|body. --->
					<cfcase value="outcome">
						<cfif structKeyExists(arguments.params, "code")>
							<cfset outcomes = New lib.services.outcomes()>
							<cfset data = outcomes.getByCode(arguments.params.code)>
							<cfsavecontent variable="output">
								<cfif data.recordCount>
									<cfoutput>#data.code# #REReplace(data.outcome, regHTML, "", "all")#</cfoutput>
								<cfelse>
									<cfoutput><!-- Outcome code #data.code# not found --></cfoutput>
								</cfif>
							</cfsavecontent>
						</cfif>
					</cfcase>

					<cfcase value="outcomes">
						<cfif structKeyExists(arguments.params, "syllabuscode")>
							<cfif structkeyexists(arguments.params, "render") and lcase(arguments.params.render) eq 'table-stages'>
								<cfmodule template="/lib/customtags/macro/outcomesBystages.cfm" syllabuscode="#arguments.params.syllabuscode#" return="output" macro="#arguments.params#" context="#arguments.rc#">
							</cfif>
						</cfif>
					</cfcase>

					<!--- Displays sub-navigation, based off an existing page navurl --->
					<cfcase value="subnav">
						<cfif structKeyExists(arguments.params, "url")>
							<cfset var pages = New lib.services.pages()>
							<cfset var allNav = isDefined("arguments.rc.allNavs") ? arguments.rc.allNavs : pages.getAllNav()>
							<cfset var page = pages.get(navURL=pages.renderURL(pages.renderURL(arguments.params.url)), source="qoq", sourceqoq=allNav)>
							<cfif page.recordCount>
								<cfquery name="data" dbtype="query">
									SELECT	*
									FROM	allNav
									WHERE	parent = #page.id#
								</cfquery>
							</cfif>
							<cfif isValid("query", data) && data.recordCount>
								<cfset output = pages.buildNav(page.id, data)>
							<cfelse>
								<cflog text="Macro: No subnav found for #arguments.params.url# [URL: #CGI.path_info#]" type="information" file="#application.applicationName#">
							</cfif>
						</cfif>
					</cfcase>

					<cfdefaultcase></cfdefaultcase>
				</cfswitch>
			</cfif>
		<cfelseif arguments.params.macroType EQ "glossary">

			<cfset var glossaries = new lib.services.glossary()>
			<cfset var syllabus = "">
			<cfset var glossary = "">
			<cfset var syllabusFoundByCode = "">

			<!--- Macro can have a 'syllabuscode', if not then we grab via the syllabus_id (note: global should be passed as '') --->
			<cfif structKeyExists(arguments.params, "syllabuscode") AND len(arguments.params.syllabuscode)>
				<cfif arguments.params.syllabuscode != "global">
					<cfset syllabus = new lib.model.beans.syllabus()>
					<cfset syllabusFoundByCode = syllabus.getByCode(arguments.params.syllabuscode)>
					<cfif syllabusFoundByCode.recordcount>
						<cfset syllabus_id = syllabusFoundByCode.id[1]>
					</cfif>
				<cfelse>
					<cfset syllabus_id = -1>
				</cfif>
			</cfif>

			<cfset glossary = glossaries.getByAlias(alias=arguments.params.alias, syllabus_id=syllabus_id)>

			<!--- Override the label (even if an alternate label was used in the cms) if the user wants --->
			<cfif structKeyExists(arguments.params, "label") AND len(arguments.params.label)>
				<cfset glossary.setDisplayLabel(arguments.params.label)>
			</cfif>

			<cfset output = (len(glossary.getDisplayLabel())) ? glossary.getDisplayLabel() : glossary.getTitle()>

			<cfif !len(trim(output))>
				<cfset output = "<!-- Glossary code #arguments.params.alias# not found -->">
			</cfif>
		</cfif>

		<cfreturn output>
	</cffunction>


	<cffunction name="getAllMacrosOnPage" access="public" returnType="array" hint="retrieve all macros on a page without executed">
		<cfargument name="text" type="string" required="true">
		<cfargument name="filter" type="struct" required="false" default="#StructNew()#">
		<cfscript>
			var output = arguments.text;
			var regMacros = variables.MACRO_REGEX;
			var macros = REMatchNoCase(regMacros, output);
			var temp = '';
			var result = ArrayNew(1);
			var valid = true;
			var k = '';

			for (var mac in macros)
			{
				temp = 	parseParams(mac);
				valid = validateMacro(temp).status;

				if (NOT StructIsEmpty(arguments.filter))
				{
					for (k in arguments.filter)
					{
						valid = valid AND StructKeyExists(temp, k) AND temp[k] eq arguments.filter[k];
					}
				}


				if (valid)
					ArrayAppend(result, {
						text = mac
						, params =	temp
					});

			}

			return result;
		</cfscript>
	</cffunction>


	<cffunction name="tidyBeforeRender" access="public" output="false" returnType="string" hint="clean up the wrapped p, span tags before rendering the macro content">
		<cfargument name="text" type="string" required="true">
		<cfset var returnStr = arguments.text>
		<cfset var regMacros = variables.MACRO_REGEX>
		<cfset var tidyRegex1 = "\<(p.*?)\>\s*\<span\>" & regMacros & "\<\/span\>\s*\<\/p\>" >
		<cfset var tidyRegex2 = "\<span\>\s*" & regMacros & "\s*\<\/span\>" >
		<!--- <cfset var tidyRegex3 = "\<(p.*?)\>" & regMacros & "\<\/p\>"> --->
		<cfset var tidyRegex3 = "\<p\>\s*" & regMacros & "\s*\<\/p\>">
		<cfset var macros1 = "">
		<cfset var macros2 = "">
		<cfset var macros3 = "">

		<cfscript>

			macros1 = REMatchNoCase(tidyRegex1, returnStr);
			macros2 = REMatchNoCase(tidyRegex2, returnStr);
			macros3 = REMatchNoCase(tidyRegex3, returnStr);

			// clean wrapper <p><span>[[.....]]</span></p>
			if(arrayLen(macros1))
			{
				for (var macro1 in macros1)
				{
					returnStr = replace(returnStr, macro1, REReplace(macro1,"<[^>]*>","","all"), "all" );
				}
			}
			// clean wrapper <span>[[.....]]</span>
			else if(arrayLen(macros2))
			{
				for (var macro2 in macros2)
				{
					returnStr = replace(returnStr, macro2, REReplace(macro2,"<[^>]*>","","all"), "all" );
				}
			}
			// clean wrapper like <p>[[.....]]</p>
			else if(arrayLen(macros3))
			{
				for (var macro3 in macros3)
				{
					if(isXML(macro3))
					{
						returnStr = replace(returnStr, macro3, REReplace(macro3,"<[^>]*>","","all"), "all" );
					}
				}
			}

		</cfscript>
		<cfreturn returnStr />
	</cffunction>


	<cffunction name="render" access="public" output="false" returnType="string" hint="Looks for a specific 'macro' in a string and returns the parsed content">
		<cfargument name="text" type="string" required="true">
		<cfargument name="rc" type="any" required="false">

		<cfscript>
			var output = arguments.text;
			var params = "";
			var macros = "";
			var renderedMacro = "";
			var macroValidate = "";
			var validMacros = variables.VALID_MACRO;
			var regMacros = variables.MACRO_REGEX;


			try
			{
				// clean macro that was surrounding by <span>...</span>, <p>...</p>, <p><span>...</span></p> tags
				output = tidyBeforeRender(output);

				macros = REMatchNoCase(regMacros, output);

				if (arrayLen(macros))
				{
					//writeDump(var="sssskkk", output="/Volumes/Dev/workspace/myproject/dumpData/dump.html", format="html");abort;

					// For each macro (block or glossary or macro) found, parse the content
					for (var mac in macros)
					{
						try
						{
							// For each macro, grab the parameters so we can pass to parseMacro()
							params = parseParams(mac);
							macroValidate = validateMacro(params);

							if (macroValidate.status)
							{
								renderedMacro = executeMacro(params, arguments.rc);

								if (len(trim(renderedMacro)))
								{
									renderedMacro = wrapper(renderedMacro, params);

						            renderedMacro = tidyMacroContent(renderedMacro);
								}
								else
								{
									renderedMacro = "<!-- Nothing returned from macro -->";
								}

								output = replace(output, mac, renderedMacro, "all");
							}
							else
							{
								output = renderException(output, mac, macroValidate);
							}

						}
						catch (syllabus.render.macro e)
						{
							output = replace(output, mac, "<!-- Render: #e.message# -->", "all");
							writeLog(text="Render: #e.message#", type="error", file=application.applicationName);
						}
						catch (any e)
						{
							output = replace(output, mac, "<span class='error'>Macro content not found</span>", "all");
							writeLog(text="Render: #e.message#", type="error", file=application.applicationName);
						}

					}

					// Now that we've rendered all macros in the `text`, call render() again to see if we generated any content with new macros
					output = render(replace(output, mac, renderedMacro, "all"), arguments.rc);
				}
			}
			catch (syllabus.render.macro e)
			{
				output = "<!-- Render: #e.message# -->";
				writeLog(text="Render: #e.message#", type="error", file=application.applicationName);
			}

			return output;
		</cfscript>
	</cffunction>


	<cffunction name="parseParams" access="private" output="false" returnType="struct" hint="Takes a string in a specific format and returns a structure of key|value pairs">
		<cfargument name="data" type="string" required="true" hint="String to parse">

		<cfscript>
			var params = {};
			var temp = "";
			var macroType = "";
			var regParams = "\s+([\w-.]+)(?:\s*=\s*(""[^""]*""|[^\s>]*))?";
			var regMacroType = "\[\[[A-Za-z]+";

			arguments.data = Replace(arguments.data,'&##160;', ' ', 'all');

			// Create an array of key|value pairs for the macro attributes
			temp = REMatch(regParams, arguments.data);
			// Retrieve the macro 'type' (likely in this case to be either 'block' or 'widget' or 'macro')
			macroType = REMatch(regMacroType, arguments.data);
			// Get rid of the leading "[["
			macroType = right(macroType[1], len(macroType[1])-2);

			// Generate a return struct for easy access (we assume there won't be an '=' within the parameter 'value')
			for (var i in temp)
			{
				// Remove quotes from values as we don't want them in the struct
				//i = replace(i, "'", "", "all");
				i = replace(i, '"', "", "all");
				params[trim(listFirst(i, "="))] = (listLen(i, "=") > 1) ? trim(listLast(i, "=")) : "";
			}

			params["macroType"] = macroType;

			return params;
		</cfscript>
	</cffunction>


	<cffunction name="renderException" access="private" output="false" returnType="string" hint="Writes a validation error to the browser, either comments or HTML">
		<cfargument name="text" type="string" required="true" hint="Original string">
		<cfargument name="macro" type="string" required="true" hint="Macro which failed">
		<cfargument name="validation" type="struct" required="true" hint="Validation struct">

		<cfscript>
			var output = arguments.text;
			var msg = "";

			for (var i in validation.errors)
			{
				msg = "<li>#i#</li>";
			}

			msg = '<ul class="errors">' & msg & '</ul>';

			if (variables.instance.exceptionMode NEQ "loud")
			{
				msg = '<!-- #msg# -->';
			}

			output = replace(output, arguments.macro, msg, "all");

			return output;
		</cfscript>
	</cffunction>


	<cffunction name="tidyMacroContent" access="private" output="false" returntype="string" hint="tidy up and midify the macro content for better export">
		<cfargument name="inputContent" type="string" required="true">

		<cfset var renderedMacro = arguments.inputContent>
		<cfset var returnedMacroContent = "">
		<cfset var xmlUtil = New lib.model.utils.XmlUtil()>
		<cfset var tempRootTagsRegx = "(<\s*tempRoot.*?>|<\s*/tempRoot\s*>)" >
		<cfset var spanTagsRegx = "(<\s*span.*?>|<\s*/span\s*>)">
		<cfset var pTagsRegx = "(<\s*p.*?>|<\s*/p\s*>)">
		<cfset var listItemContentRegx = '\<(li.*?)\s*\>(.*?)\<\/(li)\>'>
		<cfset var listTagRegx = "(<\s*li.*?>|<\s*/li\s*>)">
		<cfset var listItems = "" >
		<cfset var divTagsRegx = "(<\s*div.*?>|<\s*/div\s*>)">
		<cfset var commentTagRegx = "<!--.*?-->">
		<cfset var macroContentDOM = "">
		<cfset var xmlNodeArray = "">
		<cfset var xmlNode = "">
		<cfset var listItemContent ="">
		<cfset var string = New lib.model.utils.String()>
		<!--- <cfset var jsoup = New lib.packages.jsoup.jsoup()> --->
		<cfset var string = new lib.model.utils.String() />
		<cfset var htmlType = 0>
		<!--- <cfset var validAttributeList = "src,alt,herf"> --->
		<cfscript>

				/*clean up the macro content for better export, this only need in cms not preveiw
				* 1, remove all the class attributes set from preview
				* 2, set customized style class attribute for exporting
				* 3, remove all the p tags inside of the li tag*/

				// use jsoup to do a better tidyup for export

				//renderedMacro = jsoup.tidy(renderedMacro);

				if(NOT isXML(renderedMacro))
				{
					renderedMacro = "<tempRoot>" & renderedMacro & "</tempRoot>";
				}

	            if(isXML(renderedMacro))
	            {
	            	macroContentDOM = xmlParse(renderedMacro);
					xmlNodeArray = xmlsearch(macroContentDOM, "//*");
					for (xmlNode in xmlNodeArray)
					{
						/*if(structKeyExists(xmlNode.xmlAttributes,"class"))
						{
							StructDelete(xmlNode.xmlAttributes, "class");
						}*/
						if(structKeyExists(xmlNode.xmlAttributes,"id"))
						{
							StructDelete(xmlNode.xmlAttributes, "id");
						}
						if(structKeyExists(xmlNode.xmlAttributes,"data-stage_code"))
						{
							StructDelete(xmlNode.xmlAttributes, "data-stage_code");
						}
						/*structClear(xmlNode.xmlAttributes);*/

						if(xmlNode.xmlName EQ "span")
						{
							xmlNode.xmlText = " " & trim(xmlNode.xmlText);
						}
					}

					renderedMacro = xmlUtil.xmlToString(macroContentDOM);
					renderedMacro = REReplaceNoCase(renderedMacro, tempRootTagsRegx, "", "All");
					renderedMacro = REReplaceNoCase(renderedMacro, divTagsRegx, "", "All");
					renderedMacro = REReplaceNoCase(renderedMacro, commentTagRegx, "", "All");
					//renderedMacro = string.cleanIndentCharacters(renderedMacro);

					listItems = REMatchNoCase(listItemContentRegx, renderedMacro);
					for (listItemContent in listItems)
					{
						renderedMacro = replace(renderedMacro, listItemContent, REReplace(listItemContent, pTagsRegx, "","all"), "all" );
					}

					// this could be a nasty way fixing the invalid html brought by macro
					/*htmlType=xmlUtil.distinguishHTMLFormat(renderedMacro);
					if(htmlType EQ 3)
					{
						returnedMacroContent = "<p>" & renderedMacro & "</p>";
					}
					else
					{ */
						returnedMacroContent = renderedMacro;
					/* } */

	            }
		</cfscript>

		<cfreturn returnedMacroContent >
	</cffunction>


	<cffunction name="validateMacro" access="private" output="false" returnType="struct" hint="Validates a macro (syntax etc) prior to execution">
		<cfargument name="params" type="struct" required="true">

		<cfscript>
			var valid = {status=true, message="", errors=[]};
			var errors = [];

			if (NOT structKeyExists(arguments.params, "macroType"))
			{
				arrayAppend(errors, "No macro type found, please check your syntax");
			}
			else
			{
				switch (arguments.params.macroType)
				{
					case "block":
						if (NOT structKeyExists(arguments.params, "ref"))
						{
							arrayAppend(errors, "No reference found for your block");
						}
						break;
					case "macro":
						if (NOT structKeyExists(arguments.params, "type"))
						{
							arrayAppend(errors, "No type found for your #arguments.params.macroType#");
						}
						break;
					case "glossary":
						if (NOT structKeyExists(arguments.params, "alias"))
						{
							arrayAppend(errors, "No alias found for your #arguments.params.macroType#");
						}
						break;
					default:
						arrayAppend(errors, "Unknown macro type found: #arguments.params.macroType#");
				}
			}

			if (arrayLen(errors))
			{
				valid.status = false;
				valid.errors = errors;
				valid.message = "Invalid macro";
			}

			return valid;
		</cfscript>
	</cffunction>


	<cffunction name="wrapper" access="private" output="false" returnType="string" hint="Wraps the rendered block|glossary|macro with markup">
		<cfargument name="value" type="string" required="true">
		<cfargument name="params" type="struct" required="true">

		<cfset var output = arguments.value>
		<cfset var className = StructKeyExists(arguments.params, 'class') ? arguments.params.class : 'block'>
		<cfset var wrapperTop = '<div class="#className#">'>	<!--- default --->
		<cfset var wrapperTail = '</div>'>					<!--- default --->
		<cfset var i = "">

		<!--- Override with a custom wrapper (from the macro|block) --->
		<cfif len(trim(output)) && structKeyExists(arguments.params, "wrapper")>
			<!--- clear the defaults --->
			<cfset wrapperTop = "">
			<cfset wrapperTail = "">
			<!--- If wrapper is empty...we don't add one (i.e. we override the default with "") --->
			<cfif len(arguments.params.wrapper)>
				<!--- Build up the top and tail wrapper text based off HTML tag names (e.g. wrapper="p,em" would give you <p><em>body text here</em></p>) --->
				<cfloop list="#trim(arguments.params.wrapper)#" index="i">
					<cfset wrapperTop &= "<#i#>">
				</cfloop>
				<cfloop from="#listLen(trim(arguments.params.wrapper))#" to="1" step="-1" index="i">
					<cfset wrapperTail &= "</#listGetAt(trim(arguments.params.wrapper), i)#>">
				</cfloop>
			</cfif>
		</cfif>

		<cfreturn wrapperTop & output & wrapperTail>
	</cffunction>


</cfcomponent>