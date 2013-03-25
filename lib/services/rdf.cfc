component extends="_base"
{

	public void function createRDF(required string type)
	{
		var jena_lib_path = getConfig("path").packages & "jena/lib/";
		var rootNamespace = "http://purl.org/ASN/schema/core/";
		var rdfManager = new lib.model.service.RdfManager(
															rootNamespace = rootNamespace,
															packagePath = jena_lib_path
														 );

		switch(arguments.type)
		{
			case "document":
				rdfManager.createStandardDocument();
				break;
			case "stage":
				rdfManager.createStage();
				break;
			case "strand":
				rdfManager.createStrand();
				break;
			case "outcome":
				rdfManager.createOutcome();
				break;
			case "contentgroup":
				rdfManager.createContentGroup();
				break;
			case "acara":
				rdfManager.createAcaraContent();
				break;
			case "bos":
				rdfManager.createBosContent();
				break;
			case "lable":
				rdfManager.createBosContent();
				break;
			default:
				break;
		}
	}


}