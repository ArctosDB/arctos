<cfoutput>
<cfquery name="newSpec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		guid,
		collection,
		cat_num
	from
		filtered_flat
	where
		round(LAST_EDIT_DATE-sysdate) >-45
</cfquery>

<cfloop query="newSpec">
	<a href="/guid/#guid#">#collection# #cat_num#</a>
</cfloop>
</cfoutput>