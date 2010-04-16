<cfinclude template = "/includes/functionLib.cfm">

<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	   	select dec_lat,dec_long from flat where scientific_name like '#scientific_name#%'
	</cfquery>
	<cfdump var=#d#>
</cfoutput>