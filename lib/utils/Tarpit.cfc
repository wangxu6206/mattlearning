component displayname="Tarpit" output="false"
{

	public function init(required string dsn, required string dsn_ro, numeric failLimit = 5, string logFile = application.applicationName)
	{
		variables.instance = {
			failLimit = arguments.failLimit, 	// How many failed attempts before we lock a user out
			dsn = arguments.dsn,			// Master database (read/write)
			dsn_ro = arguments.dsn_ro,		// Slave database (read only)
			logFile = arguments.logFile		// Where to log messages
		}
		return this;
	}


	/**
	* @hint Checks whether a user is in the tarpit. If they are, see whether they need to be "tarred" or not
	*/
	public struct function check(required string user_id, boolean ignoreTarpit = false)
	{
		var tarpit = {};
		var minutes = 0;
		var seconds = 0;
		var pitLeft = 0;
		var msg = "";
		var checkUser = "";

		try
		{
			tarpit = {
				hasTarpit = false,				// Does the user have a tarpit entry?
				tarred = false,					// Is the user currently tarpitted/locked out?
				fails = 0,						// How many failed attempts?
				lockoutFails = 0,				// How many failed attempts during a lockout? This is cumulative, ie it is never reset. Serves as an audit for a user
				lockout = 0,						// Unix timestamp that the user is locked out until (default to empty)
				pitLeft = 0,						// How long does the user have in the pit?
				user_id = arguments.user_id,	// User to check against the database
				now = left(getTickCount(), 10),	// Unix timestamp of the latest request (we trim the 3 digit milliseconds)
				tarred = false,					// Whether the user is tarpitted
				messages = []					// Return message(s) to calling page
			}

			checkUser = fetch(tarpit.user_id);

			// If the user is in the tarpit, see if we need to lock them out
			if (checkUser.recordCount)
			{
				// Option to ignore the tarpit. Used in cases like logging in from a reset password operation
				// We do this here as we need the original `lockoutFails` value
				if (arguments.ignoreTarpit)
				{
					tarpit.ignoreTarpit = true;
					tarpit.lockoutFails = checkUser.lockout_fails;
					return tarpit;
				}

				tarpit.hasTarpit = true;
				tarpit.tarred = (tarpit.now < checkUser.lockout);
				tarpit.fails = checkUser.fails;
				tarpit.lockoutFails = checkUser.lockout_fails;
				tarpit.lockout = checkUser.lockout;
				pitLeft = (tarpit.lockout - tarpit.now);

				// If the user is tarpitted set failure message
				if (tarpit.tarred)
				{
					msg = "You can log in again in";
					minutes = int(pitLeft/60);
					seconds = pitLeft-60*minutes;
					if (minutes > 0)
					{
						msg &= " #minutes# minute";
						if (minutes > 1)
						{
							msg &= "s";
						}
						if (seconds > 0)
						{
							msg &= " and #seconds# second";
							if (seconds > 1)
							{
								msg &= "s";
							}
						}
					}
					else
					{
						msg &= " 1 minute";
					}

					arrayAppend(tarpit.messages, "You have been locked out temporarily because of too many failed login attempts.");
					arrayAppend(tarpit.messages, msg);
				}
			}

			return tarpit;
		}
		catch (any e)
		{
			writeLog(type="error", message="Tarpit.check() #e.message#", file=variables.instance.logFile);
			// Let the user continue if for some reason the tarpit barfs, but log so a developer can look into the problem
			return { tarred = false };
		}
	}


	/**
	* @hint Clears tarpit entries (except lockout_fails)
	*/
	private void function clear(required struct tarpit)
	{
		var pit = arguments.tarpit; 	// Save to a local variable for easy access

		pit.lockout = 0;
		pit.fails = 0;

		save(pit);
	}


	/**
	* @hint Handles a post-login attempt, whether successful or failed. Sets the tarpit values (if they need to be saved) accordingly
	* @param tarpit {struct} The initial values as defined in the check() method. Created pre-logon
	* @param status {boolean} Whether a login attempt was successful or not
	*/
	public void function finalise(required struct tarpit, required boolean status)
	{
		var lockTime = 0;			// Amount (in seconds) to lock someone out for
		var pit = arguments.tarpit; 	// Save to a local variable for easy access

		try
		{
			// Option to ignore the tarpit. Used in cases like logging in from a reset password operation
			if (structKeyExists(pit, "ignoreTarpit") && pit.ignoreTarpit) { clear(pit); return; }

			// If a successful logon attempt
			if (arguments.status)
			{
				// If we haven't previously stored a user...don't store them now (no need!)
				if (!pit.hasTarpit)
				{
					return;
				}
				// If they were previously tarpitted (they have a record), but this was a successful attempt (and all pit values were already 0), return...no need to UPDATE
				else if (pit.fails == 0 && pit.lockout == 0)
				{
					return;
				}
				// Had a previous `failed` logon attempt, clear tarpit values (cheaper than a DELETE and re-INSERT next time)
				else
				{
					clear(pit);
				}
			}
			// A failed login attempt
			else
			{
				// Increment the total failed logon attempt count
				pit.fails++;

				// If the user was already tarred, also increment the lockout_fails count
				if (pit.tarred)
				{
					pit.lockoutFails++;
				}
				// We have old tarpit entries (past the maximum lockout time). Clear values.
				else if (pit.now - pit.lockout > 1800)
				{
					pit.lockout = pit.now;
					pit.fails = 1;
				}
				// If they weren't already tarred, determine whether they need to be via the number of failed attempts
				else if (pit.fails >= variables.instance.failLimit)
				{
					pit.tarred = true;
				}

				// Increase the lockTime (if the user has been, or was, tarred)
				if (pit.tarred)
				{
					if (pit.fails >= 9)
					{
						lockTime = 1800;		// 30 minutes (maximum lockout time)
					}
					else if (pit.fails >= 6)
					{
						lockTime = 900;		// 15 minutes
					}
					else
					{
						lockTime = 300;		// 5 minutes
					}

					pit.lockout = pit.now + lockTime;	// Set the value for the "lockout" period
				}
			}

			save(pit);
		}
		catch (any e)
		{
			writeLog(type="error", message="Tarpit.finalise() #e.message#", file=variables.instance.logFile);
		}
	}


	/**
	* @hint Check the tarpit for a user record, returns an empty recordset or a single row
	*/
	private query function fetch(required string user_id)
	{
		var q = new Query();
		var sql = "SELECT lockout, fails, lockout_fails
					FROM _tarpit
					WHERE	user_id = :userid";

		q.addParam(name="userid", value=arguments.user_id, cfsqltype="cf_sql_varchar");
		q.setDatasource(variables.instance.dsn_ro).setSQL(sql);

		return q.execute().getResult();
	}


	/**
	* @hint INSERT or UPDATE a user record for an unsuccessful login attempt, or clear values for a successful attempt
	* @param {struct} tarpit A struct of values generated from the initial check() and modified in finalise()
	*/
	private void function save(required struct tarpit)
	{
		var q = new Query();
		var sql = "INSERT INTO _tarpit
					(
						user_id
						, lockout
						, fails
						, lockout_fails
					)
					VALUES
					(
						:userid
						, :lockout
						, :fails
						, :lockoutfails
					) ON DUPLICATE KEY UPDATE lockout = :lockout
						, fails = :fails
						, lockout_fails = :lockoutfails";

		q.addParam(name="userid", value=arguments.tarpit.user_id, cfsqltype="cf_sql_varchar");
		q.addParam(name="lockout", value=arguments.tarpit.lockout, cfsqltype="cf_sql_integer");
		q.addParam(name="fails", value=arguments.tarpit.fails, cfsqltype="cf_sql_integer");
		q.addParam(name="lockoutfails", value=arguments.tarpit.lockoutFails, cfsqltype="cf_sql_integer");
		q.setDatasource(variables.instance.dsn).setSQL(sql);
		q.execute();
	}

}
