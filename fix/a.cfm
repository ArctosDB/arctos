<cfinclude template="includes/_header.cfm">
<script>
function a(b){
	var c=isDate(b);
	console.log(b + ': ' + c);
	}
</script>
<input type="text" onchange="a(this.value)">