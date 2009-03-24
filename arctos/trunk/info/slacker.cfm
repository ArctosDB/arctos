<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
	<a href="slacker.cfm?action=pubNoAuth">Publications without Authors</a>
	<a href="slacker.cfm?action=pubNoCit">Publications without Citations</a>
</cfif>
<cfif action is "pubNoAuth">
	<cfquery name="data" datasource="uam_god">
		select 
			publication_id,
			publication_type
		from 
			publication 
		where 
			publication_id not in (select publication_id from publication_author_name)
	</cfquery>
	<cfoutput>
		<h2>Publications with no Authors</h2>
		<cfset i=1>
		<cfloop query="data">
			<a href="/SpecimenUsage.cfm?action=search&publication_id=#publication_id#">#publication_type#: #publication_id#</a>
			<br>
			<cfset i=i+1>
		</cfloop>
	</cfoutput>
</cfif>

<cfif action is "pubNoCit">
	<cfquery name="data" datasource="uam_god">
		select 
			publication_id,
			formatted_publication 
		from 
			formatted_publication
		where
			publication_id not in (
				select publication_id from citation
			)
		order by
			formatted_publication
	</cfquery>
	<cfoutput>
		<h2>Publications with no Citations</h2>
		<cfset i=1>
		<cfloop query="data">
			<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
				<p class="indent">
					#formatted_publication#
					<br>
					<a href="/SpecimenUsage.cfm?action=search&publication_id=#publication_id#">Details</a>
				</p>
			</div>
			<cfset i=i+1>
		</cfloop>
	</cfoutput>
</cfif>

<cfinclude template="/includes/_footer.cfm">