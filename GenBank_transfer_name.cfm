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

<cfftp action="open" username="#Application.genBankUsername#" password="#decrypt(Application.genBankPwd,'genbank')#" server="ftp-private.ncbi.nih.gov" connection="genbank" passive="true" timeout="240">
	<cfftp connection="genbank" action="changedir" passive="true" directory="holdings">
	<cfftp connection="genbank" action="putfile" passive="true" localfile="#Application.webDirectory#/temp/names.ft" remotefile="names.ft" name="Put_names">
	<cfftp connection="genbank" action="close">
<!----

---->
</cfoutput>