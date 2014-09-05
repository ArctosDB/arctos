<cfinclude template="/includes/_frameHeader.cfm">
<script type='text/javascript' src='/includes/_editIdentification.js'></script>
<script type='text/javascript' src='/includes/checkForm.js'></script>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		$("#made_date").datepicker();
		$("input[id^='made_date_']").each(function(){
			$("#" + this.id).datepicker();
		});
	});
</script>
<!----------------------------------------------------------------------------------->
<cfif action is "nothing">
<cfoutput>
<cfquery name="ctnature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select nature_of_id from ctnature_of_id
</cfquery>
<cfquery name="ctFormula" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select taxa_formula from cttaxa_formula order by taxa_formula
</cfquery>
<cfquery name="getID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	SELECT
		identification.identification_id,
		institution_acronym,
		identification.scientific_name,
		cat_num,
		cataloged_item.collection_cde,
		agent_name,
		identifier_order,
		identification_agent.agent_id,
		made_date,
		nature_of_id,
		accepted_id_fg,
		identification_remarks,
		identification_agent_id,
		short_citation,
		identification.publication_id
	FROM
		cataloged_item,
		identification,
		collection ,
		identification_agent,
		preferred_agent_name,
		publication
	WHERE
		identification.collection_object_id = cataloged_item.collection_object_id AND
		identification.identification_id = identification_agent.identification_id (+) AND
		identification_agent.agent_id = preferred_agent_name.agent_id (+) AND
		cataloged_item.collection_id=collection.collection_id AND
		identification.publication_id=publication.publication_id (+) and
		cataloged_item.collection_object_id = #collection_object_id#
		ORDER BY accepted_id_fg
	DESC
</cfquery>


<form name="newID" id="newID" method="post" action="editIdentification.cfm">

	<table class="newRec">
 <tr>
 	<td colspan="2">
