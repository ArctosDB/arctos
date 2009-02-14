
<cfabort>

<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select max(cat_num) mc from cataloged_item where collection_id =1000002
</cfquery>
<cfquery name="toChange" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select cat_num,collection.collection_cde,institution_acronym, coll_obj_other_id_num.collection_object_id from coll_obj_other_id_num,cataloged_item,collection
	where 
	coll_obj_other_id_num.collection_object_id=cataloged_item.collection_object_id and
	cataloged_item.collection_id=collection.collection_id and
	other_id_type='NK Number' and
	to_number(other_id_num) >= 123303 and
	to_number(other_id_num) <= 123771
</cfquery>
<cfset thisCatNum = #a.mc# + 1>
<cfset i=1>
<cftransaction>
<cfoutput query="toChange">
	<cfquery name="f" datasource="#Application.uam_dbo#">
	UPDATE cataloged_item SET cat_num=#thisCatNum#,collection_id=1000002
	where collection_object_id = #collection_object_id#
	and collection_id = 1000005
	</cfquery>
	<cfset thisCatNum =#thisCatNum# + 1>
	<cfset i =#i# + 1>
</cfoutput>
</cftransaction>