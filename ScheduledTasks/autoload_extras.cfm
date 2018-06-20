<!---
	deal with "data entry extras" marked "autoload"
---->
<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select
			cf_temp_specevent.key,
			flat.guid
		from
			cf_temp_specevent,
			flat,
			coll_obj_other_id_num
		where
			coll_obj_other_id_num.OTHER_ID_TYPE='UUID' and
			coll_obj_other_id_num.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID and
			coll_obj_other_id_num.DISPLAY_VALUE=cf_temp_specevent.UUID and
			cf_temp_specevent.status='autoload' and
			cf_temp_specevent.guid is null
	</cfquery>
	<cfloop query="d">
		<cfquery name="ud" datasource="uam_god">
			update cf_temp_specevent set guid='#d.guid#' where key=#d.key#
		</cfquery>
	</cfloop>
	<cfdump var=#d#>
	<!--------
	<cfif isdefined("cf_temp_specevent_key") and len(cf_temp_specevent_key) gt 0>
		<cfquery name="cf_temp_specevent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_specevent set status='autoload' where key in (#ListQualify(cf_temp_specevent_key, "'")#)
		</cfquery>
	</cfif>

	<cfif isdefined("cf_temp_parts_key") and len(cf_temp_parts_key) gt 0>
		<cfquery name="cf_temp_parts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_parts set status='autoload' where key in (#ListQualify(cf_temp_parts_key, "'")#)
		</cfquery>
	</cfif>


	<cfif isdefined("cf_temp_attributes_key") and len(cf_temp_attributes_key) gt 0>
		<cfquery name="cf_temp_attributes" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_attributes set status='autoload' where key in (#ListQualify(cf_temp_attributes_key, "'")#)
		</cfquery>
	</cfif>


	<cfif isdefined("cf_temp_oids_key") and len(cf_temp_oids_key) gt 0>
		<cfquery name="cf_temp_oids" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_oids set status='autoload' where key in (#ListQualify(cf_temp_oids_key, "'")#)
		</cfquery>
	</cfif>

	<cfif isdefined("cf_temp_collector_key") and len(cf_temp_collector_key) gt 0>
		<cfquery name="cf_temp_collector" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_collector set status='autoload' where key in (#ListQualify(cf_temp_collector_key, "'")#)
		</cfquery>
	</cfif>
	---------->
</cfoutput>