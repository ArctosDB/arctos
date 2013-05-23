<cfinclude template="/includes/_header.cfm">
<script>
	function getScanned(v){
		if (v.length>0){
			$("#bc").val($("#bc").val() + ',' + $.trim(v));
		}
		$("#scantarget").select();
	}


</script>
<cfoutput>
	<cfif not isdefined("bc")><cfset bc =""></cfif>
	<form name="a" method="post" action="barcode2guid.cfm">
		<label for="scantarget">
			scan single barcodes here
		</label>
		<input type="text" id="scantarget" onchange="getScanned(this.value);">
		<input style="font-size:.001em;" type="text" id="tabbedin" size="1" onfocus="$('##scantarget').select();">
		<label for="bc">
			Comma-delimited list of barcodes here
		</label>
		<textarea name="bc" id="bc" rows="20" cols="80">#bc#</textarea>
		<label for="delim">Barcodes delimited by....</label>
		<select name="delim" id="delim">
		<br><input type="submit" value="get guids">
	</form>
	<cfif len(bc) gt 0>
	
		<cfset fileDir = "#Application.webDirectory#">
		<cfset variables.encoding="UTF-8">
		<cfset fname = "barcode2guid.csv">
		<a href="/download/#fname#">Download CSV</a>

		<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			variables.joFileWriter.writeLine('barcode,guid'); 
		</cfscript>
		<cfquery name="d" datasource="uam_god">
			select 
				c.barcode,
				guid 
			from 
				flat,
				specimen_part,
				coll_obj_cont_hist,
				container p,
				container c 
			where 
				flat.collection_object_id=specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				coll_obj_cont_hist.container_id=p.container_id and
				p.parent_container_id=c.container_id and
				c.barcode in (#ListQualify(BC, "'")#)
		</cfquery>
		<!--- order is important there - rather than trusting the query to do anything, loop over the input list --->
		<table border>
			<tr>
				<th>Barcode</th>
				<th>GUID</th>
			</tr>
			<cfloop list="#bc#" index="b">
				<cfquery name="t" dbtype="query">
					select * from d where barcode='#b#'
				</cfquery>
				<tr>
					<td>#b#</td>
					<td>#t.guid#</td>
				</tr>
				<cfscript>
					variables.joFileWriter.writeLine('"#b#","t.guid#"');
				</cfscript>
			</cfloop>
		</table>
		<cfscript>	
			variables.joFileWriter.close();
		</cfscript>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">