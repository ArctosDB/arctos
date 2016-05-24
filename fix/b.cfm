<cfinclude template="/includes/_header.cfm">
<script language="JavaScript" src="/includes/polyline.js" type="text/javascript"></script>
<script language="JavaScript" src="/includes/wellknown.js" type="text/javascript"></script>

	<cfquery name="one" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select wkt_polygon from geog_auth_rec where geog_auth_rec_id=1001663
	</cfquery>
	<cfdump var=#one#>

	<script>

		function encthis(){
			var w=$("#wkt").val();
			var x=parse(w);
			console.log(x);
			console.log('coords: ' + x.coordinates);
			console.log(x.coordinates[0]);


			var pl=polyline.encode(x.coordinates[0]);
			console.log(pl);
		}


	</script>
<cfoutput>

<span class="likeLink" onclick="encthis()">encthis</span>
<input type="text" id="wkt" value="#one.wkt_polygon#">



</cfoutput>
