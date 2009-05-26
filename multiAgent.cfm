<cfinclude template="/includes/_header.cfm">
	<script language="JavaScript" src="/includes/CalendarPopup.js" type="text/javascript"></script>
	<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
		var cal1 = new CalendarPopup("theCalendar");
		cal1.showYearNavigation();
		cal1.showYearNavigationInput();
	</SCRIPT>
	<SCRIPT LANGUAGE="JavaScript" type="text/javascript">document.write(getCalendarStyles());</SCRIPT>
<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "nothing">
<cfset title = "Edit Collectors">
<cfoutput> 
	<cfquery name="getColls" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
		 	cataloged_item.collection_object_id as collection_object_id, 
			cat_num,
			concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
			scientific_name,
			country,
			state_prov,
			county,
			quad,
			collection.collection,
			CONCATPREP(cataloged_item.collection_object_id) preps,
			concatColl(cataloged_item.collection_object_id) colls
		FROM 
			identification, 
			collecting_event,
			locality,
			geog_auth_rec,
			cataloged_item,
			collection,
			#session.SpecSrchTab#
		WHERE 
			locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id 
			AND collecting_event.locality_id = locality.locality_id 
			AND cataloged_item.collecting_event_id = collecting_event.collecting_event_id 
			AND cataloged_item.collection_object_id = identification.collection_object_id 
			and accepted_id_fg=1
			AND cataloged_item.collection_id = collection.collection_id
			AND cataloged_item.collection_object_id =#session.SpecSrchTab#.collection_object_id
		ORDER BY 
			cataloged_item.collection_object_id
	</cfquery>
	<h2>
		Add/Remove collectors for all specimens listed below
	</h2>
  <form name="newID" method="post" action="multiAgent.cfm">
            <input type="hidden" name="Action" value="createManyNew">
            <input type="hidden" name="collection_object_id" value="#collection_object_id#" >
    		
                    <input type="submit" value="Add Identification to all listed specimens" class="insBtn"
   onmouseover="this.className='insBtn btnhov';this.focus();" onmouseout="this.className='insBtn'">	


          
        </form>
		
		
  
<br><b>Specimens:</b>

<table border="1">
<tr>
	<td><strong>Catalog Number</strong></td>
	<td><strong>#session.CustomOtherIdentifier#</strong></td>
	<td><strong>Accepted Scientific Name</strong></td>
	<th>Collectors</th>
	<th>Preparators</th>
	<td><strong>Country</strong></td>
	<td><strong>State</strong></td>
	<td><strong>County</strong></td>
	<td><strong>Quad</strong></td>
</tr>
<cfloop query="getColls">
    <tr>
	  <td>
	  	#collection#&nbsp;#cat_num#
	  </td>
	<td>
		#CustomID#&nbsp;
	</td>
	<td><i>#Scientific_Name#</i></td>
	<td>#colls#</td>
	<td>#preps#</td>
	<td>#Country#&nbsp;</td>
	<td>#State_Prov#&nbsp;</td>
	<td>
		#county#&nbsp;
	</td>
	<td>
		#quad#&nbsp;
	</td>
</tr>
</cfloop>
</table>
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<!----------------------------------------------------------------------------------->
<cfif #Action# is "createManyNew">

<cfoutput>
<cfif #taxa_formula# is "A">
	<cfset scientific_name = "#taxa_a#">
<cfelseif #taxa_formula# is "A or B">
	<cfset scientific_name = "#taxa_a# or #taxa_b#">
<cfelseif #taxa_formula# is "A x B">
	<cfset scientific_name = "#taxa_a# x #taxa_b#">
<cfelseif #taxa_formula# is "A ?">
		<cfset scientific_name = "#taxa_a# ?">
<cfelseif #taxa_formula# is "A sp.">
		<cfset scientific_name = "#taxa_a# sp.">
<cfelseif #taxa_formula# is "A cf.">
	<cfset scientific_name = "#taxa_a# cf.">
<cfelseif #taxa_formula# is "A aff.">
	<cfset scientific_name = "#taxa_a# aff.">
<cfelseif #taxa_formula# is "A ssp.">
	<cfset scientific_name = "#taxa_a# ssp.">
<cfelseif #taxa_formula# is "A / B intergrade">
	<cfset scientific_name = "#taxa_a# / #taxa_b# intergrade.">
<cfelseif #taxa_formula# is "A and B">
	<cfset scientific_name = "#taxa_a# and #taxa_b#">
<cfelse>
	The taxa formula you entered isn't handled yet! Please submit a bug report.
	<cfabort>
</cfif>
<!--- looop through the collection_object_list and update things one at a time--->
	<cftransaction>
		<cfloop list="#collection_object_id#" index="i">
		<cfquery name="upOldID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE identification SET ACCEPTED_ID_FG=0 where collection_object_id = #i#
		</cfquery>
		<cfquery name="newID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO identification (
				IDENTIFICATION_ID,
				COLLECTION_OBJECT_ID
				<cfif len(#MADE_DATE#) gt 0>
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
				#i#
				<cfif len(#MADE_DATE#) gt 0>
					,'#dateformat(MADE_DATE,"dd-mmm-yyyy")#'
				</cfif>
				,'#NATURE_OF_ID#'
				 ,1
				 <cfif len(#IDENTIFICATION_REMARKS#) gt 0>
					,'#stripQuotes(IDENTIFICATION_REMARKS)#'
				</cfif>
				,'#taxa_formula#'
				,'#scientific_name#')
			</cfquery>
			<cfquery name="newIdAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
				<cfquery name="newIdAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
				<cfquery name="newIdAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			 <cfquery name="newId2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO identification_taxonomy (
					identification_id,
					taxon_name_id,
					variable)
				VALUES (
					sq_identification_id.currval,
					#TaxonAID#,
					'A')
			 </cfquery>
			 <cfif #taxa_formula# contains "B">
				 <cfquery name="newId3" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					INSERT INTO identification_taxonomy (
						identification_id,
						taxon_name_id,
						variable)
					VALUES (
						sq_identification_id.currval,
						#TaxonBID#,
						'B')
				 </cfquery>
			 </cfif>
</cfloop>
	</cftransaction>
	<cflocation url="multiIdentification.cfm?collection_object_id=#collection_object_id#" addtoken="no">
	
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
	<cfinclude template="includes/_footer.cfm">

<DIV ID="theCalendar" STYLE="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></DIV>