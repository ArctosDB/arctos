<!--- call at the bottom of anything used as an iframe in SpecimenDetail.cfm to sync the iframe with the main frame --->
<cfoutput>
	<cfif isdefined("session.currentStyleSheet")>
		<cfset csss = #session.currentStyleSheet#>
		<cfhtmlhead text='<link rel="alternate stylesheet" type="text/css" href="/includes/css/#session.currentStyleSheet#.css" title="#session.currentStyleSheet#">'>
	<cfelse>
		<cfset csss = "">
	</cfif>
	<script type="text/javascript" language="javascript">
		changeStyle('#csss#');
		parent.dyniframesize();
	</script>
</cfoutput>