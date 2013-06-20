<cfinclude template="includes/_header.cfm">
<script type='text/javascript' src='/includes/_editIdentification.js'></script>
<script language="JavaScript" src="/includes/jquery/scrollTo.js" type="text/javascript"></script>
<script>
	function makeClone (guid){
		$("#guid").val(guid);
		getCatalogedItemCitation();
		$(document).scrollTo( $('#newRec'), 800 );
	}
	function deleteCitation(cid,pid){
		var yesno=confirm('This will not delete Citation-created Identifications. Do that from the specimen record. Proceed?');
		if (yesno==true) {
	  		document.location="Citation.cfm?action=deleCitation&citation_id=" + cid + "&publication_id=" + pid;
	 	} else {
		  	return false;
	  	}
	}
	jQuery(document).ready(function() {
		$("#made_date").datepicker();
		$("input[id^='made_date_']").each(function(){
			$("#" + this.id).datepicker();
		});
	});
	function getCatalogedItemCitation () {
		$("#foundSpecimen").html('<img src="/images/indicator.gif">');

		// GUID overrides everything
		if ($("#guid").val().length > 0) {
			$("#collection").val('');
			$("#cat_num").val('');
			$("#custom_id").val('');
		}
		// require something to run the query
		if ($("#guid").val().length == 0 && $("#cat_num").val().length == 0 && $("#custom_id").val().length == 0) {
			$("#foundSpecimen").html('[ find a specimen to continue ]');
			return false;
		}
		
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "getCatalogedItemCitation",
				collection_id : $("#collection").val(),
				cat_num : $("#cat_num").val(),
				custom_id : $("#custom_id").val(),
				guid : $("#guid").val(),
				returnformat : "json",
				queryformat : 'column'
			},
			success_getCatalogedItemCitation
		);
	}
	function success_getCatalogedItemCitation (r) {
		var result=r.DATA;
		if (result.COLLECTION_OBJECT_ID[0] < 0) {
			// error handling is packaged wonky
			alert('error: ' + result.SCIENTIFIC_NAME[0]);
			$("#foundSpecimen").html('error: ' + result.SCIENTIFIC_NAME[0]);
			return false;
		} else {
			var ltxt = 'Working with Specimen: <a target="_blank" href="/guid/' + result.GUID[0] + '">' + result.GUID[0] + ' - ' + result.SCIENTIFIC_NAME[0] + '</a>';
			if (result.CUSTOMIDTYPE[0] != null) {
				ltxt+=' - ' + result.CUSTOMIDTYPE[0] + ': ' + result.CUSTOMID[0];
			}
			ltxt+'<br>';
			$("#collection_object_id").val(result.COLLECTION_OBJECT_ID[0]);
			// default some possibly-useful stuff in
			$("#taxona").val(result.SCIENTIFIC_NAME[0]);
			$("#taxona_id").val(result.TAXON_NAME_ID[0]);
			$("#nature_of_id").val(result.NATURE_OF_ID[0]);
			$("#foundSpecimen").html(ltxt);
			ltxt='';
			for (i=0;i<r.ROWCOUNT;i++) {
				ltxt += '<ul><li>';
					ltxt += '<strong>' + result.SCIENTIFIC_NAME[i] + '</strong>';
				if (result.ACCEPTED_ID_FG[i]==1){
					ltxt += ' (accepted)';
				} else {
					ltxt += ' (unaccepted)';
				}
				ltxt += '<input type="button" class="insBtn" value="Create Citation with this Identification" onclick="createCitWithExistingID(' + result.IDENTIFICATION_ID[0] + ');">';
				ltxt += '<br>Nature of ID: ' + result.NATURE_OF_ID[i];
				ltxt += '<br>Identified By: ' + result.IDBY[i] + ' on ' + result.MADE_DATE[i];
				ltxt += '<br>ID <i>Sensu</i>: ' + result.SHORT_CITATION[i];
				ltxt += '<br>ID Remark: ' + result.IDENTIFICATION_REMARKS[i];
				ltxt += '</li></ul>'; 
			}
			$("#resulttext").html(ltxt);
		}
	}
	function createCitWithExistingID(IdId){
		if ($("#type_status").val().length==0){
			alert('pick a type status');
			return false;
		}
		if ($("#collection_object_id").val().length==0){
			alert('pick a specimen');
			return false;
		}
		newCitation.action.value='newCitationExistingID';
		$("#identification_id").val(IdId);
		newCitation.submit();
	}

	function createCitWithNewID(IdId){
		if ($("#type_status").val().length==0){
			alert('pick a type status');
			return false;
		}
		if ($("#collection_object_id").val().length==0){
			alert('pick a specimen');
			return false;
		}
		newCitation.action.value='newCitation';
		newCitation.submit();
	}
