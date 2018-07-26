<!---
	dataentry_extras_notification.cfm
	send email to the folks who entered this stuff and whoever has manage_collection for them
---->
<cfsavecontent variable="emailFooter">
	<div style="font-size:smaller;color:gray;">
		--
		<br>Don't want these messages? Update Collection Contacts.
		<br>Want these messages? Update Collection Contacts, make sure you have a valid email address.
		<br>Links not working? Log in, log out, or check encumbrances.
		<br>Need help? Send email to arctos.database@gmail.com
	</div>
</cfsavecontent>

<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select
			tblname,
			c,
			username,
			status
		from
			(
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
		)
		where
			status = 'linked to bulkloader' or
			status like '%autoload%'
	</cfquery>
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
	<cfquery name="nagt" dbtype="query">
		select distinct username from nagt_p
	</cfquery>
	<cfquery name="adrs" datasource="uam_god">
		select agent_name,get_address(agent_name.agent_id,'email') email from agent_name where upper(agent_name) in (#listqualify(valuelist(nagt.username),"'")#)
	</cfquery>

	<cfquery name="f_adrs" dbtype="query">
		select distinct agent_name,email from adrs where email is not null
	</cfquery>
	<cfquery name="d_s" dbtype="query">
		select * from d where username is not null order by username
	</cfquery>

	<cfif isdefined("Application.version") and  Application.version is "prod">
		<cfset subj="Arctos Pending Data Notification">
		<cfset maddr=valuelist(f_adrs.email)>
	<cfelse>
		<cfset maddr=application.bugreportemail>
		<cfset subj="TEST PLEASE IGNORE: Arctos Pending Data Notification">
	</cfif>
	<cfmail to="#maddr#" bcc="#Application.LogEmail#" subject="#subj#" from="pending_data@#Application.fromEmail#" type="html">
		<cfif isdefined("Application.version") and  Application.version is not "prod">
			<hr>
				prodemaillist: #valuelist(f_adrs.email)#
			<hr>
		</cfif>
		<p>
			You are receiving this message because you have data in a bulkloader available from "data entry extras," or because
			you have manage_collection for a user with data in a bulkloader available from "data entry extras."
		</p>
		<p>
			Data for specimens which have not yet been entered are available at EnterData/Bulkloader/BrowseAndEdit-->Extras or the individual bulkloaders.
			<p>
				NOTE: Records which have been orphaned by deleting from the specimen bulkloader or changing UUID in either the specimen
				bulkloader or the individual bulkloader will NOT be available at EnterData/Bulkloader/BrowseAndEdit-->Extras. These
				must be reconciled from the individual bulkloader.
			</p>
		</p>
		<p>
			Data for specimens which have been entered are available at EnterData/Bulkloader/ExtrasForLoadedSpecimens or the individual bulkloaders.
		</p>
		<p>
			Summary:
		</p>
		<table border>
			<tr>
				<th>Username</th>
				<th>Table</th>
				<th>Status</th>
				<th>Count</th>
			</tr>
			<cfloop query="d_s">
				<tr>
					<td>#USERNAME#</td>
					<td>#TBLNAME#</td>
					<td>#STATUS#</td>
					<td>#C#</td>
				</tr>
			</cfloop>
		</table>
		#emailFooter#
	</cfmail>
</cfoutput>