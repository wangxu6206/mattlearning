
<cfset request.layout = true>
<cfsetting enablecfoutputonly="true">

<cfoutput><!DOCTYPE html>
<!--[if lt IE 7]>      <html  lang="en" class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html  lang="en" class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html  lang="en" class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html  lang="en" class="no-js"> <!--<![endif]-->
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width">
	<title>Matt Learning :: Practice and Learning</title>
	<link href="/static/css/main.css" rel="stylesheet" type="text/css">
	<link rel="stylesheet" href="/static/vendor/bootstrap/css/bootstrap.css" rel="stylesheet" type="text/css">
	<link rel="stylesheet" href="/static/vendor/bootstrap/css/bootstrap-responsive.css" rel="stylesheet" type="text/css">
</head>
<body>
	 <div class="navbar navbar-top">
      <div class="navbar-inner">
        <div class="container-fluid">
          <a class="brand" href="/">Testing and Learning</a>
        </div>
      </div>
    </div>

	<div class="container-fluid">

	    <div class="sidebar-nav span2">
		    <ul class="nav nav-list">
		       <li class="nav-header">Tool</li>
			   <li><a href="/tidyhtml/default/">JTidy</a></li>
			   <li><a href="/jsoup/default/">Jsoup</a></li>
			    <li><a href="##">CK Editor</a></li>
		       <li class="nav-header">JavaScript</li>
		       <li><a href="##">jQueryPlay</a></li>
		       <li><a href="##">jQueryUI</a></li>
		       <li class="nav-header">API & Utility</li>
		       <li><a href="/asposeword/default/">Aspose Word</a></li>
		       <li><a href="/sitemap/default/">Site Map</a></li>
		       <li><a href="/rdf/default/">Jena RDF</a></li>
		    </ul>
	    </div>

    	<div class="container-fluid main">
			<div class="row-fluid">
			  <div class="span10">
				#body#
			</div>
		</div>

	</div>
	<footer id="footer">
		<!--- <div>
			<ul class="nav nav-pills">
				<li><a target="_blank" href="http://www.nsw.gov.au/">NSW Government</a></li>
				<li><a target="_blank" href="http://www.boardofstudies.nsw.edu.au/">Board of Studies NSW</a></li>
				<li><a target="_blank" href="http://syllabus.bos.nsw.edu.au/">Syllabus</a></li>
				<li><a target="_blank" href="http://syllabus.bos.nsw.edu.au/copyright/">Copyright</a></li>
			</ul>
		</div> --->
	</footer>
</body>
</html>
</cfoutput>