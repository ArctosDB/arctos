<cfstoredproc datasource="#Application.uam_dbo#" procedure="sp_createuser">
	 <cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="username_" value="dlm">
	 <cfprocparam type="in" cfsqltype="cf_sql_varchar" dbvarname="pwd" value="dlm123">
</cfstoredproc>