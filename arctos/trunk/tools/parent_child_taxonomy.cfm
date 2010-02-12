<cfinclude template="/includes/_header.cfm">
<cfset title="Sync IDs">
<cfif #action# is "nothing">
<script>
	function goChange (v,c) {
		//alert(v);
		//alert(c);
		var theChild = "child" + c;
		var child = document.getElementById(theChild);
		if (v == true) {
			child.value = c;
		} else {
			child.value = '';
		}
	}
</script>
<!--- first, get everything in a parent/child relationship that has different accepted ID --->
Use this to synchronize child ID to parent's. Check the boxes and click submit to make it do stuff. It will add an accepted ID - current IDs are preserved. Search is parent is on parent is "parent of" and parent.ID <> child.ID.
<hr />
<cfif not isdefined("customOtherIdentifier")>
	<cfset customOtherIdentifier = '--'>
<cfelse>
</cfif>
<cfquery name="whatIDs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		pID.scientific_name as parentname,
		cID.scientific_name as childname,
		pID.nature_of_id as pNat,
		cID.nature_of_id as cNat,
		cCatItem.collection_object_id as cCollID,
		pCatItem.collection_object_id as pCollID,
		concatSingleOtherId(cCatItem.collection_object_id,'#session.CustomOtherIdentifier#') as childCustom,
		concatSingleOtherId(pCatItem.collection_object_id,'#session.CustomOtherIdentifier#') as parentCustom,
		cCatItem.cat_num as cCatNum,
		pCatItem.cat_num as pCatnum,
		pColl.collection_cde as pColl,
		pColl.institution_acronym as pInst,
		cColl.collection_cde as cColl,
		cColl.institution_acronym as cInst
	FROM
		cataloged_item cCatItem,
		cataloged_item pCatItem,
		collection pColl,
		collection cColl,
		biol_indiv_relations,
		identification pID,
		identification cID
	WHERE
		cCatItem.collection_object_id = cID.collection_object_id AND
		pCatItem.collection_object_id = pID.collection_object_id AND
		cCatItem.collection_id = cColl.collection_id AND
		pCatItem.collection_id = pColl.collection_id AND
		pCatItem.collection_object_id = biol_indiv_relations.collection_object_id AND
		cCatItem.collection_object_id = biol_indiv_relations.RELATED_COLL_OBJECT_ID AND
		BIOL_INDIV_RELATIONSHIP='parent of' AND
		pID.accepted_id_fg=1 AND
		cID.accepted_id_fg=1 AND
		pID.scientific_name <> cID.scientific_name
		<cfif isdefined("collection_object_id") and len(#collection_object_id#) gt 0>
			AND pCatItem.collection_object_id=#collection_object_id#
		</cfif>
		order by pCatnum
		
</cfquery>
<cfoutput>
<table border>
<tr>
	<td colspan="2" align="center">Parent</td>
	<td colspan="2" align="center">Child</td>
	<td>Update?</td>
</tr>
<form name="u" method="post" action="parent_child_taxonomy.cfm">
<input type="hidden" name="action" value="upThese" />
 	<cfloop query="whatIDs">
		<tr>
			<td>
				#parentname# 
				<span style="font-size:small">(#pNat#)</span>
				
			</td>
			<td>
				<a href="/SpecimenDetail.cfm?collection_object_id=#pCollID#">#pInst# #pColl# #pCatnum#</a>	
				(#session.CustomOtherIdentifier# = #parentCustom#)	
			</td>
			<td>
				#childname# 
				<span style="font-size:small">(#cNat#)</span>
			</td>
			<td>
				<a href="/SpecimenDetail.cfm?collection_object_id=#cCollID#">#cInst# #cColl# #cCatnum#</a>
				(#session.CustomOtherIdentifier# = #childCustom#)	
			</td>
			<td>
				<input type="hidden" id="child#cCollID#" name="child_coll_obj_id" />
				<input type="checkbox" onchange="goChange(this.checked,'#cCollID#')" />
			</td>
		</tr>
	</cfloop>
	<tr>
		<td colspan="4">
			<input type="submit" />
		</td>
	</tr>
</form>
</table>
</cfoutput>
</cfif>
<!--------------------------------------------------------->
<cfif #action# is "upThese">
	<cfoutput>
		<cfloop list="#child_coll_obj_id#" index="i">
			<!--- make sure the child only has one parent --->
			<cftransaction>
			<cfquery name="numP" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select count(*) c from biol_indiv_relations where
				BIOL_INDIV_RELATIONSHIP='parent of' AND
				RELATED_COLL_OBJECT_ID = #i#
			</cfquery>
			<cfif #numP.c# neq 1>
				Something's hinky!  
				<a href="/SpecimenDetail.cfm?collection_object_id=#i#">this critter</a>
				 seems to have #numP.c# parents! That may be good data, but I can't handle it here. Update the ID from the link.
				<cfabort>
			</cfif>
			<cfquery name="pData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from identification where
				identification.accepted_id_fg=1 and collection_object_id IN (
				select collection_object_id from biol_indiv_relations where
				BIOL_INDIV_RELATIONSHIP='parent of' AND
				RELATED_COLL_OBJECT_ID = #i#)
			</cfquery>
			<cfquery name="remOldIf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update identification set accepted_id_fg=0 where collection_object_id=#i#
			</cfquery>
			<cfquery name="idta" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from identification_taxonomy where identification_id=#pData.identification_id#
			</cfquery>
			<cfquery name="newID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into identification (
				 IDENTIFICATION_ID,
				 COLLECTION_OBJECT_ID,
				 MADE_DATE,
				 NATURE_OF_ID,
				 ACCEPTED_ID_FG,
				 TAXA_FORMULA,
				 SCIENTIFIC_NAME
				 ) values (
				 sq_identification_id.nextval,
				 #i#,
				 '#dateformat(now(),"dd-mmm-yyyy")#',
				 'ID of kin',
				 1,
				 '#pData.TAXA_FORMULA#',
				 '#pData.SCIENTIFIC_NAME#')
				 </cfquery>
				 <cfloop query="idta">
				 	<cfquery name="newTID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					insert into identification_taxonomy (
						 IDENTIFICATION_ID ,
						 TAXON_NAME_ID,
						 VARIABLE)
						 values (
						 	sq_identification_id.currval,
							#TAXON_NAME_ID#,
							'#VARIABLE#')
					 </cfquery>
				 </cfloop>
				 <cfquery name="insertida1" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					insert into identification_agent (
						IDENTIFICATION_ID,
						AGENT_ID,
						IDENTIFIER_ORDER
					) values (
						sq_identification_id.currval,
						#session.myAgentId#,
						1
					)
				</cfquery>
			</cftransaction>
				<!----where identification.identification_id = identification_taxonomy.identification_id and
			#SCIENTIFIC_NAME# #TAXA_FORMULA# ## ##
			--#numP.c#--
			#i#<br />
			--->
		</cfloop>
	</cfoutput>
	If there's nothing above, it probably worked. Go 
	<a href="parent_child_taxonomy.cfm">here</a>
	 and see if anything was missed.
</cfif>
<cfinclude template="/includes/_footer.cfm">