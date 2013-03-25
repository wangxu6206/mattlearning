component displayname="Proxy" accessors="true" output="false"
{

	property name="proxyPort" type="string" getter="true" setter="true" default="";
	property name="proxyServer" type="string" getter="true" setter="true" default="";

	public function init(required struct settings)
	{
		setProxyPort(arguments.settings.proxyPort);
		setProxyServer(arguments.settings.proxyServer);
		return this;
	}

}