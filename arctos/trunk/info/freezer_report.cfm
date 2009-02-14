<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="Freezer Report">
<cfoutput>
<cfquery name="raw" datasource="#Application.web_user#">
	SELECT  
		 rtrim(reverse(SYS_CONNECT_BY_PATH(reverse(to_char(container_id)),',')),',') thepath
 	from 
		container 
	where 
		CONNECT_BY_ISLEAF=1
	start with container_id IN ( 					
			SELECT container.container_id  FROM container  
			inner join coll_obj_cont_hist on (container.container_id=coll_obj_cont_hist.container_id) 
			inner join specimen_part on (coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id) 
			inner join #session.SpecSrchTab# on (#session.SpecSrchTab#.collection_object_id=specimen_part.derived_from_cat_item)  
		) 				
		connect by prior parent_container_id = container_id
		order by  thepath
</cfquery>
<table border id="t" class="sortable">
	<tr>
		<th>Freezer</th>
		<th>FreezerPosition</th>
		<th>Rack</th>
		<th>RackPosition</th>
		<th>Box</th>
		<th>BoxPosition</th>
		<th>Tube</th>
		<th>Critter</th>
		<cfif  len(#session.CustomOtherIdentifier#) gt 0>
			<td>#session.CustomOtherIdentifier#</td>		
		</cfif>
	</tr>
<cfloop query="raw">
	<cfquery name="thisRow" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		select * from container where container_id IN (#thepath#)
	</cfquery>
	<cftry>
		<cfquery name="freezer" dbtype="query">
			select container_id,label from thisRow where container_type='freezer'
		</cfquery>
	<cfcatch>
		<cfquery name="freezer" dbtype="query">
			select -1 as container_id,' ' as label from thisRow where container_id = #listgetat(thepath,1)#
		</cfquery>
	</cfcatch>
	</cftry>
	<cftry>
		<cfquery name="freezer_posn" dbtype="query">
			select container_id,label from thisRow where parent_container_id=#freezer.container_id#
		</cfquery>
	<cfcatch>
		<cfquery name="freezer_posn" dbtype="query">
			select -1 as container_id,' ' as label from thisRow where container_id = #listgetat(thepath,1)#
		</cfquery>
	</cfcatch>
	</cftry>
	<cftry>
		<cfquery name="rack" dbtype="query">
			select container_id,label from thisRow where container_type='freezer rack'
		</cfquery>
	<cfcatch>
		<cfquery name="rack" dbtype="query">
			select -1 as container_id,' ' as label from thisRow where container_id = #listgetat(thepath,1)#
		</cfquery>
	</cfcatch>
	</cftry>
	<cftry>
		<cfquery name="rackPosition" dbtype="query">
			select container_id,label from thisRow where parent_container_id=#rack.container_id#
		</cfquery>
	<cfcatch>
		<cfquery name="rackPosition" dbtype="query">
			select -1 as container_id,' ' as label from thisRow where container_id = #listgetat(thepath,1)#
		</cfquery>
	</cfcatch>
	</cftry>
	<cftry>
		<cfquery name="freezer_box" dbtype="query">
			select container_id,label from thisRow where container_type='freezer box'
		</cfquery>
	<cfcatch>
		<cfquery name="freezer_box" dbtype="query">
			select -1 as container_id,' ' as label from thisRow where container_id = #listgetat(thepath,1)#
		</cfquery>
	</cfcatch>
	</cftry>
	<cftry>
		<cfquery name="box_posn" dbtype="query">
			select container_id,label from thisRow where parent_container_id=#freezer_box.container_id#
		</cfquery>
	<cfcatch>
		<cfquery name="box_posn" dbtype="query">
			select -1 as container_id,' ' as label from thisRow where container_id = #listgetat(thepath,1)#
		</cfquery>
	</cfcatch>
	</cftry>
	<cftry>
		<cfquery name="cryovial" dbtype="query">
			select container_id,label from thisRow where container_type='cryovial'
		</cfquery>
	<cfcatch>
		<cfquery name="cryovial" dbtype="query">
			select -1 as container_id,' ' as label from thisRow where container_id = #listgetat(thepath,1)#
		</cfquery>
	</cfcatch>
	</cftry>
	<cftry>
		<cfquery name="collection_object" dbtype="query">
			select container_id,label from thisRow where container_type='collection object'
		</cfquery>
		<cfif  len(#session.CustomOtherIdentifier#) gt 0>
			<cfquery name="catitem" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
				select 	concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID
				from coll_obj_cont_hist,
				specimen_part,
				cataloged_item
				 where 
				 	coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id and
				 	specimen_part.derived_from_cat_item=cataloged_item.collection_object_id and
				 coll_obj_cont_hist.container_id=#collection_object.container_id#
			</cfquery>
		</cfif>
	<cfcatch>
		<cfquery name="collection_object" dbtype="query">
			select -1 as container_id,' ' as label from thisRow where container_id = #listgetat(thepath,1)#
		</cfquery>
		<cfif  len(#session.CustomOtherIdentifie#) gt 0>
			<cfquery name="catitem"  dbtype="query">
				select 	' ' AS CustomID  from thisRow where container_id = #listgetat(thepath,1)#
			</cfquery>
		</cfif>
	</cfcatch>
	</cftry>
	<!---
	<tr>
		<td colspan="6">
				<cfdump var=#thisRow#>
		</td>
	</tr>
	--->
	<tr>
		<td>#freezer.label#</td>
		<td>#freezer_posn.label#</td>
		<td>#rack.label#</td>
		<td>#rackPosition.label#</td>
		<td>#freezer_box.label#</td>
		<td>#box_posn.label#</td>
		<td>#cryovial.label#</td>
		<td>#collection_object.label#</td>
		<cfif len(#session.CustomOtherIdentifier#) gt 0>
			<td>#catitem.CustomID#</td>		
		</cfif>
	</tr>
</cfloop>
</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">