<strong><font size="+1">Add new Determination</font></strong>&nbsp;
<a href="javascript:void(0);" onClick="getDocs('identification')"><img src="/images/info.gif" border="0"></a>
	</td>
 </tr>
    <input type="hidden" name="Action" value="createNew">
    <input type="hidden" name="collection_object_id" value="#collection_object_id#" >
    <tr>
		<td>
			<div class="helpLink" id="taxa_formula">ID Formula:</div>
		</td>
		<td>
			<cfif not isdefined("taxa_formula")>
				<cfset taxa_formula='A'>
			</cfif>
			<cfset thisForm = "#taxa_formula#">
			<select name="taxa_formula" id="taxa_formula" size="1" class="reqdClr"
				onchange="newIdFormula(this.value);">
					<cfloop query="ctFormula">
						<option
							<cfif #thisForm# is "#ctFormula.taxa_formula#"> selected </cfif>value="#ctFormula.taxa_formula#">#taxa_formula#</option>
					</cfloop>
			</select>
		</td>
	</tr>
	<tr>
    	<td>
			<div class="helpLink" id="scientific_name">Taxon A:</div>
		</td>
         <td>
		  	<input type="text" name="taxona" id="taxona" class="reqdClr" size="50"
				onChange="taxaPick('taxona_id','taxona','newID',this.value); return false;"
				onKeyPress="return noenter(event);">
			<input type="hidden" name="taxona_id" id="taxona_id" class="reqdClr">
		</td>
  	</tr>
	<tr id="userID" style="display:none;">
    	<td>
			<div class="helpLink" id="user_identification">Identification:</div>
		</td>
         <td>
		  	<input type="text" name="user_id" id="user_id" size="50">
		</td>
  	</tr>
	<tr id="taxon_b_row" style="display:none;">
    	<td>
			<div align="right">Taxon B:</div>
		</td>
        <td>
			<input type="text" name="taxonb" id="taxonb"  size="50"
				onChange="taxaPick('taxonb_id','taxonb','newID',this.value); return false;"
				onKeyPress="return noenter(event);">
			<input type="hidden" name="taxonb_id" id="taxonb_id">
		</td>
  	</tr>
    <tr>
    	<td>
			<div class="helpLink" id="id_by">ID By:</div>
		</td>
        <td>
			<input type="text" name="newIdBy" id="newIdBy" class="reqdClr" size="50"
				onchange="getAgent('newIdBy_id',this.id,'newID',this.value);">
            <input type="hidden" name="newIdBy_id" id="newIdBy_id" class="reqdClr">
			<span class="infoLink" onclick="addNewIdBy('two');">more...</span>
		</td>
	</tr>
	<tr id="addNewIdBy_two" style="display:none;">
    	<td>
			<div align="right">
				ID By:<span class="infoLink" onclick="clearNewIdBy('two');"> remove</span>
			</div>
		</td>
        <td>
			<input type="text" name="newIdBy_two" id="newIdBy_two" size="50"
				onchange="getAgent('newIdBy_two_id',this.id,'newID',this.value);">
            <input type="hidden" name="newIdBy_two_id" id="newIdBy_two_id">
			<span class="infoLink" onclick="addNewIdBy('three');">more...</span>
		 </td>
	</tr>
    <tr id="addNewIdBy_three" style="display:none;">
    	<td>
			<div align="right">
				ID By:<span class="infoLink" onclick="clearNewIdBy('three');"> remove</span>
			</div>
		</td>
        <td>
			<input type="text" name="newIdBy_three" id="newIdBy_three" size="50"
				onchange="getAgent('newIdBy_three_id',this.id,'newID',this.value);">
            <input type="hidden" name="newIdBy_three_id" id="newIdBy_three_id">
		 </td>
    </tr>
    <tr>
    	<td>
			<div class="helpLink" id="identification.made_date">ID Date:</div>
		</td>
        <td>
			<input type="text" name="made_date" id="made_date">
		</td>
	</tr>
    <tr>
    	<td>
			<div class="helpLink" id="nature_of_id">Nature of ID</div>
		</td>
		<td>
			<select name="nature_of_id" id="nature_of_id" size="1" class="reqdClr">
            	<cfloop query="ctnature">
                	<option  value="#ctnature.nature_of_id#">#ctnature.nature_of_id#</option>
                </cfloop>
            </select>
			<span class="infoLink" onClick="getCtDoc('ctnature_of_id',newID.nature_of_id.value)">Define</span>
		</td>
	</tr>
    <tr>
    	<td>
			<div class="helpLink" id="identification_publication">Sensu:</div>
		</td>
		<td>
			<input type="hidden" name="new_publication_id" id="new_publication_id">
			<input type="text" id="newPub" onchange="getPublication(this.id,'new_publication_id',this.value,'newID')" size="50">
		</td>
	</tr>
    <tr>
    	<td>
			<div class="helpLink" id="identification_remarks">Remarks:</div>
		</td>
        <td>
			<input type="text" name="identification_remarks" id="identification_remarks" size="50">
		</td>
    </tr>
    <tr>
		<td colspan="2">
			<div align="center">
            	<input type="submit" id="newID_submit" value="Create" class="insBtn reqdClr" title="Create Identification">
             </div>
		</td>
    </tr>
	</table>
</form>

<strong><font size="+1">Edit an Existing Determination</font></strong>
<img src="/images/info.gif" border="0" onClick="getDocs('identification')" class="likeLink">
<cfset i = 1>
<cfquery name="distIds" dbtype="query">
	SELECT
		identification_id,
		institution_acronym,
		scientific_name,
		cat_num,
		collection_cde,
		made_date,
		nature_of_id,
		accepted_id_fg,
		identification_remarks,
		short_citation,
		publication_id
	FROM
		getID
	GROUP BY
		identification_id,
		institution_acronym,
		scientific_name,
		cat_num,
		collection_cde,
		made_date,
		nature_of_id,
		accepted_id_fg,
		identification_remarks,
		short_citation,
		publication_id
	ORDER BY
		accepted_id_fg DESC,
		made_date
</cfquery>
<form name="editIdentification" id="editIdentification" method="post" action="editIdentification.cfm">
    <input type="hidden" name="Action" value="saveEdits">
    <input type="hidden" name="collection_object_id" value="#collection_object_id#" >
	<input type="hidden" name="number_of_ids" id="number_of_ids" value="#distIds.recordcount#">
