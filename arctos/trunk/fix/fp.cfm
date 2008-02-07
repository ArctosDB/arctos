<cfset pw='jmalaney'>
<cfquery name="np" datasource="#Application.uam_dbo#">
	update cf_users set password='#hash(pw)#' where
	username='jmalaney'
</cfquery>