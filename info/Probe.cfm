<cfinclude template="/includes/_header.cfm">
<cfoutput>
This page is a general measure of system health. <br>
Don't believe anything you read here. 
<br>
It's probably a network issue. 
<br>
Go defrag your hard drive.
<br>
You don't have the latest updates.
<br>
<cfset sTime=getTickCount()>
<cfloop from="1" to="100" index="i">
<cfquery datasource="#Application.web_user#" name="1000CatItems">
	select collection_object_id from cataloged_item
	where rownum < 10000
</cfquery>
</cfloop>
<cfset eTime=getTickCount()>
<cfset elapTime= (#eTime# - #sTime#) / 100>
<br>Got 10000 records back in an average time of #elapTime# milliseconds.
<br>If this value is less than a couple hundred, everything's probably spiffy with Oracle.
<br>
<cfset sTime=getTickCount()>
	<cfloop query="1000CatItems">
		<cfset nothing=#collection_object_id#>
	</cfloop>
<cfset eTime=getTickCount()>
<cfset elapTime=#eTime# - #sTime#>
<br>Looped 10000 records back in #elapTime# milliseconds.
</cfoutput>
<cfinclude template="/includes/_footer.cfm">