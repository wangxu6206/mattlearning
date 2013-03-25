component displayname="rdf" extends="_base"
{
	public any function init(required any fw)
	{

		super.init(arguments.fw);
	}

	public void function before(required any rc)
	{

		if (NOT StructKeyExists(request, 'failedAction')){
			if (NOT isLoggedIn())
			{
				//setStatusCode(401); // set status code will affect the request, eg, if the 401 is set here, will throw web page not found error.
				arguments.rc.json = serializeJSON('');
				//variables.fw.abortController();
			}

			super.before(arguments.rc);

			if (isLoggedIn()){
				arguments.rc.user_id = getUser().getId();
				//validateRequestParams(arguments.rc);
			}
		}
	}


	public void function default(rc)
	{
		arguments.rc.meta = {
			subTitle = "Generate RDF",
			links = {
					 create = "/rdf/create/"
					}
		}
	}


	public void function create(rc)
	{
		try {
			var rdfService = new lib.services.rdf();

			arguments.rc.meta = {
				subTitle = "Generate RDF",
				links = {
					cancel = "/rdf/default/"
				}
			}

			rdfService.createRDF(type=rc.type);
			variables.fw.setView("rdf.create");
		}
		catch(any e) {
			writeDump(e);
		}
	}

}