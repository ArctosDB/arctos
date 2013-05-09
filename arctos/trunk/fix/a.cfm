<cfoutput>
<cffunction name="toRad">
	<cfargument name="n" required="yes">
	
	<cfreturn n * 180 / pi()>
</cffunction>

<cfset x=toRad(30)>

<cfdump var=#x#>

</cfoutput>


<!------------
Number.prototype.toRad = function() {
   return this * Math.PI / 180;
}

Number.prototype.toDeg = function() {
   return this * 180 / Math.PI;
}

google.maps.LatLng.prototype.destinationPoint = function(brng, dist) {
   dist = dist / 6371;  
   brng = brng.toRad();  

   var lat1 = this.lat().toRad(), lon1 = this.lng().toRad();

   var lat2 = Math.asin(Math.sin(lat1) * Math.cos(dist) + 
                        Math.cos(lat1) * Math.sin(dist) * Math.cos(brng));

   var lon2 = lon1 + Math.atan2(Math.sin(brng) * Math.sin(dist) *
                                Math.cos(lat1), 
                                Math.cos(dist) - Math.sin(lat1) *
                                Math.sin(lat2));

   if (isNaN(lat2) || isNaN(lon2)) return null;

   return new google.maps.LatLng(lat2.toDeg(), lon2.toDeg());
}

---------------->

<!--------------
Documentation: http://n2t.net/ezid/doc/apidoc.html

	Username: apitest

	Pword: apitest


		 A client manipulates an identifier by performing HTTP operations on its EZID URL: PUT to create the identifier, GET to view it,
		 and POST to modify it.

		 If a request comes in with an HTTP Accept header that expresses a preference for any form of HTML or XML,
		 the UI is invoked; otherwise, the API is invoked.

		c.setRequestProperty("Accept", "text/plain");


		r.add_header("Authorization", "Basic " + base64.b64encode("username:password"))

	<cfset title=URLEncodedFormat('ALA V122164: Draba palanderiana Kjellman')>
	<cfset creator=URLEncodedFormat('this is a test')>

	<cfset publisher=URLEncodedFormat('MVZ')>
	<cfset pyear=	URLEncodedFormat('2013')>
	<cfset dURL=URLEncodedFormat('http://arctos-test.tacc.utexas.edu/media/56925')>
	<cfset params='{
		url = "https://n2t.net/",
		method = "PUT",
		password = "apitest",
		path = "ezid/id/",
		username = "apitest",
		title="#title#",
		creator="#creator#",
		publisher="#publisher#",
		publication year="#pyear#",
		url="#dURL#"
	}'>

		<cfhttp attributecollection="#params#"></cfhttp>



			method="get"
			path="ezid/id/"
			username="apitest"
			password="apitest"
				port="443">
			<cfhttpparam
			    type = "header"
			    name = "Accept"
			    value = "text/plain">

				<cfhttpparam
							    type = "header"
							    name = "ark"
							    value = "/99999/fk4cz3dh0">




			<cfhttpparam type = "formField" name = "datacite.title" value = "this is a title">
			<cfhttpparam type = "formField" name = "datacite.publisher" value = "this is hte publisher">
			<cfhttpparam type = "formField" name = "datacite.publicationyear" value = "1842">
			<cfhttpparam type = "formField" name = "datacite.resourcetype" value = "Image">
,
		title: this is a title,
		publisher: this is hte publisher,
		publicationyear: 1842,
		resourcetype: Image
https://n2t.net/ezid/id/


			<cfhttpparam type = "BODY"  value = "#x#">
<cfoutput>
<cfquery name="d" datasource="uam_god">
		select
			locality.LOCALITY_ID,
			higher_geog,
			SPEC_LOCALITY,
			DEC_LAT,
			DEC_LONG
		from
		locality,geog_auth_rec where
		locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
		 S$LASTDATE is null and rownum<20
	</cfquery>
	<cfset obj = CreateObject("component","component.functions")>

	<cfloop query="d">
		<cfset x=obj.getMap(locality_id=#locality_id#,forceOverrideCache=false)>
		back for #locality_id#<br>
	</cfloop>
</cfoutput>

		-------------->
