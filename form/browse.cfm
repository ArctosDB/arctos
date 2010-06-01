<cfoutput>
<cfquery name="rSpec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from (
		select 
			guid,
			collection,
			cat_num,
			scientific_name
		from
			filtered_flat
		ORDER BY dbms_random.value
	)
	WHERE rownum <= 10
</cfquery>



<cfloop query="rSpec">
	<a href="/guid/#guid#">#collection# #cat_num# <i>#scientific_name#</i></a><br>
</cfloop>

<cfquery name="rTax" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from (
		select 
			scientific_name,
			display_value
		from
			taxonomy
		ORDER BY dbms_random.value
	)
	WHERE rownum <= 10
</cfquery>

<cfloop query="rTax">
	<a href="/name/#scientific_name#">#display_value#</a><br>
</cfloop>
</cfoutput>