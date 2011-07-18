<cfinclude template="includes/_header.cfm">	
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT
				trans.transaction_id,
				accn_number,
			 	accn_status,
				accn_type,
				received_date,
				nature_of_material,
				received_agent_id,
				trans_remarks,
				trans_date,
				collection,
				trans.collection_id,
				CORRESP_FG,
				concattransagent(trans.transaction_id,'entered by') enteredby,
				estimated_count
			FROM
				trans, 
				accn,
				collection
			WHERE
				trans.transaction_id = accn.transaction_id AND
				trans.collection_id=collection.collection_id and
				trans.transaction_id = #transaction_id#
		</cfquery>
		<cfquery name="transAgents" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				trans_agent_id,
				trans_agent.agent_id, 
				agent_name,
				trans_agent_role
			from
				trans_agent,
				preferred_agent_name
			where
				trans_agent.agent_id = preferred_agent_name.agent_id and
				trans_agent_role != 'entered by' and
				trans_agent.transaction_id=#transaction_id#
			order by
				trans_agent_role,
				agent_name
		</cfquery>
		Accession #d.collection# #d.accn_number#
		<br>Obtained by #d.accn_type#
		<br>Status: #d.accn_status#
		<br>Received #d.received_date#
		<br>Estimated Count: #d.estimated_count#
		<br>Nature of Material: #d.nature_of_material#
		<cfloop query="transAgents">
			<br>#trans_agent_role#: #agent_name#
		</cfloop>
		<br>Remarks: #d.trans_remarks#
		
		
			<cfquery name="accncontainers" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select barcode from container, trans_container where
				container.container_id=trans_container.container_id and
				transaction_id=#transaction_id#
			</cfquery>
			<br>In Containers #valuelist(accncontainers.barcode)#
			
			<strong>Projects associated with this Accn:</strong>
			<ul>
				<cfquery name="projs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select project_name, project.project_id from project,
					project_trans where 
					project_trans.project_id =  project.project_id
					and transaction_id=#transaction_id#
				</cfquery>
				<cfif #projs.recordcount# gt 0>
					<cfloop query="projs">
						<li>
							<a href="/Project.cfm?Action=editProject&project_id=#project_id#"><strong>#project_name#</strong></a><br>
						</li>
					</cfloop>
				<cfelse>
					<li>None</li>
				</cfif>
			</ul>
			

			<strong>Media associated with this Accn:</strong>
			<cfquery name="media" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					media.media_id,
					preview_uri,
					media_uri,
					media_type,
					label_value
				from 
					media,
					media_relations,
					(select * from media_labels where media_label='description') media_labels
				where
					media.media_id=media_labels.media_id (+) and
					media.media_id=media_relations.media_id and
					media_relationship like '% accn' and
					related_primary_key=#transaction_id#
			</cfquery>
			<ul>
				<cfif #media.recordcount# gt 0>
					<cfloop query="media">
						<li>
							<a href="#media_uri#">
								<cfif len(preview_uri) gt 0>
									<img src="#preview_uri#">
								<cfelse>
									<img src="/images/noThumb.jpg">
								</cfif>
							</a>
							<br><a class="infoLink" href="/MediaSearch.cfm?action=search&media_id=#media_id#">edit</a>
							<br>#label_value#
						</li>
					</cfloop>
				<cfelse>
					<li>None</li>
				</cfif>
			</ul>

		</div>
		<cfquery name="getPermits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				permit.permit_id,
				issuedBy.agent_name as IssuedByAgent,
				issuedTo.agent_name as IssuedToAgent,
				issued_date,
				renewed_date,
				exp_date,
				permit_Num,
				permit_Type,
				permit_remarks	
			FROM
				permit, 
				permit_trans, 
				preferred_agent_name issuedTo, 
				preferred_agent_name issuedBy
			WHERE
				permit.permit_id = permit_trans.permit_id AND
				permit.issued_by_agent_id = issuedBy.agent_id AND
				permit.issued_to_agent_id = issuedTo.agent_id AND
				permit_trans.transaction_id = #d.transaction_id#
		</cfquery>
		<div style="float:left;width:55%;">
			<br><strong>Permits:</strong>  
			<cfloop query="getPermits">
				<p><strong>Permit ## #permit_Num# (#permit_Type#)</strong> issued to #IssuedToAgent# by #IssuedByAgent# on #dateformat(issued_date,"yyyy-mm-dd")#. <cfif len(#renewed_date#) gt 0> (renewed #renewed_date#)</cfif>Expires #dateformat(exp_date,"yyyy-mm-dd")#  <cfif len(#permit_remarks#) gt 0>Remarks: #permit_remarks# </cfif> 
				<form name="killPerm#currentRow#" method="post" action="editAccn.cfm">
					<input type="hidden" name="transaction_id" value="#accnData.transaction_id#">
					<input type="hidden" name="action" value="delePermit">
					<input type="hidden" name="permit_id" value="#permit_id#">
					 <input type="submit" value="Remove this Permit" class="delBtn">	
				</form>
			</cfloop>
			<form name="addPermit" action="editAccn.cfm" method="post">
				<input type="hidden" name="transaction_id" value="#accnData.transaction_id#">
				<input type="hidden" name="permit_id">
				  <input type="button" value="Add a permit" class="picBtn"
			   		onClick="javascript: window.open('picks/PermitPick.cfm?transaction_id=#transaction_id#', 'PermitPick', 
						'resizable,scrollbars=yes,width=600,height=600')">
			</form>
		</td></tr></table>
	</cfoutput>
<cfinclude template="includes/_footer.cfm">