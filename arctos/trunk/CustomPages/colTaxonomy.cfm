<cfinclude template="/includes/_header.cfm">
<cfset title="COL taxonomy">
<script src="/includes/sorttable.js"></script>
<cfif not isdefined('sql')>
	<cfset sql="select * from ttaxonomy where rownum<10">
</cfif>
<cfif not isdefined('bsql')>
	<cfset bsql="">
</cfif>
<script>
	function a(t){
		if(t=='badsp'){
			t="select species from ttaxonomy where nomenclatural_code not in ('ICBN','ICZN') and not regexp_like(species,'^[a-z]*$') group by species";
		}
		if(t=='badssp'){
			t="select subspecies from ttaxonomy where nomenclatural_code not in ('ICBN','ICZN') and not regexp_like(subspecies,'^[a-z]*$') group by subspecies";
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
					<textarea rows="4" cols="100" id="sql" name="sql">#sql#</textarea>
					<br><input type="submit" value="click this to run ^ that SQL">
					&nbsp;&nbsp;&nbsp;<input type="button" value="reset" onclick="document.location='colTaxonomy.cfm'">
				</form>
			</td>
			<td valign="top">
				<label>Shortcuts (or type your own SQL <-- there)</label>
				<div style="height:8em;border:1px dotted green;overflow:auto;">
					<div class="likeLink" onclick="a('[fail]');">won't load</div>
					<div class="likeLink" onclick="a('select * from ttaxonomy where kingdom is null');">no kingdom</div>
					<div class="likeLink" onclick="a('[badgenus]');">funky genus (not ICBN/ICZN)</div>
					<div class="likeLink" onclick="a('badsp');">funky species (not ICBN/ICZN)</div>
					<div class="likeLink" onclick="a('badssp');">funky subspecies (not ICBN/ICZN)</div>
					<div class="likeLink" onclick="a('[badany]');">anything bad, uncontrolled</div>
					<div class="likeLink" onclick="a('[random]');">.5% random sample</div>
				</div>
			</td>
		</tr>
	</table>
	<cfif sql is "[badgenus]">
		<cfset bsql="select genus from ttaxonomy where nomenclatural_code not in ('ICBN','ICZN','ICTV') and 
			not regexp_like(genus,'^[A-Z][a-z]*$') group by genus">
	<cfelseif sql is "[fail]">
		<cfset bsql="select * from ttaxonomy where fu is not null">
	<cfelseif sql is "[random]">
		<cfset bsql="select * from ttaxonomy sample(.05) order by dbms_random.value">
	<cfelseif sql is "[badany]">
		<cfset bsql="select * from ttaxonomy where nomenclatural_code not in ('ICBN','ICZN','ICTV') and
			(
				not regexp_like(genus,'^[A-Z][a-z]*$') or
				not regexp_like(species,'^[a-z]*$') or
				not regexp_like(subspecies,'^[a-z]*$') or
				not regexp_like(kingdom,'^[A-Z][a-z]*$') or
				not regexp_like(PHYLUM,'^[A-Z][a-z]*$') or
				not regexp_like(PHYLCLASS,'^[A-Z][a-z]*$') or
				not regexp_like(SUBCLASS,'^[A-Z][a-z]*$') or
				not regexp_like(PHYLORDER,'^[A-Z][a-z]*$') or
				not regexp_like(SUBORDER,'^[A-Z][a-z]*$') or
				not regexp_like(SUPERFAMILY,'^[A-Z][a-z]*$') or
				not regexp_like(family,'^[A-Z][a-z]*$') or
				not regexp_like(SUBFAMILY,'^[A-Z][a-z]*$') or
				not regexp_like(TRIBE,'^[A-Z][a-z]*$') or
				not regexp_like(SUBGENUS,'^[A-Z][a-z]*$')
			)">
	<cfelse>
		<cfset bsql=sql>
	</cfif>
	<cfif bsql does not contain " from ttaxonomy ">
		badSQL<cfabort>
	</cfif>
	<cfquery name="d" datasource="uam_god">
		select * from ( #preservesinglequotes(bsql)# ) where rownum<5000
	</cfquery>
	<div style="border:1px solid green">
		#bsql#
	</div>
	n: #d.recordcount#
	<table border id="t" class="sortable">
		<tr>
			<cfloop list="#d.columnList#" index="i">
				<th>
					<cfif len(i) gt 7>
						#left(i,6)#...
					<cfelse>
						#i#
					</cfif>
				</th>
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