</script>
<!------------------------------------------------------------------------------->
<cfif action is "nothing">
	<script>
		jQuery(document).ready(function() {
			var ptl="/includes/forms/listExistingCitations.cfm?publication_id=" + $("#publication_id").val();
			jQuery.get(ptl, function(data){
				 jQuery('#theCitationsGoHere').html(data);
			})
		});	
	</script>
	<cfset title="Manage Citations">
	<cfoutput>
		<cfquery name="ctTypeStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select type_status from ctcitation_type_status order by type_status
		</cfquery>
		<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select collection_id,collection from collection order by collection
		</cfquery>
		<cfquery name="ctnature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select nature_of_id from ctnature_of_id order by nature_of_id
		</cfquery>
		<cfquery name="ctFormula" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select taxa_formula from cttaxa_formula order by taxa_formula
		</cfquery>
		<cfquery name="getPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				PUBLISHED_YEAR,
				full_citation
			FROM 
				publication
			WHERE
				publication_id = #publication_id#
		</cfquery>
		<cfquery name="auth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select 
				rownum r,
				preferred_agent_name.agent_id, 
				agent_name 
			from 
				preferred_agent_name, 
				publication_agent
			where 
				publication_agent.agent_id=preferred_agent_name.agent_id and
				publication_agent.publication_id = #publication_id#
		</cfquery>
		<style>
			.fieldgroup {
				display: inline-block;
				border:2px solid green;
			}
		</style>
		Citations for <b>#getPub.full_citation#</b>
		<br><span class="helpLink"  onClick="getDocs('publication','citation')">[ help ]</span>
		<a href="/Publication.cfm?publication_id=#publication_id#">[ Edit Publication ]</a>
		<a href="/SpecimenUsage.cfm?action=search&publication_id=#publication_id#">[ View Publication ]</a>
		Lots of citations? Try the <a href="/tools/BulkloadCitations.cfm">Citation Bulkloader</a>.
		<a name="newCitation"></a>
		<form name="newCitation" id="newCitation" method="post" action="Citation.cfm" onkeypress="return event.keyCode != 13;">
			<input type="hidden" name="action" value="">
			<input type="hidden" name="publication_id" id="publication_id" value="#publication_id#">
			<input type="hidden" name="identification_id" id="identification_id" value="">
			<input type="hidden" name="collection_object_id" id="collection_object_id">
			<div class="newRec" id="newRec">
				<h3>Add Citation and/or Identification</h3>
				<label for="theCitationDiv">Citation</label>
				<fieldset id="theCitationDiv" class="fieldgroup">
					<table>
						<tr>
							<td>
								<label for="type_status">
									<span class="likeLink" onClick="getDocs('publication','citation_type')">Citation Type</span>
									<span class="likeLink" onClick="getCtDoc('ctcitation_type_status',newCitation.type_status.value)">[ Define ]</span>
								</label>
								<select name="type_status" id="type_status" size="1" class="reqdClr">
									<option value=''></option>
									<cfloop query="ctTypeStatus">
										<option value="#ctTypeStatus.type_status#">#ctTypeStatus.type_status#</option>
									</cfloop>
								</select>
							</td>
							<td>
								<label class="likeLink" onClick="getDocs('publication','cited_on_page_number')" for="occurs_page_number">Page ##</label>
								<input type="text" name="occurs_page_number" id="occurs_page_number" size="4">
							</td>
							<td>
								<label for="citation_remarks">Citation Remarks:</label>
								<input type="text" name="citation_remarks" id="citation_remarks" size="90">
							</td>
						</tr>
					</table>
				</fieldset>
				<label for="theSpLkupDiv">Find Specimen</label>
				<fieldset id="theSpLkupDiv" class="fieldgroup">
					<label for="guid">GUID (UAM:Mamm:12 format; overrides any other identifiers)</label>
					<input type="text" name="guid" id="guid" onchange="getCatalogedItemCitation()">
					<table>
						<tr>
							<td>
								<label for="collection">Collection</label>
								<select name="collection" id="collection" size="1">
									<option value=""></option>
									<cfloop query="ctcollection">
										<option value="#collection_id#">#collection#</option>
									</cfloop>
								</select>
							</td>
							<td>
								<label for="cat_num">Catalog Number</label>
								<input type="text" name="cat_num" id="cat_num" onchange="getCatalogedItemCitation()">
							</td>
							<td>
								<cfif len(session.CustomOtherIdentifier) gt 0>
									<label for="custom_id">#session.CustomOtherIdentifier#</label>
									<input type="text" name="custom_id" id="custom_id" onchange="getCatalogedItemCitation(this.id,'#session.CustomOtherIdentifier#')">
								<cfelse>
									<input type="hidden" name="custom_id" id="custom_id">
								</cfif>
							</td>
						</tr>
					</table>
					<input type="button" class="schLink" onclick="getCatalogedItemCitation();" value="Find Specimen">
					<div id="foundSpecimen">[ find a specimen to continue ]</div>
				</fieldset>
				<label for="theSpLkupDiv">Identification</label>
				<fieldset id="theSpLkupDiv" class="fieldgroup">
					<table>
						<tr>
							<td class="valigntop">
								<label for="">Create new Identification</label>
								<fieldset id="newIDflg" class="fieldgroup">
									<label for="accepted_id_fg">Make this the accepted specimen ID?</label>
									<select name="accepted_id_fg" id="accepted_id_fg" size="1" class="reqdClr">
										<option value="0">no</option>
										<option value="1">yes</option>
									</select>
									<label for="taxa_formula"><span class="helpLink" id="taxa_formula">ID Formula:</span></label>
									<select name="taxa_formula" id="taxa_formula" size="1" class="reqdClr" onchange="newIdFormula(this.value);">
										<cfloop query="ctFormula">
											<option value="#ctFormula.taxa_formula#">#taxa_formula#</option>
										</cfloop>
									</select>
									<label for="taxona"><span class="helpLink" id="scientific_name">Taxon A:</span></label>
									<input type="text" name="taxona" id="taxona" class="reqdClr" size="50" 
										onChange="taxaPick('taxona_id','taxona','newCitation',this.value); return false;"
										onKeyPress="return noenter(event);">
									<input type="hidden" name="taxona_id" id="taxona_id" class="reqdClr">	
									<div id="userID" style="display:none;">
								    	<label for="user_id"><span class="helpLink" id="user_identification">Identification:</span></label>
										<input type="text" name="user_id" id="user_id" size="50">
									</div>
									<div id="taxon_b_row" style="display:none;">
										<label for="taxonb"><span class="helpLink" id="scientific_name">Taxon B:</span></label>
										<input type="text" name="taxonb" id="taxonb"  size="50" 
											onChange="taxaPick('taxonb_id','taxonb','newCitation',this.value); return false;"
											onKeyPress="return noenter(event);">
										<input type="hidden" name="taxonb_id" id="taxonb_id">
									</div>
									<cfquery name="a1" dbtype="query">
										select * from auth where r=1
									</cfquery>
									<cfquery name="a2" dbtype="query">
										select * from auth where r=2
									</cfquery>
									<cfquery name="a3" dbtype="query">
										select * from auth where r=3
									</cfquery>
									<label for="">ID <em>sensu</em> this publication?</label>
									<select name="use_id_sensu" id="use_id_sensu" size="1" class="reqdClr">
										<option value="true">yes</option>
										<option value="false">no</option>
									</select>
									<label for="usePublicationAuthors">Use Publication Authors & ignore any agent info below</label>
									<select name="usePublicationAuthors" id="usePublicationAuthors" size="1" class="reqdClr">
										<option value="0">no, use author info below</option>
										<option value="1">yes, ignore author info below</option>
									</select>
									<label for="newIdBy"><span class="helpLink" id="id_by">ID Agent 1 (save and edit for more agents)</span></label>
									<input type="text" name="newIdBy" id="newIdBy" class="reqdClr" size="50" value="#a1.agent_name#"
										onchange="getAgent('newIdBy_id',this.id,'newCitation',this.value);">
									<input type="hidden" name="newIdBy_id" id="newIdBy_id" class="reqdClr" value="#a1.agent_id#"> 
									<label for="newIdBy_two"><span class="helpLink" id="id_by">ID Agent 2</span></label>
									<input type="text" name="newIdBy_two" id="newIdBy_two" size="50"  value="#a2.agent_name#"
										onchange="getAgent('newIdBy_two_id',this.id,'newCitation',this.value);">
								    <input type="hidden" name="newIdBy_two_id" id="newIdBy_two_id" value="#a2.agent_id#"> 
									<label for="newIdBy_three"><span class="helpLink" id="id_by">ID Agent 3</span></label>
									<input type="text" name="newIdBy_three" id="newIdBy_three" size="50" value="#a3.agent_name#" 
										onchange="getAgent('newIdBy_three_id',this.id,'newCitation',this.value);">
								    <input type="hidden" name="newIdBy_three_id" id="newIdBy_three_id" value="#a3.agent_id#"> 	
									<label for="made_date"><span class="helpLink" id="identification.made_date">ID Date:</span></label>
									<input type="text" name="made_date" id="made_date" value='#getPub.PUBLISHED_YEAR#'>
									<label for="nature_of_id"><span class="helpLink" id="nature_of_id">Nature of ID</span></label>
									<select name="nature_of_id" id="nature_of_id" size="1" class="reqdClr">
										<cfloop query="ctnature">
										<option  value="#ctnature.nature_of_id#">#ctnature.nature_of_id#</option>
										</cfloop>
									</select>
									<span class="infoLink" onClick="getCtDoc('ctnature_of_id',newID.nature_of_id.value)">Define</span>
									<label for="identification_remarks"><span class="helpLink" id="identification_remarks">Remarks</span></label>
									<input type="text" name="identification_remarks" id="identification_remarks" size="50">
									<br><input type="button" onclick="createCitWithNewID();" id="newID_submit" value="Create Citation and Identification" class="insBtn">	
								</fieldset>
							</td>
							<td class="valigntop">
								<label for="theSpLkupDiv">Use an existing Identification</label>
								<fieldset id="theSpLkupDiv" class="fieldgroup">
									<div id="resulttext">[ Find a specimen ]</div>
								</fieldset>
							</td>
						</tr>
					</table>
				</fieldset>
			</div>
		</form>
		<!--- split the table out so it can be loaded asynchronously - see http://code.google.com/p/arctos/issues/detail?id=559 --->
		<p><strong>Existing Citations</strong></p>
		<div id="theCitationsGoHere"><img src="/images/indicator.gif"></div>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->

