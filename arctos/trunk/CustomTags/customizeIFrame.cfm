<!--- call at the bottom of anything used as an iframe in SpecimenDetail.cfm to sync the iframe with the main frame --->
<cfoutput>
	<cfif isdefined("client.currentStyleSheet")>
		<cfset csss = #client.currentStyleSheet#>
		<cfhtmlhead text='<link rel="alternate stylesheet" type="text/css" href="/includes/css/#client.currentStyleSheet#.css" title="#client.currentStyleSheet#">'>
	<cfelse>
		<cfset csss = "">
	</cfif>
	<script type="text/javascript" language="javascript">
		changeStyle('#csss#');
		parent.dyniframesize();
	</script>
</cfoutput>