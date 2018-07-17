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
	<cfquery name="aa" datasource="uam_god">
			select a.grantee as username from dba_role_privs a, dba_role_privs b where a.grantee=b.grantee and a.granted_role IN (
			select granted_role from dba_role_privs,cf_collection where
			dba_role_privs.granted_role=cf_collection.portal_name and
			upper(grantee) in (#listqualify(valuelist(usrs.username),"'")#)
			) and b.granted_role='MANAGE_COLLECTION'
	</cfquery>

	<cfquery name="nagt_p" dbtype="query">
		select username from usrs union select username from aa
	</cfquery>
	<cfdump var=#nagt_p#>
	<cfquery name="nagt" dbtype="query">
		select distinct username from nagt_p
	</cfquery>
	<cfquery name="adrs" datasource="uam_god">
		select agent_name,get_address(agent_name.agent_id,'email') email from agent_name where upper(agent_name) in  (#listqualify(valuelist(nagt.username),"'")#)
	</cfquery>


	<cfdump var=#usrs#>
	<cfdump var=#aa#>
	<cfdump var=#nagt#>


	<cfdump var=#adrs#>

	<!----
	<cfloop query="usrs">
		<cfquery name="mgr" datasource="uam_god">


			select granted_role from dba_role_privs,cf_collection where
			dba_role_privs.granted_role=cf_collection.portal_name and
			upper(grantee)='DLM'
			;


			select grantee from dba_role_privs  where granted_role='MLZ_EGG';
			select a.grantee from dba_role_privs a, dba_role_privs b where a.grantee=b.grantee and a.granted_role='MLZ_EGG' and b.granted_role='MANAGE_COLLECTION' ;








			dba_role_privs.granted_role=cf_collection.portal_name and
			upper(grantee)='DLM'
			;





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
	---->



</cfoutput>



