component output="false"
{

	/**
	 * @hint Create a bcrypt password hash
	 * 			- see http://www.aliaspooryorik.com/blog/index.cfm/e/posts.details/post/using-bcrypt-in-coldfusion-10-370
	 * @param string password The cleartext password to hash.
	 * @return string The hashed password, ~60 chars, ready to save to db or authenticate against.
	 */
	public string function hashPassword(required string password)
	{
		var bCrypt = createObject( "java", "BCrypt", "/lib/packages/bcrypt" );
		var workFactor = 10; // Work factor determines how long it takes to hash / compare.
		return bCrypt.hashpw(arguments.password, bCrypt.gensalt(workFactor));
	}


	/**
	 * @hint Compare a cleartext password against its hashed version.
	 * 		- see http://www.aliaspooryorik.com/blog/index.cfm/e/posts.details/post/using-bcrypt-in-coldfusion-10-370
	 * @param {string} password The cleartext password.
	 * @param {string} hashed The previously hashed password to compare against.
	 * @return boolean match?
	 */
	public boolean function checkPassword(required string password, required string hashed)
	{
		var bCrypt = createObject( "java", "BCrypt", "/lib/packages/bcrypt" );
		try
		{
			return bCrypt.checkpw(arguments.password, arguments.hashed);
		}

		// TODO - Remove these two catches, they're only there to give testing users a friendlier error message if they have an old format
		// or truncated password, so not relevant in production.

		// Password wasnt generated with bcrypt -  can't check.
		catch (java.lang.IllegalArgumentException e)
		{
			throw(type="lib.model.utils.Auth", message="There was an error checking your credentials. Please reset using the 'forgot password' option.");
		}
		// Password field was set to null - string error.
		catch (java.lang.StringIndexOutOfBoundsException e)
		{
			throw(type="lib.model.utils.Auth", message="There was an error checking your credentials. Please reset using the 'forgot password' option.");
		}
	}

}
