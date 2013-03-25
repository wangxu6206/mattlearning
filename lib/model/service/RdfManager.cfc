component displayname="Rdfmanager" output="false"
{

	public function init(String rootNamespace, String packagePath)
	{
		variables.instance.rootNamespace = arguments.rootNamespace;
		variables.instance.packagePath = arguments.packagePath;

		return this;
	}


	public void function createStandardDocument(any data)
	{
		var rootNamespace = "http://purl.org/ASN/schema/core/";
		var RootURI = "http://somewhere/URI(curri ⊥ culum)";
		var RootName = "StandardDocument";
		var namespace = {};
		var model = "";

		try {
			namespace = {
				"asn" = "http://purl.org/ASN/schema/core/",
				"dc" = "http://purl.org/dc/terms/",
				"dcterms" = "http://purl.org/dc/terms/",
				"gemq" = "http://purl.org/gem/qualifiers/"
			}

			/* set utf-8 as the encoding type */
			processingdirective pageencoding="utf-8"
			{

				model = new lib.packages.jena.jena(pathPackages=variables.instance.packagePath);
				model.setupReferenceNameSpace(namespace);
				/* example of creating the cached template rdf file into file system */
				/* var cached_template_directory = ExpandPath(variables.instance.packagePath) & "/test/";
				var cached_template_fileName = "cached_template.rdf";
 				model.generateRDF(cached_template_directory & cached_template_fileName); */

				model.setRootResource(rootResourceNameSpace=rootNamespace, rootResourceName=RootName, rootResourceURI=RootURI);

				model.addStatement(model.createProperty(namespace.asn, "Jurisdiction"), model.createResource("http://purl.org/ASN/scheme/ASNJurisdiction/AU-NSW"));
				model.addStatement(model.createProperty(namespace.dc, "language"), model.createResource("http://id.loc.gov/vocabulary/iso639-2/eng"));
				model.addStatement(model.createProperty(namespace.dc, "rights"), "TEXT(rights)");
				model.addStatement(model.createProperty(namespace.dc, "rightsHolder"), model.createResource("http://www.boardofstudies.nsw.edu.au/"));
				model.addStatement(model.createProperty(namespace.asn, "publicationStatus"), model.createResource("http://purl.org/ASN/scheme/ASNPublicationStatus/Published"));
				model.addStatement(model.createProperty(namespace.dc, "publisher"), model.createResource("http://www.boardofstudies.nsw.edu.au/"));
				model.addStatement(model.createProperty(namespace.dc, "source"), "TEXT(where this curriculum came fromi.e. the Board of Studies web site for this curriculum document)");
				model.addStatement(model.createProperty(namespace.dc, "modified"), "DATE(Stage changed)");
				model.addStatement(model.createProperty(namespace.dc, "subject"), model.createResource("http://vocabulary.curriculum.edu.au/AUScurriculumStrand/learning area 1"));
				model.addStatement(model.createProperty(namespace.dc, "subject"), model.createResource("http://vocabulary.curriculum.edu.au/AUScurriculumStrand/learning area n"));

				model.addStatement(model.createProperty(namespace.dc, "educationLevel"), model.createResource("http://somewhere/first year level out of http/schoolLevel/0"));
				model.addStatement(model.createProperty(namespace.dc, "educationLevel"), model.createResource("http://somewhere/first year level out of http/schoolLevel/1"));
				model.addStatement(model.createProperty(namespace.dc, "educationLevel"), model.createResource("http://somewhere/first year level out of http/schoolLevel/2"));
				model.addStatement(model.createProperty(namespace.dc, "educationLevel"), model.createResource("http://somewhere/first year level out of http/schoolLevel/3"));
				model.addStatement(model.createProperty(namespace.dc, "educationLevel"), model.createResource("http://somewhere/first year level out of http/schoolLevel/4"));

				model.addStatement(model.createProperty(namespace.dc, "abstract"), "URI(introduction)");
				model.addStatement(model.createProperty(namespace.dc, "abstract"), "URI(key)");
				model.addStatement(model.createProperty(namespace.dc, "abstract"), "URI(rationale)");
				model.addStatement(model.createProperty(namespace.dc, "abstract"), "URI(place in curriculum)");
				model.addStatement(model.createProperty(namespace.dc, "abstract"), "URI(aim)");
				model.addStatement(model.createProperty(namespace.dc, "abstract"), "URI(objectives)");
				model.addStatement(model.createProperty(namespace.dc, "abstract"), "URI(outcomes)");
				model.addStatement(model.createProperty(namespace.dc, "abstract"), "URI(stage statements)");
				model.addStatement(model.createProperty(namespace.dc, "abstract"), "URI(organisation of content)");
				model.addStatement(model.createProperty(namespace.dc, "abstract"), "URI(life skills)");
				model.addStatement(model.createProperty(namespace.dc, "abstract"), "URI(assessment)");
				model.addStatement(model.createProperty(namespace.dc, "abstract"), "URI(JSON manifest)");

				model.addStatement(model.createProperty(namespace.gemq, "hasChild"), model.createResource("http://somewhere/URI(Strand 1)"));
				model.addStatement(model.createProperty(namespace.gemq, "hasChild"), model.createResource("http://somewhere/URI(Strand n)"));
				model.addStatement(model.createProperty(namespace.gemq, "hasChild"), model.createResource("http://somewhere/URI(Stage 1)"));
				model.addStatement(model.createProperty(namespace.gemq, "hasChild"), model.createResource("http://somewhere/URI(Stage n)"));

				model.updateNameSpacePrefix();
				model.generateRDF();

			}

		}
		catch(any e)
		{
			writeDump(e);abort();
		}

	}


	public void function createStage(any data)
	{
		var rootNamespace = "http://purl.org/ASN/schema/core/";
		var RootURI = "http://somewhere/URI(curri ⊥ culum)";
		var RootName = "Statement";
		var namespace = {};
		var model = "";

		try {
			namespace = {
				"asn" = "http://purl.org/ASN/schema/core/",
				"dc" = "http://purl.org/dc/terms/",
				"dcterms" = "http://purl.org/dc/terms/",
				"gemq" = "http://purl.org/gem/qualifiers/"
			}
			/* set utf-8 as the encoding type */
			processingdirective pageencoding="utf-8"
			{
				model = new lib.packages.jena.jena(pathPackages=variables.instance.packagePath);
				model.setupReferenceNameSpace(namespace);
				model.setRootResource(rootResourceNameSpace=rootNamespace, rootResourceName=RootName, rootResourceURI=RootURI);

				model.addStatement(model.createProperty(namespace.asn, "isPartOf"), model.createResource("http://somewhere/data/curriculum_document"));
				model.addStatement(model.createProperty(namespace.dc, "title"), "Stage name");
				model.addStatement(model.createProperty(namespace.asn, "authorityStatus"), model.createResource("http://purl.org/ASN/scheme/ASNAuthorityStatus/Original"));
				model.addStatement(model.createProperty(namespace.dc, "modified"), "DATE(Stage changed)");
				model.addStatement(model.createProperty(namespace.asn, "indexingStatus"), model.createResource("http://purl.org/ASN/scheme/ASNIndexingStatus/No"));
				model.addStatement(model.createProperty(namespace.asn, "statementLabel"), model.createLiteral("Stage", "en"));
				model.addStatement(model.createProperty(namespace.dc, "description"), "TEXT(Stage preface)");
				model.addStatement(model.createProperty(namespace.dc, "rights"), "TEXT(rights if any)");
				model.addStatement(model.createProperty(namespace.dc, "rightsHolder"), model.createResource("http://www.boardofstudies.nsw.edu.au"));
				model.addStatement(model.createProperty(namespace.dc, "educationLevel"), model.createResource("http://somewhere/first year level out of http"));
				model.addStatement(model.createProperty(namespace.gemq, "isChildOf"), model.createResource("http://somewhere/Curriculumid"));
				model.addStatement(model.createProperty(namespace.gemq, "hasChild"), model.createResource("http://somewhere/Intermediate Grouping 1"));

				model.updateNameSpacePrefix();
				model.generateRDF();
			}
		}
		catch(any e)
		{
			writeDump(e);abort();
		}
	}


	public void function createStrand(any data)
	{
		var rootNamespace = "http://purl.org/ASN/schema/core/";
		var RootURI = "http://somewhere/URI(Strand_id)";
		var RootName = "Statement";
		var namespace = {};
		var model = "";

		try {
			namespace = {
				"asn" = "http://purl.org/ASN/schema/core/",
				"dc" = "http://purl.org/dc/terms/",
				"dcterms" = "http://purl.org/dc/terms/",
				"gemq" = "http://purl.org/gem/qualifiers/"
			}

			/* set utf-8 as the encoding type */
			processingdirective pageencoding="utf-8"
			{

				model = new lib.packages.jena.jena(pathPackages=variables.instance.packagePath);
				model.setupReferenceNameSpace(namespace);
				model.setRootResource(rootResourceNameSpace=rootNamespace, rootResourceName=RootName, rootResourceURI=RootURI);

				model.addStatement(model.createProperty(namespace.asn, "isPartOf"), model.createResource("http://somewhere/data/curriculum_document"));
				model.addStatement(model.createProperty(namespace.asn, "authorityStatus"), model.createResource("http://purl.org/ASN/scheme/ASNAuthorityStatus/Original"));
				model.addStatement(model.createProperty(namespace.dc, "modified"), "DATE(Stage changed)");
				model.addStatement(model.createProperty(namespace.asn, "indexingStatus"), model.createResource("http://purl.org/ASN/scheme/ASNIndexingStatus/No"));
				model.addStatement(model.createProperty(namespace.asn, "statementLabel"), model.createLiteral("Stage", "en"));
				model.addStatement(model.createProperty(namespace.dc, "description"), "TEXT(Stage preface)");
				model.addStatement(model.createProperty(namespace.dc, "subject"), model.createResource("http://vocabulary.curriculum.edu.au/AUScurriculumStrand/learning area"));
				model.addStatement(model.createProperty(namespace.dc, "rights"), "TEXT(rights if any)");
				model.addStatement(model.createProperty(namespace.dc, "rightsHolder"), model.createResource("http://www.boardofstudies.nsw.edu.au"));

				model.addStatement(model.createProperty(namespace.dc, "title"), "Strand name");

				model.addStatement(model.createProperty(namespace.dc, "educationLevel"), model.createResource("http://somewhere/first year level out of http/schoolLevel/0"));
				model.addStatement(model.createProperty(namespace.dc, "educationLevel"), model.createResource("http://somewhere/first year level out of http/schoolLevel/1"));
				model.addStatement(model.createProperty(namespace.dc, "educationLevel"), model.createResource("http://somewhere/first year level out of http/schoolLevel/2"));
				model.addStatement(model.createProperty(namespace.dc, "educationLevel"), model.createResource("http://somewhere/first year level out of http/schoolLevel/3"));
				model.addStatement(model.createProperty(namespace.dc, "educationLevel"), model.createResource("http://somewhere/first year level out of http/schoolLevel/4"));

				model.addStatement(model.createProperty(namespace.gemq, "isChildOf"), model.createResource("http://somewhere/Curriculumid"));
				model.addStatement(model.createProperty(namespace.gemq, "hasChild"), model.createResource("http://somewhere/URI(Strand 1)"));
				model.addStatement(model.createProperty(namespace.gemq, "hasChild"), model.createResource("http://somewhere/URI(Strand n)"));

				model.updateNameSpacePrefix();
				model.generateRDF();
			}
		}
		catch(any e)
		{
			writeDump(e);abort();
		}
	}


	public void function createOutcome(any data)
	{
		var rootNamespace = "http://purl.org/ASN/schema/core/";
		var RootURI = "http://somewhere/URI(Outcome_id)";
		var RootName = "Statement";
		var namespace = {};
		var model = "";

		try {
			namespace = {
				"asn" = "http://purl.org/ASN/schema/core/",
				"dc" = "http://purl.org/dc/terms/",
				"dcterms" = "http://purl.org/dc/terms/",
				"gemq" = "http://purl.org/gem/qualifiers/"
			}

			/* set utf-8 as the encoding type */
			processingdirective pageencoding="utf-8"
			{

				model = new lib.packages.jena.jena(pathPackages=variables.instance.packagePath);
				model.setupReferenceNameSpace(namespace);
				model.setRootResource(rootResourceNameSpace=rootNamespace, rootResourceName=RootName, rootResourceURI=RootURI);

				model.addStatement(model.createProperty(namespace.asn, "isPartOf"), model.createResource("http://somewhere/data/curriculum_document"));
				model.addStatement(model.createProperty(namespace.asn, "authorityStatus"), model.createResource("http://purl.org/ASN/scheme/ASNAuthorityStatus/Original"));
				model.addStatement(model.createProperty(namespace.dc, "modified"), "DATE(Stage changed)");
				model.addStatement(model.createProperty(namespace.asn, "indexingStatus"), model.createResource("http://purl.org/ASN/scheme/ASNIndexingStatus/No"));
				model.addStatement(model.createProperty(namespace.asn, "statementLabel"), model.createLiteral("Stage", "en"));
				model.addStatement(model.createProperty(namespace.asn, "statementNotation"), "TEXT(Outcome code)");

				model.addStatement(model.createProperty(namespace.dc, "title"), "Outcome");
				model.addStatement(model.createProperty(namespace.dc, "description"), "TEXT(Stage preface)");
				model.addStatement(model.createProperty(namespace.dc, "subject"), model.createResource("http://vocabulary.curriculum.edu.au/AUScurriculumStrand/learning area"));
				model.addStatement(model.createProperty(namespace.dc, "rights"), "TEXT(rights if any)");
				model.addStatement(model.createProperty(namespace.dc, "rightsHolder"), model.createResource("http://www.boardofstudies.nsw.edu.au"));

				model.addStatement(model.createProperty(namespace.dc, "educationLevel"), model.createResource("http://somewhere/first year level out of http/schoolLevel/0"));

				model.addStatement(model.createProperty(namespace.gemq, "isChildOf"), model.createResource("http://somewhere/URI(Intermediate grouping 1)"));
				model.addStatement(model.createProperty(namespace.gemq, "isChildOf"), model.createResource("http://somewhere/URI(Intermediate grouping n)"));

				model.addStatement(model.createProperty(namespace.asn, "conceptTerm"), model.createResource("http://somewhere/URI(ScOT keyword 1)"));
				model.addStatement(model.createProperty(namespace.asn, "conceptTerm"), model.createResource("http://somewhere/URI(ScOT keyword n)"));

				model.addStatement(model.createProperty(namespace.dc, "spatial"), "TEXT(Spatial Coverage 1)");
				model.addStatement(model.createProperty(namespace.dc, "spatial"), model.createResource("http://vocabulary.curriculum.edu.au/AUScurriculumStrand/learning area"));

				model.addStatement(model.createProperty(namespace.dc, "temporal"), "TEXT(Temporal Coverage 1)");
				model.addStatement(model.createProperty(namespace.dc, "temporal"), model.createResource("http://vocabulary.curriculum.edu.au/AUScurriculumStrand/Temporal Coverage n"));

				model.updateNameSpacePrefix();
				model.generateRDF();
			}
		}
		catch(any e)
		{
			writeDump(e);abort();
		}
	}


	public void function createContentGroup(any data)
	{
		var rootNamespace = "http://purl.org/ASN/schema/core/";
		var RootURI = "http://somewhere/URI(intermediate Grouping id)";
		var RootName = "Statement";
		var namespace = {};
		var model = "";

		try {
			namespace = {
				"asn" = "http://purl.org/ASN/schema/core/",
				"dc" = "http://purl.org/dc/terms/",
				"dcterms" = "http://purl.org/dc/terms/",
				"gemq" = "http://purl.org/gem/qualifiers/"
			}

			/* set utf-8 as the encoding type */
			processingdirective pageencoding="utf-8"
			{

				model = new lib.packages.jena.jena(pathPackages=variables.instance.packagePath);
				model.setupReferenceNameSpace(namespace);
				model.setRootResource(rootResourceNameSpace=rootNamespace, rootResourceName=RootName, rootResourceURI=RootURI);

				model.addStatement(model.createProperty(namespace.asn, "isPartOf"), model.createResource("http://somewhere/data/curriculum_document"));
				model.addStatement(model.createProperty(namespace.dc, "title"), "Stage name");
				model.addStatement(model.createProperty(namespace.asn, "authorityStatus"), model.createResource("http://purl.org/ASN/scheme/ASNAuthorityStatus/Original"));
				model.addStatement(model.createProperty(namespace.dc, "modified"), "DATE(Stage changed)");
				model.addStatement(model.createProperty(namespace.asn, "indexingStatus"), model.createResource("http://purl.org/ASN/scheme/ASNIndexingStatus/No"));
				model.addStatement(model.createProperty(namespace.asn, "statementLabel"), model.createLiteral("Stage", "en"));
				model.addStatement(model.createProperty(namespace.dc, "description"), "TEXT(Stage preface)");
				model.addStatement(model.createProperty(namespace.dc, "rights"), "TEXT(rights if any)");
				model.addStatement(model.createProperty(namespace.dc, "rightsHolder"), model.createResource("http://www.boardofstudies.nsw.edu.au"));
				model.addStatement(model.createProperty(namespace.dc, "educationLevel"), model.createResource("http://somewhere/first year level out of http"));
				model.addStatement(model.createProperty(namespace.gemq, "isChildOf"), model.createResource("http://somewhere/Curriculumid"));
				model.addStatement(model.createProperty(namespace.gemq, "hasChild"), model.createResource("http://somewhere/Intermediate Grouping 1"));

				model.updateNameSpacePrefix();
				model.generateRDF();
			}
		}
		catch(any e)
		{
			writeDump(e);abort();
		}
	}


	public void function createAcaraContent(any data)
	{
		var rootNamespace = "http://purl.org/ASN/schema/core/";
		var RootURI = "http://somewhere/URI(acara content id)";
		var RootName = "Statement";
		var namespace = {};
		var model = "";

		try {
			namespace = {
				"asn" = "http://purl.org/ASN/schema/core/",
				"dc" = "http://purl.org/dc/terms/",
				"dcterms" = "http://purl.org/dc/terms/",
				"gemq" = "http://purl.org/gem/qualifiers/"
			}

			/* set utf-8 as the encoding type */
			processingdirective pageencoding="utf-8"
			{

				model = new lib.packages.jena.jena(pathPackages=variables.instance.packagePath);
				model.setupReferenceNameSpace(namespace);
				model.setRootResource(rootResourceNameSpace=rootNamespace, rootResourceName=RootName, rootResourceURI=RootURI);

				model.addStatement(model.createProperty(namespace.asn, "isPartOf"), model.createResource("http://somewhere/data/curriculum_document"));
				model.addStatement(model.createProperty(namespace.dc, "title"), "Stage name");
				model.addStatement(model.createProperty(namespace.asn, "authorityStatus"), model.createResource("http://purl.org/ASN/scheme/ASNAuthorityStatus/Original"));
				model.addStatement(model.createProperty(namespace.dc, "modified"), "DATE(Stage changed)");
				model.addStatement(model.createProperty(namespace.asn, "indexingStatus"), model.createResource("http://purl.org/ASN/scheme/ASNIndexingStatus/No"));
				model.addStatement(model.createProperty(namespace.asn, "statementLabel"), model.createLiteral("Stage", "en"));
				model.addStatement(model.createProperty(namespace.dc, "description"), "TEXT(Stage preface)");
				model.addStatement(model.createProperty(namespace.dc, "rights"), "TEXT(rights if any)");
				model.addStatement(model.createProperty(namespace.dc, "rightsHolder"), model.createResource("http://www.boardofstudies.nsw.edu.au"));
				model.addStatement(model.createProperty(namespace.dc, "educationLevel"), model.createResource("http://somewhere/first year level out of http"));
				model.addStatement(model.createProperty(namespace.gemq, "isChildOf"), model.createResource("http://somewhere/Curriculumid"));
				model.addStatement(model.createProperty(namespace.gemq, "hasChild"), model.createResource("http://somewhere/Intermediate Grouping 1"));

				model.updateNameSpacePrefix();
				model.generateRDF();
			}
		}
		catch(any e)
		{
			writeDump(e);abort();
		}
	}


	public void function createBosContent(any data)
	{
		var rootNamespace = "http://purl.org/ASN/schema/core/";
		var RootURI = "http://somewhere/URI(bos content id)";
		var RootName = "Statement";
		var namespace = {};
		var model = "";

		try {
			namespace = {
				"asn" = "http://purl.org/ASN/schema/core/",
				"dc" = "http://purl.org/dc/terms/",
				"dcterms" = "http://purl.org/dc/terms/",
				"gemq" = "http://purl.org/gem/qualifiers/"
			}

			/* set utf-8 as the encoding type */
			processingdirective pageencoding="utf-8"
			{

				model = new lib.packages.jena.jena(pathPackages=variables.instance.packagePath);
				model.setupReferenceNameSpace(namespace);
				model.setRootResource(rootResourceNameSpace=rootNamespace, rootResourceName=RootName, rootResourceURI=RootURI);

				model.addStatement(model.createProperty(namespace.asn, "isPartOf"), model.createResource("http://somewhere/data/curriculum_document"));
				model.addStatement(model.createProperty(namespace.dc, "title"), "Stage name");
				model.addStatement(model.createProperty(namespace.asn, "authorityStatus"), model.createResource("http://purl.org/ASN/scheme/ASNAuthorityStatus/Original"));
				model.addStatement(model.createProperty(namespace.dc, "modified"), "DATE(Stage changed)");
				model.addStatement(model.createProperty(namespace.asn, "indexingStatus"), model.createResource("http://purl.org/ASN/scheme/ASNIndexingStatus/No"));
				model.addStatement(model.createProperty(namespace.asn, "statementLabel"), model.createLiteral("Stage", "en"));
				model.addStatement(model.createProperty(namespace.dc, "description"), "TEXT(Stage preface)");
				model.addStatement(model.createProperty(namespace.dc, "rights"), "TEXT(rights if any)");
				model.addStatement(model.createProperty(namespace.dc, "rightsHolder"), model.createResource("http://www.boardofstudies.nsw.edu.au"));
				model.addStatement(model.createProperty(namespace.dc, "educationLevel"), model.createResource("http://somewhere/first year level out of http"));
				model.addStatement(model.createProperty(namespace.gemq, "isChildOf"), model.createResource("http://somewhere/Curriculumid"));
				model.addStatement(model.createProperty(namespace.gemq, "hasChild"), model.createResource("http://somewhere/Intermediate Grouping 1"));

				model.updateNameSpacePrefix();
				model.generateRDF();
			}
		}
		catch(any e)
		{
			writeDump(e);abort();
		}
	}


	public void function createlableContent(any data)
	{
		var rootNamespace = "http://purl.org/ASN/schema/core/";
		var RootURI = "http://somewhere/URI(lable content id)";
		var RootName = "Statement";
		var namespace = {};
		var model = "";

		try {
			namespace = {
				"asn" = "http://purl.org/ASN/schema/core/",
				"dc" = "http://purl.org/dc/terms/",
				"dcterms" = "http://purl.org/dc/terms/",
				"gemq" = "http://purl.org/gem/qualifiers/"
			}

			/* set utf-8 as the encoding type */
			processingdirective pageencoding="utf-8"
			{

				model = new lib.packages.jena.jena(pathPackages=variables.instance.packagePath);
				model.setupReferenceNameSpace(namespace);
				model.setRootResource(rootResourceNameSpace=rootNamespace, rootResourceName=RootName, rootResourceURI=RootURI);

				model.addStatement(model.createProperty(namespace.asn, "isPartOf"), model.createResource("http://somewhere/data/curriculum_document"));
				model.addStatement(model.createProperty(namespace.dc, "title"), "Stage name");
				model.addStatement(model.createProperty(namespace.asn, "authorityStatus"), model.createResource("http://purl.org/ASN/scheme/ASNAuthorityStatus/Original"));
				model.addStatement(model.createProperty(namespace.dc, "modified"), "DATE(Stage changed)");
				model.addStatement(model.createProperty(namespace.asn, "indexingStatus"), model.createResource("http://purl.org/ASN/scheme/ASNIndexingStatus/No"));
				model.addStatement(model.createProperty(namespace.asn, "statementLabel"), model.createLiteral("Stage", "en"));
				model.addStatement(model.createProperty(namespace.dc, "description"), "TEXT(Stage preface)");
				model.addStatement(model.createProperty(namespace.dc, "rights"), "TEXT(rights if any)");
				model.addStatement(model.createProperty(namespace.dc, "rightsHolder"), model.createResource("http://www.boardofstudies.nsw.edu.au"));
				model.addStatement(model.createProperty(namespace.dc, "educationLevel"), model.createResource("http://somewhere/first year level out of http"));
				model.addStatement(model.createProperty(namespace.gemq, "isChildOf"), model.createResource("http://somewhere/Curriculumid"));
				model.addStatement(model.createProperty(namespace.gemq, "hasChild"), model.createResource("http://somewhere/Intermediate Grouping 1"));

				model.updateNameSpacePrefix();
				model.generateRDF();
			}
		}
		catch(any e)
		{
			writeDump(e);abort();
		}
	}

}