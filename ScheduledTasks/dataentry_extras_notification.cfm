<!---
	dataentry_extras_notification.cfm
	send email to the folks who entered this stuff and whoever has manage_collection for them
---->
<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select
			'cf_temp_specevent' tblname,
			count(*) c,
	        upper(username) username,
	        status
		from
	    	cf_temp_specevent
		group by
	    	upper(username),
	       	status
	    union
	    select
			'cf_temp_parts' tblname,
			count(*) c,
	        upper(username) username,
	        status
		from
	    	cf_temp_parts
		group by
	    	upper(username),
	       	status
	    union
	    select
			'cf_temp_attributes' tblname,
			count(*) c,
	        upper(username) username,
	        status
		from
	    	cf_temp_attributes
		group by
	    	upper(username),
	       	status
	    union
	    select
			'cf_temp_oids' tblname,
			count(*) c,
	        upper(username) username,
	        status
		from
	    	cf_temp_oids
		group by
	    	upper(username),
	       	status
	    union
	    select
			'cf_temp_collector' tblname,
			count(*) c,
	        upper(username) username,
	        status
		from
	    	cf_temp_collector
		group by
	    	upper(username),
	       	status
	</cfquery>
	<cfdump var=#d#>
	<cfquery name="usrs" dbtype="query">
		select distinct username from d
	</cfquery>
	<cfdump var=#usrs#>



</cfoutput>



