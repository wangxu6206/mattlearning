<cfcomponent name="string" displayname="string" hint="clean out invalid html">

	<cffunction name="escapeXMLEntity" displayname="Tidy parser" returnType="string" hint="Takes a string as an argument and returns parsed and valid xHTML" output="false">
		<cfargument name="inputString" required="true" type="string" default="" />
		
		<cfset var libLoadPath = getdirectoryfrompath(getcurrenttemplatepath()) & "commons-lang3-3.1.jar">
		<cfset var commonlang = createObject("java", "org.apache.commons.lang.StringEscapeUtils", libLoadPath)>
		

		<cfset var stReturn = "">
		<!--- <cfset var whitelist = "&##lt;,&##gt;,&##amp;,&##apos;,&quot;"> --->
		<cftry>
			<cfset stReturn = commonlang.escapeXml(arguments.inputString) />
			

			<cfset stReturn = Replace(stReturn, "&lt;", "<", "All")>
			<cfset stReturn = Replace(stReturn, "&gt;", ">", "All")>
			<cfset stReturn = Replace(stReturn, "&amp;", "&", "All")>
			<cfset stReturn = Replace(stReturn, "&apos;", "'", "All")>
			
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