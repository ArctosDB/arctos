<cfcomponent>
	<cffunction name="getHostInfo" access="remote">
		<cfargument name="ip" type="string" required="yes">
		 <!---- this has to be called remotely, but only allow logged-in Operators access--->
	    <cfif not isdefined("session.roles") or not listFind(session.roles, 'COLDFUSION_USER')>
	      <cfthrow message="unauthorized">
	    </cfif>
		<cfset inet_address = CreateObject("java", "java.net.InetAddress")>
		<cfset getCanonicalHostName = inet_address.getByName("#ip#").getCanonicalHostName()>
		<cfreturn getCanonicalHostName>
	</cffunction>
	<!--------------------------------------------------------------------------->
	<cffunction name="updatecf_temp_spec_to_geog" access="remote">
		<cfargument name="old" type="string" required="yes">
		<cfargument name="new" type="string" required="yes">
		 <!---- this has to be called remotely, but only allow logged-in Operators access--->
	    <cfif not isdefined("session.roles") or not listFind(session.roles, 'COLDFUSION_USER')>
	      <cfthrow message="unauthorized">
	    </cfif>
		<cfquery name="gotone" datasource="uam_god">
			update cf_temp_spec_to_geog set higher_geog='#new#' where spec_locality='#old#'
		</cfquery>
		<cfreturn "ok">
	</cffunction>
		<!--------------------------------------------------------------------------->
	<cffunction name="upDSStatus" access="remote">
		<cfargument name="pkey" type="numeric" required="yes">
		<cfargument name="status" type="string" required="yes">
		 <!---- this has to be called remotely, but only allow logged-in Operators access--->
	    <cfif not isdefined("session.roles") or not listFind(session.roles, 'COLDFUSION_USER')>
	      <cfthrow message="unauthorized">
	    </cfif>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update ds_temp_geog set status='#status#' where pkey=#pkey#
		</cfquery>
		<cfreturn pkey>
	</cffunction>
	<!--------------------------------------------------------------------------->
	<cffunction name="upDSStatusHG" access="remote">
		<cfargument name="pkey" type="numeric" required="yes">
		<cfargument name="status" type="string" required="yes">
		 <!---- this has to be called remotely, but only allow logged-in Operators access--->
	    <cfif not isdefined("session.roles") or not listFind(session.roles, 'COLDFUSION_USER')>
	      <cfthrow message="unauthorized">
	    </cfif>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update ds_temp_geog_hg set status='#status#' where pkey=#pkey#
		</cfquery>
		<cfreturn pkey>
	</cffunction>
	<!--------------------------------------------------------------------------->
	<cffunction name="upDSGeog" access="remote">
		<cfargument name="pkey" type="numeric" required="yes">
		<cfargument name="geog" type="string" required="yes">
		 <!---- this has to be called remotely, but only allow logged-in Operators access--->
	    <cfif not isdefined("session.roles") or not listFind(session.roles, 'COLDFUSION_USER')>
	      <cfthrow message="unauthorized">
	    </cfif>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update ds_temp_geog set HIGHER_GEOG='#geog#' where pkey=#pkey#
		</cfquery>
		<cfreturn pkey>
	</cffunction>
	<!--------------------------------------------------------------------------->
	<cffunction name="upDSGeogHG" access="remote">
		<cfargument name="pkey" type="numeric" required="yes">
		<cfargument name="geog" type="string" required="yes">
		 <!---- this has to be called remotely, but only allow logged-in Operators access--->
	    <cfif not isdefined("session.roles") or not listFind(session.roles, 'COLDFUSION_USER')>
	      <cfthrow message="unauthorized">
	    </cfif>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update ds_temp_geog_hg set HIGHER_GEOG='#geog#' where pkey=#pkey#
		</cfquery>
		<cfreturn pkey>
	</cffunction>
	<!--------------------------------------------------------------------------->
	<cffunction name="getSpecimenByPartBarcode" access="remote">
		<cfthrow detail="block not found" errorcode="9945" message="A block of code (component.DSFunctions,getSpecimenByPartBarcode) was not found.">
		<!--------------
	<cfargument name="barcode" type="any" required="yes">
	<cfquery name="d" datasource="uam_god">
		select
			c.barcode,
			CAT_NUM,
			VERBATIM_DATE,
			LAST_EDIT_DATE,
			INDIVIDUALCOUNT,
			COLL_OBJ_DISPOSITION,
			COLLECTORS,
			OTHERCATALOGNUMBERS,
			RELATEDCATALOGEDITEMS,
			TYPESTATUS,
			ACCESSION,
			HIGHER_GEOG,
			CONTINENT_OCEAN,
			COUNTRY,
			STATE_PROV,
			COUNTY,
			FEATURE,
			ISLAND,
			ISLAND_GROUP,
			QUAD,
			SEA,
			SPEC_LOCALITY,
			MINIMUM_ELEVATION,
			MAXIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
			DEC_LAT,
			DEC_LONG,
			DATUM,
			ORIG_LAT_LONG_UNITS,
			VERBATIMLATITUDE,
			VERBATIMLONGITUDE,
			LAT_LONG_REF_SOURCE,
			COORDINATEUNCERTAINTYINMETERS,
			GEOREFMETHOD,
			LAT_LONG_REMARKS,
			LAT_LONG_DETERMINER,
			SCIENTIFIC_NAME,
			IDENTIFIEDBY,
			MADE_DATE,
			REMARKS,
			HABITAT,
			ASSOCIATED_SPECIES,
			FULL_TAXON_NAME,
			FAMILY,
			GENUS,
			SPECIES,
			SUBSPECIES,
			AUTHOR_TEXT,
			NOMENCLATURAL_CODE,
			INFRASPECIFIC_RANK,
			GUID,
			COLLECTING_METHOD,
			COLLECTING_SOURCE,
			AGE_CLASS,
			ATTRIBUTES,
			VERIFICATIONSTATUS,
			VERBATIMELEVATION,
			BEGAN_DATE,
			ENDED_DATE,
			ID_SENSU
		from
			flat,
			specimen_part,
			coll_obj_cont_hist,
			container p,
			container c
		where
			flat.collection_object_id=specimen_part.derived_from_cat_item and
			specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
			coll_obj_cont_hist.container_id=p.container_id and
			p.parent_container_id=c.container_id and
			c.barcode in (#ListQualify(barcode, "'")#)
	</cfquery>
	<cfreturn d>

	------------>
</cffunction>

<cffunction name="getGuidByPartBarcode" access="remote">
	<cfargument name="barcode" type="any" required="yes">
	 <!---- this has to be called remotely, but only allow logged-in Operators access--->
    <cfif not isdefined("session.roles") or not listFind(session.roles, 'COLDFUSION_USER')>
      <cfthrow message="unauthorized">
    </cfif>
	<cfquery name="d" datasource="uam_god">
		select
			c.barcode,
			guid
		from
			flat,
			specimen_part,
			coll_obj_cont_hist,
			container p,
			container c
		where
			flat.collection_object_id=specimen_part.derived_from_cat_item and
			specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
			coll_obj_cont_hist.container_id=p.container_id and
			p.parent_container_id=c.container_id and
			c.barcode in (#ListQualify(barcode, "'")#)
	</cfquery>
	<cfreturn d>
</cffunction>
<!----------------------------------------------------------------------------------->
<cffunction name="getMediaUriByFilename" access="remote">
	<cfargument name="filename" type="any" required="yes">
	<cfargument name="mimetype" type="any" required="no">
	<!---- this has to be called remotely, but only allow logged-in Operators access--->
    <cfif not isdefined("session.roles") or not listFind(session.roles, 'COLDFUSION_USER')>
      <cfthrow message="unauthorized">
    </cfif>
	<cfquery name="d" datasource="uam_god">
		select media_uri from media where media_uri like '%/#filename#%'
		<cfif isdefined("mimetype") and len(mimetype) gt 0>
			and mime_type='#mimetype#'
		</cfif>
	</cfquery>
	<cfreturn d>
</cffunction>
<!---------------------------------------------------------------------->
<cffunction name="getMediaByFilename" access="remote">
	<cfargument name="filename" type="any" required="yes">
	<!---- this has to be called remotely, but only allow logged-in Operators access--->
    <cfif not isdefined("session.roles") or not listFind(session.roles, 'COLDFUSION_USER')>
      <cfthrow message="unauthorized">
    </cfif>

	<cfquery name="d" datasource="uam_god">
		select count(*) c from media where media_uri like '%/#filename#%'
	</cfquery>
	<cfreturn d.c>
</cffunction>
<!---------------------------------------------------------------------->
<cffunction name="getMediaByExactFilename" access="remote">
	<cfargument name="filename" type="any" required="yes">
	<!---- this has to be called remotely, but only allow logged-in Operators access--->
    <cfif not isdefined("session.roles") or not listFind(session.roles, 'COLDFUSION_USER')>
      <cfthrow message="unauthorized">
    </cfif>
	<cfquery name="d" datasource="uam_god">
		select count(*) c from media where media_uri like '%/#filename#'
	</cfquery>
	<cfreturn d.c>
</cffunction>
<!---------------------------------------------------------------------->


<cffunction name="getAllAgentNames" access="remote">
	<cfargument name="agent_id" type="any" required="yes">
	<!---- this has to be called remotely, but only allow logged-in Operators access--->
    <cfif not isdefined("session.roles") or not listFind(session.roles, 'COLDFUSION_USER')>
      <cfthrow message="unauthorized">
    </cfif>
	<cfif isnumeric(agent_id) and len(agent_id) gt 0>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select agent_name from agent_name where agent_id=#agent_id# order by agent_name
		</cfquery>
		<cfreturn valuelist(d.agent_name,';')>
	<cfelse>
		<cfreturn "">
	</cfif>
</cffunction>

<!--------------------------------------------->

<cffunction name="findAgentMatch" access="remote">
	<cfargument name="key" type="numeric" required="yes">
	<!---- this has to be called remotely, but only allow logged-in Operators access--->
    <cfif not isdefined("session.roles") or not listFind(session.roles, 'COLDFUSION_USER')>
      <cfthrow message="unauthorized">
    </cfif>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select first_name,middle_name,last_name,preferred_name,other_name_1,other_name_2,other_name_3
		from ds_temp_agent where key=#key#
	</cfquery>
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
	        #KEY# key,
	        preferred_agent_name.agent_id,
	        preferred_agent_name.agent_name preferred_agent_name
		from
	        agent_name srch,
	        preferred_agent_name
		where
	        srch.agent_id=preferred_agent_name.agent_id and
	        trim(srch.agent_name) in (
	        	trim('#d.preferred_name#'),
	        	trim('#d.other_name_1#'),
	        	trim('#d.other_name_2#'),
	        	trim('#d.other_name_3#')
	        )
	    group by
	    	preferred_agent_name.agent_id,
	        preferred_agent_name.agent_name,
	        #key#
	    union
	    select
	    	#KEY# key,
	        preferred_agent_name.agent_id,
	        preferred_agent_name.agent_name preferred_agent_name
		from
			person,
			preferred_agent_name
		where
			person.person_id=preferred_agent_name.agent_id and
			upper(first_name) = trim(upper('#d.first_name#')) and
			upper(last_name) = trim(upper('#d.last_name#'))
	</cfquery>
	<cfreturn result>
</cffunction>
<!------------------------------------------>
<cffunction name="findAgentMatchOld" access="remote">
	<cfargument name="key" type="numeric" required="yes">
	<!---- this has to be called remotely, but only allow logged-in Operators access--->
    <cfif not isdefined("session.roles") or not listFind(session.roles, 'COLDFUSION_USER')>
      <cfthrow message="unauthorized">
    </cfif>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_agent where key=#key#
	</cfquery>
	<cfquery name="n" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
	        first_name,
	        middle_name,
	        last_name,
	        birth_date,
	        death_date,
	        suffix,
	        preferred_agent_name.agent_id,
	        preferred_agent_name.agent_name preferred_agent_name
		from
	        person,
	        agent_name srch,
	        preferred_agent_name
		where
	        person.person_id=srch.agent_id and
	        person.person_id=preferred_agent_name.agent_id and
	        srch.agent_name in ('#d.preferred_name#','#d.other_name_1#','#d.other_name_2#','#d.other_name_3#')
	    group by
	    	first_name,
	        middle_name,
	        last_name,
	        birth_date,
	        death_date,
	        suffix,
	        preferred_agent_name.agent_id,
	        preferred_agent_name.agent_name
	</cfquery>
	<cfset result = querynew("key,first_name,middle_name,last_name,birth_date,death_date,suffix,agent_id,
			preferred_agent_name,othernames,n_agent_type,n_preferred_name,n_first_name,n_middle_name,n_last_name,n_birth_date,n_death_date,
			n_prefix,n_suffix,n_other_name_1,n_other_name_type_1,n_other_name_2,n_other_name_type_2,n_other_name_3,
			n_other_name_type_3")>



	<cfset i=1>
	<cfloop query="n">
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "key", key, i)>
		<cfset temp = QuerySetCell(result, "first_name", n.first_name, i)>
		<cfset temp = QuerySetCell(result, "middle_name", n.middle_name, i)>
		<cfset temp = QuerySetCell(result, "last_name", n.last_name, i)>
		<cfset temp = QuerySetCell(result, "birth_date", n.birth_date, i)>
		<cfset temp = QuerySetCell(result, "death_date", n.death_date, i)>
		<cfset temp = QuerySetCell(result, "suffix", n.suffix, i)>
		<cfset temp = QuerySetCell(result, "agent_id", n.agent_id, i)>
		<cfset temp = QuerySetCell(result, "preferred_agent_name", n.preferred_agent_name, i)>
		<cfset temp = QuerySetCell(result, "n_agent_type", d.n_agent_type, i)>
		<cfset temp = QuerySetCell(result, "n_preferred_name", d.n_preferred_name, i)>
		<cfset temp = QuerySetCell(result, "n_first_name", d.n_first_name, i)>
		<cfset temp = QuerySetCell(result, "n_middle_name", d.n_middle_name, i)>
		<cfset temp = QuerySetCell(result, "n_last_name", d.n_last_name, i)>
		<cfset temp = QuerySetCell(result, "n_birth_date", d.n_birth_date, i)>
		<cfset temp = QuerySetCell(result, "n_death_date", d.n_death_date, i)>
		<cfset temp = QuerySetCell(result, "n_prefix", d.n_prefix, i)>
		<cfset temp = QuerySetCell(result, "n_suffix", d.n_suffix, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_1", d.n_other_name_1, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_type_1", d.n_other_name_type_1, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_2", d.n_other_name_2, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_type_2", d.n_other_name_type_2, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_3", d.n_other_name_3, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_type_3", d.n_other_name_type_3, i)>
		<cfset i=i+1>
	</cfloop>
	<cfreturn result>
</cffunction>
</cfcomponent>