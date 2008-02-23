<cfinclude template="/service/uBio.cfc">
<cfset bla = namebank_search_canonical()>
namebank_search_canonical:
<p></p>
<cfdump var=#bla#>
<hr>
<cfset bla = namebank_search()>
namebank_search:
<p></p>
<cfdump var=#bla#>
<hr>
