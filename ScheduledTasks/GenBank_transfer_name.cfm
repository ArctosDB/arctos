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
<cfftp action="open" 
	timeout="3000"
	username="#Application.genBankUsername#"
	password="#decrypt(Application.genBankPwd,'genbank')#"
	server="ftp-private.ncbi.nih.gov" 
	connection="genbankn" 
	passive="true" 
	>
		<cfftp connection="genbankn" action="changedir" passive="true" directory="holdings">
		<cfftp connection="genbankn" 
			action="putfile" 
			passive="true" 
			localfile="#Application.webDirectory#/temp/names.ft" 
			remotefile="names.ft" 
			name="Put_names"
			timeout="3000">
	<cfftp connection="genbankn" action="close">
</cfoutput>