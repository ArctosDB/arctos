<cfinclude template="alwaysInclude.cfm">
<cfif not isdefined("formName")>
	<p style="color:#FF0000; font-size:14px;">
		This form was not called properly - aborting....
	</p>
	<cfabort>
</cfif>
<cfoutput>
<div align="center">
<cfif not isdefined("msg") OR len(#msg#) is 0>
	<cfset msg="this record">
</cfif>
<b><font color="##FF0000" size="+1">Are you sure you want to delete #msg#?</font></b><br>
<form name="abort" method="post" action="/includes/abort.cfm">
	<input type="hidden" name="formName" value="#formName#">
	<input type="hidden" name="action">
	 <input type="button"
				value="Delete" 
				class="delBtn"
				onmouseover="this.className='delBtn btnhov'"
				onmouseout="this.className='delBtn'"
				onClick="abort.action.value='go';submit();">
	 <input type="button"
				value="Do Nothing" 
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'"
				onmouseout="this.className='savBtn'"
				onClick="abort.action.value='abort';submit();">	
</form>
<cfif #action# is "go">
	<script>
		window.opener.document.#formName#.submit();
		self.close();
	</script>
<cfelseif #action# is "abort">
	<script>
		self.close();
	</script>
</cfif>
</div>
</cfoutput>