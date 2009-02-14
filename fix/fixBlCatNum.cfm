<!--- no security --->

<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select max(cat_num) mc from cataloged_item where collection_id =1
</cfquery>
<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		num
	from 
		nums 
	where 
		num <= #a.mc# and
		not exists (
			select
				cat_num
			from 
				cataloged_item
			where 
				cat_num=num and
				collection_id = 1
				)
			order by num
</cfquery>
<cfoutput query="b">
	<cfquery name="lb" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select min(collection_object_id) collection_object_id from bulkloader where
		cat_num is null and
		institution_acronym='UAM' and
		collection_cde='Mamm'
		and collection_object_id > 20
	</cfquery>
	<cfif len(#lb.collection_object_id#) gt 0>
	<cfquery name="upbl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update bulkloader set cat_num='#num#' where
		collection_object_id = #lb.collection_object_id#
	</cfquery>
	<br>
	</cfif>
</cfoutput>