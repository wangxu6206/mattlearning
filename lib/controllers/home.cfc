component displayname="home" extends="_base"
{

	/**
	* @hint Route used to bootstrap the application on the initial page load
	*/
	public void function default(required struct rc) output=false
	{
		var bootstrap = {};
		var csrfp = _CSRFProvider;

		arguments.rc.meta = {
			subTitle = "Welcome to the Home page!"
		}

		bootstrap = {
			"tokens"         = {
				"default" =  csrfp.generateToken(intention = getConfig("csrf").defaultIntention),
				"login" = csrfp.generateToken(intention = "login"),
				"register" = csrfp.generateToken(intention = "register"),
				"registeractivate" = csrfp.generateToken(intention = "registeractivate"),
				"dopasswordreset" = csrfp.generateToken(intention = "dopasswordreset")
			},
			"environment" = getConfig("environment").mode,
			"trackingcode" = getConfig("analytic").trackingcode,
			"validation" = {}
		}

		if (isLoggedIn())
		{
			bootstrap["user"] = getUser().getExposedProperties();
		}

		arguments.rc.json = serializeJSON(bootstrap);
	}

}