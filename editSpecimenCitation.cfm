<cfinclude template="/includes/alwaysInclude.cfm">
<cfif action is "nothing">
	<cfoutput>
		<cfquery name="getCited" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				citation.citation_id,
				citation.publication_id,
				citation.collection_object_id,
				cataloged_item.cat_num,
				collection.guid_prefix,
				identification.scientific_name,
				identification.identification_id idid,
				citation.occurs_page_number,
				citation.type_status,
				citation.citation_remarks,
				publication.short_citation,
				citation.identification_id,
				identification.accepted_id_fg,
				identification.made_date,
				guid_prefix || ':' || cat_num guid,
				agent_name,
				IDENTIFIER_ORDER,
				NATURE_OF_ID,
				IDENTIFICATION_REMARKS,
				sensu.short_citation sensupub,
				identification.publication_id sensupubid
			FROM
				cataloged_item,
				collection,
				citation,
				identification,
				publication,
				identification_agent,
				preferred_agent_name,
				publication sensu
			WHERE
				cataloged_item.collection_id = collection.collection_id AND
				cataloged_item.collection_object_id = citation.collection_object_id AND
				cataloged_item.collection_object_id = identification.collection_object_id AND
				citation.publication_id = publication.publication_id AND
				identification.identification_id=identification_agent.identification_id (+) and
				identification_agent.agent_id = preferred_agent_name.agent_id (+) and
				identification.publication_id=sensu.publication_id (+) and
				cataloged_item.collection_object_id=#collection_object_id#
		</cfquery>
		
		<cfquery name="one" dbtype="query">
			select
				publication_id,
				collection_object_id,
				cat_num,
				guid_prefix,
				occurs_page_number,
				type_status,
				citation_remarks,
				short_citation,
				identification_id,
				citation_remarks,
				guid,
				citation_id
			from
				getCited
			group by
				publication_id,
				collection_object_id,
				cat_num,
				guid_prefix,
				occurs_page_number,
				type_status,
				citation_remarks,
				short_citation,
				identification_id,
				citation_remarks,
				guid,
				citation_id
		</cfquery>
		<cfquery name="citns" dbtype="query">
			select
				scientific_name,
				idid,
				accepted_id_fg,
				made_date,
				NATURE_OF_ID,
				IDENTIFICATION_REMARKS,
				sensupub,
				sensupubid
			from
				getCited
			group by
				scientific_name,
				idid,
				accepted_id_fg,
				made_date,
				NATURE_OF_ID,
				IDENTIFICATION_REMARKS,
				sensupub,
				sensupubid
			order by
				accepted_id_fg desc,
				made_date
		</cfquery>
		<cfquery name="ctTypeStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select type_status from ctcitation_type_status order by type_status
		</cfquery>
		<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select collection_id,guid_prefix from collection order by guid_prefix
		</cfquery>
		<cfquery name="ctnature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select nature_of_id from ctnature_of_id
		</cfquery>
		<cfquery name="ctFormula" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select taxa_formula from cttaxa_formula order by taxa_formula
		</cfquery>
		<br>Edit Citation for <strong><a target="_blank" href="/guid/#one.guid#">#one.guid#</a></strong> in
		<b><a target="_blank" href="/publication/#one.publication_id#">#one.short_citation#</a></b>.
		<ul>
			<li>Edit <a target="_blank" href="/guid/#one.guid#">#one.guid#</a> in a new window</li>
			<li>View details for <a target="_blank" href="/publication/#one.publication_id#">#one.short_citation#</a> in a new window</li>
			<li>Manage citations for <a href="Citation.cfm?publication_id=#one.publication_id#">#one.short_citation#</a></li>
			<li>Not finding a useful ID? Add one to the specimen.</li>
			<li>Need to edit an ID? Edit the specimen.</li>
			<li>This is a mess? Delete the citation and try again.</li>
		</ul>
		<form name="editCitation" id="editCitation" method="post" action="Citation.cfm">
			<input type="hidden" name="Action" value="saveEdits">
			<input type="hidden" name="publication_id" value="#one.publication_id#">
			<input type="hidden" name="citation_id" value="#citation_id#">
			<input type="hidden" name="collection_object_id" value="#one.collection_object_id#">
			<label for="type_status">Citation Type</label>
			<select name="type_status" id="type_status" size="1">
				<cfloop query="ctTypeStatus">
					<option
						<cfif ctTypeStatus.type_status is one.type_status> selected </cfif>value="#ctTypeStatus.type_status#">#ctTypeStatus.type_status#</option>
				</cfloop>
			</select>
			<label for="occurs_page_number">Page</label>
			<input type="text" name="occurs_page_number" id="occurs_page_number" size="4" value="#one.occurs_page_number#">
			<label for="citation_remarks">Remarks</label>
			<input type="text" name="citation_remarks" id="citation_remarks" size="50" value="#one.citation_remarks#">
			<br>Identifications for #one.guid#:
			<table border>
				<tr>
					<th>Accepted ID?</th>
					<th>Cited ID?</th>
					<th>Scientific Name</th>
					<th>Made Date</th>
					<th>Nature of ID</th>
					<th>ID Remark</th>
					<th>Sensu</th>
					<th>ID Agents</th>
					<th>UseThisOne</th>
				</tr>
				<cfloop query="citns">
					<cfquery name="agnts" dbtype="query">
						select agent_name from getCited where
						idid=#idid#
						order by IDENTIFIER_ORDER
					</cfquery>
					<tr>
						<td>
							<cfif accepted_id_fg is 1>
								YES
							<cfelse>
								no
							</cfif>
						</td>
						<td>
							<cfif idid is one.identification_id>
								YES
							<cfelse>
								no
							</cfif>
						</td>
						<td>#scientific_name#</td>
						<td>#made_date#</td>
						<td>#NATURE_OF_ID#</td>
						<td>#IDENTIFICATION_REMARKS#</td>
						<td>
							<a target="_blank" href="/publication/#sensupubid#">#sensupub#</a>
						</td>
						<td>#replace(valuelist(agnts.agent_name),",",", ","all")#</td>
						<td><input type="radio" name="identification_id" <cfif idid is one.identification_id> checked="true" </cfif>value="#idid#"></td>
					</tr>
				</cfloop>
			</table>
		<input type="submit" value="Save Edits" class="savBtn" id="sBtn" title="Save Edits">
	</form>
		
		
	</cfoutput>
