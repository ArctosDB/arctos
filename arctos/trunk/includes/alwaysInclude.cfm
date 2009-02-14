<cfif not isdefined("action")>
	<cfset action="nothing">
</cfif>
<cfif not isdefined("content_url")>
	<cfset content_url="">
</cfif>
<link rel="stylesheet" type="text/css" href="/includes/style.css" >
<script type='text/javascript' src='/ajax/core/engine.js'></script>
<script type='text/javascript' src='/ajax/core/util.js'></script>
<script type='text/javascript' src='/ajax/core/settings.js'></script>
<script language="JavaScript" src="/includes/_overlib.js" type="text/javascript"></script>
<script src="http://www.google-analytics.com/urchin.js" type="text/javascript"></script>
<cfoutput>
	<script type="text/javascript">_uacct = "#Application.Google_uacct#";urchinTracker();</script>
</cfoutput>