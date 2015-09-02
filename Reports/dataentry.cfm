
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
This report provides a summary of the status of entry data in Arctos. It is drawn from bulkloader.ENTEREDTOBULKDATE
<cfquery name="ctcoln" datasource="uam_god">
	select distinct
		decode(guid_prefix,
		null,institution_acronym || ':' || collection_cde,
		guid_prefix) guid_prefix from bulkloader_deletes order by guid_prefix
</cfquery>

<cfquery name="ctenteredby" datasource="uam_god">
	select distinct enteredby from bulkloader_deletes order by enteredby
</cfquery>
<cfparam name="guid_prefix" default="">
<cfparam name="enteredby" default="">
<cfparam name="begindate" default="">
<cfparam name="enddate" default="">
<cfparam name="results" default="csv">
<cfoutput>
<form name="r" method="get" action="dataentry.cfm">
	<label for="guid_prefix">guid_prefix</label>
	<select name="guid_prefix" id="guid_prefix">
		<option></option>
		<cfset x=guid_prefix>
		<cfloop query="ctcoln">
			<option <cfif ctcoln.guid_prefix is x> selected="selected" </cfif>value="#ctcoln.guid_prefix#">#ctcoln.guid_prefix#</option>
		</cfloop>
	</select>
	<label for="enteredby">enteredby</label>
	<select name="enteredby" id="enteredby">
		<option></option>
		<cfset x=enteredby>
		<cfloop query="ctenteredby">
			<option  <cfif ctenteredby.enteredby is x> selected="selected" </cfif>value="#enteredby#">#enteredby#</option>
		</cfloop>
	</select>
	<label for="date">dates</label>
	<input type="text" name="begindate" id="begindate" placeholder="from" value="#begindate#">
	<input type="text" name="enddate" id="enddate" placeholder="to" value="#enddate#">
	<label for="results">See Results As</label>
	<select name="results" id="results">
		<option  <cfif results is "csv"> selected="selected" </cfif>value="csv">csv</option>
	</select>
	<br>
	<input type="submit">
</form>

<cfif len(guid_prefix) gt 0 or len(enteredby) gt 0 or len(begindate) gt 0 or len(enddate) gt 0>
	<cfquery name="d" datasource="uam_god">
		select
			count(*) numrecs,
			decode(guid_prefix,
				null,institution_acronym || ':' || collection_cde,
				guid_prefix) guid_prefix,
			enteredby,
			nvl(to_char(enteredtobulkdate,'YYYY-MM-DD'),'NULL') enteredtobulkdate
		from
			bulkloader_deletes
		where
			1=1
			<cfif len(guid_prefix) gt 0>
				and (guid_prefix='#guid_prefix#' or institution_acronym || ':' || collection_cde='#guid_prefix#')
			</cfif>
			<cfif len(enteredby) gt 0>
				and enteredby='#enteredby#'
			</cfif>
			<cfif len(begindate) gt 0>
				and to_char(enteredtobulkdate,'YYYY-MM-DD') >= '#begindate#'
			</cfif>
			<cfif len(enddate) gt 0>
				and to_char(enteredtobulkdate,'YYYY-MM-DD') >= '#enddate#'
			</cfif>
		group by
			decode(guid_prefix,
				null,institution_acronym || ':' || collection_cde,
				guid_prefix),
			enteredby,
			nvl(to_char(enteredtobulkdate,'YYYY-MM-DD'),'NULL')
	</cfquery>
	<cfif results is "csv">
		csv yo
	</cfif>
	<cfdump var=#d#>
</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
