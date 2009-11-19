<cfinclude template="/includes/_header.cfm">
<!----
	The code to make the table that this relies on is:
	create table nums as select rownum num from coll_object;
	create public synonym nums for nums;
	grant select on nums to public;
	commit;
---->

<cfif #action# is "nothing">
	Find gaps in catalog numbers:
	<cfquery name="oidnum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select distinct(other_id_type) from coll_obj_other_id_num order by other_id_type
	</cfquery>
	<cfquery name="collection_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select institution_acronym||' '||collection_cde CID, collection_id from collection
		group by institution_acronym||' '||collection_cde,collection_id
		order by institution_acronym||' '||collection_cde
	</cfquery>
	<form name="go" method="post" action="findGap.cfm">
		<input type="hidden" name="action" value="cat_num">
		<select name="collection_id" size="1">
			<cfoutput query="collection_id">
				<option value="#collection_id#">#CID#</option>
			</cfoutput>
		</select>
		<!----<select name="thisaction" size="1" onChange="document.go.action.value=this.value">
			<option value="cat_num">cat_num</option>
			<!---
			<cfoutput query="oidnum">
				<option value="#other_id_type#">#other_id_type#</option>
			</cfoutput>
			---->
		</select>
		---->
		<input type="submit"
				value="show me the gaps" 
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'"
				onmouseout="this.className='savBtn'">
	</form>
</cfif>

<cfif #action# is "cat_num">
<!--- max catnum --->
<!--- a little info --->
<cfquery name="what" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection from collection where collection_id=#collection_id#
</cfquery>
<cfoutput>
<b>The following catalog number are not used in the #what.collection# collection:</b>
<br>
</cfoutput>
<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select max(cat_num) mc from cataloged_item where collection_id IN (#collection_id#)
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
				collection_id = #collection_id#
				)
			order by num
</cfquery>
<cfoutput query="b">
	#num#<br>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is not "nothing" and #action# is not "cat_num">
select max(to_number(other_id_num)) mc from 
		cataloged_item,coll_obj_other_id_num where
		cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id and
		 collection_id =#collection_id# and
		 other_id_type='#action#'
<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select max(to_number(other_id_num)) mc from 
		cataloged_item,coll_obj_other_id_num where
		cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id and
		 collection_id =#collection_id# and
		 other_id_type='#action#'
</cfquery>
--_#a.mc#
<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		num
	from 
		nums
	where 
		num <= #a.mc# and
		not exists (
			select
				to_number(other_id_num)
			from 
				cataloged_item,
			 	coll_obj_other_id_num
			where 
				cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id and
				to_number(other_id_num)=num and
				collection_id = #collection_id# and
		 		other_id_type='#action#'
				)
			order by num
</cfquery>
select 
		num
	from 
		nums
	where 
		to_number(other_id_num) <= #a.mc# and
		not exists (
			select
				to_number(other_id_num)
			from 
				cataloged_item,
			 	coll_obj_other_id_num
			where 
				cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id and
				to_number(other_id_num)=num and
				collection_id = #collection_id#
				)
			order by num

<cfoutput query="b">
	#num#<br>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">