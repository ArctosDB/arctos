<cfquery name="j" datasource="#Application.uam_dbo#">
	select * from journal order by journal_id
</cfquery>
<cfoutput>
	<cfloop query="j">
		<cfquery name="isDup" datasource="#Application.uam_dbo#">
			select * from journal where journal_id <> #journal_id#
			and journal_name='#journal_name#'
		</cfquery>
		<cfif #isDup.recordcount# is 1>
			<br />#j.journal_name# (#j.journal_id#)is #isDup.journal_name# (#isDup.journal_id#)
			<cftransaction>
			<cfquery name="uJA" datasource="#Application.uam_dbo#">
				update journal_article set journal_id=#j.journal_id#
				where journal_id=#isDup.journal_id#
			</cfquery>
			<cfquery name="d" datasource="#Application.uam_dbo#">
				delete from journal where journal_id=#isDup.journal_id#
			</cfquery>
			
			</cftransaction>
		</cfif>
	</cfloop>
</cfoutput>