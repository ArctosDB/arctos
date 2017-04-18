<cfinclude template="/includes/_header.cfm">
	<cfset title="flattened freezer locations">
	<script src="/includes/sorttable.js"></script>
	<cfset title="Flatten Parts">
	<cfoutput>
	<cfif not isdefined("transaction_id")>
		<cfset transaction_id="">
	</cfif>
	<cfif not isdefined("container_id")>
		<cfset container_id="">
	</cfif>
	<cfif not isdefined("collection_object_id")>
		<cfset collection_object_id="">
	</cfif>
	<cfif not isdefined("part1")>
		<cfset part1="">
	</cfif>
	<cfif not isdefined("part2")>
		<cfset part2="">
	</cfif>
	<cfif not isdefined("part3")>
		<cfset part3="">
	</cfif>
	<cfif not isdefined("frozenPartsOnly")>
		<cfset frozenPartsOnly="">
	</cfif>
	<cfset filterparts=part1>
	<cfset filterparts=listappend(filterparts,part2,"\")>
	<cfset filterparts=listappend(filterparts,part3,"\")>
	<cfset filterparts=listqualify(filterparts,"'","\")>
	<cfset filterparts=replace(filterparts,"'\'","','","all")>
	<cfset sel="select
			guid_prefix || ':' || cat_num guid,
			cataloged_item.collection_object_id,
			concatSingleOtherId(cataloged_item.collection_object_id,'#session.customOtherIdentifier#') CustomID,
			part_name,
			coll_obj_cont_hist.container_id,
			COLL_OBJ_DISPOSITION,
			decode(SAMPLED_FROM_OBJ_ID,
				NULL,'no',
				'yes') is_subsample	">
	<cfset frm=" FROM
			cataloged_item,
			collection,
			specimen_part,
			coll_obj_cont_hist,
			coll_object">
	<cfset whr=" WHERE cataloged_item.collection_id = collection.collection_id AND
			cataloged_item.collection_object_id = specimen_part.derived_from_cat_item and
			specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id and
			specimen_part.collection_object_id = coll_object.collection_object_id ">

	<cfif len(transaction_id) gt 0>
		<cfset frm="#frm# ,loan_item">
		<cfset whr="#whr# AND specimen_part.collection_object_id = loan_item.collection_object_id and
				loan_item.transaction_id = #transaction_id#">
	</cfif>
	<cfif len(container_id) gt 0>
		<cfif listlen(container_id) lt 1000>
			<cfset whr="#whr# AND coll_obj_cont_hist.container_id in (#container_id#)">
		<cfelse>
			<!---- wonky workaround to Oracle's list limitations ---->
			<cftry>
				<cfquery name="rem_my_big_list" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					drop table my_big_list
				</cfquery>
				<cfcatch>
					<br>caught drop
				</cfcatch>
			</cftry>
			<cfquery name="my_big_list" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				create table my_big_list (litem number)
			</cfquery>
			<cfloop list="#container_id#" index="i">
				<cfquery name="insmy_big_list" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into my_big_list (litem) values (#i#)
				</cfquery>
			</cfloop>
			<cfset whr="#whr# AND coll_obj_cont_hist.container_id in (select litem from my_big_list)">
		</cfif>
	</cfif>
	<cfif len(collection_object_id) gt 0>
		<cfset whr="#whr# AND cataloged_item.collection_object_id in (#collection_object_id#)">
	</cfif>
	<cfif frozenPartsOnly is "yes">
		<cfset whr="#whr# AND  part_name like '%frozen%' ">
	<cfelseif frozenPartsOnly is "no">
		<cfset whr="#whr# AND  part_name not like '%frozen%' ">
	</cfif>
	<cfif len(filterparts) gt 0>
		<cfset whr="#whr# AND  part_name in (#preservesinglequotes(filterparts)#) ">
	</cfif>
	<cfset sql="#sel# #frm# #whr#">
	<cfquery name="allCatItemsRaw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(sql)#
	</cfquery>

	<cfdump var=#allCatItemsRaw#>

	<cfquery name="allCatItems" dbtype="query">
		select * from allCatItemsRaw
	</cfquery>
	<cfquery name="ctpart" dbtype="query">
		select part_name from allCatItemsRaw group by part_name order by part_name
	</cfquery>
	<cfset a=1>
	<cfset fileName = "FreezerLocation_#left(session.sessionKey,10)#.csv">
	<a href="/download.cfm?file=#fileName#">Download</a>
	<cfset dlData="guid,#session.customOtherIdentifier#,part_name,location,disposition">
	<cffile action="write" file="#Application.webDirectory#/download/#fileName#" addnewline="yes" output="#dlData#">
	<form name="f" method="post" action="loanFreezerLocn.cfm">
		<input type="hidden" name="container_id" value="#container_id#">
		<input type="hidden" name="transaction_id" value="#transaction_id#">
		<input type="hidden" name="collection_object_id" value="#collection_object_id#">
		<label for="part1">Filter for part</label>
		<select name="part1" id="part1">
			<option value="">no filter</option>
			<cfloop query="ctpart">
				<option value="#part_name#" <cfif part1 is part_name> selected="selected"</cfif>>#part_name#</option>
			</cfloop>
		</select>
		OR
		<select name="part2" id="part2">
			<option value="">no filter</option>
			<cfloop query="ctpart">
				<option value="#part_name#" <cfif part2 is part_name> selected="selected"</cfif>>#part_name#</option>
			</cfloop>
		</select>
		OR
		<select name="part3" id="part3">
			<option value="">no filter</option>
			<cfloop query="ctpart">
				<option value="#part_name#" <cfif part3 is part_name> selected="selected"</cfif>>#part_name#</option>
			</cfloop>
		</select>
		<label for="frozenPartsOnly">AND part name contains "frozen"</label>
		<select name="frozenPartsOnly" id="frozenPartsOnly">
			<option <cfif frozenPartsOnly is "" >selected="selected" </cfif>value="">no filter</option>
			<option <cfif frozenPartsOnly is "yes" >selected="selected" </cfif>value="yes">contains FROZEN</option>
			<option <cfif frozenPartsOnly is "no" >selected="selected" </cfif>value="no">does not contain FROZEN</option>
		</select>
		<input type="submit" value="filter" class="lnkBtn">
	</form>
	<table border id="t" class="sortable">
		<th>Cataloged Item</th>
		<th>#session.customOtherIdentifier#</th>
		<th>Part Name</th>
		<th>Location</th>
		<th>Disposition</th>
		<cfloop query="allCatItems">
			<cfif len(container_id) gt 0>
				<cfquery name="freezer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select
						CONTAINER_ID,
						PARENT_CONTAINER_ID,
						CONTAINER_TYPE,
						DESCRIPTION,
						PARENT_INSTALL_DATE,
						CONTAINER_REMARKS,
						label,
						level
					 from container
					start with container_id=#container_id#
					connect by prior parent_container_id = container_id
					order by level DESC
				</cfquery>
			</cfif>
				<tr	#iif(a MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
					<td>#guid#</td>
					<td>#CustomID#&nbsp;</td>
					<cfset pn=part_name>
					<cfif is_subsample is "yes">
						<cfset pn=pn & "(subsample)">
					</cfif>
					<td>
						#pn#
					</td>
					<cfif len(container_id) gt 0>
						<cfset posn="">
						<cfloop query="freezer">
							<cfif CONTAINER_TYPE is "position">
								<cfset posn=posn & '<span style="font-weight:bold;">[#label#]</span>'>
							<cfelse>
								<cfset posn=posn & '[#label#]'>
							</cfif>
						</cfloop>
					<cfelse>
						<cfset posn='no position available'>
					</cfif>
					<td>
						#posn#
					</td>
					<td>#coll_obj_disposition#</td>
				</tr>
				<cfset a=a+1>
				<cfset oneLine='"#guid#","#CustomID#","#pn#","#posn#","#coll_obj_disposition#"'>
				<cfset oneLine=replace(oneLine,"</span>","","all")>
				<cfset oneLine=replace(oneLine,'<span style="font-weight:bold;">',"","all")>
				<cffile action="append" file="#Application.webDirectory#/download/#fileName#" addnewline="yes" output="#oneLine#">

		</cfloop>
	</table>
</cfoutput>