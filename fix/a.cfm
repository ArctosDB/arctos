<cfinclude template="/includes/_header.cfm">
<cfoutput>
<cfhttp url="http://arctos-test.arctos.database.museum/guid/MSB:Mamm:345" charset="utf-8" method="get">
<cfdump var="#cfhttp#">
</cfoutput>