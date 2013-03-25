<!--- <cfdump var="#rc#"> --->
<cfsavecontent variable="testhtml">
<cfoutput>
	<ul>
		<li>these is the test for lis
		   <ul>
		   	  <li>these the second test for lis</li>
		   	  <li>asdfasfasfasdfasf</li>
		   </ul>
		</li>
		<li>shang qiu hen nan ren</li>
	</ul>
</cfoutput>
</cfsavecontent>

<cfsavecontent variable="testhtml1">
<cfoutput>
	<ul>
		<li>these is the test for lis
		   <ul>
		   	  <li>these the second test for lis</li>
		   	  <li>asdfasfasfasdfasf</li>
		   </ul>
		</li>
		<li>shang qiu hen nan ren</li>
	</ul>
</cfoutput>
</cfsavecontent>

<!--- <cfoutput>#testhtml#</cfoutput> --->
<cfoutput>
	<form action="#rc.meta.links.import#" method="post" enctype="multipart/form-data">
		<fieldset>
			<legend>Select doc1 to import:</legend>
			<input type="file" name="wordFileImport1" id="uploadFile1" class="xxlarge" />
			<input type="file" name="wordFileImport2" id="uploadFile2" class="xxlarge" />
		</fieldset>

		<div style="clear: both; text-align: right;">
			<input class="btn btn-primary" type="submit" name="import" id="import" value="Import" />
		</div>
	</form>

	<form action="#rc.meta.links.export#" method="post">
		<fieldset>
			<legend>test html</legend>
			<textarea name="htmlcontent" style="height: 250px; width: 99%;">#testhtml1#</textarea>
		</fieldset>
		<div style="clear: both; text-align: right;">
			<input class="btn btn-primary" type="submit" name="export" id="export" value="Export" />
		</div>
	</form>
</cfoutput>



