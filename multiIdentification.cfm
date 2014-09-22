<cfinclude template="/includes/_header.cfm">
<script language="JavaScript" type="text/javascript">
	jQuery(document).ready(function() {
		jQuery("#made_date").datepicker();
	});
</script>
<script type='text/javascript' src='/includes/_editIdentification.js'></script>
<!--------------------------------------------------------------------------------------------------->
<cfif Action is "nothing">
	<!--- edit IDs for a list of specimens passed in from specimenresults --->
	<!--- no security --->
	<cfset title = "Edit Identification">
	<cfquery name="ctnature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select nature_of_id from ctnature_of_id
	</cfquery>
	<cfquery name="ctFormula" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select taxa_formula from cttaxa_formula order by taxa_formula
	</cfquery>
	<cfquery name="raw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		 SELECT 
		 	flat.guid,
			concatSingleOtherId(flat.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
			flat.scientific_name,
			flat.higher_geog,
			specimen_part.part_name,
			container.container_type,
			container.barcode,
			parentcontainer.barcode parentbarcode,
			parentcontainer.container_type parenttype
		FROM 
			#session.SpecSrchTab#,
			flat,
			specimen_part,
			coll_obj_cont_hist,
			container part,
			container,
			container parentcontainer
		WHERE 
			#session.SpecSrchTab#.collection_object_id=flat.collection_object_id and
			flat.collection_object_id=specimen_part.derived_from_cat_item (+) and
			specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id (+) and
			coll_obj_cont_hist.container_id=part.container_id (+) and
			part.parent_container_id=container.container_id (+) and
			container.parent_container_id=parentcontainer.container_id (+)
		ORDER BY 
			flat.collection_object_id
	</cfquery>
	<cfquery name="specimenList" dbtype="query">
		select
			guid,
			CustomID,
			scientific_name,
			higher_geog
		from
			raw
		group by
			guid,
			CustomID,
			scientific_name,
			higher_geog
		order by
			guid
	</cfquery>
	<cfquery name="distPart" dbtype="query">
		select 
			part_name 
		from 
			raw
		where
			barcode is not null
		group by 
			part_name 
		order by 
			part_name
	</cfquery>
	<cfoutput>
		<table width="100%"><tr><td width="50%"><!--- left column ---->
			<h2>Add Identification for ALL Specimens listed below</h2>	
		    <form name="newID" method="post" action="multiIdentification.cfm">
		  		<input type="hidden" name="Action" value="createManyNew">
		    	<table>
		    		<tr>
						<td>
							<a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','id_formula')">ID Formula:</a>
						</td>
						<td>
							<cfif not isdefined("taxa_formula")>
								<cfset taxa_formula='A'>
							</cfif>
							<cfset thisForm = "#taxa_formula#">
							<select name="taxa_formula" id="taxa_formula" size="1" class="reqdClr" onchange="newIdFormula(this.value);">
								<cfloop query="ctFormula">
									<option 
										<cfif #thisForm# is "#ctFormula.taxa_formula#"> selected </cfif>value="#ctFormula.taxa_formula#">#taxa_formula#</option>
								</cfloop>
							</select>
						</td>
					</tr>     
		            <tr> 
		            	<td><div align="right">Taxon A:</div></td>
						<td>
							<input type="text" name="taxona" id="taxona" class="reqdClr" size="50" 
								onChange="taxaPick('taxona_id','taxona','newID',this.value); return false;"
								onKeyPress="return noenter(event);">
							<input type="hidden" name="taxona_id" id="taxona_id"> 
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
						<td><div align="right">Taxon B:</div></td>
						<td>
							<input type="text" name="taxonb" id="taxonb" class="reqdClr" size="50" 
								onChange="taxaPick('taxonb_id','taxonb','newID',this.value); return false;"
								onKeyPress="return noenter(event);">
							<input type="hidden" name="taxonb_id" id="taxonb_id">
						</td>
					</tr>
					<tr> 
						<td>
							<div align="right">
								<a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','id_by')">ID By:</a>
							</div>
						</td>
						<td>
							<input type="text" name="idBy" class="reqdClr" size="50" 
								onchange="getAgent('newIdById','idBy','newID',this.value); return false;"
						 		onkeypress="return noenter(event);"> 
							<input type="hidden" name="newIdById"> 
							<span class="infoLink" onclick="addNewIdBy('two');">more...</span>
						</td>
					</tr>
					<tr id="addNewIdBy_two" style="display:none;"> 
						<td>
							<div align="right">
								ID By:<span class="infoLink" onclick="clearNewIdBy('two');"> clear</span>	
							</div>
						</td>
						<td>
							<input type="text" name="idBy_two" id="idBy_two" class="reqdClr" size="50" 
								onchange="getAgent('newIdById_two','idBy_two','newID',this.value); return false;"
								onkeypress="return noenter(event);"> 
							<input type="hidden" name="newIdById_two" id="newIdById_two"> 
							<span class="infoLink" onclick="addNewIdBy('three');">more...</span>			
						</td>
					</tr>
					<tr id="addNewIdBy_three" style="display:none;"> 
						<td>
							<div align="right">
								ID By:<span class="infoLink" onclick="clearNewIdBy('three');"> clear</span>	
							</div>
						</td>
						<td>
							<input type="text" name="idBy_three" id="idBy_three" class="reqdClr" size="50" 
								onchange="getAgent('newIdById_three','idBy_three','newID',this.value); return false;"
								onkeypress="return noenter(event);"> 
							<input type="hidden" name="newIdById_three" id="newIdById_three"> 			
						</td>
					</tr>
					<tr> 
						<td>
							<div align="right">
								<a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','id_date')">ID Date:</a></td>
							</div>
						</td>
						<td><input type="text" name="made_date" id="made_date"></td>
					</tr>
					<tr> 
						<td>
							<div align="right">
								<a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','nature_of_id')"> Nature of ID:</a></td>
							</div>
						</td>
						<td>
							<select name="nature_of_id" size="1" class="reqdClr">
								<cfloop query="ctnature">
									<option  value="#ctnature.nature_of_id#">#ctnature.nature_of_id#</option>
								</cfloop>
							</select>
							<span class="infoLink" onClick="getCtDoc('ctnature_of_id',newID.nature_of_id.value)">define</span>
						</td>
					</tr>
					<tr> 
						<td><div align="right">Remarks:</div></td>
						<td><input type="text" name="identification_remarks" size="50"></td>
					</tr>
					<tr> 
						<td colspan="2">
							<div align="center"> 
								<input type="submit" value="Add Identification to all listed specimens" class="insBtn">	
							</div>
						</td>
					</tr>
				</table>
			</form>
		</td><!--- end left column ----><!---- start right column ----><td>
		<h2>
			Move Part Containers
		</h2>
		<p style="border:2px solid red; margin:1em;padding:1em;">
			<strong>Important note:</strong> 
			<br>This form will NOT install parts.
			<br>It will move the parent container of the part container.
			<br>That's usually the thing with a barcode, such as a NUNC tube. 
			<br>Use one of the many other container applications install parts.
			<br>
			<strong>Only moveable parts are listed in the table below.</strong>
		</p>
		<p>
			For every specimen in the table below, move part(s) of type....
			 <form name="newIDParts" method="post" action="multiIdentification.cfm">
	            <input type="hidden" name="action" value="moveParts">
				<label for="partsToMove">pick part(s) to move</label>
				<select name="partsToMove" size="10" multiple="multiple">
					<cfloop query="distPart">
						<option value="#part_name#">#part_name#</option>
					</cfloop>
				</select>
				<label for="newPartContainer">Move parts to container barcode</label>
				<input type="text" name="newPartContainer" id="newPartContainer">
				<br> <input type="submit" value="Move selected Parts for all listed specimens" class="savBtn">	
			</form>
			
		</p>
		</td></tr></table><!---- end header column table ---->	
		<h3>#specimenList.recordcount# Specimens Being Re-Identified:</h3>		
		*Changes can take a few minutes to show up in this table and in specimenresults.
		<table width="95%" border="1">
			<tr>
				<td><strong>GUID</strong></td>
				<td><strong><cfoutput>#session.CustomOtherIdentifier#</cfoutput></strong></td>
				<td><strong>Accepted Scientific Name</strong></td>
				<td><strong>Geography</strong></td>
				<td><strong>Part | container type | barcode | parentbarcode | parenttype</strong></td>
			</tr>
			 <cfloop query="specimenList">
				<cfquery name="p" dbtype="query">
					select
						part_name,
						container_type,
						barcode,
						parentbarcode,
						parenttype
					from
						raw
					where
						barcode is not null and 
						guid='#guid#'
				</cfquery>
				<cfif p.recordcount gt 0>
					<cfset pcnt=p.recordcount>
				<cfelse>
					<cfset pcnt=1>
				</cfif>
				<tr>
					<td><a href="/guid/#guid#">#guid#</a></td>
					<td>#CustomID#&nbsp;</td>
					<td><i>#Scientific_Name#</i></td>
					<td>#higher_geog#</td>
					<td>
						<table border width="100%">
							<cfloop query="p">
								<tr>
									<td width="20%">#part_name#</td>
									<td width="20%">#container_type#</td>
									<td width="20%">#barcode#</td>
									<td width="20%">#parentbarcode#</td>
									<td width="20%">#parenttype#</td>
								</tr>
							</cfloop>
						</table>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->

<!----------------------------------------------------------------------------------->
<cfif Action is "moveParts">

<cfoutput>
<!-----
	specimen
	part
	container (coll obj)             <---- this parent container ID is a shortcut to what we need to move
	container (with barcode)         <---- move this thing
	container (thing that holds the "part barcode"
	
------------->

	<cfquery name="scannedID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update 
			container 
		set 
			parent_container_id=(select container_id from container where barcode='#newPartContainer#')
		where 
			container_id in (
				select 
					part_container.parent_container_id
				from
					#session.SpecSrchTab#,
					specimen_part,
					coll_obj_cont_hist,
					container part_container
				WHERE 
					#session.SpecSrchTab#.collection_object_id=specimen_part.derived_from_cat_item and
					specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
					coll_obj_cont_hist.container_id=part_container.container_id and
					specimen_part.part_name in ( #ListQualify(partsToMove,"'")# )
			)
	</cfquery>
<cflocation url="multiIdentification.cfm" addtoken="no">

</cfoutput>
</cfif>		
<!------------------------------------

<cflocation url="multiIdentification.cfm" addtoken="no">
		<cfdump var=#scannedID#>




----------------------------------------------->
<cfif Action is "createManyNew">

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
<!--- looop through the collection_object_list and update things one at a time--->
			<cfquery name="theList" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select collection_object_id from #session.SpecSrchTab#
			</cfquery>
		

		
		
	<cftransaction>
		<cfloop query="theList">
		
		
		<cfquery name="upOldID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			UPDATE identification SET ACCEPTED_ID_FG=0 where collection_object_id = #collection_object_id#
		</cfquery>
		<cfquery name="newID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO identification (
				IDENTIFICATION_ID,
				COLLECTION_OBJECT_ID
				<cfif len(MADE_DATE) gt 0>
					,MADE_DATE
				</cfif>
				,NATURE_OF_ID
				 ,ACCEPTED_ID_FG
				 <cfif len(#IDENTIFICATION_REMARKS#) gt 0>
					,IDENTIFICATION_REMARKS
				</cfif>
				,taxa_formula
				,scientific_name)
			VALUES (
				sq_identification_id.nextval,
				#collection_object_id#
				<cfif len(#MADE_DATE#) gt 0>
					,'#MADE_DATE#'
				</cfif>
				,'#NATURE_OF_ID#'
				 ,1
				 <cfif len(#IDENTIFICATION_REMARKS#) gt 0>
					,'#stripQuotes(IDENTIFICATION_REMARKS)#'
				</cfif>
				,'#taxa_formula#'
				,'#scientific_name#')
			</cfquery>
			<cfquery name="newIdAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into identification_agent (
					identification_id,
					agent_id,
					identifier_order) 
				values (
					sq_identification_id.currval,
					#newIdById#,
					1
					)
			</cfquery>
			 <cfif len(#newIdById_two#) gt 0>
				<cfquery name="newIdAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into identification_agent (
						identification_id,
						agent_id,
						identifier_order) 
					values (
						sq_identification_id.currval,
						#newIdById_two#,
						2
						)
				</cfquery>
			 </cfif>
			 <cfif len(#newIdById_three#) gt 0>
				<cfquery name="newIdAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into identification_agent (
						identification_id,
						agent_id,
						identifier_order) 
					values (
						sq_identification_id.currval,
						#newIdById_three#,
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
</cfloop>
	</cftransaction>
		<cflocation url="multiIdentification.cfm" addtoken="no">

	<!----
	----->
	all done
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<cfinclude template="includes/_footer.cfm">