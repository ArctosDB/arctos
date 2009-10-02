<!--- call at the bottom of anything used as an iframe in SpecimenDetail.cfm to sync the iframe with the main frame --->
<cfoutput>
	<cfif isdefined("session.currentStyleSheet") and len(trim(session.currentStyleSheet)) gt 0>
		<cfset csss = #session.currentStyleSheet#>
		<cfhtmlhead text='<link rel="---alternate stylesheet" type="text/css" href="/includes/css/#trim(session.currentStyleSheet)#.css" title="#trim(session.currentStyleSheet)#">'>
		<cfhtmlhead text='<!-- csss here -->'>
	<cfelse>
		<cfset csss = "">
	</cfif>
	<script type="text/javascript" language="javascript">
		changeStyle('#csss#');
		parent.dyniframesize();
	</script>
</cfoutput>