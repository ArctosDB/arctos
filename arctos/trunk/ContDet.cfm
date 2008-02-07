<cfinclude template="includes/_frameHeader.cfm">
<!---- this is an internal use page and needs a security wrapper --->
 <!--- no security --->
 <div style="float:right; position:absolute; right:0; top:0;">
	<cfinclude template="container_nav.cfm">
</div>
<cfif #client.target# is "_self">
	<cfset thisTarget = "_top">
<cfelse>
	<cfset thisTarget = "_blank">
</cfif>
<cfif not isdefined("container_id")>
	<cfabort><!--- need an ID to do anything --->
</cfif>

<cfquery name="Detail" datasource="#Application.web_user#">
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
		af_num.af_num, 
		scientific_name,
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
		identification, 
		af_num
	WHERE container.container_id = coll_obj_cont_hist.container_id (+) AND 
		coll_obj_cont_hist.collection_object_id = specimen_part.collection_object_id (+) AND 
		specimen_part.derived_from_cat_item = cataloged_item.collection_object_id   (+) AND 
		cataloged_item.collection_object_id = identification.collection_object_id (+) AND 
		cataloged_item.collection_object_id = af_num.collection_object_id (+)  AND
		container.container_id=#container_id# 
		ORDER BY container_id
</cfquery>
<font size="+1"><strong> Container Details</strong></font>
 <a href="javascript:void(0);" onClick="getDocs('location_tree')"><img src="/images/info.gif" border="0"></a>
<cfoutput query="Detail" group="container_id">
	<table border="1">
		<tr>
		   <td>Container Type:</td>
			<td>#container_type#</td>
		</tr>
		<tr>
			<td> Label:</td>
			<td> #label#</td>
		</tr>
		<cfif len(#description#) gt 0>
		  <tr>
			<td> Description:</td>
			<td> #description#</td>
		  </tr>
		</cfif>
		<cfif len(#container_remarks#) gt 0>
		  <tr>
			<td>Container Remarks:</td>
			<td>#container_remarks#</td>
		  </tr>
		</cfif>
		<cfif len(#barcode#) gt 0>
		  <tr>
			<td>Barcode:</td>
			<td>#barcode#</td>
		  </tr>
		</cfif>
		<cfif len(#parent_install_date#) gt 0>
		  <tr>
			<td>Install Date:</td>
			<td>#dateformat(parent_install_date,"dd mmm yyyy")#
			&nbsp;
			#timeformat(parent_install_date,"hh:mm:ss")#</td>
		  </tr>
		</cfif>
		<cfif len(#part_name#) gt 0>
		  <tr>
			<td>Part Name:</td>
			<td>#part_name#</td>
		  </tr>
		  <tr>
			<td>Catalog Number:</td>
			<td>#cat_num# </td>
		  </tr>
		  <tr>
			<td>AF Number:</td>
			<td>#af_num#</td>
		  </tr>
		  <tr>
			<td>Scientific Name: </td>
			<td>#scientific_name# </td>
		  </tr>
		</cfif>
		<cfif len(#WIDTH#) gt 0 OR len(#HEIGHT#) gt 0 OR len(#length#) gt 0>
		  <tr>
			<td>Dimensions (W x H x D): </td>
			<td> #WIDTH# x #HEIGHT# x #length# CM</td>
		  </tr>
		</cfif>
		<cfif len(#NUMBER_POSITIONS#) gt 0>
		  <tr>
			<td>Number of Positions: </td>
			<td> #NUMBER_POSITIONS#</td>
		  </tr>
		</cfif>
	</table> 
	<p>
	<table cellpadding="0" cellspacing="0">
		<cfif len(#collection_object_id#) gt 0>
			<tr>
				<td><a href="SpecimenDetail.cfm?content_url=editParts.cfm&collection_object_id=#collection_object_id#" 
				target="#thisTarget#">Edit this Part</a></td>
			</tr>
		<cfelse>
			<tr>
				<td><a href="EditContainer.cfm?container_id=#container_id#" target="_detail">Edit this container</a>
				 <a href="javascript:void(0);" onClick="getDocs('edit_container')"><img src="/images/info.gif" border="0"></a>
			</td>
			</tr>
		</cfif>
		<tr>
			<td>
				<a href="bits2containers.cfm" 
					target="#thisTarget#">
					Manually add collection objects to a container
				</a>&nbsp;
				<a href="javascript:void(0);" onClick="getDocs('move_objects')"><img src="/images/info.gif" border="0"></a>
			</td>
		</tr>
		<tr>
			<td>
				<a href="/location_tree.cfm?container_id=#container_id#&action=contentsSearch" 
					target="_tree">See all containers in this container</a>
				<a href="javascript:void(0);" 
					onClick="getDocs('location_tree','see_containers')"><img src="/images/info.gif" border="0"></a>
			</td>
		</tr>
		<tr>
			<td>
				<a href="javascript:parent._tree.location='allContainerLeafNodes.cfm?container_id=#container_id#';" 
					target="_tree">
						See all collection objects in this container</a>
				<a href="javascript:void(0);" 
					onClick="getDocs('location_tree','see_leaf')"><img src="/images/info.gif" border="0"></a>
			</td>
		</tr>
		<tr>
			<td>
				<a href="/containerPositions.cfm?container_id=#container_id#" 
					target="_blank">Positions</a> <font size="-1">(new window)</font>
			</td>
			</tr>
			<tr>
				<td>
					<a href="javascript:void(0)" onClick="getHistory('#container_id#'); return false;">History</a>
				</td>
			</tr>
		</table>
</cfoutput>