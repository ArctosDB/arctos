<cfinclude template="../includes/_pickHeader.cfm">
 
 
 <!---<SCRIPT LANGUAGE=JAVASCRIPT><!--


    function setForm() {
    opener.document.f1.f1.value = document.selectedAgent.agentID.value;
    opener.document.f1.f2.value = document.selectedAgent.agentName.value;
    self.close();
    return false;
}

//--></SCRIPT>--->
<!---<FORM NAME="inputForm1" onSubmit="return setForm();">
<BR><INPUT NAME="inputField1" TYPE="TEXT" VALUE="">
<BR><INPUT NAME="inputField2" TYPE="TEXT" VALUE="">
<BR><INPUT TYPE="SUBMIT" VALUE="Update opener">
</FORM> --->


<!--- create a small application that can be called as a pop-up window used to select agent_id --->

<!--- build an agent id search --->
<cfoutput>
<cfif len(part_name) gt 0>
	<cfset search=true>
</cfif>
<form name="s" action="findPart.cfm" method="post">
	<br>Part Name: <input type="text" name="part_name" value="#part_name#">
	<br><input type="submit" value="Find Matches">
	<input type="hidden" name="search" value="true">
		
		<input type="hidden" name="collCde" value="#collCde#">
		<input type="hidden" name="partFld" value="#partFld#">
		<input type="hidden" name="formName" value="#formName#">
</form>
<cfif isdefined("search") and search is "true">
	<!--- make sure we're searching for something --->
	<cfif len(part_name) is 0>
		You must enter search criteria.
		<cfabort>
	</cfif>
		<cfquery name="gp" datasource="uam_god">
			select 
				part_name 
			from 
				pt_ctspecimen_part_name,
		    	ctspecimen_part_list_order
			where 
				collection_cde=trim('#collCde#') and
		  		pt_ctspecimen_part_name.part_name =  ctspecimen_part_list_order.partname (+) and
		  		upper(part_name) like '%#ucase(part_name)#%'		  		
			order by partname, part_name
		</cfquery>
	<cfloop query="gp">
		
		<br><a href="##" onClick="javascript: opener.document.#formName#.#partFld#.value='#part_name#';self.close();">#part_name#</a>
	<!---	
		<br><a href="##" onClick="javascript: document.selectedAgent.agentID.value='#agent_id#';document.selectedAgent.agentName.value='#agent_name#';document.selectedAgent.submit();">#agent_name# - #agent_id#</a> - 
	--->
	
	</cfloop>
</cfif>
	</cfoutput>

<cfinclude template="../includes/_pickFooter.cfm">