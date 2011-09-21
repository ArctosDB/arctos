<cfinclude template="/includes/_header.cfm">
		<iframe width="1000" height="1000" id="gl" src="http://www.museum.tulane.edu/geolocate/web/WebGeoref.aspx?v=1&Country=USA&State=Alaska&Locality=Fairbanks"></iframe>

<script>
	function getit() {
		$("#a").val($("#lat_id").val());
	}
</script>
<cfoutput>
	
	


<form>
	<input name="a" id="a" type="text">
</form>
<span onclick="getit()">getit</span>
</cfoutput>
