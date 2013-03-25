/**
* @author  Michael Sharman
* @description A generic class to abstract application logging (to server log files) to a single point.
* That way the application can log to different files and be easily changed or even turned off from
* a single file. Recommended to be used as a singleton.
* Liberal diagnostic logging can be turned on and off by the use of groups (logGroup). The format is
* 	logGroup = {
* 		myLogArea = true,
* 		myOtherLogArea = false,
* 		anotherLogArea = true
* 	}
* 	Logging.write(text="a sample message", group="myOtherLogArea");
* In the example above, that line wouldn't log anything until `myOtherLogArea` was set to true in the
* logGroup struct. Useful for turning on/off diagnostics that might otherwise clutter up the log file(s)
*/
component output="false"
{

	/**
	* @param {boolean} logLongRequest Whether or not this class is being used to log any long running requests
	* @param {numeric} longRequestLimit The number if milliseconds that is the long running request threshold
	* @param {string} logFile Default file to log all messages to
	* @param {struct} logGroup Key/value pairs (boolean) that decide whether to log a message or not
	* @param {string} logType Default log type
	*/
	public function init(boolean logLongRequest = true, numeric longRequestLimit = 0, string logFile, struct logGroup = {}, string logType = "error")
	{
		// Which log file to write to?
		//	- First look in arguments
		//	- First try application.applicationName
		//	- then default to application.log if all else fails
		var file = "application";
		if (structKeyExists(arguments, "logFile") && len(arguments.logFile))
		{
			file = arguments.logFile;
		}
		else if (isDefined("application.applicationName") && len(application.applicationName))
		{
			file = application.applicationName;
		}

		variables.config = {
			logFile				= file,
			logGroup			= arguments.logGroup,
			logLongRequest	= arguments.logLongRequest,
			longRequestLimit	= arguments.longRequestLimit,
			logType				= arguments.logType
		}

		if (variables.config.logLongRequest && variables.config.longRequestLimit <= 0)
		{
			throw (message="Request logging is enabled but no longRequestLimit was passed", type="Error");
		}

		return this;
	}


	/**
	* @hint Generic check to see how long the request took, if longer than a certain amount...log as an error so developers can investigate
	* @param {numeric} startTime A numeric counter generated using getTickCount() that references the start of the request
	* @param {string} action Represents a system `event` or `route` indicating where the request came from
	* @param {string} file The name of the log file to write any errors to
	* @param {string} type What kind of message to log (error|information|debug)
	*/
	public void function requestTime(required numeric startTime, string action = "", string file, string type)
	{
		var qs = (len(trim(CGI.query_string))) ? "?#CGI.query_string#" : "";
		var logFile = (structKeyExists(arguments, "file") && len(trim(arguments.file))) ? arguments.file : variables.config.logFile;
		var logType = (structKeyExists(arguments, "type") && len(trim(arguments.type))) ? arguments.type : variables.config.logType;

		if (variables.config.logLongRequest && arguments.startTime > 0)
		{
			var requestEndTime = getTickCount()-arguments.startTime;
			if (requestEndTime > variables.config.longRequestLimit)
			{
				write(text="Request took #requestEndTime#ms to run (URL: #CGI.path_info##qs# | Action: #arguments.action#)", file=logFile, type=logType);
			}
		}
		else if (arguments.startTime == 0)
		{
			write(text="logging.requestTime() Missing or invalid startTime variable (URL: #CGI.path_info##qs# | Action: #arguments.action# | StartTime #arguments.startTime#)", file=logFile, type=logType);
		}
	}


	/**
	* @hint Writes a message to a server logfile, prepends `group` if passed as an argument
	* @param {string} text The text message to be written to a log file
	* @param {string} file The name of the log file to write any errors to
	* @param {string} type What kind of message to log (error|information|debug)
	* @param {string} group Log group, used to turn on/off diagnostic logging
	*/
	public void function write(required string text, string file, string type, string group)
	{
		var doLog = true;
		var logFile = (structKeyExists(arguments, "file") && len(trim(arguments.file))) ? arguments.file : variables.config.logFile;
		var logType = (structKeyExists(arguments, "type") && len(trim(arguments.type))) ? arguments.type : variables.config.logType;

		if (structKeyExists(arguments, "group") && len(arguments.group))
		{
			doLog = checkGroup(arguments.group);
			// Prepend the group to the log text
			arguments.text = "[#uCase(arguments.group)#] #trim(arguments.text)#";
		}

		if (doLog)
		{
			writeLog(text=trim(arguments.text), file=logfile, type=logType);
		}
	}


	/**
	* @hint Returns whether logging is turned on or off for this `group`
	* @param {string} groupKey The group to look for in the class logGroup
	*/
	private boolean function checkGroup(required string groupKey)
	{
		return structKeyExists(variables.config.logGroup, arguments.groupKey) && variables.config.logGroup[arguments.groupKey];
	}

}