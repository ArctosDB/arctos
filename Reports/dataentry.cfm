
<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="Arctos Data Entry Summary">
<script>
jQuery(document).ready(function() {
		$("#begindate").datepicker();
		$("#enddate").datepicker();
	});
</script>

<h3>Arctos Data Entry Report</h3>
This report provides a summary of the status of entry data in Arctos. It is drawn from bulkloader.ENTEREDTOBULKDATE. <h3>
<cfquery name="ctcoln" datasource="uam_god">
	select distinct
		decode(guid_prefix,
		null,institution_acronym || ':' || collection_cde,
		guid_prefix) guid_prefix from bulkloader_deletes order by guid_prefix
</cfquery>

<cfquery name="ctenteredby" datasource="uam_god">
	select distinct enteredby from bulkloader_deletes order by enteredby
</cfquery>
<cfparam name="variables.guid_prefix" default="">
<cfparam name="enteredby" default="">
<cfparam name="begindate" default="">
<cfparam name="enddate" default="">
<cfoutput>
<form name="r" method="get" action="dataentry.cfm">
	<label for="guid_prefix">guid_prefix</label>
	<select name="guid_prefix" id="guid_prefix">
		<option></option>
		<cfloop query="ctcoln">
			<option <cfif ctcoln.guid_prefix is variables.guid_prefix> selected="selected" </cfif>value="#ctcoln.guid_prefix#">#ctcoln.guid_prefix#</option>
		</cfloop>
	</select>
	<label for="enteredby">enteredby</label>
	<select name="enteredby" id="enteredby">
		<option></option>
		<cfloop query="ctenteredby">
			<option value="#enteredby#">#enteredby#</option>
		</cfloop>
	</select>
	<label for="date">dates</label>
	<input type="text" name="begindate" id="begindate" placeholder="from">
	<input type="text" name="enddate" id="enddate" placeholder="to">
	<br>
	<input type="submit">
</form>

<cfif len(guid_prefix) gt 0 or len(enteredby) gt 0 or len(begindate) gt 0 or len(enddate) gt 0>

</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
