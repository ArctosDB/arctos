<cfoutput>
	<cfset rurl='/SpecimenUsage.cfm'>
	<cfif isdefined("publication_id")>
		<cfset rurl=rurl & '?action=search&publication_id=' & publication_id>
	</cfif>
	<cfheader statuscode="301" statustext="Moved permanently">
	<cfheader name="Location" value="#rurl#"> 
</cfoutput>