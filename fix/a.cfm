<cfinclude template="/includes/_header.cfm">
<cfquery name="roles" datasource="uam_god">
	select barcode from container where barcode is not null
</cfquery>