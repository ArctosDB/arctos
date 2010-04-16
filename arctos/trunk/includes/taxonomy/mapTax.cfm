<cfinclude template = "/includes/functionLib.cfm">

<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	   	select dec_lat,dec_long from flat,taxonomy
	   	 where flat.scientific_name =taxonomy.scientific_name and 
	   	 taxon_name_id=#taxon_name_id#
	</cfquery>
	<cfdump var=#d#>
</cfoutput>