<cfif action is "newCitationExistingID">
	<cfoutput>
	 	<cfquery name="newCite" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO citation (
				publication_id,
				collection_object_id,
				cit_current_fg,
				identification_id			
				<cfif len(occurs_page_number) gt 0>
					,occurs_page_number
				</cfif>
				<cfif len(type_status) gt 0>
					,type_status
				</cfif>
				<cfif len(citation_remarks) gt 0>
					,citation_remarks
				</cfif>
			) VALUES (
				#publication_id#,
				#collection_object_id#,
				1,
				#identification_id#
				<cfif len(occurs_page_number) gt 0>
					,#occurs_page_number#
				</cfif>
				<cfif len(type_status) gt 0>
					,'#type_status#'
				</cfif>
				<cfif len(citation_remarks) gt 0>
					,'#escapeQuotes(citation_remarks)#'
				</cfif>
			) 
		</cfquery>
	<cflocation addtoken="false" url="Citation.cfm?publication_id=#publication_id###newCitation">
	</cfoutput>
</cfif>	
<!------------------------------------------------------------------------------->
<cfif action is "newCitation">		
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
		<cfif accepted_id_fg is 1>
			<cfquery name="upOldID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				UPDATE identification SET ACCEPTED_ID_FG=0 where collection_object_id = #collection_object_id#
			</cfquery>
		</cfif>
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
				#accepted_id_fg#,
				'#IDENTIFICATION_REMARKS#',
				'#taxa_formula#',
				'#scientific_name#',
				<cfif use_id_sensu is true>
					#publication_id#
				<cfelse>
					NULL
				</cfif>
			)
		</cfquery>
		<cfif isdefined("usePublicationAuthors") and usePublicationAuthors is true>
			<cfquery name="pa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select AGENT_ID from publication_agent where publication_id=#publication_id#
			</cfquery>
			<cfset ap=1>
			<cfloop query="pa">
				<cfquery name="newIdAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into identification_agent (
						identification_id,
						agent_id,
						identifier_order) 
					values (
						sq_identification_id.currval,
						#AGENT_ID#,
						#ap#
						)
				</cfquery>
				<cfset ap=ap+1>
			</cfloop>
		<cfelse>
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
			<cfif len(newIdBy_two_id) gt 0>
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
			<cfif len(newIdBy_three_id) gt 0>
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
		 <cfif taxa_formula contains "B">
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
		<cfquery name="newCite" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO citation (
				publication_id,
				collection_object_id,
				cit_current_fg,
				identification_id			
				<cfif len(#occurs_page_number#) gt 0>
					,occurs_page_number
				</cfif>
				<cfif len(#type_status#) gt 0>
					,type_status
				</cfif>
				<cfif len(#citation_remarks#) gt 0>
					,citation_remarks
				</cfif>
			) VALUES (
				#publication_id#,
				#collection_object_id#,
				1,
				sq_identification_id.currval
				<cfif len(#occurs_page_number#) gt 0>
					,#occurs_page_number#
				</cfif>
				<cfif len(#type_status#) gt 0>
					,'#type_status#'
				</cfif>
				<cfif len(#citation_remarks#) gt 0>
					,'#citation_remarks#'
				</cfif>
			) 
		</cfquery>
	</cftransaction>
	<cflocation addtoken="false" url="Citation.cfm?publication_id=#publication_id###newCitation">
</cfif>
<!------------------------------------------------------------------------------->
<cfif #Action# is "saveEdits">
	<cfoutput>
	<cfquery name="edCit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		UPDATE citation SET
			cit_current_fg = 1,
			identification_id = #identification_id#,
			type_status = '#type_status#',
			citation_remarks = '#citation_remarks#',
			occurs_page_number=
			<cfif len(occurs_page_number) gt 0>
				#occurs_page_number#
			  <cfelse>
			  	null
			</cfif>
		WHERE 
			citation_id = #citation_id#
		</cfquery>
		<cflocation addtoken="false" url="Citation.cfm?action=editCitation&citation_id=#citation_id###cid#citation_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif action is "editCitation">
	<cfset title="Edit Citations">
	<cfoutput>
		<cfquery name="getCited" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				citation.citation_id,
				citation.publication_id,
				citation.collection_object_id,
				cataloged_item.cat_num,
				collection.collection,
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
				citation.citation_id = #citation_id#
		</cfquery>
		<cfquery name="one" dbtype="query">
			select 	
				publication_id,
				collection_object_id,
				cat_num,
				collection,
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
				collection,
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
			select collection_id,collection from collection order by collection
		</cfquery>
		<cfquery name="ctnature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select nature_of_id from ctnature_of_id
		</cfquery>
		<cfquery name="ctFormula" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select taxa_formula from cttaxa_formula order by taxa_formula
		</cfquery>
		<br>Edit Citation for <strong><a target="_blank" href="/guid/#one.guid#">#one.collection# #one.cat_num#</a></strong> in 
		<b><a target="_blank" href="/publication/#one.publication_id#">#one.short_citation#</a></b>.
		<ul>
			<li>Edit <a target="_blank" href="/guid/#one.guid#">#one.collection# #one.cat_num#</a> in a new window</li>
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
<!------------------------------------------------------------------------------->
<cfif Action is "deleCitation">
<cfoutput>
	<cfquery name="deleCit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from citation where citation_id = #citation_id#
	</cfquery>
	<cflocation url="Citation.cfm?publication_id=#publication_id#">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfinclude template="includes/_footer.cfm">