</cfif>
	<!-------------
	
	<cfabort>
		
	<style>
		.dragger {
			cursor:move;
		}
	</style>
	<cfquery name="ctcollector_role" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select collector_role from ctcollector_role order by collector_role
	</cfquery>
	<cfquery name="getColls" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT
			agent_name,
			collector_role,
			coll_order,
			collector.agent_id,
			collector_id
		FROM
			collector,
			preferred_agent_name
		WHERE
			collector.collection_object_id = #collection_object_id# and
			collector.agent_id = preferred_agent_name.agent_id
		ORDER BY
			coll_order
	</cfquery>
	<script>
		function deleteThis(i){
			$("#name_" + i).val('DELETE');
			$("#agent_id_" + i).val('');
		}
		jQuery(document).ready(function() {
			$( "#colls" ).submit(function( event ) {
				var linkOrderData=$("#sortable").sortable('toArray').join(',');
				$( "#roworder" ).val(linkOrderData);
				return true;
			});
		});
		$(function() {
			$( "#sortable" ).sortable({
				handle: '.dragger'
			});
		});
	</script>
	<cfoutput>
		<cfset i=1>
		<form name="colls" id="colls" method="post" action="editColls.cfm" >
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
			<input type="hidden" name="action" value="saveEdits">
			<input type="hidden" name="roworder" id="roworder" value="">
			<table id="clastbl" border="1">
				<thead>
					<tr>
						<th>Drag To Order</th>
						<th>Agent</th>
						<th>Role</th>
						<th></th>
					</tr>
				</thead>
				<tbody id="sortable">
					<cfloop query="getColls">
						<input type="hidden" name="collector_id_#i#" value="#collector_id#">
						<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))# id="row_#i#">
							<td class="dragger">
								(drag row here)
							</td>
							<td>
								<input type="text" name="name_#i#" id="name_#i#" value="#getColls.agent_name#" class="reqdClr"
									onchange="getAgent('agent_id_#i#','name_#i#','colls',this.value); return false;"
							 		onKeyPress="return noenter(event);">
								<input type="hidden" name="agent_id_#i#" id="agent_id_#i#" value="#getColls.agent_id#">
							</td>
							<td>
								 <select name="collector_role_#i#" id="collector_role_#i#" size="1"  class="reqdClr">
								 	<cfloop query="ctcollector_role">
								 		<option <cfif getColls.collector_role is ctcollector_role.collector_role> selected="selected" </cfif>
								 			value="#ctcollector_role.collector_role#">#ctcollector_role.collector_role#</option>
								 	</cfloop>
								</select>
							</td>
							<td>
								<input type="button" class="delBtn" value="delete" onclick="deleteThis('#i#');">
							</td>
						</tr>
						<cfset i = i+1>
					</cfloop>
					<tr class="newRec" id="row_new1">
						<td class="dragger">
							(drag row here)
						</td>
						<td>
							<input type="hidden" name="collector_id_new1" value="new">
							<input type="text" name="name_new1" id="name_new1" value="" class=""
								placeholder="Add an Agent"
								onchange="getAgent('agent_id_new1','name_new1','colls',this.value); return false;"
						 		onKeyPress="return noenter(event);">
							<input type="hidden" name="agent_id_new1" id="agent_id_new1">
						</td>
						<td>
							 <select name="collector_role_new1" id="collector_role_new1" size="1"  class="reqdClr">
							 	<cfloop query="ctcollector_role">
							 		<option	value="#ctcollector_role.collector_role#">#ctcollector_role.collector_role#</option>
							 	</cfloop>
							</select>
						</td>
						<td>
							<input type="button" class="delBtn" value="delete" onclick="deleteThis('new1');">
						</td>
					</tr>
					<tr class="newRec" id="row_new2">
						<td class="dragger">
							(drag row here)
						</td>
						<td>
							<input type="hidden" name="collector_id_new2" value="new">
							<input type="text" name="name_new2" id="name_new2" value="" class=""
								placeholder="Add an Agent"
								onchange="getAgent('agent_id_new2','name_new2','colls',this.value); return false;"
						 		onKeyPress="return noenter(event);">
							<input type="hidden" name="agent_id_new2" id="agent_id_new2">
						</td>
						<td>
							 <select name="collector_role_new2" id="collector_role_new2" size="1"  class="reqdClr">
							 	<cfloop query="ctcollector_role">
							 		<option	value="#ctcollector_role.collector_role#">#ctcollector_role.collector_role#</option>
							 	</cfloop>
							</select>
						</td>
						<td>
							<input type="button" class="delBtn" value="delete" onclick="deleteThis('new2');">
						</td>
					</tr>
					<tr class="newRec" id="row_new3">
						<td class="dragger">
							(drag row here)
						</td>
						<td>
							<input type="hidden" name="collector_id_new3" value="new">
							<input type="text" name="name_new3" id="name_new3" value="" class=""
								placeholder="Add an Agent"
								onchange="getAgent('agent_id_new3','name_new3','colls',this.value); return false;"
						 		onKeyPress="return noenter(event);">
							<input type="hidden" name="agent_id_new3" id="agent_id_new3">
						</td>
						<td>
							 <select name="collector_role_new3" id="collector_role_new3" size="1"  class="reqdClr">
							 	<cfloop query="ctcollector_role">
							 		<option	value="#ctcollector_role.collector_role#">#ctcollector_role.collector_role#</option>
							 	</cfloop>
							</select>
						</td>
						<td>
							<input type="button" class="delBtn" value="delete" onclick="deleteThis('new3');">
						</td>
					</tr>
				</tbody>
			</table>
			<br>
			<input type="submit" value="Save" class="savBtn">
		</form>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------->
