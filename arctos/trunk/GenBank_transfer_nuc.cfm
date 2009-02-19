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

<cfftp action="open" username="#Application.genBankUsername#" password="#decrypt(Application.genBankPwd,'genbank')#" server="ftp-private.ncbi.nih.gov" connection="genbank" passive="true">
	<cfftp connection="genbank" action="changedir" passive="true" directory="holdings">
	<cfftp connection="genbank" action="putfile" passive="true" localfile="#Application.webDirectory#/temp/nucleotide.ft" remotefile="nucleotide.ft" name="Put_nucleotide">
	<cfftp connection="genbank" action="close">
<!----

---->
</cfoutput>