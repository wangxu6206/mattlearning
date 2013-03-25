component displayname="asposeword" extends="_base"
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
			subTitle = "Import and export Word document with Aspose.Words API",
			links = {
					 import = "/asposeword/create/",
					 export = "/asposeword/export/"
					}
		}
	}


	public void function import(rc)
	{
		try {
			var asposeword = New lib.packages.asposewords.AsposeConversion();
			writeDump(asposeword);abort();
			/* var fileUploadResult1 = fileUpload(getTempDirectory(), "wordFileImport1", "", "MakeUnique");
			var fileUploadResult2 = fileUpload(getTempDirectory(), "wordFileImport2", "", "MakeUnique");
			var uploadedFilePath1 = fileUploadResult1.serverdirectory & "/" & fileUploadResult1.serverfile;
			var uploadedFilePath2 = fileUploadResult2.serverdirectory & "/" & fileUploadResult2.serverfile;

			asposeword.mergeDocument(uploadfile1=uploadedFilePath1, uploadfile2=uploadedFilePath2);

			arguments.rc.outputhtml2 = addedRoot;

			variables.fw.setView('wordpoc.display'); */
		}
		catch(any e) {
			writeDump(e);
		}
	}


	public void function export(rc)
	{

			var jsoup = New lib.packages.jsoup.jsoup();

			var util = New lib.utils.String();
			var xmlUtil = New lib.utils.XmlUtil();
			var templatePath = getConfig("path").export_template;
			var asposewordsLicPath = getConfig("path").packages & "/asposewords/lib/";
			var stReturn = "";
			var html2doc = "";
			var template = expandPath(templatePath) & "template.doc";
			var exportManager = new lib.model.service.ExportManager(
																	asposewordsLicensePath = expandPath(asposewordsLicPath)
																	);

			var exportConfig = "";


			try{
				//var checkXMl = xmlUtil.distinguishHTMLFormat(rc.htmlcontent);
				exportConfig = {
							exportFileName = "TestExport",
							format = "doc",
							template = template,
							footerLabel = "test footer",
							orientation = "protrait",
							toc = false
							};

				exportManager.exportDocument(
									htmlString = rc.htmlcontent,
									config = exportConfig
									);
			}
			catch(any e)
			{
				dump(var=e);abort;
			}

	}

}