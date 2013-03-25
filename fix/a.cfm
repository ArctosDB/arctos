	Documentation: http://n2t.net/ezid/doc/apidoc.html

	Username: apitest

	Pword: apitest


		 A client manipulates an identifier by performing HTTP operations on its EZID URL: PUT to create the identifier, GET to view it,
		 and POST to modify it.

		 If a request comes in with an HTTP Accept header that expresses a preference for any form of HTML or XML,
		 the UI is invoked; otherwise, the API is invoked.

		c.setRequestProperty("Accept", "text/plain");


		r.add_header("Authorization", "Basic " + base64.b64encode("username:password"))

	<cfset params="{
		url = "https://n2t.net/",
		method = "PUT",
		password = "apitest",
		path = "ezid/id/",
		username = "apitest",
		title="#URLEncodedFormat('ALA V122164: Draba palanderiana Kjellman')#",
		creator="#URLEncodedFormat('this is a test')#",
		publisher="#URLEncodedFormat('MVZ')#",
		publication year="#URLEncodedFormat('2013')#",
		url="#URLEncodedFormat('http://arctos-test.tacc.utexas.edu/media/56925')#"
	}">

		<cfhttp attributecollection="#params#"></cfhttp>

		<cfdump var=#cfhttp#>