<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
	upload Fusion Tables KML
	<form name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45">
		<input type="submit" value="Upload this file" class="savBtn">
	</form>
</cfif>
<cfif action is "getFile">
<cfoutput>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">



	<cfdump var=#FiletoUpload#>


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