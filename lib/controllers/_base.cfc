component
{

	public any function init(fw)
	{
		variables.fw       = arguments.fw;
		variables._Logging = application.cfcs.Logging;
		variables._CSRFProvider	= application.cfcs.CSRFProvider;
		return this;
	}


	/**
	 * @hint Adds any application messages to a query in the request scope for display in views
	 */
	private void function addMessage(required struct messages)
	{
		var i = 0;
		var item = "";

		param name="arguments.messages.list" default="#[]#";

		do
		{
			i++;
			item = (arrayLen(arguments.messages.list)) ? arguments.messages.list[i] : "";
			request.addMessage(arguments.messages.type, arguments.messages.title, item);
		}
		while (i < arrayLen(arguments.messages.list));
	}



	public void function after(rc)
	{
		param name="arguments.rc.requestStartTime" default=0;
		_Logging.requestTime(startTime=val(arguments.rc.requestStartTime), action=arguments.rc.action, type="warning");
	}


	public void function before(rc)
	{
		var method = CGI.request_method;
		var intention = "";
		var customIntentions = ["login", "register", "registeractivate", "dopasswordreset"];

		arguments.rc.requestStartTime = getTickCount();

		/* if (listFindNoCase("POST,PUT,DELETE", method))
		{
			intention = (arrayFindNoCase(customIntentions, request.item)) ? lCase(request.item) : "";
			try
			{
				validateRequestOrigin(intention);
			}
			catch (any e)
			{
				arguments.rc.json = serializeJSON({
					"status": false,
					"title": "Request failed",
					"message": [e.message]
				});
				variables.fw.abortController();
			}
		} */
	}


	/**
	* @hint Returns either the full application.config, or a specific key from within application.config
	* @param {String} key A specific key referencing a nested struct of config parameters (an exception is thrown if the key doesn't exist)
	*/
	private struct function getConfig(String key)
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


	/**
	* @hint Returns a User object (for a logged in user). If called where a user is not logged in, an exception will be thrown
	*/
	private struct function getUser()
	{
		return session.user;
	}


	/**
	* @hint Returns true|false if a request was made asynchronously
	*/
	private any function isAjax()
	{
		var headers = getHttpRequestData().headers;
		return structKeyExists(headers, "X-Requested-With") && (headers["X-Requested-With"] == "XMLHttpRequest");
	}


	/**
	* @hint Returns true|false if the current user is logged in or not
	*/
	private boolean function isLoggedIn()
	{
		return isDefined("session") && structKeyExists(session, "user");
	}


	/**
	* @hint Sets the HTTP status code in the response header
	* @param {Numeric} Status code to set
	*/
	private void function setStatusCode(required Numeric code)
	{
		request.statuscode = arguments.code;
		getPageContext().getResponse().setstatus(arguments.code);
	}


	/**
	* @hint Validates that a request (typically POST, PUT or DELETE) came from the same origin. Logged in users have a
	* single token (and intention) for the application, see getConfig("csrf"). All `public` forms need a specific intention/token.
	* @param {String} intention Passed if you want to test a specific form (login and register are the only specific forms)
	*/
	private void function validateRequestOrigin(String intention)
	{
		var _intention = "";
		var _token = "";
		var isValidRequest = "";

		// Get the intention used to verify the request being made
		if (structKeyExists(arguments, "intention") && len(arguments.intention))
		{
			_intention = arguments.intention;
		}
		else
		{
			_intention = getConfig("csrf").defaultIntention;
		}

		// Get the CSRF token to verify from the request being made
		if (len(CGI["X-CSRF-Token"]))
		{
			_token = CGI["X-CSRF-Token"];
		}
		else
		{
			setStatusCode(403);
			_Logging.write(text="#request.action# - Invalid request, no token found");
			throw(type="error", message="Invalid request, no token found");
		}

		isValidRequest = _CSRFProvider.verifyToken(intention = _intention, token = _token);

		if (!isValidRequest)
		{
			setStatusCode(403);
			_Logging.write(text="#request.action# - Invalid request, check origin");
			throw(type="error", message="Invalid submission, check origin");
		}
	}

}