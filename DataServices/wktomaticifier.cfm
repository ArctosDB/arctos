<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">


<script type="text/javascript">
function PassFileName()
{
document.getElementById("fileName").value=document.getElementById("FiletoUpload").value;
}
</script>




	upload Fusion Tables KML
	<form name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" id="FiletoUpload" size="45" onchange="PassFileName()">
		<input type="hidden" id="fileName" size="20" name="fileName" />
		<input type="submit" value="Upload this file" class="savBtn">
	</form>
</cfif>
<cfif action is "getFile">
<cfoutput>



	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfdump var=#form#>

<hr>

	<cfset fileContent=replace(fileContent,",","|","all")>
	<cfset fileContent=replace(fileContent," ","!","all")>
	<cfset fileContent=replace(fileContent,"<Polygon><outerBoundaryIs><LinearRing><coordinates>","POLYGON((","all")>
	<cfset fileContent=replace(fileContent,"</coordinates></LinearRing></outerBoundaryIs></Polygon>","))","all")>
	<cfset fileContent=replace(fileContent,"<MultiGeometry>POLYGON((","MULTIPOLYGON(((","all")>
	<cfset fileContent=replace(fileContent,"))</MultiGeometry>",")))","all")>
	<cfset fileContent=replace(fileContent,"|"," ","all")>
	<cfset fileContent=replace(fileContent,"!",",","all")>
	<cfset fileContent=replace(fileContent,",0.0 "," ","all")>
	<cfset fileContent=replace(fileContent,",0.0))","))","all")>
	<cfset fileContent=replace(fileContent," 0.0,",",","all")>
	<cfset fileContent=replace(fileContent," 0.0))","))","all")>

	<cfdump var=#fileContent#>


	<cflocation url="/download.cfm?file=#fname#" addtoken="false">


</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">