<table border>
<cfloop query="distIds">
	<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#><td>
	<cfquery name="identifiers" dbtype="query">
		select
			agent_name,
			identifier_order,
			agent_id,
			identification_agent_id
		FROM
			getID
		WHERE
			identification_id=#identification_id#
		group by
			agent_name,
			identifier_order,
			agent_id,
			identification_agent_id
		ORDER BY
			identifier_order
	</cfquery>
	<cfset thisIdentification_id = #identification_id#>
	<input type="hidden" name="identification_id_#i#" id="identification_id_#i#" value="#identification_id#">
	<input type="hidden" name="number_of_identifiers_#i#" id="number_of_identifiers_#i#"
			value="#identifiers.recordcount#">
	<table id="mainTable_#i#">
    	<tr>
        	<td><div align="right">Scientific Name:</div></td>
            <td><b><i>#scientific_name#</i></b>
			</td>
        </tr>
        <tr>
        	<td><div align="right">Accepted?</div></td>
			<td>
				<cfif #accepted_id_fg# is 0>
					<select name="accepted_id_fg_#i#"
						id="accepted_id_fg_#i#" size="1"
						class="reqdClr" onchange="flippedAccepted('#i#')">
						<option value="1"
							<cfif #ACCEPTED_ID_FG# is 1> selected </cfif>>yes</option>
                    	<option
							<cfif #accepted_id_fg# is 0> selected </cfif>value="0">no</option>
						<cfif #ACCEPTED_ID_FG# is 0>
							<option value="DELETE">DELETE</option>
						</cfif>
                  	</select>
					<cfif #ACCEPTED_ID_FG# is 0>
						<span class="infoLink red" onclick="document.getElementById('accepted_id_fg_#i#').value='DELETE';flippedAccepted('#i#');">Delete</span>
					</cfif>
				<cfelse>
					<input name="accepted_id_fg_#i#" id="accepted_id_fg_#i#" type="hidden" value="1">
					<b>Yes</b>
				</cfif>
			</td>
       	</tr>
        <tr>
			<td colspan="2">
				<table id="identifierTable_#i#">
					<tbody id="identifierTableBody_#i#">
						<cfset idnum=1>
						<cfloop query="identifiers">
							<tr id="IdTr_#i#_#idnum#">
								<td>Identified By:</td>
								<td>
									<input type="text"
										name="IdBy_#i#_#idnum#"
										id="IdBy_#i#_#idnum#"
										value="#agent_name#"
										class="reqdClr"
										size="50"
										onchange="getAgent('IdBy_#i#_#idnum#_id',this.id,'editIdentification',this.value);">
									<input type="hidden"
										name="IdBy_#i#_#idnum#_id"
										id="IdBy_#i#_#idnum#_id" value="#agent_id#"
										class="reqdClr">
									<input type="hidden" name="identification_agent_id_#i#_#idnum#" id="identification_agent_id_#i#_#idnum#"
										value="#identification_agent_id#">
									<cfif #idnum# gt 1>
										<img src="/images/del.gif" class="likeLink"
											onclick="removeIdentifier('#i#','#idnum#')" />
									</cfif>
				 				</td>
				 			</tr>
							<cfset idnum=idnum+1>
						</cfloop>
					</tbody>
				</table>
			</td>
		</tr>
        <tr>
			<td>
				<span class="infoLink" id="addIdentifier_#i#"
					onclick="addIdentifier('#i#','#idnum#')">Add Identifier</span>
			</td>
		</tr>
		<tr>
        	<td>
				<div class="helpLink" id="identification.made_date">ID Date:</div>
			</td>
            <td>
				<input type="text" value="#made_date#" name="made_date_#i#" id="made_date_#i#">
           </td>
		</tr>
        <tr>
	        <td>
				<div class="helpLink" id="nature_of_id">Nature of ID:</div>
			</td>
	        <td>
				<cfset thisID = #nature_of_id#>
				<select name="nature_of_id_#i#" id="nature_of_id_#i#" size="1" class="reqdClr">
	            	<cfloop query="ctnature">
	                	<option <cfif #ctnature.nature_of_id# is #thisID#> selected </cfif> value="#ctnature.nature_of_id#">#ctnature.nature_of_id#</option>
	                </cfloop>
	           	</select>
				<span class="infoLink" onClick="getCtDoc('ctnature_of_id',newID.nature_of_id.value)">Define</span>
			</td>
        </tr>
        <tr>
	        <td>
				<div class="helpLink" id="identification_publication">Sensu:</div>
			</td>
	        <td>
				<input type="hidden" name="publication_id_#i#" id="publication_id_#i#" value="#publication_id#">
				<input type="text"
					id="publication_#i#"
					value='#short_citation#'
					onchange="getPublication(this.id,'publication_id_#i#',this.value,'editIdentification')" size="50">
				<span class="infoLink" onclick="$('##publication_id_#i#').val('');$('##publication_#i#').val('');">Remove</span>

			</td>
        </tr>
        <tr>
          	<td><div align="right">Remarks:</div></td>
         	 <td>
				<input type="text" name="identification_remarks_#i#" id="identification_remarks_#i#"
					value="#stripQuotes(identification_remarks)#" size="50">
			</td>
        </tr>
	</table>
  <cfset i = #i#+1>
