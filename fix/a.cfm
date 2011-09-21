<cfinclude template="/includes/_header.cfm">
		<iframe width="1000" height="1000" id="gl" src="http://www.museum.tulane.edu/geolocate/web/WebGeoref.aspx?v=1&Country=USA&State=Alaska&Locality=Fairbanks"></iframe>

<script>
	function getit() {
		var lat=$("#lat_id").val();
		console.log(lat);
		$("#a").val(lat);
	}
	function getit2() {
		var lat=$("#gl").contents().find('#lat_id').val();
		console.log(lat);
		$("#a").val(lat);
	}
	
	 
	
</script>
<cfoutput>
	
	


<form>
	<input name="a" id="a" type="text">
</form>
<span onclick="getit()">getit</span>
<span onclick="getit2()">getit2</span>

</cfoutput>
