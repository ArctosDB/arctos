<cfinclude template="includes/_header.cfm">
<!--- no security --->

<cfif #action# is "nothing">
<cfoutput>
	<form name="labels" method="post" action="SpecimenContainerLabels.cfm">
		<input type="hidden" name="action">
		<input type="button" 
			value="Download Box Labels" 
			class="lnkBtn"
   			onmouseover="this.className='lnkBtn btnhov'" 
			onmouseout="this.className='lnkBtn'"
			onClick="window.open('/SpecimenResults.cfm?print_fg=1&detail_level=4&action=labels');">	
		<input type="button" 
			value="Print Vial Labels" 
			class="lnkBtn"
   			onmouseover="this.className='lnkBtn btnhov'" 
			onmouseout="this.className='lnkBtn'"
			onClick="window.open('/SpecimenResults.cfm?print_fg=2&detail_level=4&action=labels');">	
   	<input type="button" 
			value="Print Box Labels online" 
			class="lnkBtn"
   			onmouseover="this.className='lnkBtn btnhov'" 
			onmouseout="this.className='lnkBtn'"
			onClick="window.open('/SpecimenResults.cfm?print_fg=1&detail_level=4&action=flashyLabelyThingys');">	
			
		<input type="button" 
			value="Clear Vial Labels" 
			class="delBtn"
   			onmouseover="this.className='delBtn btnhov'" 
			onmouseout="this.className='delBtn'"
			onClick="labels.action.value='clearvial';submit();">
		<input type="button" 
			value="Clear Box Labels" 
			class="delBtn"
   			onmouseover="this.className='delBtn btnhov'" 
			onmouseout="this.className='delBtn'"
			onClick="labels.action.value='clearbox';submit();">	
	
	</form>
	<br>
	<br>
	</cfoutput>
</cfif><!--- not action is nothing --->

<cfif #Action# is "clearbox">
	
	<cfquery name="clear" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	update container set print_fg=null where print_fg=1
	</cfquery>
	<p><font color="#FF0000" size="+1">You've cleared all container print flags!</font></p>
</cfif>
<cfif #Action# is "clearvial">
	
	<cfquery name="clear" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	update container set print_fg=null where print_fg=2
	</cfquery>
	<p><font color="#FF0000" size="+1">You've cleared all vial print flags!</font></p>
	
</cfif>
<cfinclude template="includes/_footer.cfm">