</td></tr>
</cfloop>
<tr>
	<td>
		<input type="submit" class="savBtn" id="editIdentification_submit" value="Save Changes" title="Save Changes">
	</td>
</tr>
</table>
</form>
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<cfif #action# is "saveEdits">
<cfoutput>
	<cftransaction>
		<cfloop from="1" to="#NUMBER_OF_IDS#" index="n">
			<cfset thisAcceptedIdFg = #evaluate("ACCEPTED_ID_FG_" & n)#>
			<cfset thisIdentificationId = #evaluate("IDENTIFICATION_ID_" & n)#>
			<cfset thisIdRemark = #evaluate("IDENTIFICATION_REMARKS_" & n)#>
			<cfset thisMadeDate = #evaluate("MADE_DATE_" & n)#>
			<cfset thisNature = #evaluate("NATURE_OF_ID_" & n)#>
			<cfset thisNumIds = #evaluate("NUMBER_OF_IDENTIFIERS_" & n)#>
			<cfset thisPubId = #evaluate("publication_id_" & n)#>

			<cfif thisAcceptedIdFg is 1>
				<cfquery name="upOldID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					UPDATE identification SET ACCEPTED_ID_FG=0 where collection_object_id = #collection_object_id#
				</cfquery>
				<cfquery name="newAcceptedId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					UPDATE identification SET ACCEPTED_ID_FG=1 where identification_id = #thisIdentificationId#
				</cfquery>
			</cfif>
			<cfif thisAcceptedIdFg is "DELETE">
					<cfquery name="deleteId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						DELETE FROM identification_agent WHERE identification_id = #thisIdentificationId#
					</cfquery>
					<cfquery name="deleteTId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						DELETE FROM identification_taxonomy WHERE identification_id = #thisIdentificationId#
					</cfquery>
					<cfquery name="deleteId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						DELETE FROM identification WHERE identification_id = #thisIdentificationId#
					</cfquery>

			<cfelse>
				<cfquery name="updateId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						UPDATE identification SET
						nature_of_id = '#thisNature#',
						made_date = '#thisMadeDate#',
						identification_remarks = '#escapeQuotes(thisIdRemark)#'
						<cfif len(thisPubId) gt 0>
							,publication_id = #thisPubId#
						<cfelse>
							,publication_id = NULL
						</cfif>
					where identification_id=#thisIdentificationId#
				</cfquery>

				<cfloop from="1" to="#thisNumIds#" index="nid">
					<cftry>
						<!--- couter does not increment backwards - may be a few empty loops in here ---->
						<cfset thisIdId = evaluate("IdBy_" & n & "_" & nid & "_id")>
						<cfcatch>
							<cfset thisIdId =-1>
						</cfcatch>
					</cftry>
					<cftry>
						<cfset thisIdAgntId = evaluate("identification_agent_id_" & n & "_" & nid)>
						<cfcatch>
							<cfset thisIdAgntId=-1>
						</cfcatch>
					</cftry>
					<cfif #thisIdAgntId# is -1 and (thisIdId is not "DELETE" and thisIdId gte 0)>
						<!--- new identifier --->
						<cfquery name="updateIdA" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							insert into identification_agent
								( IDENTIFICATION_ID,AGENT_ID,IDENTIFIER_ORDER)
							values
								(
									#thisIdentificationId#,
									#thisIdId#,
									#nid#
								)
						</cfquery>
					<cfelse>
						<!--- update or delete --->
						<cfif #thisIdId# is "DELETE">
							<!--- delete --->
							<cfquery name="updateIdA" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								delete from identification_agent
								where identification_agent_id=#thisIdAgntId#
							</cfquery>
						<cfelseif thisIdId gte 0>
							<!--- update --->
							<cfquery name="updateIdA" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								update identification_agent set
									agent_id=#thisIdId#,
									identifier_order=#nid#
								 where
								 	identification_agent_id=#thisIdAgntId#
							</cfquery>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
	</cftransaction>
	<cflocation url="editIdentification.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------->
