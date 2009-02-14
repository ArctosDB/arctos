<cfinclude template="/includes/functionLib.cfm">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> 
<head>
<cfinclude template="/includes/alwaysInclude.cfm"><!--- keep this stuff accessible from non-header-having files --->
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<cfset ssName = replace(session.stylesheet,".css","","all")>
<link rel="alternate stylesheet" type="text/css" href="/includes/css/#session.stylesheet#" title="#ssName#">
<META http-equiv="Default-Style" content="#ssName#">
</head>
<body>
<cf_rolecheck>