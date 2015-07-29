<!--- 
	builds reciprocal links from GenBank
	Run daily
	Run after adding GenBank other IDs
	Requires: 
		Application.genBankPrid
		Application.genBankPwd (encrypted)
		Application.genBankUsername
---->
<cfquery name="cf_global_settings" datasource="uam_god">
	select * from cf_global_settings
</cfquery>
<cfoutput>
<!--- get all relevant files ---->
<cfdirectory action="LIST"
    	directory="#Application.webDirectory#/temp/"
        name="rfiles"
		recurse="yes"
		filter="nucleotide_#dateformat(now(),'yyyymmdd')#*">
		
<cfftp action="open" username="#cf_global_settings.GENBANK_USERNAME#" 
	password="#cf_global_settings.GENBANK_PASSWORD#" server="ftp-private.ncbi.nih.gov" connection="genbank" passive="true">
		<cfftp connection="genbank" action="changedir" passive="true" directory="holdings">
		<cfloop query="rfiles">
			<cfftp 
				connection="genbank" 
				action="putfile" 
				passive="true" 
				localfile="#Application.webDirectory#/temp/#name#" 
				remotefile="#name#" 
				name="Put_nucleotide">
		</cfloop>
	<cfftp connection="genbank" action="close">
</cfoutput>