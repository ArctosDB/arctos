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
		select distinct username from d where username is not null
	</cfquery>
	<cfdump var=#usrs#>
	<cfloop query="usrs">
		<cfquery name="mgr" datasource="uam_god">
			select distinct
	               my_privs.grantee
	              from
	                dba_role_privs user_privs,
	                dba_role_privs my_privs,
	                cf_collection user_colns,
	                cf_collection my_colns
	              where
	                user_privs.granted_role = user_colns.portal_name and
	                my_privs.granted_role = my_colns.portal_name and
	                upper(user_privs.grantee)='#ucase(username)#' and
	                user_colns.portal_name=my_colns.portal_name
			</cfquery>
	<cfdump var=#mgr#>


	</cfloop>



</cfoutput>



