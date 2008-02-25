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
<cfquery datasource="#Application.web_user#" name="1000CatItems">
	select collection_object_id from cataloged_item
	where rownum < 10000
</cfquery>
<cfset eTime=getTickCount()>
<cfset elapTime=#eTime# - #sTime#>
<br>Got 10000 records back in #elapTime# milliseconds.
<br>If this value is less than a couple hundred, everything's probably spiffy.
</cfoutput>
<cfinclude template="/includes/_footer.cfm">