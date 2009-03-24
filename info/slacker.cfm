<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
	<a href="slacker.cfm?action=pubNoAuth">Publications without Authors</a>
	<br><a href="slacker.cfm?action=pubNoCit">Publications without Citations</a>
	<br><a href="slacker.cfm?action=projNoCit">Projects with Loans and without Publications</a>
</cfif>
<cfif action is "projNoCit">
	<cfquery name="data" datasource="uam_god">
		select 
			project_id,
			project_name
		from 
			project 
		where 
			project_id in (
				select 
					project_id 
				from 
					project_trans,
					loan
				where
					project_trans.transaction_id=loan.transaction_id
				) and
			project_id not in (
				select project_id from project_publication
				)
		order by
			project_name
	</cfquery>
	<cfoutput>
		<h2>Projects with Loans and without Publications</h2>
		<cfset i=1>
		<cfloop query="data">
			<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
				<p class="indent">
					#project_name#
					<br>
					<a href="/ProjectDetail.cfm.cfm?project_id=#project_id#">Project Details</a>
				</p>
			</div>
			<cfset i=i+1>
		</cfloop>
	</cfoutput>
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
			<a href="/Publication.cfm?publication_id=#publication_id#">#publication_type#: #publication_id#</a>
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
					<a href="/SpecimenUsage.cfm?action=search&publication_id=#publication_id#">Details (This link may not work. These data are suspect. That's why they're here.)</a>
					<br>
					<a href="/Publication.cfm?publication_id=#publication_id#">Edit Publication</a>
				</p>
			</div>
			<cfset i=i+1>
		</cfloop>
	</cfoutput>
</cfif>

<cfinclude template="/includes/_footer.cfm">