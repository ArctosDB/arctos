<cfinclude template="/includes/_header.cfm">
<cfset title="COL taxonomy">
<script src="/includes/sorttable.js"></script>
<cfif not isdefined('sql')>
	<cfset sql="rownum<10">
</cfif>
<script>
	function a(t){
		if(t=='badgenus'){
			t="select genus from taxonomy where not regexp_like(genus,'[A-Z][a-z]*$') group by genus";
		}
		$('#sql').val(t)
	}
</script>
<cfoutput>
	<table>
		<tr>
			<td valign="top">
				<form name="f" method="get" action="colTaxonomy.cfm">
					<label for="sql">SQL</label>
					<textarea rows="4" columns="150" id="sql" name="sql">#sql#</textarea>
					<br><input type="submit">
					
					<br><input type="button" value="reset" onclick="document.location='colTaxonomy.cfm'">
				</form>
			</td>
			<td val="top">
				<div class="likeLink" onclick="a('select * from ttaxonomy where fu is not null');">won't load</div>
				<div class="likeLink" onclick="a('select * from ttaxonomy where kingdom is null');">no kingdom</div>
				<div class="likeLink" onclick="a('badgenus');">funky genus</div>
			</td>
		</tr>
	</table>
	
	<cfquery name="d" datasource="uam_god">
		#preservesinglequotes(sql)#
	</cfquery>
	<div style="border:1px solid green">
		#sql#
	</div>
	n: #d.recordcount#
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
