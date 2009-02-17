<cfinclude template="/includes/_header.cfm">
<cfset title="Agent Merge">
<cfif #action# is "nothing">

<!--- first, make VERY SURE this is doing what we want it to - make users read the list before pushing the button! ---->

<cfquery name="bads" datasource="uam_god">
	select 
		agent_relations.agent_id,
		badname.agent_name bad_name,
		related_agent_id,
		goodname.agent_name good_name
	from
		agent_relations,
		preferred_agent_name badname,
		preferred_agent_name goodname		
	where 
		agent_relationship = 'bad duplicate of'
		AND agent_relations.agent_id = badname.agent_id and
		agent_relations.related_agent_id = goodname.agent_id
</cfquery>
<table border>
	<tr>
		<td>
			Bad Name
		</td>
		<td>Good Name</td>
	</tr>
	<cfoutput>
		<cfloop query="bads">
			<tr>
				<td>
					<a href="/agents.cfm?agent_id=#bads.agent_id#">#bad_name#</a>
					
				</td>
				<td>
				<a href="/agents.cfm?agent_id=#bads.related_agent_id#">#good_name#</a>
				</td>
			</tr>
			
		</cfloop>
	</cfoutput>
</table>
Before you even THINK about pushing this button, read through the list above, look at the individual 
agent records for anything that's even a little bit ambiguous, then do it again. You will be changing 
agent IDs in a big pile-O-tables; make sure you really want to first!
<form name="go" method="post" action="killBadAgentDups.cfm">
	<input type="hidden" name="action" value="doIt">
	<input type="submit" 
					 	value="Make the Changes" 
						class="savBtn"
   						onmouseover="this.className='savBtn btnhov'" 
						onmouseout="this.className='savBtn'">
</form>
</cfif>
<cfif #action# is "doIt">
<cfoutput>
<cfquery name="bads" datasource="uam_god">
	select 
		agent_id,
		related_agent_id
	from
		agent_relations
	where 
		agent_relationship = 'bad duplicate of'
</cfquery>

<cfloop query="bads">
---#agent_id#-----#related_agent_id#----
<cfflush>
<!---------- have to disable triggers outside the transaction ------------------>
<cfquery name="disableTrig" datasource="uam_god">
	alter trigger DEL_AGENT_NAME disable
</cfquery>
<cftransaction>
<hr>
<cfset nogo="false">
<cfquery name="name" datasource="uam_god">
	select agent_name_id FROM agent_name where agent_id=#bads.agent_id#