<cfif action is "saveEdits">
	<cfoutput>
		<cfset agntOrdr=1>
		<cftransaction>
			<cfquery name="killall" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from
					collector
				where
					collection_object_id=#collection_object_id#
			</cfquery>
			<cfloop list="#ROWORDER#" index="i">
				<cfset thisID=replacenocase(i,'row_','','all')>
				<cfset thisName=evaluate("NAME_" & thisID)>
				<cfset thisAgentID=evaluate("AGENT_ID_" & thisID)>
				<cfset thisRole=evaluate("COLLECTOR_ROLE_" & thisID)>
				<cfset thisCollectorID=evaluate("COLLECTOR_ID_" & thisID)>
				<cfif len(thisAgentID) gt 0>
					<cfquery name="nc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into collector (
							collector_id,
							collection_object_id,
							agent_id,
							collector_role,
							coll_order
						) values (
							sq_collector_id.nextval,
							#collection_object_id#,
							#thisAgentID#,
							'#thisRole#',
							#agntOrdr#
						)
					</cfquery>
					<cfset agntOrdr=agntOrdr+1>
				</cfif>
			</cfloop>
		</cftransaction>
		<cflocation url="editColls.cfm?collection_object_id=#collection_object_id#" addtoken="false">
	</cfoutput>
</cfif>
------------->
<cf_customizeIFrame>