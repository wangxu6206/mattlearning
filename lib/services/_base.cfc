component
{
	public any function init()
	{
		variables._Logging			= application.cfcs.Logging;
		variables._Util				= application.cfcs.Util;
		return this;
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