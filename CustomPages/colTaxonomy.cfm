<cfinclude template="/includes/_header.cfm">
<cfset title="COL taxonomy">
<script src="/includes/sorttable.js"></script>
<cfif not isdefined('sql')>
	<cfset sql="rownum<10">
</cfif>
<script>
	function a(t){
		$('#sql').val(t)
	}
</script>
<cfoutput>
	<table>
		<tr>
			<td valign="top">
				<form name="f" method="get" action="colTaxonomy.cfm">
					<label for="sql">select * from ttaxonomy where...</label>
					<textarea rows="4" columns="150" id="sql" name="sql">#sql#</textarea>
					<br><input type="submit">
				</form>
			</td>
			<td val="top">
				<div class="likeLink" onclick="a('fu is not null');">won't load</div>
				<div class="likeLink" onclick="a('kingdom is null');">no kingdom</div>
			</td>
		</tr>
	</table>
	
	<cfquery name="d" datasource="uam_god">
		select * from ttaxonomy where #sql#
	</cfquery>
	<table border id="t" class="sortable">
		<tr>
			<cfloop list="#d.columnList#" index="i">
				<th>#i#</th>
			</cfloop>
		</tr>
		
	
		<cfloop query="d">
			<tr>
				<cfloop list="#d.columnList#" index="i">
					<td>#evaluate("d." & i)#</td>
				</cfloop>
			</tr>
		</cfloop>
	</table>
</cfoutput>






<cfinclude template="/includes/_footer.cfm">
