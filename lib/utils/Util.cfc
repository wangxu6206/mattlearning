<cfcomponent output="false">


	<cffunction name="buildQueryFromArray" access="public" returntype="query" output="false" hint="This turns an array of structures into a array with reference query metadata (query column name list).">
		<cfargument name="data" type="array" required="yes" />
		<cfargument name="metadata" type="array" required="yes">
		<cfset var returnQuery = queryNew("")>
		<cfset var i = 1>
		<cfset var j = 1>
		<cfset var k = 1>

		<cfscript>
			for(i;i <= arrayLen(arguments.metadata); i++)
			{
				QueryAddColumn(returnQuery, arguments.metadata[i].name);
			}
			// populate this array into query
			for(j; j <= arrayLen(arguments.data); j++)
			{
				QueryAddRow(returnQuery);
				for(k=1; k <= arrayLen(arguments.metadata); k++)
				{
					QuerySetCell(returnQuery, arguments.metadata[k].name, arguments.data[j]['#arguments.metadata[k].name#']);
				}
			}
		</cfscript>
		<cfreturn returnQuery>
	</cffunction>


	<cffunction name="dateLetters" access="public" output="false" returnType="string">
		<cfargument name="dateStr" type="string" required="true">
		<cfscript>
			/**
			 * Add's the st,nd,rd,th after a day of the month.
			 *
			 * @param dateStr 	 Date to use. (Required)
			 * @param formatStr 	 Format string for month and year. (Optional)
			 * @return Returns a string.
			 * @author Ian Winter (ian@defusionx.om)
			 * @version 1, May 22, 2003
			 */
			var letterList="st,nd,rd,th";
			var domStr=DateFormat(dateStr,"d");
			var domLetters='';
			var formatStr = "";

			if(arrayLen(arguments) gte 2) formatStr = dateFormat(dateStr,arguments[2]);

			switch (domStr) {
				case "1": case "21": case "31":  domLetters=ListGetAt(letterList,'1'); break;
				case "2": case "22": domLetters=ListGetAt(letterList,'2'); break;
				case "3": case "23": domLetters=ListGetAt(letterList,'3'); break;
				default: domLetters=ListGetAt(letterList,'4');
			}

			return domStr & domLetters & " " & formatStr;
		</cfscript>
	</cffunction>



	<cffunction name="daysToBusinessWeek" access="public" output="false" returnType="string">
		<cfargument name="numOfDays" type="numeric" required="true">

		<cfset var returnBusinessDate = "">
		<cfset var weekDayLength = 5>
		<cfset var weeks = 0 >
		<cfset var days = 0 >
		<cfset var weekDate = "" >
		<cfset var dayDate = "" >

		<cfscript>
			/* caculate the business weeks */
			weeks =	int(arguments.numOfDays / weekDayLength);

			/* caculate the extra business days */
			days = arguments.numOfDays % weekDayLength;

			if(weeks > 1)
			{
				weekDate = weeks & " weeks";
			}
			else if (weeks == 1)
			{
				weekDate = weeks & " week";
			}
			else
			{
				weekDate = "";
			}

			if(days > 1)
			{
				dayDate = days & " days";
			}
			else if (days == 1)
			{
				dayDate = days & " day";
			}
			else
			{
				dayDate = "";
			}

			returnBusinessDate = weekDate & " " & dayDate;

		</cfscript>

		<cfreturn returnBusinessDate>
	</cffunction>



	<cffunction name="fncFileSize" access="public" output="false" returnType="string">
		<cfargument name="size" type="string" required="true">
		<cfscript>
			/**
			* Will take a number returned from a File.Filesize, calculate the number in terms of Bytes/Kilobytes/Megabytes and return the result.
			* v2 by Haikal Saadh
			* v3 by Michael Smith, cleaned up and added Gigabytes
			*
			* @param number      Size in bytes of the file. (Required)
			* @return Returns a string.
			* @author Kyle Morgan (admin@kylemorgan.com)
			* @version 3, February 3, 2009
			*/
			if (size lt 1024) return "#size# b";
			if (size lt 1024^2) return "#round(size / 1024)# Kb";
			if (size lt 1024^3) return "#decimalFormat(size/1024^2)# Mb";
			return "#decimalFormat(size/1024^3)# Gb";
		</cfscript>
	</cffunction>


	<cffunction name="periodElapsed" access="public" output="false" returnType="string" hint="Calculates in weeks or days the period elapsed from the passed in date">
		<cfargument name="d" type="any" required="true" hint="Datetime to parse">
		<cfargument name="renderType" type="string" required="false" default="granular" hint="general|granular">
		<cfargument name="mask" type="string" required="false" default="ddd dd mmm">

		<cfset var periodElapsed = "">
		<cfset var hoursAgo = "">
		<cfset var minutesAgo = "">
		<cfset var suffix = "">
		<cfset var daysAgo = "">

		<cfif isValid("date", arguments.d)>
			<cfset daysAgo = dateDiff("d", arguments.d, now())>
			<cfif arguments.renderType EQ "granular">
				<cfif daysAgo EQ 0>
					<cfset hoursAgo = dateDiff("h", arguments.d, now())>
					<cfif hoursAgo EQ 0>
						<cfset minutesAgo = dateDiff("n", arguments.d, now())>
						<cfif minutesAgo LTE 1>
							<cfset periodElapsed = "Just now">
						<cfelse>
							<cfset periodElapsed = minutesAgo & " minutes ago">
						</cfif>
					<cfelse>
						<cfif  hoursAgo GT 1>
							<cfset suffix = "s">
						</cfif>
						<cfset periodElapsed = hoursAgo & " hour#suffix# ago">
					</cfif>
				<cfelse>
					<cfset periodElapsed = lsDateFormat(arguments.d, arguments.mask)>
				</cfif>
			<cfelseif arguments.renderType EQ "general">
				<cfif daysAgo EQ 1>
					<cfset periodElapsed = "1 day ago">
				<cfelseif daysAgo GT 1 AND daysAgo LT 7>
					<cfset periodElapsed = daysAgo & " days ago">
				<cfelseif daysAgo EQ 7>
					<cfset periodElapsed = daysAgo & " week ago">
				<cfelse>
					<cfset periodElapsed = round(daysAgo/7) & " weeks ago">
				</cfif>
			</cfif>
		</cfif>

		<cfreturn periodElapsed>
	</cffunction>


	<cffunction name="printDateTime" access="public" output="false" returnType="string">
		<cfargument name="d" type="any" required="true">
		<cfargument name="includeTime" type="boolean" required="false" default="true">
		<cfargument name="mask_date" type="string" required="false" default="dd mmm yyyy">
		<cfargument name="mask_time" type="string" required="false" default="HH:mm:ss">

		<cfset var d = "">

		<cfif isValid("date", arguments.d)>
			<cfset d = lsDateFormat(arguments.d, arguments.mask_date)>
			<cfif arguments.includeTime>
				<cfset d = d & " " & lsTimeFormat(arguments.d, arguments.mask_time)>
			</cfif>
		</cfif>

		<cfreturn d>
	</cffunction>


	<cffunction name="queryAppend" access="public" returntype="void" output="false" hint="Takes two queries and appends the second one to the first one. This actually updates the first query and does not return anything.">
		<cfargument name="QueryOne" type="query" required="true" />
		<cfargument name="QueryTwo" type="query" required="true" />

		<cfset var LOCAL = StructNew() />

		<!--- Get the column list (as an array for faster access. --->
		<cfset LOCAL.Columns = ListToArray( ARGUMENTS.QueryTwo.ColumnList ) />
		<!--- Loop over the second query. --->
		<cfloop query="ARGUMENTS.QueryTwo">
			<!--- Add a row to the first query. --->
			<cfset QueryAddRow( ARGUMENTS.QueryOne ) />
			<!--- Loop over the columns. --->
			<cfloop index="LOCAL.Column" from="1" to="#ArrayLen( LOCAL.Columns )#" step="1">
				<!--- Get the column name for easy access. --->
				<cfset LOCAL.ColumnName = LOCAL.Columns[ LOCAL.Column ] />

				<!--- Set the column value in the newly created row. --->
				<cfset ARGUMENTS.QueryOne[ LOCAL.ColumnName ][ ARGUMENTS.QueryOne.RecordCount ] = ARGUMENTS.QueryTwo[ LOCAL.ColumnName ][ ARGUMENTS.QueryTwo.CurrentRow ] />
			</cfloop>
		</cfloop>
	</cffunction>


	<cffunction name="queryRowToStruct" access="public" output="false" returnType="struct">
		<cfargument name="query" type="query" required="true" hint="Query to convert to structure" />

		<cfscript>

			/**
			 * Makes a row of a query into a structure.
			 *
			 * @param query 	 The query to work with.
			 * @param row 	 Row number to check. Defaults to row 1.
			 * @return Returns a structure.
			 * @author Nathan Dintenfass (nathan@changemedia.com)
			 * @version 1, December 11, 2001
			 */

			//by default, do this to the first row of the query;
			var row = 1;
			//a var for looping;
			var ii = 1;
			//the cols to loop over;
			var cols = listToArray(query.columnList);
			//the struct to return;
			var stReturn = structnew();
			//if there is a second argument, use that for the row number;
			if(arrayLen(arguments) GT 1)
				row = arguments[2];
			//loop over the cols and build the struct from the query row;
			for(ii = 1; ii lte arraylen(cols); ii = ii + 1){
				stReturn[cols[ii]] = query[cols[ii]][row];
			}
			//return the struct
			return stReturn;

		</cfscript>
	</cffunction>


	<cffunction name="relativeDate" access="public" returntype="string">

		<cfargument name="datetime" type="any" required="true">

		<cfset var d = lsdateformat(arguments.datetime,'dd mmm')>

		<cfif NOT isDate(d)>
			<cfreturn ''>
		</cfif>

		<cfif DateDiff("d",d,now()) EQ 0 >
			<cfreturn "Today">
		<cfelseif DateDiff("d",d,now()) EQ 1>
			<cfreturn "Yesterday">
		<cfelseif DateDiff("d",d,now()) LT 5>
			<cfreturn LSDateFormat(d, 'dddd')>
		<cfelse>
			<cfreturn LSDateFormat(d, 'dd mmm')>
		</cfif>

	</cffunction>


	<cffunction name="QueryToArray" access="public" returntype="array" output="false" hint="This turns a query into an array of structures.">
		<cfargument name="Data" type="query" required="yes" />
		<cfargument name="Columnmaps" type="struct" required="false">
		<cfscript>

			var LOCAL = StructNew();
			LOCAL.Columns = ListToArray( ARGUMENTS.Data.ColumnList );
			LOCAL.QueryArray = ArrayNew( 1 );

			for (LOCAL.RowIndex = 1 ; LOCAL.RowIndex LTE ARGUMENTS.Data.RecordCount ; LOCAL.RowIndex = (LOCAL.RowIndex + 1)){
				LOCAL.Row = StructNew();
				for (LOCAL.ColumnIndex = 1 ; LOCAL.ColumnIndex LTE ArrayLen( LOCAL.Columns ) ; LOCAL.ColumnIndex = (LOCAL.ColumnIndex + 1)){
					LOCAL.ColumnName = lCase(LOCAL.Columns[ LOCAL.ColumnIndex ]);

					LOCAL.StructKeyName = LOCAL.ColumnName;

					if (StructKeyExists(arguments, 'Columnmaps') AND StructKeyExists( arguments.Columnmaps, LOCAL.ColumnName))
						LOCAL.StructKeyName = LCASE(  arguments.Columnmaps[LOCAL.ColumnName] );

					LOCAL.Row[ LOCAL.StructKeyName ] = ARGUMENTS.Data[ LOCAL.ColumnName ][ LOCAL.RowIndex ];
				}
				ArrayAppend( LOCAL.QueryArray, LOCAL.Row );
			}
			// Return the array equivalent.
			return( LOCAL.QueryArray );

		</cfscript>
	</cffunction>


	<cffunction name="directorySearch" access="public" output="false" returnType="any" hint="This turns a customized cfdirectory function to access the directory.">
		<cfargument name="directory_path" type="string" required="true">
		<cfargument name="conditions" type="struct" required="false">

		<cfset var i = 1>
		<cfset var returnDataArray = []>
        <cfset var templateData = "">
		<cfset var templatePath = "">

		<cfif DirectoryExists(arguments.directory_path)>

		    <cfdirectory directory="#arguments.directory_path#"
		    			 name="dirQuery"
		    			 action="LIST"
		    			 type="#arguments.conditions.type#"
		    			 filter="#arguments.conditions.filter#"
		    			 recurse = "#arguments.conditions.recurse#" />

			<cfloop query="dirQuery">
				    <cfset templateData = {}>
				    <cfset templateData.name = listFirst(dirQuery.name, ".")>
				    <cfset templateData.templatePath = arguments.directory_path & dirQuery.name>
				    <cfset templateData.dt_modified = application.cfcs.util.periodElapsed(dirQuery.dateLastModified)>

				 	<cfset arrayAppend(returnDataArray, templateData)>

			</cfloop>

		</cfif>

		<cfreturn returnDataArray />
	</cffunction>


	<cffunction name="ArrayPick" access="public" output="false" returntype="array" hint="pick selected array of structs">

		<cfargument name="array" required="true" type="array" />
		<cfargument name="filters_params" required="true" type="struct" />
		<cfargument name="pick_fields" required="false" type="string" default="" />

		<cfset var result = [] />
		<cfset var truthTest = true />
		<cfset var k = "" />
		<cfset var stItem = {} />

		<cfloop array="#arguments.array#" index="item">
			<cfif isStruct(item)>
				<cfset truthTest = true />
				<cfloop collection="#arguments.filters_params#" item="k">
					<cfset truthTest = truthTest AND structKeyExists(item, k) AND item[k] eq arguments.filters_params[k] />
				</cfloop>
				<cfif truthTest>
					<cfif not Len(arguments.pick_fields)>
						<cfset arrayAppend(result, duplicate(item) ) />
					<cfelse>
						<cfset stItem = {} />
						<cfloop list="#arguments.pick_fields#" index="f">
							<cfif structKeyExists(item, f)>
								<cfset stItem[f] = duplicate(item[f]) />
							</cfif>
						</cfloop>
						<cfset arrayAppend(result, stItem) />
					</cfif>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn result />

	</cffunction>


</cfcomponent>