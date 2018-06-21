<!---
	deal with "data entry extras" marked "autoload"

	just run until we finish or time out


---->
<cfoutput>
	<cfset loader = CreateObject("component","component.loader")>

	<!--- get GUID for events ---->
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
	<!----- validate events ---->
	<cfquery name="d2" datasource="uam_god">
		select
			*
		from
			cf_temp_specevent
		where
			cf_temp_specevent.status='autoload' and
			cf_temp_specevent.guid is not null
	</cfquery>
	<cfloop query="d2">
		<cfquery name="thisRow" dbtype="query">
			select * from d2 where [key] = #d2.key#
		</cfquery>
		<cfset x=loader.validateSpecimenEvent(thisRow)>
		<cfquery name="ud" datasource="uam_god">
			update cf_temp_specevent set
				key=key
				<cfif isdefined("x.problems") and len(x.problems) gt 0>
					,status='autoload:#x.problems#'
				</cfif>
				<cfif isdefined("x.collection_object_id") and len(x.collection_object_id) gt 0>
					,l_collection_object_id=#x.collection_object_id#
				</cfif>
				<cfif isdefined("x.agent_id") and len(x.agent_id) gt 0>
					,l_event_assigned_id=#x.agent_id#
				</cfif>
			where
				key=#x.key#
		</cfquery>
	</cfloop>
	<!----- load events ---->
	<cfquery name="d3" datasource="uam_god">
		select * from
			cf_temp_specevent
		where
			cf_temp_specevent.status='autoload:precheck_pass' and
			cf_temp_specevent.guid is not null
	</cfquery>
	<cfloop query="d3">
		<cfquery name="thisRow" dbtype="query">
			select * from d3 where [key] = #d3.key#
		</cfquery>
		<cfset x=loader.createSpecimenEvent(thisRow)>
		<cfif x.status is "success">
			<cfquery name="ud" datasource="uam_god">
				delete from cf_temp_specevent where	key=#x.key#
			</cfquery>
		<cfelse>
			<cfquery name="ud" datasource="uam_god">
				update cf_temp_specevent set
					status='autoload:#x.status#'
				where
					key=#x.key#
			</cfquery>
		</cfif>
	</cfloop>

	<!--- get GUID for attributes ---->
	<cfquery name="d" datasource="uam_god">
		select
			cf_temp_attributes.key,
			flat.guid
		from
			cf_temp_attributes,
			flat,
			coll_obj_other_id_num
		where
			coll_obj_other_id_num.OTHER_ID_TYPE='UUID' and
			coll_obj_other_id_num.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID and
			cf_temp_attributes.OTHER_ID_TYPE='UUID' and
			coll_obj_other_id_num.DISPLAY_VALUE=cf_temp_attributes.OTHER_ID_NUMBER and
			cf_temp_attributes.status='autoload' and
			cf_temp_attributes.guid is null
	</cfquery>
	<cfloop query="d">
		<br>update cf_temp_attributes set guid='#d.guid#' where key=#d.key#
		<cfquery name="ud" datasource="uam_god">
			update cf_temp_attributes set guid='#d.guid#' where key=#d.key#
		</cfquery>
	</cfloop>

	<!----- validate attributes ---->
	<cfquery name="d2" datasource="uam_god">
		select
			*
		from
			cf_temp_attributes
		where
			cf_temp_attributes.status='autoload' and
			cf_temp_attributes.guid is not null
	</cfquery>
	<cfloop query="d2">
		<cfquery name="thisRow" dbtype="query">
			select * from d2 where [key] = #d2.key#
		</cfquery>
		<cfset x=loader.validateSpecimenAttribute(thisRow)>
		<cfdump var=#x#>

		<cfquery name="ud" datasource="uam_god">
			update cf_temp_attributes set
				key=key
				<cfif isdefined("x.problems") and len(x.problems) gt 0>
					,status='autoload:#x.problems#'
				</cfif>
				<cfif isdefined("x.collection_object_id") and len(x.collection_object_id) gt 0>
					,collection_object_id=#x.collection_object_id#
				</cfif>
				<cfif isdefined("x.agent_id") and len(x.agent_id) gt 0>
					,DETERMINED_BY_AGENT_ID=#x.determiner_id#
				</cfif>
			where
				key=#x.key#
		</cfquery>
	</cfloop>

	<!----- load attributes ---->
	<cfquery name="d3" datasource="uam_god">
		select * from
			cf_temp_attributes
		where
			cf_temp_attributes.status='autoload:precheck_pass' and
			cf_temp_attributes.guid is not null
	</cfquery>
	<cfloop query="d3">
		<cfquery name="thisRow" dbtype="query">
			select * from d3 where [key] = #d3.key#
		</cfquery>
		<cfset x=loader.createSpecimenAttribute(thisRow)>
		<cfdump var=#x#>
		<cfquery name="ud" datasource="uam_god">
				update cf_temp_attributes set
					status='autoload:#x.status#'
				where
					key=#x.key#
			</cfquery>
		<!----
		<cfif x.status is "success">
			<cfquery name="ud" datasource="uam_god">
				delete from cf_temp_specevent where	key=#x.key#
			</cfquery>
		<cfelse>
			<cfquery name="ud" datasource="uam_god">
				update cf_temp_specevent set
					status='autoload:#x.status#'
				where
					key=#x.key#
			</cfquery>
		</cfif>
		---->
	</cfloop>

</cfoutput>



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

