<cfinclude template="/includes/_frameHeader.cfm">
<cfoutput>
	<cfif not isdefined("eid")>
		did not get element ID; aborting<cfabort>
	</cfif>
	pulling #eid#....
</cfoutput>
i am mdeditor.cfm