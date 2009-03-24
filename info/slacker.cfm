<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
	<a href="slacker.cfm?action=pubNoCit">Publications without Citations</a>
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
		<cfloop query="data">
			<a href="/SpecimenUsage.cfm?action=search&publication_id=#publication_id#">#formatted_publication#</a>
		</cfloop>
	</cfoutput>
</cfif>

<cfinclude template="/includes/_footer.cfm">