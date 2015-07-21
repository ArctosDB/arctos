<!--- collections for which current user is a manager --->
<cfquery name="get_admin_group" datasource="uam_god">
	select 
		distinct(collroles.granted_role) admin_for_groups
	from 
		dba_role_privs collroles,
		dba_role_privs isMgr,
		collection
	where
		upper(collroles.granted_role) = upper(collection.institution_acronym || '_' || collection.collection_cde) and
		isMgr.granted_role='MANAGE_COLLECTION' and
		isMgr.grantee=collroles.grantee and
		upper(collroles.grantee) = '#ucase(session.username)#'
</cfquery>
<!--- collections for which current user is authorized data entry ---->
<cfquery name="get_entry_group" datasource="uam_god">
	select 
		distinct(collroles.granted_role) entry_in_groups
	from 
		dba_role_privs collroles,
		dba_role_privs isMgr,
		collection
	where
		upper(collroles.granted_role) = upper(replace(collection.guid_prefix,':','_')) and
		isMgr.granted_role='DATA_ENTRY' and
		isMgr.grantee=collroles.grantee and
		upper(collroles.grantee) = '#ucase(session.username)#'
</cfquery>
<!--- users who current user can act as admin for --->
<cfquery name="admin_for_users" datasource="uam_god">
	select 
		distinct(cf_users.username) admin_of_user
	from 
		dba_role_privs users,
		dba_role_privs collroles,
		cf_users	
	where
		users.grantee=collroles.grantee and
		upper(users.grantee)=upper(cf_users.username) and
		users.granted_role='DATA_ENTRY' and
		collroles.granted_role IN (
			select 
				distinct(collroles.granted_role)
			from 
				dba_role_privs collroles,
				dba_role_privs isMgr,
				collection
			where
				upper(collroles.granted_role) = upper(replace(collection.guid_prefix,':','_')) and
				isMgr.granted_role='MANAGE_COLLECTION' and
				isMgr.grantee=collroles.grantee and
				upper(collroles.grantee) = '#ucase(session.username)#'
		)
	order by cf_users.username
</cfquery>

<cfset caller.inAdminGroups = valuelist(get_admin_group.admin_for_groups)>
<cfset caller.inEntryGroups = valuelist(get_entry_group.entry_in_groups)>
<cfset caller.adminForUsers = valuelist(admin_for_users.admin_of_user)>
