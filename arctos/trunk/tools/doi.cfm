
<cfset x="datacite.creator: Arctos">
<cfset x=x & chr(10) & "datacite.title: this is a title">
<cfset x=x & chr(10) & "datacite.publisher: this is hte publisher">
<cfset x=x & chr(10) & "datacite.publicationyear: 1846">
<cfset x=x & chr(10) & "datacite.resourcetype: Image">



		<cfhttp username="apitest" password="apitest" method="POST" url="https://n2t.net/ezid/shoulder/doi:10.5072/FK2">
			<cfhttpparam type = "header" name = "Accept" value = "text/plain">
			<cfhttpparam type = "header" name = "Content-Type" value = "text/plain; charset=UTF-8">

			<cfhttpparam type = "body" value = "#x#">



			<cfhttpparam type = "header" name = "_target" value = "http://arctos-test.tacc.utexas.edu/media/10219911">
		</cfhttp>


	<cfif cfhttp.Statuscode is "201 CREATED">
		<cfset newDOI=replace(listgetat(listgetat(cfhttp.filecontent,2,":"),1,"|"),"doi:","")>
		got doi #newDOI#

	<cfelse>
		error: <cfdump var=#cfhttp#>
	</cfif>

		<cfdump var=#cfhttp#>