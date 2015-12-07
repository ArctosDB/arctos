<cfquery name="cf_global_settings" datasource="uam_god">
	select * from cf_global_settings
</cfquery>
	<!---
	builds reciprocal links from GenBank
	Run daily
	Run after adding GenBank other IDs
	Requires:
		Application.genBankPrid
		Application.genBankPwd (encrypted)
		Application.genBankUsername
---->
<cfoutput>
<cfsetting requesttimeout="3000" />

<!--- get all relevant files ---->
<cfdirectory action="LIST"
    	directory="#Application.webDirectory#/temp/"
        name="rfiles"
		recurse="yes"
		filter="names_*">

<cfftp action="open"
	timeout="3000"
	username="#cf_global_settings.GENBANK_USERNAME#"
	password="#cf_global_settings.GENBANK_PASSWORD#"
	server="ftp-private.ncbi.nih.gov"
	connection="genbankn"
	passive="true"
	>
		<cfftp connection="genbankn" action="changedir" passive="true" directory="holdings">

		<cfloop query="rfiles">
			<cfftp connection="genbankn"
				action="putfile"
				passive="true"
				localfile="#Application.webDirectory#/temp/#name#"
				remotefile="#name#"
				name="Put_names"
				timeout="3000">
		</cfloop>
	<cfftp connection="genbankn" action="close">
</cfoutput>