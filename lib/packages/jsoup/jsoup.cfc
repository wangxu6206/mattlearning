<cfcomponent name="jsoup" displayname="jSoup" hint="clean out invalid html">

	<cffunction name="tidy" displayname="Tidy parser" returnType="string" hint="Takes a string as an argument and returns parsed and valid xHTML" output="false">
		<cfargument name="inputString" required="true" type="string" default="" />

		<cfset var libLoadPath = getdirectoryfrompath(getcurrenttemplatepath()) & "jsoup-1.6.3.jar">
		<cfset var jsoup = createObject("java", "org.jsoup.Jsoup", libLoadPath)>
		<cfset var whiteList = createObject("java", "org.jsoup.safety.Whitelist", libLoadPath)>
		<cfset var stReturn = "">
		<cfset var document = createObject("java", "org.jsoup.nodes.Document", libLoadPath)>
		<cfset var htmldocument = "">
		<cfset var outputsetting = "">
		<cfset var escapeMode = "">
		<cftry>

			<cfscript>

				htmldocument = jsoup.parse(arguments.inputString);
				escapeMode = htmldocument.outputSettings().escapeMode();
				htmldocument.outputSettings().charset("UTF-8");
				htmldocument.outputSettings().escapeMode(escapeMode.extended);
				htmldocument.outputSettings().prettyPrint(false);

				/*outputsetting = htmldocument.outputSettings();


				escapeMode = outputsetting.escapeMode();

				outputsetting.escapeMode(escapeMode.xhtml);
				outputsetting.prettyPrint(false);*/

				stReturn = htmldocument.body().html();

			</cfscript>

			<cfreturn stReturn />

			<cfcatch type="a">
				<!--- display and log error message  --->
				<cftrace type="warning" text="jsoup: #warning#" />
				<!--- displays input data so the application still works --->
				<cfreturn stReturn />
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>