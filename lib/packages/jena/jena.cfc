/**
* @author Matthew Wang
* @date 2013-03-18
* @description a utility to create RDF using Apache Jena API. see- http://jena.apache.org/documentation/tools/index.html
* @note: in order to make the jena library working without warning and error, it needs to set the dependency jar files properly,
* 		 Dependencies: jena-iri-0.9.5.jar, log4j-1.2.16.jar, slf4j-api-1.6.4.jar, slf4j-log4j12-1.6.4.jar, xercesImpl-2.10.0.jar, xml-apis-1.4.01.jar
* 		 They should be put into tomcat/lib directory for deploy before initialize the jena class
*/
component displayname="RDF Model build from Jena API" output="false"
{
	/**
	 * @hint Constructor of Jena RDF model
	 * @param {any} rdf -- uri|path_of_a_file.rdf|empty, empty means create am empty rdf model, otherwise create the model from loading the rdf template from uri or file system.
	 * @param {string} pathPackages -- path to the directory where the jena-core.jar file exists
	 */
	public function init(any rdf, required string pathPackages)
	{
		var input = "";
		var javaString = "";
		var stream = "";

		/* set the path for loading the jena library */
		variables.config.path = {
			jena = getdirectoryfrompath(arguments.pathPackages) & "/jena-core.jar"
		}

		variables.instance = {
			RDFModelName = "jena",
			RDFFactory = createObject("java", "com.hp.hpl.jena.rdf.model.ResourceFactory",variables.config.path.jena),
			RDFModel = createObject("java", "com.hp.hpl.jena.rdf.model.ModelFactory",variables.config.path.jena).createDefaultModel(), // create the new and empty model
			RDFModelRoot = createObject("java", "com.hp.hpl.jena.rdf.model.ResourceFactory",variables.config.path.jena).createResource(), // create a default resource as root node
			rootNamespace = "http://www.w3.org/1999/02/22-rdf-syntax-ns/", // set the default namespace for root node
			referneceNamespace = {}
		}

		/* see if the the model is create from default or from a exists rdf template*/
		if(structKeyExists(arguments, "rdf"))
		{
			if(isValid("URL",arguments.rdf))
			{
				/* initialize the model from uri */
				variables.instance.RDFModel.read(arguments.rdf);
				/* set the namespace for the root node for looking up propery easily by getProperty()*/
				variables.instance.rootNamespace = arguments.rdf;
			}
			else if(isXml(arguments.rdf))
			{
				/* initialize the model from reading a rdf template from system */
				javaString = createObject("java", "java.lang.String").init(toString(arguments.rdf), "utf-8");
                stream = createObject("java", "java.io.ByteArrayInputStream").init(javaString.getBytes());
                variables.instance.RDFModel.read(stream, "");
			}
		}

		return this;
	}


	/**
	* @hint  Add a statement to this model.
	* @param {any} property -- com.hp.hpl.jena.rdf.model.Property, which will form the rdf tag of the statement node
	* @param {any} object -- com.hp.hpl.jena.rdf.model.Resource|com.hp.hpl.jena.rdf.model.Literal|String, resource and literal will form the necessary attribute for the statement node
	*/
	public void function addStatement(required any property, required any object)
	{

			variables.instance.RDFModel.add(variables.instance.RDFModelRoot, arguments.property, arguments.object);

	}


	/**
	* @hint  Create a Literal attribute, such as xml:lang="en" .
	* @param {string} name -- the lexical form of the literal
	* @param {string} language -- the language associated with the literal
	* @return {any} -- the created Literal instance
	*/
	public any function createLiteral(required string name, required string language)
	{
		return variables.instance.RDFModel.createLiteral(arguments.name, arguments.language);
	}


	/**
	* @hint  Create a property with a given URI composed from a namespace part and a localname part by concatenating the strings.
	* @param {string} namespace -- the nameSpace of the property
	* @param {string} name -- the name of the property within its namespace
	* @return {any} -- the created Property instance
	*/
	public any function createProperty(required string namespace, required string name)
	{
		return variables.instance.RDFModel.createProperty(arguments.namespace, arguments.name);
	}


	/**
	* @hint  Create a new anonymous resource whose model is this model
	* @param {string} uri -- the URI of the resource to be created
	* @return {any} -- a new resource linked to this model.
	*/
	public any function createResource(required string uri)
	{
		return variables.instance.RDFModel.createResource(arguments.uri);
	}


	/**
	* @hint  Create a new resource as the reference node type with customized namespace and name such as <asm:root about=""></asm:root>.
	* @param {string} namespace -- a nameSpace used to create new this node type
	* @param {string} nodeName -- a name for the new node type
	* @return {any} -- Resource as the reference node type
	*/
	public any function createResourceNodeType(required string namespace, required string nodeName)
	{
		return variables.instance.RDFFactory.createResource(arguments.namespace & arguments.nodeName);
	}


	/**
	* @hint  Return a Property instance with the given root namespace and the property name in this model
	* @param {string} name -- the localName of the property in its namespace
	* @return {any} -- a property linked to this model
	*/
	public any function getProperty(required string name)
	{
		var p = "";

		if(isValid("URL", variables.instance.rootNamespace))
		{
			p = variables.instance.RDFModel.getProperty(variables.instance.rootNamespace, arguments.name);
		}
		return p;
	}


	/**
	* @hint   Generate the rdf file from the model into file system or on the page at run time
	* @param {string} fullFileName -- if a valid full file path passed in, function will generate the rdf file into that path, otherwise it will generate the rdf on the web page
	* @param {string} outputStandard -- the output standard for setting the generated rdf format, default standard set to "RDF/XML-ABBREV" for printing customized statement tag properly
	*/
	public void function generateRDF(String fullFileName, string outputStandard="RDF/XML-ABBREV")
	{
		var outputFilePath = "";
		var FileOutputStream = "";
		var fileOutputDir = "";
		var fileName = "";
		var fileSize = 0;
		var generateOnThePage = false;
		var RDFwriter = variables.instance.RDFModel.getWriter(arguments.outputStandard);
		var PrintStream = "";
		var OutputStreamWriter = "";

		try {

			if(structKeyExists(arguments, "fullFileName"))
			{
				fileName = listLast(arguments.fullFileName, "/");
				fileOutputDir = replace(arguments.fullFileName, fileName, "", "All");
				if(!directoryExists(fileOutputDir))
					DirectoryCreate(fileOutputDir);
				outputFilePath = arguments.fullFileName;
			}
			else
			{
				generateOnThePage = true;
				fileName = variables.instance.RDFModelName & ".rdf";
				outputFilePath = getTempDirectory() & fileName;
			}

			FileOutputStream = createObject("java", "java.io.FileOutputStream").init(outputFilePath);
			fileSize = createObject("java","java.io.File").init(outputFilePath).length();
			//OutputStreamWriter = createObject("java", "java.io.OutputStreamWriter").init(FileOutputStream, "utf-8");
			RDFwriter.setProperty("showXmlDeclaration","true");
			RDFwriter.setProperty("showDoctypeDeclaration","true");
			//RDFwriter.write(variables.instance.RDFModel, OutputStreamWriter, "");
			RDFwriter.write(variables.instance.RDFModel, FileOutputStream, "");

			if(generateOnThePage)
			{
				/* header name="Content-Disposition" value='attachment;filename="#fileName#"'; */
				content type="application/rdf+xml" file="#outputFilePath#" reset="true";
				header name="Content-Length" value="#fileSize#";
			}
		}
		catch(any e) {
			throw "Error occured at generate rdf file. message:#e.message#";
		}
	}


	/**
	* @hint   Set the root resource node for the current model
	* @param {string} rootResourceNameSpace -- nameSpace used to create the node type for root resource node
	* @param {string} rootResourceName -- name for the node type  for root resource node
	* @param {string} rootResourceURI -- uri used for create the root resource node such as <asn:statement about="rootResourceURI"></asn:statement>
	*/
	public void function setRootResource(required string rootResourceNameSpace, required string rootResourceName, required string rootResourceURI)
	{
		var rootResourceNodeType = "";

			rootResourceNodeType = createResourceNodeType(namespace=rootResourceNameSpace, nodeName=rootResourceName);
			variables.instance.RDFModelRoot = variables.instance.RDFModel.createResource(arguments.rootResourceURI, rootResourceNodeType);

	}


	/**
	* @hint   Update the default namespace such as j.0, j.1 withe the customized namespace
	* @param {struct} namespace -- a struct which has a set of key/value, key is the namespace name such as "dc", "gemq", value is the valid and actual uri for this namespace
	*/
	public void function setupReferenceNameSpace(required struct namespace)
	{
		if(isStruct(arguments.namespace))
       		variables.instance.referneceNamespace = arguments.namespace;
	}


	/**
	* @hint   Update the default namespace such as j.0, j.1 withe the customized namespace
	* @param {struct} namespace -- a struct which has a set of key/value, key is the namespace name such as "dc", "gemq", value is the valid and actual uri for this namespace
	*/
	public void function updateNameSpacePrefix()
	{
       for(var ns IN variables.instance.referneceNamespace)
       {
      		variables.instance.RDFModel.setNsPrefix(lcase(ns), variables.instance.referneceNamespace[ns]);
       }
	}

}