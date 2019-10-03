<cfinclude template="/includes/_pickHeader.cfm">
<cfparam name="name" default="">
<cfoutput>
	<script>
		function useConcept(id,str){
			parent.$("###tcidFld#").val(id);
			parent.$("###tcvFld#").val(str).removeClass('badPick').addClass('goodPick');
			parent.$(".ui-dialog-titlebar-close").trigger('click');
		}
	</script>\<!----
	<form name="searchForAgent">
		<label for="agent_name">Agent Name</label>
		<input type="text" name="name" id="name" value="#name#">
		<input type="submit" value="Search" class="lnkBtn">
		<input type="hidden" name="agentIdFld" value="#agentIdFld#">
		<input type="hidden" name="agentNameFld" value="#agentNameFld#">
	</form>
	<cfif session.roles contains "manage_agents">
		<p>
			<input type="button" value="Create Person" class="insBtn" onClick="createAgent('person','findAgent','#agentIdFld#','#agentNameFld#');">
			<input type="button" value="Create Agent" class="insBtn" onClick="createAgent('','findAgent','#agentIdFld#','#agentNameFld#');">
		</p>
	</cfif>
	<cfif len(name) is 0>
		<cfabort>
	</cfif>
	---->
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			taxon_concept_id,
			publication.SHORT_CITATION,
			taxon_concept.concept_label,
			scientific_name
		from
			taxon_concept,
			publication,
			taxon_name
		where
			taxon_concept.publication_id=publication.publication_id and
			taxon_concept.taxon_name_id=taxon_name.taxon_name_id
		order by
			scientific_name,
			concept_label
	</cfquery>
	<cfif d.recordcount is 1>
	<cfoutput>
		<cfset str = #replace(d.concept_label,"'","\'","all")#>
		<script>
			useConcept('#d.taxon_concept_id#','#str#');
		</script>
	 </cfoutput>
	<cfelseif d.recordcount is 0>
		Nothing matched.
	<cfelse>
		<cfloop query="d">
		<cfset str = #replace(d.concept_label,"'","\'","all")#>
			<div>
				<span onclick="useConcept('#d.taxon_concept_id#','#str#')" class="likeLink">
					#scientific_name# :: #concept_label# :: SHORT_CITATION
				</span>
			</div>
		</cfloop>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_pickFooter.cfm">