<cfinclude template="/includes/_frameHeader.cfm">
<cfset fName="#Application.webDirectory#/temp/LoanInstructions.pdf">
<cfdocument overwrite="true"
	format="pdf"
	pagetype="letter"
	margintop=".25"
	marginbottom=".25"
	marginleft=".25"
	marginright=".25"
	orientation="portrait"
	fontembed="yes"
	filename="#fName#" >
<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">
<cf_getLoanFormInfo>
<cfoutput>
<table width="100%">
	<tr>
    	<td valign="top">	
			<div align="right">
				<font size="1" face="Arial, Helvetica, sans-serif">
					<b>Loan ## #getLoan.loan_number#</b>
				</font> 
			</div>
			<div align="center" style="font-weight:bold;">
		        <font size="3">Loan Instructions Appendix</font> 
		</td>
	</tr>
	<tr>
		<td>
			<strong>Loan Instructions:</strong>
		</td>
	</tr>
	<tr>
		<td>
			#getLoan.loan_instructions#
		</td>
	</tr>
</cfoutput>
</cfdocument>

<cfoutput>
	<cfset fUrl=replace(fName,application.webDirectory,application.serverRootUrl)>
	<cflocation url="#fUrl#">
</cfoutput>
<!------------------------------------------------------------------->
<cfinclude template="/includes/_pickFooter.cfm">

