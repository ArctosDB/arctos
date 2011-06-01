<cfinclude template="/includes/_header.cfm">
<cfset title="COL taxonomy">
<script src="/includes/sorttable.js"></script>
<cfif not isdefined('sql')>
	<cfset sql="rownum<10">
</cfif>
<cfoutput>
	<form name="f" method="get" action="colTaxonomy.cfm">
		<label for="sql">select * from ttaxonomy where...</label>
		<textarea rows="4" columns="50" id="sql" name="sql">#sql#</textarea>
	</form>
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
			<cfloop list="#d.columnList#" index="i">
				<td>#evaluate("d." & i)#</td>
			</cfloop>
		</cfloop>
	</table>
</cfoutput>






<cfinclude template="/includes/_footer.cfm">