</cfquery>
<cfset names="">
<cfloop query="name">
	<cfif len(#names#) is 0>
		<cfset names=#agent_name_id#>
	<cfelse>
		<cfset names="#names#,#agent_name_id#">
	</cfif>
</cfloop>
<cfif len(#names#) is 0>
	There are no names for <a href="/agents.cfm?agent_id=#bads.agent_id#">Agent ID #bads.agent_id#</a>. It's probably a bad earlier deletion. Add a (fake) name and try again.
	<cfset nogo = "true">
</cfif>
<!--- see if we have a good replacement ---->
<cfquery name="isGoodRelated" datasource="uam_god">
	select agent_type 
	from agent where agent_id=#bads.related_agent_id#
</cfquery>
<cfif #isGoodRelated.recordcount# neq 1>
	<br><a href="/agents.cfm?agent_id=#bads.related_agent_id#">Agent ID #bads.related_agent_id#</a> isn't a viable replacement for  #bads.agent_id#.
	<cfset nogo = "true">
</cfif>
<!---- see if the bad has agent_name anywhere. We can't deal with that here ---->
<cfquery name="project_agent" datasource="uam_god">
	select count(*) cnt from project_agent where agent_name_id IN (#names#)
</cfquery>
<cfif #project_agent.cnt# gt 0>
	<br>Agent ID #bads.agent_id# is a project agent. I can't deal with that here.
	<cfset nogo = "true">
</cfif>
<cfquery name="publication_author_name" datasource="uam_god">
	select count(*) cnt from publication_author_name where agent_name_id IN (#names#)
</cfquery>
<cfif #publication_author_name.cnt# gt 0>
	<br><a href="/agents.cfm?agent_id=#bads.agent_id#">Agent ID #bads.agent_id#</a> is a publication agent. I can't deal with that here.
	<cfset nogo = "true">
</cfif>
<!--- relationship things that we don't care about:
	related_agent_id = bads.related_agent_id AND agent_id = bads.agent_id AND agent_relationship = 'bad duplicate of'
		-- how we got here in the first place
	related_agent_id = bads.agent_id AND agent_id = bads.related_agent_id AND agent_relationship = 'good duplicate of'
		-- reciprocal of how we got here
---->		
<cfquery name="agent_relations" datasource="uam_god">
	select count(*) cnt from agent_relations where 
		(agent_id=#bads.agent_id# OR related_agent_id = #bads.agent_id#)
		AND NOT (
		(related_agent_id = #bads.related_agent_id# AND agent_id = #bads.agent_id# AND agent_relationship = 'bad duplicate of')
		OR (related_agent_id = #bads.agent_id# AND agent_id = #bads.related_agent_id# AND agent_relationship = 'good duplicate of')
		)
</cfquery>
<cfif #agent_relations.cnt# gt 0>
	<br><a href="/agents.cfm?agent_id=#bads.agent_id#">Agent ID #bads.agent_id#</a> is involved in relationships. I can't deal with that here.
	<br><a href="/agents.cfm?agent_id=#bads.related_agent_id#">Agent ID #bads.related_agent_id# (good agent)</a>
	<cfquery name="relAgent" datasource="uam_god">
		select * from agent_relations where agent_relationship <> 'bad duplicate of'
		and (agent_id=#bads.agent_id# OR related_agent_id=#bads.agent_id#)
	</cfquery>
	<br />Relationships:
	<table border>
		<tr>
			<td>ID</td>
			<td>Related ID</td>
			<td>Relationship</td>
		</tr>
	<cfloop query="relAgent">
	<tr>
			<td><a href="/agents.cfm?agent_id=#agent_id#">#agent_id# </a></td>
			<td><a href="/agents.cfm?agent_id=#related_agent_id#">#related_agent_id#</a></td>
			<td>#agent_relationship#</td>
		</tr>
		
		 
	
	</cfloop>
	</table>
	
	<cfset nogo = "true">
</cfif>
<cfquery name="addr" datasource="uam_god">
	select count(*) cnt from addr where agent_id=#bads.agent_id#
</cfquery>
<cfif #addr.cnt# gt 0>
	<br><a href="/agents.cfm?agent_id=#bads.agent_id#">Agent ID #bads.agent_id#</a> has addresses. I can't deal with that here.
	<cfset nogo = "true">
</cfif>

<cfquery name="electronic_address" datasource="uam_god">
	select count(*) cnt from electronic_address where agent_id=#bads.agent_id#
</cfquery>
<cfif #electronic_address.cnt# gt 0>
	<br>
	<a href="/agents.cfm?agent_id=#bads.agent_id#">Agent ID #bads.agent_id#</a>
	 has electronic addresses. I can't deal with that here.
	<cfset nogo = "true">
</cfif>


<cfif #nogo# is "false">
<br>going--
<br>good id: #bads.related_agent_id#
<br>bad id: #bads.agent_id#
<cfflush>
	<!---- names not used anywhere, go ahead and make necessary switches ---->
	
	<cfquery name="collector" datasource="uam_god">
		UPDATE collector SET agent_id = #bads.related_agent_id#
		WHERE agent_id = #bads.agent_id#
	</cfquery>
	got collector<br><cfflush>
	<cfquery name="attributes" datasource="uam_god">
		update attributes SET determined_by_agent_id=#bads.related_agent_id#
		where determined_by_agent_id = #bads.agent_id#
	</cfquery>
	got attributes<br><cfflush>
	<cfquery name="mediarc" datasource="uam_god">
		UPDATE 
		media_relations SET CREATED_BY_AGENT_ID=#bads.related_agent_id#
		where CREATED_BY_AGENT_ID=#bads.agent_id#
	</cfquery>
	got media 1<br><cfflush>
	<cfquery name="mediard" datasource="uam_god">
		UPDATE 
			media_relations 
		SET RELATED_PRIMARY_KEY=#bads.related_agent_id#
		where RELATED_PRIMARY_KEY=#bads.agent_id# and
		upper(SUBSTR(media_relationship,instr(media_relationship,' ',-1)+1))='AGENT'
	</cfquery>
	got media 2<br><cfflush>
	<cfquery name="medialbl" datasource="uam_god">
		UPDATE 
			media_labels 
		SET ASSIGNED_BY_AGENT_ID=#bads.related_agent_id#
		where ASSIGNED_BY_AGENT_ID=#bads.agent_id# 
	</cfquery>
	got media label<br><cfflush>
	<cfquery name="encumbrance" datasource="uam_god">
		UPDATE encumbrance SET encumbering_agent_id = #bads.related_agent_id#
		where encumbering_agent_id = #bads.agent_id#
	</cfquery>
	got encumbrance<br><cfflush>
	<cfquery name="identification_agent" datasource="uam_god">
		update identification_agent set
		agent_id = #bads.related_agent_id#
		where agent_id = #bads.agent_id#
	</cfquery>
	got ID agnt<br><cfflush>
	<cfquery name="lat_long" datasource="uam_god">
		update
		lat_long set 
		determined_by_agent_id = #bads.related_agent_id# where
		determined_by_agent_id = #bads.agent_id#
	</cfquery>
	got latlong<br><cfflush>
		
	<cfquery name="permit_to" datasource="uam_god">
		update permit set
			ISSUED_TO_AGENT_ID = #bads.related_agent_id# where
			ISSUED_TO_AGENT_ID = #bads.agent_id#
	</cfquery>
	update trans_agent set
			AGENT_ID = #bads.related_agent_id# where
			AGENT_ID = #bads.agent_id#killagent<CFFLUSH>
	<cfquery name="trans_agent" datasource="uam_god">
		update trans_agent set
			AGENT_ID = #bads.related_agent_id# where
			AGENT_ID = #bads.agent_id#
	</cfquery>
	got tagent<br><cfflush>
	<cfquery name="permit_by" datasource="uam_god">
		update permit set
			ISSUED_by_AGENT_ID = #bads.related_agent_id# where
			ISSUED_by_AGENT_ID = #bads.agent_id#
	</cfquery>
	got permit<br><cfflush>
	<cfquery name="shipment" datasource="uam_god">
		update shipment set 
		PACKED_BY_AGENT_ID = #bads.related_agent_id# where
		PACKED_BY_AGENT_ID = #bads.agent_id#
	</cfquery>
	got shipment<br><cfflush>
	<cfquery name="entered" datasource="uam_god">
		update coll_object set
		ENTERED_PERSON_ID = #bads.related_agent_id# where
		ENTERED_PERSON_ID = #bads.agent_id#
	</cfquery>
	got collobject<br><cfflush>
	<cfquery name="last_edit" datasource="uam_god">
		update coll_object set
		LAST_EDITED_PERSON_ID = #bads.related_agent_id# where
		LAST_EDITED_PERSON_ID = #bads.agent_id#
	</cfquery>
	got collobjed<br><cfflush>
	<cfquery name="loan_item" datasource="uam_god">
		update loan_item set
		RECONCILED_BY_PERSON_ID = #bads.related_agent_id# where
		RECONCILED_BY_PERSON_ID = #bads.agent_id#
	</cfquery>
	
	<cfquery name="media_relations" datasource="uam_god">
		update media_relations set
		RELATED_PRIMARY_KEY = #bads.related_agent_id# where
		RELATED_PRIMARY_KEY = #bads.agent_id# and
		MEDIA_RELATIONSHIP like '% agent'
	</cfquery>
	<cfquery name="media_relations_creator" datasource="uam_god">
		update media_relations set
		CREATED_BY_AGENT_ID = #bads.related_agent_id# where
		CREATED_BY_AGENT_ID = #bads.agent_id#
	</cfquery>
	<cfquery name="media_labels" datasource="uam_god">
		update media_labels set
		ASSIGNED_BY_AGENT_ID = #bads.related_agent_id# where
		ASSIGNED_BY_AGENT_ID = #bads.agent_id#
	</cfquery>
	got media labels<br><cfflush>
	<cfquery name="group_member" datasource="uam_god">
		update group_member set
		MEMBER_AGENT_ID = #bads.related_agent_id# where
		MEMBER_AGENT_ID = #bads.agent_id#
	</cfquery>
	got group_member<br><cfflush>
	<cfquery name="object_condition" datasource="uam_god">
		update object_condition set
		DETERMINED_AGENT_ID = #bads.related_agent_id# where
		DETERMINED_AGENT_ID = #bads.agent_id#
	</cfquery>
	got object_condition<br><cfflush>
	<cfquery name="collection_contacts" datasource="uam_god">
		update collection_contacts set
		CONTACT_AGENT_ID = #bads.related_agent_id# where
		CONTACT_AGENT_ID = #bads.agent_id#
	</cfquery>
	got collection_contacts<br><cfflush>
	
	<!---
	<cftransaction action="commit">
	---->
	<cfquery name="related" datasource="uam_god">
		DELETE FROM agent_relations WHERE agent_id = #bads.agent_id# OR related_agent_id = #bads.agent_id#
	</cfquery>
	del agntreln<br><cfflush>
	
	<cfquery name="killnames" datasource="uam_god">
		DELETE FROM agent_name WHERE agent_id = #bads.agent_id#
	</cfquery>
	del agntname<br><cfflush>
	
	
	<cfquery name="killperson" datasource="uam_god">
		DELETE FROM person WHERE person_id = #bads.agent_id#
	</cfquery>
	del person<br><cfflush>
	<cfquery name="killagent" datasource="uam_god">
		DELETE FROM agent WHERE agent_id = #bads.agent_id#
	</cfquery>
	del agnt<br><cfflush>
</cfif>
</cftransaction>

<cfquery name="enableTrig" datasource="uam_god">
	alter trigger DEL_AGENT_NAME enable
</cfquery>
	
</cfloop>


<p></p>
Anything linked above was missed and needs your attention. Otherwise, it's all cleaned up!
</cfoutput>
</cfif>
<cfinclude template = "/includes/_footer.cfm">