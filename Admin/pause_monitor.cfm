<cfinclude template="/includes/_header.cfm">
<cfquery name="p" datasource="uam_god">
	update cf_global_settings set monitor_pause_end=sysdate + 12/24;
</cfquery>
monitor has been paused for 12 hours
<cfinclude template="/includes/_footer.cfm">
