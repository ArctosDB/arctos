<cfinclude template="includes/_frameHeader.cfm">
<cfif not isdefined("container_id")>
	<cfabort><!--- need an ID to do anything --->
</cfif>
<cfquery name="Detail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT 
		cataloged_item.collection_object_id,
		container.container_id,
		container_type,
		label,
		description,
		container_remarks,
		container.barcode, 
		part_name, 
		cat_num, 
		scientific_name,
		concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
		parent_install_date,
		WIDTH,
		HEIGHT,
		length,
		NUMBER_POSITIONS
	FROM 
		container, 
		cataloged_item, 
		specimen_part, 
		coll_obj_cont_hist, 
		(select * from identification where accepted_id_fg=1) identification
	WHERE container.container_id = coll_obj_cont_hist.container_id (+) AND 
		coll_obj_cont_hist.collection_object_id = specimen_part.collection_object_id (+) AND 
		specimen_part.derived_from_cat_item = cataloged_item.collection_object_id   (+) AND 
		cataloged_item.collection_object_id = identification.collection_object_id (+) AND
		container.container_id=#container_id#
</cfquery>
<font size="+1"><strong> Container Details</strong></font>
<cfoutput query="Detail">
	

	
	<table border="1">
		<tr>
		   <td class="lbl">Container Type:</td>
			<td>#container_type#</td>
		</tr>
		<tr>
			<td class="lbl">Label:</td>
			<td> #label#</td>
		</tr>
		<cfif len(#description#) gt 0>
		  <tr>
			<td class="lbl"> Description:</td>
			<td> #description#</td>
		  </tr>
		</cfif>
		<cfif len(#container_remarks#) gt 0>
		  <tr>
			<td class="lbl">Container Remarks:</td>
			<td>#container_remarks#</td>
		  </tr>
		</cfif>
		<cfif len(#barcode#) gt 0>
		  <tr>
			<td class="lbl">Barcode:</td>
			<td>#barcode#</td>
		  </tr>
		</cfif>
		<cfif len(#parent_install_date#) gt 0>
		  <tr>
			<td class="lbl">Install Date:</td>
			<td>#dateformat(parent_install_date,"dd mmm yyyy")#
			&nbsp;
			#timeformat(parent_install_date,"hh:mm:ss")#</td>
		  </tr>
		</cfif>
		<cfif len(#part_name#) gt 0>
		  <tr>
			<td class="lbl">Part Name:</td>
			<td>#part_name#</td>
		  </tr>
		  <tr>
			<td class="lbl">Catalog Number:</td>
			<td>#cat_num# </td>
		  </tr>
		  <cfif len(#CustomID#) gt 0>
		  <tr>
			<td class="lbl">#session.CustomOtherIdentifier#:</td>
			<td>#CustomID#</td>
		  </tr>
		  </cfif>
		  <tr>
			<td class="lbl">Scientific Name: </td>
			<td><em>#scientific_name#</em></td>
		  </tr>
		</cfif>
		<cfif len(#WIDTH#) gt 0 OR len(#HEIGHT#) gt 0 OR len(#length#) gt 0>
		  <tr>
			<td class="lbl">Dimensions (W x H x D): </td>
			<td> #WIDTH# x #HEIGHT# x #length# CM</td>
		  </tr>
		</cfif>
		<cfif len(#NUMBER_POSITIONS#) gt 0>
		  <tr>
			<td class="lbl">Number of Positions: </td>
			<td> #NUMBER_POSITIONS#</td>
		  </tr>
		</cfif>
		<cfif len(#collection_object_id#) gt 0>
			<tr>
				<td colspan="2"><a href="SpecimenDetail.cfm?collection_object_id=#collection_object_id#" 
				target="_blank">Specimen</a>(new window)</td>
			</tr>
		<cfelse>
			<tr>
				<td colspan="2">
					<a href="EditContainer.cfm?container_id=#container_id#" target="_blank">Edit this container</a> (new window)
			</td>
			</tr>
		</cfif>
		<tr>
			<td colspan="2">
				<a href="allContainerLeafNodes.cfm?container_id=#container_id#" target="_blank">
						See all collection objects in this container</a>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<a href="/containerPositions.cfm?container_id=#container_id#" 
					target="_blank">Positions</a><font size="-1">(new window)</font>
			</td>
			</tr>
			<tr>
				<td colspan="2">
					<a href="javascript:void(0)" onClick="getHistory('#container_id#'); return false;">History</a>
				</td>
			</tr>
		</table>
</cfoutput>