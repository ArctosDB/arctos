 <cfinclude template="/includes/alwaysInclude.cfm">
<script language="JavaScript" src="/includes/dynamicHelp.js" type="text/javascript"></script>
<cfset title='Help Test Page'>
<cfset content = 'nothing'>

<!---sample of entry field--->
<!--- This portion adds the new part into the content variable --->
<script language="javascript" type="text/javascript">addContent('third');</script>
<!--- This portion is the actual link --->
<a href="javascript:void(0);" 
	onClick="betterPageHelp(title, content, 'third');">
	Third
</a><br>

<!---sample of entry field--->
<!--- This portion adds the new part into the content variable --->
<script language="javascript" type="text/javascript">addContent('second');</script>
<!--- This portion is the actual link --->
<a href="javascript:void(0);" 
	onClick="betterPageHelp(title, content, 'second');">
	Second
</a>