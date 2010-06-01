<cfoutput>
<cfquery name="newSpec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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



<cfloop query="newSpec">
	<a href="/guid/#guid#">#collection# #cat_num# <i>scientific_name</i></a><br>
</cfloop>
</cfoutput>