<cfif not isdefined("container_id")>
	<cfabort><!--- need an ID to do anything --->
</cfif>
<cfquery name="detail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	SELECT
		flat.collection_object_id,
		container.container_id,
		container_type,
		label,
		description,
		container_remarks,
		container.barcode,
		part_name,
		guid,
		scientific_name,
		concatSingleOtherId(flat.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
		parent_install_date,
		WIDTH,
		HEIGHT,
		length,
		NUMBER_POSITIONS
	FROM
		container,
		flat,
		specimen_part,
		coll_obj_cont_hist
	WHERE container.container_id = coll_obj_cont_hist.container_id (+) AND
		coll_obj_cont_hist.collection_object_id = specimen_part.collection_object_id (+) AND
		specimen_part.derived_from_cat_item = flat.collection_object_id (+) AND
		container.container_id=#container_id#
</cfquery>
<h2>Container Details</h2>
<cfoutput>
	<div>
		<div>Container Type: #detail.container_type#</div>

		<cfif len(detail.barcode) gt 0>
			<div>Barcode: #detail.barcode#</div>
		</cfif>
		<cfif detail.barcode neq detail.label>
			<div style="color:red;">Label: #detail.label#</div>
		<cfelse>
			<div>Label: #detail.label#</div>
		</cfif>
		<cfif len(detail.description) gt 0>
			<div>Description: #detail.description#</div>
		</cfif>
		<cfif len(detail.container_remarks) gt 0>
			<div>Remarks: #detail.container_remarks#</div>
		</cfif>
		<cfif len(detail.parent_install_date) gt 0>
			<div>Install Date: #dateformat(detail.parent_install_date,"yyyy-mm-dd")#T#timeformat(detail.parent_install_date,"hh:mm:ss")#</div>
		</cfif>
		<cfif len(detail.WIDTH) gt 0 OR len(detail.HEIGHT) gt 0 OR len(detail.length) gt 0>
		  <div>Dimensions (W x H x D): #detail.WIDTH# x #detail.HEIGHT# x #detail.length# CM</div>
		</cfif>

		<cfif len(detail.NUMBER_POSITIONS) gt 0>
		  <div>Number of Positions: #detail.NUMBER_POSITIONS#</div>
		</cfif>
		<cfif len(detail.part_name) gt 0>
			<div>
				Part: <a href="/guid/#detail.guid#" target="_blank" class="external">#detail.guid#</a>
				<em>#detail.scientific_name#</em> #detail.part_name#
				<cfif len(detail.CustomID) gt 0>
					(#session.CustomOtherIdentifier#: #detail.CustomID#)
				</cfif>
			</div>
		</cfif>
		<div>
			<a href="EditContainer.cfm?container_id=#container_id#" class="external" target="_blank">Edit this container</a>
		</div>
		<div>
			<a href="allContainerLeafNodes.cfm?container_id=#container_id#" class="external" target="_blank">
				See all collection objects in this container
			</a>
		</div>
		<div>
			<a href="/containerPositions.cfm?container_id=#container_id#" class="external" target="_blank">Positions</a>
		</div>
		<div>
			<a href="javascript:void(0)" onClick="getHistory('#container_id#'); return false;">History</a>
		</div>
		<cfquery name="posn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
          		CONTAINER_ID,
				level,
				getLastContainerEnvironment(CONTAINER_ID) lastenv,
		        --nvl(PARENT_CONTAINER_ID,0) PARENT_CONTAINER_ID,
		        CONTAINER_TYPE,
		        --DESCRIPTION,
		        --PARENT_INSTALL_DATE,
		        --CONTAINER_REMARKS,
		        label,
		        barcode
		        --, SYS_CONNECT_BY_PATH(container_type,':') thepath
			from container
		        start with container_id=#container_id#
		    connect by prior
		    	parent_container_id = container_id
			order by
				level desc
		</cfquery>
		<div>
			Location:
			<cfset indent=0>
			<cfloop query="posn">
				<cfset indent=indent+.5>
				<div style="margin-left: #indent#em; border:1px lightgray dotted;">
					<span class="likeLink" onclick="checkHandler(#container_id#)">#label#</span>
					<div style="margin-left:.4em;font-size:smaller;">
						<div>Container Type: #CONTAINER_TYPE#</div>
						<cfif len(barcode) gt 0>
							<cfif barcode neq label>
								<div style="color:red;">Barcode: #barcode#</div>
							<cfelse>
								<div>Barcode: #barcode#</div>
							</cfif>
						</cfif>
						<cfif len(lastenv) gt 0>
							<div>Last Envo: #lastenv#</div>
						</cfif>
					</div>
				</div>
			</cfloop>
		</div>
	</div>
</cfoutput>