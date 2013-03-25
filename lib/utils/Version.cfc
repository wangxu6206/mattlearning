component output="false" displayname="Version" hint="Reads the latest scm version information (from build.txt) and returns an HTML comment to use in the source of a website"
{

	public Version function init(String path, Struct params = {}, String type = "svn")
	{
		// version defaults
		variables.version = {
			major = 0,
			minor = 1,
			patch = 0,
			revision = "BER",
			dateChanged = ""
		};
		// extend defaults with user specified version information
		structAppend(variables.version, arguments.params, true);
		// read the build file for the latest scm build information
		if (structKeyExists(arguments, "path") && len(trim(arguments.path)))
		{
			loadBuildFile(path=arguments.path, type=arguments.type);
		}
		return this;
	}


	/**
	* @hint Reads the version number of this latest build and adds it to instance variables
	* Requires a build file to be in the project (eg build.txt)
	*/
	private void function loadBuildFile(required String path, String type = "svn")
	{
		var path = arguments.path;
		var f = "";
		var line = "";
		try
		{
			f = fileOpen(path, "read", "utf-8");
			if (arguments.type == "svn")
			{
				parseSVNFile(f);
			}
			else if (arguments.type == "git")
			{
				parseGitFile(f);
			}
		}
		catch (any e)
		{
			writelog(text="Version.loadBuildFile() #e.message#", file=application.applicationName, type="error");
		}
	}


	/**
	* @hint Parses a git log file entry to retrieve certain key values that
	* indicate when the last modification date was
	*/
	private void function parseGitFile(any file)
	{
		var f = arguments.file;
		while(!fileIsEOF(f))
		{
			line = fileReadLine(f);
			if (listFirst(line, " ") == "commit")
			{
				variables.version.revision = trim(listLast(line, " "));
			}
			else if (listFirst(line, ":") == "Date")
			{
				variables.version.dateChanged = trim(listRest(line, ":"));
			}
		}
	}


	/**
	* @hint Parses a svn log file entry to retrieve certain key values that
	* indicate when the last modification date was
	*/
	private void function parseSVNFile(any file)
	{
		var f = arguments.file;
		while(!fileIsEOF(f))
		{
			line = fileReadLine(f);
			if (listFirst(line, ":") == "Last Changed Rev")
			{
				variables.version.revision = "r#trim(listLast(line, ":"))#";
			}
			else if (listFirst(line, ":") == "Last Changed Date")
			{
				variables.version.dateChanged = trim(listRest(line, ":"));
			}
		}
	}


	/**
	* @hint Returns an HTML comment containing the latest scm version number/hash and date
	*/
	public string function render()
	{
		var output = "";
		var revDetail = "";
		var v = getVersion();
		try
		{
			// Did we get a revision number from a build file?
			if (structKeyExists(v, 'revision') && len(v.revision))
			{
				revDetail &= v.revision;
			}
			// Did we get a date from a build file?
			if (structKeyExists(v, 'dateChanged') && len(v.dateChanged))
			{
				revDetail &= " (#v.dateChanged#)";
			}
			output = "<!-- build #v.major#.#v.minor#.#v.patch# #revDetail# -->";
		}
		catch (any e)
		{
			writeLog(text="Version.render() #cfcatch.message#", type="error", file=application.applicationName);
		}
		return output;
	}


	/**
	 * @hint Returns the version information
	 * @return {Struct}
	 */
	public struct function getVersion()
	{
		return variables.version;
	}

}