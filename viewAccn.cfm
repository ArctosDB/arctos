<cfinclude template="includes/_header.cfm">
	<script>
		jQuery(document).ready(function(){
			var transaction_id=$("#transaction_id").val();
			var ptl="/form/inclMedia.cfm?q=" + transaction_id;
			var am=ptl+'&typ=accnspecimens&tgt=accnspecmedia';
			jQuery.get(am, function(data){
				 jQuery('#accnspecmedia').html(data);
			})
			var am=ptl+'&typ=accn&tgt=accnMedia';
			jQuery.get(am, function(data){
				 jQuery('#accnMedia').html(data);
			})
		})
			//var am=ptl+'&typ=accn&tgt=accnMedia';
			//



	</script>
	<cfoutput>
		<input type="hidden" id="transaction_id" value="#transaction_id#">
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				trans.transaction_id,
				accn_number,
			 	accn_status,
				accn_type,
				received_date,
				nature_of_material,
				trans_remarks,
				trans_date,
				guid_prefix,
				trans.collection_id,
				CORRESP_FG,
				concattransagent(trans.transaction_id,'entered by') enteredby,
				estimated_count,
				trans.is_public_fg
			FROM
				trans,
				accn,
				collection
			WHERE
				trans.transaction_id = accn.transaction_id AND
				trans.collection_id=collection.collection_id and
				trans.transaction_id =
				 <cfqueryparam value = "#transaction_id#" CFSQLType = "CF_SQL_INTEGER">
		</cfquery>
		<cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_transactions")>
	        <a href="/editAccn.cfm?action=edit&transaction_id=#transaction_id#">[ edit accession ]</a>
	    </cfif>
		<cfif d.is_public_fg is not 1>
			<div class="error">Data restricted by collection.</div>
			<cfabort>
		</cfif>
		<cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_transactions")>
	        <a href="/editAccn.cfm?action=edit&transaction_id=#transaction_id#">[ edit accession ]</a>
	    </cfif>
		<cfquery name="transAgents" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
				trans_agent.transaction_id=<cfqueryparam value = "#transaction_id#" CFSQLType = "CF_SQL_INTEGER">
			order by
				trans_agent_role,
				agent_name
		</cfquery>
		<p>
			<strong>Accession #d.guid_prefix# #d.accn_number#</strong>
		</p>
		<cfset title="Accession #d.guid_prefix# #d.accn_number#">
		<br><strong>Obtained by:</strong> #d.accn_type#
		<br><strong>Status:</strong> #d.accn_status#
		<br><strong>Received:</strong>
		<cfif len(d.received_date) gt 0>
			#d.received_date#
		<cfelse>
			not recorded
		</cfif>
		<cfif len(d.estimated_count) gt 0>
			<br><strong>Estimated Count:</strong> #d.estimated_count#
		</cfif>
		<br><strong>Nature of Material:</strong> #d.nature_of_material#
		<cfloop query="transAgents">
			<br><strong>#trans_agent_role#:</strong> #agent_name#
		</cfloop>
		<cfif len(d.trans_remarks) gt 0>
			<br><strong>Remarks:</strong> #d.trans_remarks#
		</cfif>
		<cfquery name="accncontainers" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select barcode from container, trans_container where
			container.container_id=trans_container.container_id and
			transaction_id=#transaction_id#
		</cfquery>
		<cfif accncontainers.recordcount gt 0>
			<p><strong>In Containers:</strong> #valuelist(accncontainers.barcode)#</p>
		</cfif>
		<cfquery name="projs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select project_name,niceURL(project_name) pn from project,
			project_trans where
			project_trans.project_id =  project.project_id
			and transaction_id=<cfqueryparam value = "#transaction_id#" CFSQLType = "CF_SQL_INTEGER">
		</cfquery>
		<p>
			<cfif projs.recordcount gt 0>
				Projects associated with this accession:
				<ul>
					<cfloop query="projs">
						<li>
							<a href="/project/#pn#">#project_name#</a>
						</li>
					</cfloop>
				</ul>
			<cfelse>
				No projects are associated with this accession.
			</cfif>
		</p>
		<p>
			Accession Media
			<div id="accnMedia"></div>
		</p>


		<cfquery name="getPermits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
				permit_trans.transaction_id = <cfqueryparam value = "#d.transaction_id#" CFSQLType = "CF_SQL_INTEGER">
		</cfquery>
		<p>
		<cfif getPermits.recordcount gt 0>
			Permits associated with this accession:
			<cfset i=0>
			<cfloop query="getPermits">
				<cfset i=i+1>
				<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<cfif len(permit_num) gt 0>
						<strong>Permit #permit_num#</strong>
					<cfelse>
						<strong>(permit number not issued)</strong>
					</cfif>
					<div style="padding-left:2em;">
						<strong>Permit Type:</strong> #permit_Type#
						<br><strong>Issued To:</strong> #IssuedToAgent#
						<br><strong>Issued By:</strong> #IssuedByAgent#
						<br><strong>Issued Date:</strong>
						<cfif len(issued_date) gt 0>
						 	#dateformat(issued_date,"yyyy-mm-dd")#
						<cfelse>
							not recorded
						</cfif>
						<cfif len(renewed_date) gt 0>
						 	<br><strong>Renewed on:</strong> #dateformat(renewed_date,"yyyy-mm-dd")#
						</cfif>
						<br><strong>Expiration Date:</strong>
						<cfif len(exp_date) gt 0>
						 	#dateformat(exp_date,"yyyy-mm-dd")#
						<cfelse>
							not recorded
						</cfif>
						<cfif len(permit_remarks) gt 0>
						 	<br><strong>Remark:</strong> #permit_remarks#
						</cfif>
					</div>
				</div>
			</cfloop>
		<cfelse>
			There are no permits associated with this accession.
		</cfif>
		</p>
		<cfquery name="spec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				guid_prefix,
				collection.collection_id,
				count(*) c
			from
				cataloged_item,
				collection
			where
				cataloged_item.collection_id=collection.collection_id and
				cataloged_item.accn_id=<cfqueryparam value = "#transaction_id#" CFSQLType = "CF_SQL_INTEGER">
			group by
				guid_prefix,
				collection.collection_id
			order by
				guid_prefix
		</cfquery>
		<p>
		<cfif spec.recordcount gt 0>
			<cfquery name="sspec" dbtype="query">
				select sum(c) tc from spec
			</cfquery>
			<br>There are <a href="/SpecimenResults.cfm?accn_trans_id=#transaction_id#">#sspec.tc# specimens</a> in this accession.
					[ <a href="/bnhmMaps/bnhmMapData.cfm?accn_trans_id=#transaction_id#">BerkeleyMapper</a> ]

			<ul>
				<cfloop query="spec">
					<li>
						<a href="/SpecimenResults.cfm?accn_trans_id=#transaction_id#&collection_id=#collection_id#">#c# #guid_prefix#</a>
						[ <a href="/bnhmMaps/bnhmMapData.cfm?accn_trans_id=#transaction_id#&collection_id=#collection_id#">BerkeleyMapper</a> ]
					</li>
				</cfloop>
			</ul>
		<cfelse>
			There are no specimens associated with this accession.
		</cfif>
		</p>
		<p>
			Accession Specimens Media
			<div id="accnspecmedia"></div>
		</p>


	</cfoutput>
<cfinclude template="includes/_footer.cfm">