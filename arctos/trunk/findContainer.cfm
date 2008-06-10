<frameset cols="50%,50%">
<cfif isdefined("RunOnLoad") and len(#RunOnLoad#) gt 0>
<cfoutput>
<frame src="findContainer.cfm?RunOnLoad=#RunOnLoad#" name="_tree">
</cfoutput>
<cfelse>
<frame src="findContainer.cfm" name="_tree">
</cfif>
	<frame name="_detail" src="nothing.cfm">
</frameset><noframes></noframes>
