<cfcomponent output="false">


	<cffunction name="cleanHTML" access="public" output="false" returnType="string">
		<cfargument name="input" type="string" required="true">

		<cfset var regHTML = "<[^>]*>">

		<cfreturn REReplaceNoCase(arguments.input, regHTML, "", "all")>
	</cffunction>


	<cffunction name="cleanHTMLComment" access="public" output="false" returnType="string">
		<cfargument name="input" type="string" required="true">

		<cfset input = REReplaceNoCase(arguments.input, "<!--(.|\s)*?-->", "", "ALL")>

		<cfreturn input>
	</cffunction>


	<cffunction name="cleanIndentCharacters" access="public" output="false" returetype="string" >
		<cfargument name="text" type="string" required="true">
		<cfset var returnString = arguments.text>
		<cfscript>
			returnString = Replace(returnString, Chr(9), "", "All"); // horizontal tab
	        returnString = Replace(returnString, Chr(10), "", "All"); // line feed , new line
	        returnString = Replace(returnString, Chr(11), "", "All"); // vertical tab
	        returnString = Replace(returnString, Chr(12), "", "All"); // form feed, page brea
	        returnString = Replace(returnString, Chr(13), "", "All"); // carriage return
		</cfscript>
		<cfreturn returnString>
	</cffunction>


	<cffunction name="cleanLatexHtmlEntity" access="public" output="false" returetype="string" >
		<cfargument name="inputString" type="string" required="true">
		<cfset var returnString = arguments.inputString>
		<cfscript>
			/*clean html entities*/
			returnString = Replace(returnString, "&nbsp;", Chr(32), "All");
			returnString = Replace(returnString, "&quot;", Chr(34), "All");
			returnString = Replace(returnString, "&amp;", Chr(38), "All");
			returnString = Replace(returnString, "&lt;", Chr(60), "All");
			returnString = Replace(returnString, "&gt;", Chr(62), "All");
			returnString = Replace(returnString, "&##126;", Chr(126), "All");
			returnString = Replace(returnString, "&##155;", Chr(155),  "All");
			returnString = Replace(returnString, "&##156", Chr(156),  "All");
			returnString = Replace(returnString, "&##160;", "", "All");
			returnString = Replace(returnString, "&##163;", Chr(163), "All");
			returnString = Replace(returnString, "&##165;", Chr(165),  "All");
			returnString = Replace(returnString, "&##169;", Chr(169), "All");
			returnString = Replace(returnString, "&##171;", Chr(171),  "All");
			returnString = Replace(returnString, "&##187;", Chr(187),  "All");
			returnString = Replace(returnString, "&##8211;", Chr(8211), "All");
			returnString = Replace(returnString, "&##8212;", Chr(8212),  "All");
			returnString = Replace(returnString, "&##8216;", "`", "All");
			returnString = Replace(returnString, "&##8217;", "'", "All");
			returnString = Replace(returnString, "&##8220;", Chr(8220),  "All");
			returnString = Replace(returnString, "&##8221;", Chr(8221),  "All");
			returnString = Replace(returnString, "&##8226;", Chr(8226),  "All");
			returnString = Replace(returnString, "&##8230;", Chr(8230),  "All");
			returnString = Replace(returnString, "&##8364;", Chr(8364), "All");
		</cfscript>
		<cfreturn returnString />
	</cffunction>



	<cffunction name="cleanSpecialCharactersInFileName" access="public" output="false" returetype="string" >
		<cfargument name="text" type="string" required="true">
		<cfset var returnString = arguments.text>
		<cfscript>

			returnString = Replace(returnString, "~", "", "All");
			returnString = Replace(returnString, "&", "", "All");
			returnString = Replace(returnString, "%", "", "All");
			returnString = Replace(returnString, "*", "", "All");
			returnString = Replace(returnString, "`", "", "All");
			returnString = Replace(returnString, "!", "", "All");
			returnString = Replace(returnString, "@", "", "All");
			returnString = Replace(returnString, "##", "", "All");
			returnString = Replace(returnString, "$", "", "All");
			returnString = Replace(returnString, "^", "", "All");
			returnString = Replace(returnString, "[", "", "All");
	        returnString = Replace(returnString, "]", "", "All");
	        returnString = Replace(returnString, "{", "", "All");
         	returnString = Replace(returnString, "}", "", "All");
         	returnString = Replace(returnString, "'", "", "All");
         	returnString = Replace(returnString, "|", "", "All");
         	returnString = Replace(returnString, "\", "", "All");
         	returnString = Replace(returnString, "/", "", "All");
         	returnString = Replace(returnString, "?", "", "All");
         	returnString = Replace(returnString, ",", "", "All");
         	returnString = Replace(returnString, ".", "", "All");
         	returnString = Replace(returnString, ">", "", "All");
         	returnString = Replace(returnString, "<", "", "All");
         	returnString = Replace(returnString, ":", "", "All");
         	returnString = Replace(returnString, ";", "", "All");
         	returnString = Replace(returnString, "+", "", "All");
         	returnString = Replace(returnString, "=", "", "All");
         	returnString = Replace(returnString, "(", "", "All");
         	returnString = Replace(returnString, ")", "", "All");
         	returnString = Replace(returnString, chr(34), "", "All"); //Double quotes
         	returnString = Replace(returnString, chr(95), "", "All"); // underscore
         	returnString = Replace(returnString, chr(96), "", "All"); // Grave accent
         	// remove any remaining ASCII 128-159 characters
			for (i = 128; i LTE 255; i = i + 1)
				returnString = Replace(returnString, Chr(i), "", "All");

         	returnString = Replace(returnString, chr(8211), "", "All");
			returnString = Replace(returnString, chr(8212), "",  "All");
			returnString = Replace(returnString, chr(8216), "", "All");
			returnString = Replace(returnString, chr(8217), "", "All");
			returnString = Replace(returnString, chr(8220), "",  "All");
			returnString = Replace(returnString, chr(8221), "",  "All");
			returnString = Replace(returnString, chr(8226), "",  "All");
			returnString = Replace(returnString, chr(8230), "",  "All");
			returnString = Replace(returnString, chr(8364), "", "All");



		</cfscript>
		<cfreturn returnString>
	</cffunction>


	<cffunction name="getCleanUUID" access="public" output="false" returnType="string" hint="Obfuscates a CF based uuid's by replacing `-` for extra security">

		<cfreturn lCase(replaceNoCase(createUUID(), "-", "", "all"))>
	</cffunction>


	<cffunction name="getListElementAfter" access="public" output="false" returnType="string" hint="Returns the next value in a list after the element argument provided">
		<cfargument name="ls" type="string" required="true" hint="List to parse" />
		<cfargument name="argName" type="string" required="true" hint="Name of the argument to look for (previous to the one we want to return)" />
		<cfargument name="delim" type="string" required="false" default="/" hint="Delimiter of list" />

		<cfscript>

			var elem = "";
			var listPosition = listFindNoCase(arguments.ls, arguments.argName, arguments.delim)+1;

			//check that there is actually an argument after the element 'argName'
			if (listPosition LTE listLen(arguments.ls, arguments.delim))
			{
				elem = listGetAt(arguments.ls, listPosition, arguments.delim);
			}

			return elem;

		</cfscript>
	</cffunction>


	<cffunction name="cleanSpecialCharacterForFind" access="public" output="false" returetype="string" >
		<cfargument name="inputString" type="string" required="true">
		<cfset var returnString = arguments.inputString>
		<cfscript>

			returnString = Replace(returnString, "\", "\\", "All"); // A backslash (Ò\Ó) character.
			returnString = Replace(returnString, "'", "\'", "All"); //A single quote (Ò'Ó) character.
			returnString = Replace(returnString, '"', '\"', "All"); //A double quote (Ò"Ó) character.
			returnString = Replace(returnString, Chr(8), "\b", "All"); // backspace character
			returnString = Replace(returnString, Chr(9), "\t", "All"); // tab character
			returnString = Replace(returnString, Chr(10), "\n", "All"); // new line or line feed
			returnString = Replace(returnString, Chr(13), "\r", "All"); // carriage return
			returnString = Replace(returnString, chr(26), "\Z", "All"); // ASCII 26 (Control+Z)
			returnString = Replace(returnString, "%", "\%", "All"); //A Ò%Ó character
			returnString = Replace(returnString, "_", "\_", "All"); //A Ò_Ó character
			returnString = Replace(returnString, "&##156", Chr(156), "All");

		</cfscript>
		<cfreturn returnString />
	</cffunction>


	<cffunction name="getFileLastModificationDate" access="public" output="false" returetype="string" >
		<cfargument name="fileFullpath" type="string" required="true">
		<cfset var fileLastModificationDate = "">
		<cfset var filepath = "">
		<cfset var fileobj = "">
		<cfset var fileDate = "">
		<cfscript>

			 fileObj = createObject("java","java.io.File").init(arguments.fileFullpath);

			 fileLastModificationDate = createObject("java","java.util.Date").init(fileObj.lastModified());

		</cfscript>
		<cfreturn fileLastModificationDate />
	</cffunction>


	<!--- ************************  STRIP HTML  ************************
	Source: http://www.pukkared.com/2010/04/stripping-out-html-tags-from-text-with-coldfusion-9/
	--->
    <cffunction name="stripHtml" displayname="Strip HTML" description="Strips out specified HTML tags." access="public" output="false" returntype="struct">

        <!--- ARGUMENTS --->
        <cfargument name="text" displayName="Text" type="string" hint="Text to strip out html tags from." required="true" />
        <cfargument name="tags" displayName="Tags" type="string" hint="Tags to be striped from the text.  Ex. '[string:tag name],[what to remove - {string:tag | string:content}],[is it a wrapping tag? {boolean}]'. Tags are delimited with semi-colons." required="true" />

        <!--- SET SOME LOCAL VARS --->
        <cfset var textbytes = "">
        <cfset var counter = 1>
        <cfset var delete = false>
        <cfset var temp = "">
        <cfset var tagtoberemoved = "">
        <cfset var whatgetsremoved = "">
        <cfset var wrappingtag = "">

        <!--- BUILD STRUCT --->
        <cfset var data = structNew()>
        <cfset data.success = true>
        <cfset data.message = "">
        <cfset data.orginaltext = ARGUMENTS.text>
        <cfset data.strippedtext = ARGUMENTS.text>

        <!--- CHECK IF ALL CONTENT SHOULD BE REMOVED --->
        <cfif ARGUMENTS.tags eq "all">
            <!--- REMOVE HTML TAGS --->
            <cfset data.strippedtext = rereplaceNoCase(ARGUMENTS.text, "<[^>]*>", "", "all")>
        <cfelse>
            <!--- LOOP OVER THE LIST OF TAGS TO BE REMOVED --->
            <cfloop list="#ARGUMENTS.tags#" index="VARIABLES.i" delimiters=";">
                <!--- SET ATTRIBUTES OF TAG TO BE DELETED --->
                <cfset tagtoberemoved = listFirst(VARIABLES.i, ",")>
                <cfset whatgetsremoved = listGetAt(VARIABLES.i, 2, ",")>
                <cfset wrappingtag = listLast(VARIABLES.i, ",")>

                <!--- IF REMOVING JUST THE TAG --->
                <cfif whatgetsremoved eq "tag">
                    <!--- CHECK IF IT IS A WRAPPING TAG --->
                    <cfif wrappingtag eq true>
                        <!--- REMOVE WRAPPING TAG, BUT NOT THE CONTENT --->
                        <cfset data.strippedtext = rereplaceNoCase(data.strippedtext, "<#tagtoberemoved#[^>]*>", "", "all")>
                        <cfset data.strippedtext = rereplaceNoCase(data.strippedtext, "</#tagtoberemoved#>", "", "all")>
                    <cfelse>
                        <!--- REMOVE CONTAINED TAG --->
                        <cfset data.strippedtext = rereplaceNoCase(data.strippedtext, "<#tagtoberemoved# />", "", "all")>
                    </cfif>

                <!--- IF REMOVING TAG AND CONTENT --->
                <cfelseif whatgetsremoved eq "content">
                    <!--- CHECK IF IT IS A WRAPPING TAG --->
                    <cfif wrappingtag eq true>
                        <!--- REMOVE THE TAG AND CONTENT --->
                        <cfset data.strippedtext = rereplaceNoCase(data.strippedtext, "<#tagtoberemoved#[^>]*>.*</#tagtoberemoved#>", "", "all")>
                    <cfelse>
                        <!--- REMOVE CONTAINED TAG --->
                        <cfset data.strippedtext = rereplaceNoCase(data.strippedtext, "<#tagtoberemoved# />", "", "all")>
                    </cfif>
                </cfif>
            </cfloop>
        </cfif>

        <!--- RETURN STRUCT --->
        <cfreturn data>

    </cffunction>

</cfcomponent>
