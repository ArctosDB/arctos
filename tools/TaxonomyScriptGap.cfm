<cfinclude template="/includes/_header.cfm">
<cfset title="Taxonomy is still a mess">
<cfset action='duGenus'>
<cfif action is 'duGenus'>
	Taxonomy gaps that cannot be scripted in.
	<br>Letter-links are first letter of genus
	<cfoutput>
		<cfif not isdefined("l")>
			<cfset l='A'>
		</cfif>
	    <cfloop index="strLetter" list="A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z" delimiters=",">
	     <a href="TaxonomyScriptGap.cfm?l=#strLetter#">#strLetter#</a>-     
	    </cfloop>	
		<cfquery name="d" datasource="uam_god">
				select
					taxonomy.genus,
					taxonomy.family,
					taxupfail.fail
				from
					taxonomy,
					taxupfail
				where
					taxonomy.genus=taxupfail.genus and
					taxupfail.genus like '#l#%'
				order by
					taxonomy.genus
		</cfquery>
		<cfquery name="g" dbtype="query">
			select genus,fail from d group by genus,fail order by genus
		</cfquery>
		<table border>
			<tr>
				<th>genus</th>
				<th>##Sp</th>
				<th>Family</th>
			</tr>
			<cfloop query="g">
				<cfquery name="f" dbtype="query">
					select family,count(*) n from d where genus='#genus#' group by family order by family
				</cfquery>
				<tr>
					<td>
						<a href="/TaxonomyResults.cfm?genus==#genus#">#genus#</a>
					</td>
					<td>#f.n#</td>
					<td>
						
						<cfloop query="f">
							<div>
								<a href="/TaxonomyResults.cfm?genus==#g.genus#&family=#family#">#family#</a>
							</div>
						</cfloop>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
	
		<!---
	<cfoutput>
		<cfif not isdefined("start")>
			<cfset start=0>
		</cfif>
		<cfif not isdefined("stop")>
			<cfset stop=50>
		</cfif>
		this form will return <=1000 rows
		<cfquery name="g" datasource="uam_god">
			Select * from (
				Select a.*, rownum rnum From (
					select
					genus,
					fail,
					rownum r
				from
					taxupfail order by genus
				) a where rownum <= #stop#
			) where rnum >= #start#
		</cfquery>
		<table border>
			<cfloop query="g">
				<tr>
					<td>#fail#</td>
					<td>
						<a href="/TaxonomyResults.cfm?genus==#genus#">#genus#</a>
					</td>
					<td>
						<cfquery name="f" datasource="uam_god">
							select family from taxonomy where genus='#genus#' group by family order by family
						</cfquery>
						<cfloop query="f">
							<div>
								<a href="/TaxonomyResults.cfm?genus==#g.genus#&family=#family#">#family#</a>
							</div>
						</cfloop>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
	--->
</cfif>
<cfinclude template="/includes/_footer.cfm">