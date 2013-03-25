	Documentation: http://n2t.net/ezid/doc/apidoc.html

	Username: apitest

	Pword: apitest


		 A client manipulates an identifier by performing HTTP operations on its EZID URL: PUT to create the identifier, GET to view it,
		 and POST to modify it.

		 If a request comes in with an HTTP Accept header that expresses a preference for any form of HTML or XML,
		 the UI is invoked; otherwise, the API is invoked.

		c.setRequestProperty("Accept", "text/plain");


		r.add_header("Authorization", "Basic " + base64.b64encode("username:password"))

		<cfhttp
		    url = "https://n2t.net/"
		    method = "put"
		    password = "apitest"
		    path = "ezid/id/"
		    username = "apitest"
		    userAgent = "user agent">



			<cfhttpparam
			    type = "header"
			    encoded = "yes"
			    name = "title"
			    value = "#URLEncodedFormat('ALA V122164: Draba palanderiana Kjellman')#">
			<cfhttpparam type = "header" encoded = "yes" name = "creator" value = "#URLEncodedFormat('this is a test')#">
			<cfhttpparam type = "header" encoded = "yes" name = "publisher" value = "#URLEncodedFormat('MVZ')#">
			<cfhttpparam type = "header" encoded = "yes" name = "publication year" value = "#URLEncodedFormat('2013')#">
			<cfhttpparam type = "header" encoded = "yes" name = "url" value = "#URLEncodedFormat('http://arctos-test.tacc.utexas.edu/media/56925')#">


		</cfhttp>

		<cfdump var=#cfhttp#>