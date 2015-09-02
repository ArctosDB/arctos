<!--- no security --->
<cfinclude template="../includes/_pickHeader.cfm">
 <cfif not isdefined("collection_object_id")>
	Didn't get a collection_object_id.<cfabort>
</cfif>
load some media yo!
<cfinclude template="../includes/_pickFooter.cfm">