<cfif #Action# is "deleteIdent">
	<cfif #accepted_id_fg# is "1">
		<font color="#FF0000" size="+1">You can't delete the accepted identification!</font>
		<cfabort>
    </cfif>
	<cflocation url="editIdentification.cfm?collection_object_id=#collection_object_id#">
</cfif>
<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "multi">
<cfoutput>
	<cflocation url="multiIdentification.cfm?collection_object_id=#collection_object_id#" addtoken="false">
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<cfif action is "createNew">
<cfoutput>
<cfif taxa_formula is "A {string}">
	<cfset scientific_name = user_id>
<cfelseif taxa_formula is "A">
	<cfset scientific_name = taxona>
<cfelseif taxa_formula is "A or B">
	<cfset scientific_name = "#taxona# or #taxonb#">
<cfelseif taxa_formula is "A and B">
	<cfset scientific_name = "#taxona# and #taxonb#">
<cfelseif taxa_formula is "A x B">
	<cfset scientific_name = "#taxona# x #taxonb#">
<cfelseif taxa_formula is "A ?">
	<cfset scientific_name = "#taxona# ?">
<cfelseif taxa_formula is "A sp.">
	<cfset scientific_name = "#taxona# sp.">
<cfelseif taxa_formula is "A ssp.">
	<cfset scientific_name = "#taxona# ssp.">
<cfelseif taxa_formula is "A cf.">
	<cfset scientific_name = "#taxona# cf.">
<cfelseif taxa_formula is "A aff.">
	<cfset scientific_name = "#taxona# aff.">
<cfelseif taxa_formula is "A / B intergrade">
	<cfset scientific_name = "#taxona# / #taxonb# intergrade">
<cfelse>
	The taxa formula you entered isn't handled yet! Please submit a bug report.
	<cfabort>
</cfif>
<cftransaction>
	<cfquery name="upOldID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		UPDATE identification SET ACCEPTED_ID_FG=0 where collection_object_id = #collection_object_id#
	</cfquery>
	<cfquery name="newID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO identification (
			IDENTIFICATION_ID,
			COLLECTION_OBJECT_ID,
			MADE_DATE,
			NATURE_OF_ID,
			ACCEPTED_ID_FG,
			IDENTIFICATION_REMARKS,
			taxa_formula,
			scientific_name,
			publication_id
		) VALUES (
			sq_identification_id.nextval,
			#COLLECTION_OBJECT_ID#,
			'#MADE_DATE#',
			'#NATURE_OF_ID#',
			1,
			'#IDENTIFICATION_REMARKS#',
			'#taxa_formula#',
			'#scientific_name#',
			 <cfif len(new_publication_id) gt 0>
				#new_publication_id#
			<cfelse>
				NULL
			</cfif>
		)
	</cfquery>
	<cfquery name="newIdAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into identification_agent (
			identification_id,
			agent_id,
			identifier_order)
		values (
			sq_identification_id.currval,
			#newIdBy_id#,
			1
			)
	</cfquery>
	<cfif len(#newIdBy_two_id#) gt 0>
		<cfquery name="newIdAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into identification_agent (
				identification_id,
				agent_id,
				identifier_order)
			values (
				sq_identification_id.currval,
				#newIdBy_two_id#,
				2
				)
		</cfquery>
	</cfif>
	<cfif len(#newIdBy_three_id#) gt 0>
		<cfquery name="newIdAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into identification_agent (
				identification_id,
				agent_id,
				identifier_order)
			values (
				sq_identification_id.currval,
				#newIdBy_three_id#,
				3
				)
		</cfquery>
	</cfif>
	<cfquery name="newId2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO identification_taxonomy (
			identification_id,
			taxon_name_id,
			variable)
		VALUES (
			sq_identification_id.currval,
			#taxona_id#,
			'A')
	 </cfquery>
	 <cfif #taxa_formula# contains "B">
		 <cfquery name="newId3" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO identification_taxonomy (
				identification_id,
				taxon_name_id,
				variable)
			VALUES (
				sq_identification_id.currval,
				#taxonb_id#,
				'B')
		 </cfquery>
	 </cfif>
</cftransaction>
	<cflocation url="editIdentification.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<cfinclude template="includes/_pickFooter.cfm">
<cf_customizeIFrame>