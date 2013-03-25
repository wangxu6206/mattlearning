component extends="lib.packages.org.corfield.framework" output="false"
{
	/* NOTE for painful when set up project running on railo
	 * 1, railo-context/admin/web.cfm---perfermance/Caching -- Inspect Tempaltes should be set to Always (Bad), otherwise it will always cached!!
	 *
	 */

	this.name = "mattlearning";
	this.applicationTimeout = createTimeSpan(0,4,0,0);

	currRequest = getPageContext().getRequest();
	// isSecure=true under ssl mode, so here I force it to use session
	if (currRequest.isSecure())
	{
		this.sessionManagement = true;
		this.sessionTimeout = createTimeSpan(0,3,0,0);
	}
	else
	{
		this.sessionManagement = true;
	}

	this.setClientCookies = false; // TO-BE-Explained:
	this.clientManagement = false; // TO-BE-Explained:
	this.scriptProtect = "cgi,cookies,url"; // TO-BE-Explained:
	this.mappings[ "/lib" ] = REReplace(GetDirectoryFromPath( GetCurrentTemplatePath() ),"[^\\/]+[\\/]$","","one") & "lib";

	variables.framework = {
		action = 'action',
		defaultSection = 'home',
		defaultItem = 'default',
		home = 'home.default',
		error = 'error.default',
		reload = 'reinit',
		password = "YfoDNQhODr30bWAtAMKRBA~~",			// Empty password == disable reload application
		reloadApplicationOnEveryRequest = true,		// Safe defaults, override below
		disableReloadApplication = false,				// Safe defaults, override below
		generateSES = true,
		SESOmitIndex = true,
		base = '/lib',
		baseURL = 'useCgiScriptName',
		suppressImplicitService = true,
		unhandledExtensions = 'cfc',
		unhandledPaths = '/flex2gateway,/tests',
		preserveKeyURLKey = 'mattlearning',
		maxNumContextsPreserved = 2, 				// Set higher if you need multiple browser windows open (i.e. one per window)
		cacheFileExists = false,
		applicationKey = 'org.corfield.framework'
	};


	/* use setupApplication() in FW1 instead of this native life span event */
	/* public any function onApplicationStart(){} */
	public boolean function setupApplication()
	{
		writeLog (file=this.name, type="Information", text="#this.name# -- setupApplication() triggerred. Application is starting...");
		appStart = getTickCount();
		application.appStartTime = now();
		application.applicationname = this.name;

		application.config = new lib.utils.INIParser(expandPath("../properties/properties.ini")).parse();
		application.config.environment["servername"] = createObject("java", "java.net.InetAddress").localhost.getHostName();

		application.cfcs = {
			CSRFProvider = new lib.utils.CSRFProvider(),
			Logging = new lib.utils.Logging(logLongRequest = getConfig("logging").logLongRequest, longRequestLimit=getConfig("logging").longRequestLimit, logGroup=getConfig("logGroup")),
			Util = new lib.utils.Util(),
			Proxy = new lib.utils.Proxy(getConfig("proxy"))
		};

		writeLog (file=this.name, type="Information", text="#this.name# -- Application has started. Time taken: #getTickCount() - appStart#ms");

		return true;
	}


	/**
	* @hint Overwriting FW/1's failure() method to ensure we set a 500 status on any uncaught
	* errors, and that we don't display a stack trace dump
	*/
	private void function failure(any exception, string event, boolean indirect = false)
	{
		getPageContext().getResponse().setStatus(500);
		include "errors/500.html";
		abort;
	}


	/* use setupSession() in FW1 instead of this native life span event */
	/* public any function onSessionStart(){} */
	public void function setupSession()
	{
		var response = getPageContext().getResponse();
		var path = "/";
		var domain = getConfig("url").https;
		var secure = "Secure";
		var HTTPOnly = "HTTPOnly";
		var header = "jsessionid=#session.sessionid#;domain=#domain#;path=#path#;#secure#;#HTTPOnly#";
		response.addHeader("Set-Cookie", header);
	}

	/* use setupRequest() in FW1 instead of this native life span event */
	public any function onRequestStart(string targetPath){
     	variables.framework.disableReloadApplication = getConfig("fw1").disableReloadApplication;
		variables.framework.password = getConfig("fw1").password;
		variables.framework.reloadApplicationOnEveryRequest = getConfig("fw1").reloadApplicationOnEveryRequest;
		super.onRequestStart(targetPath);
	}


	public void function setupRequest()
	{
		var appStart = getTickCount();
		writeLog (file=this.name, type="Information", text="#this.name# -- setupRequest() started. Time taken: #getTickCount() - appStart#ms");
		setLocale("English (Australian)");
	}

	/* public any function onRequest(){} */

	/* public any function onRequestEnd(){} */

	/* public any function onSessionEnd(){} */

	/* public any function onApplicationEnd(){} */

	/* public function onMissingMethod(){} */


	public function onMissingView()
	{
		writelog(text="onMissingView() is fired", file=this.name, type="error");
	}


	private struct function getConfig(string key)
	{
		if (structKeyExists(arguments, "key") && len(arguments.key))
		{
			return application.config[key];
		}
		else
		{
			return application.config;
		}
	}
}
