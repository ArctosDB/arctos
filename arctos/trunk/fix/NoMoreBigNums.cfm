<cfabort>
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
<cftransaction>
<cfoutput query="b">
	<cfquery name="anOldNum" datasource="#Application.uam_dbo#">
		select collection_object_id, cat_num
		from cataloged_item 
		where collection_id=1
		and cat_num IN (select max(cat_num) from cataloged_item where
			cat_num > 100000 and collection_id=1)
	</cfquery>
	<cfif #anOldNum.recordcount# is 1>
		<cfquery name="up" datasource="#Application.uam_dbo#">
			update cataloged_item set cat_num=#num# where collection_object_id=#anOldNum.collection_object_id#
		</cfquery>
	<cfelse>
	 !!!#anOldNum.recordcount#!!!
	</cfif>
	#num# - #anOldNum.collection_object_id# - #anOldNum.cat_num#<br>
</cfoutput>
</cftransaction>