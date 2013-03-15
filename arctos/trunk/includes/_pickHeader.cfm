<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<head>
	<cfinclude template="/includes/alwaysInclude.cfm">
	<cfoutput>
    	<LINK REL="SHORTCUT ICON" HREF="/images/favicon.ico">
    	<meta http-equiv="content-type" content="text/html; charset=utf-8">
   		<cfif len(trim(session.stylesheet)) gt 0>
			<cfset ssName = replace(session.stylesheet,".css","","all")>
    		<link rel="alternate stylesheet" type="text/css" href="/includes/css/#trim(session.stylesheet)#" title="#trim(ssName)#">
			<META http-equiv="Default-Style" content="#trim(ssName)#">
		</cfif>
		</head>
		<body>
		<cf_rolecheck>
	</cfoutput>
<br><br>