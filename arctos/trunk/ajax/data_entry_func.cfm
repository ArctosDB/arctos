
<!--- hint="type=keyvalue, jsreturn=array , listdelimiter=| , delimiter='='" --->
<cfinclude template="/ajax/core/cfajax.cfm">

<cffunction name="rememberLastOtherId" returntype="string">
	<cfargument name="yesno" type="numeric" required="yes">
	<cfset session.rememberLastOtherId=#yesno#>
	<cfreturn yesno>
</cffunction>
<!--------------
	<cftry>
		<cfquery name="tieRef" datasource="#Application.uam_dbo#">
			update greffy set refset_id=#refset_id# where gref_id=#gref_id#
		</cfquery>
		<cfcatch>
			<cfset result="There was a problem saving your refset!">
		</cfcatch>
		<cfset result='success'>
	</cftry>
	----------------------->
<!------------------------------------->

<!-------------------------------------------------------->
<cffunction name="is_good_accn" returntype="string">
	<cfargument name="accn" type="string" required="yes">
	<cfargument name="institution_acronym" type="string" required="yes">
	
	<cftry>
	<cfif #accn# contains "[" and #accn# contains "]">
		<cfset p = find(']',accn)>
		<cfset ia = mid(accn,2,p-2)>
		
		<cfset ac = mid(accn,p+1,len(accn))>
		<!----
		<cfset result = "-p:-#p#-ia-#ia#-ac-#ac#">
		<cfreturn result>
		---->
	<cfelse>
		<cfset ac=#accn#>
		<cfset ia=#institution_acronym#>
	</cfif>
	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			count(*) cnt
		FROM
			accn,
			trans,
			collection
		WHERE
			accn.transaction_id = trans.transaction_id AND
			trans.collection_id=collection.collection_id and
			accn.accn_number = '#ac#' and
			collection.institution_acronym = '#ia#'
	</cfquery>
		<cfset result = "#q.cnt#">
	<cfcatch>
		<cfset result = "#cfcatch.detail#">
	</cfcatch>
	</cftry>	
	<cfreturn result>
</cffunction>
<cffunction name="get_picked_locality" returntype="query">
	<cfargument name="locality_id" type="numeric" required="yes">
	<cftry>
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			locality.locality_id,
			geog_auth_rec.HIGHER_GEOG,
			locality.MAXIMUM_ELEVATION,
			locality.MINIMUM_ELEVATION,
			locality.ORIG_ELEV_UNITS,
			locality.SPEC_LOCALITY,
			locality.LOCALITY_REMARKS,
			accepted_lat_long.LAT_DEG,			
			accepted_lat_long.DEC_LAT_MIN,
			accepted_lat_long.LAT_MIN,
			accepted_lat_long.LAT_SEC,
			accepted_lat_long.LAT_DIR,			
			accepted_lat_long.LONG_DEG,
			accepted_lat_long.DEC_LONG_MIN,
			accepted_lat_long.LONG_MIN,
			accepted_lat_long.LONG_SEC,			
			accepted_lat_long.LONG_DIR,
			accepted_lat_long.DEC_LAT,
			accepted_lat_long.DEC_LONG,
			accepted_lat_long.DATUM,
			accepted_lat_long.ORIG_LAT_LONG_UNITS,
			llAgnt.agent_name DETERMINED_BY,
			to_char(accepted_lat_long.DETERMINED_DATE,'dd-Mon-yyyy') DETERMINED_DATE,
			accepted_lat_long.LAT_LONG_REF_SOURCE,
			accepted_lat_long.LAT_LONG_REMARKS,
			accepted_lat_long.MAX_ERROR_DISTANCE,
			accepted_lat_long.MAX_ERROR_UNITS,
			accepted_lat_long.EXTENT,
			accepted_lat_long.GPSACCURACY,
			accepted_lat_long.GEOREFMETHOD,
			accepted_lat_long.VERIFICATIONSTATUS,
			GEOLOGY_ATTRIBUTE,
			GEO_ATT_VALUE,
			geoAgnt.agent_name GEO_ATT_DETERMINER,
			to_char(GEO_ATT_DETERMINED_DATE,'dd-Mon-yyyy') GEO_ATT_DETERMINED_DATE,
			GEO_ATT_DETERMINED_METHOD,
			GEO_ATT_REMARK 
		FROM
			geog_auth_rec,
			locality,
			accepted_lat_long,
			preferred_agent_name llAgnt,
			geology_attributes,
			preferred_agent_name geoAgnt
		WHERE
			locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
			locality.LOCALITY_ID = accepted_lat_long.LOCALITY_ID (+) AND
			locality.LOCALITY_ID = geology_attributes.LOCALITY_ID (+) AND
			geology_attributes.GEO_ATT_DETERMINER_ID = geoAgnt.agent_id (+) AND
			accepted_lat_long.DETERMINED_BY_AGENT_ID = llAgnt.agent_id (+) AND
			locality.locality_id = #locality_id#
	</cfquery>
	<!---
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			locality.locality_id,
			geog_auth_rec.HIGHER_GEOG,
			locality.MAXIMUM_ELEVATION,
			locality.MINIMUM_ELEVATION,
			locality.ORIG_ELEV_UNITS,
			locality.SPEC_LOCALITY,
			locality.LOCALITY_REMARKS,
			accepted_lat_long.LAT_DEG,			
			accepted_lat_long.DEC_LAT_MIN,
			accepted_lat_long.LAT_MIN,
			accepted_lat_long.LAT_SEC,
			accepted_lat_long.LAT_DIR,			
			accepted_lat_long.LONG_DEG,
			accepted_lat_long.DEC_LONG_MIN,
			accepted_lat_long.LONG_MIN,
			accepted_lat_long.LONG_SEC,			
			accepted_lat_long.LONG_DIR,
			accepted_lat_long.DEC_LAT,
			accepted_lat_long.DEC_LONG,
			accepted_lat_long.DATUM,
			accepted_lat_long.ORIG_LAT_LONG_UNITS,
			agent_name DETERMINED_BY,
			to_char(accepted_lat_long.DETERMINED_DATE,'dd-Mon-yyyy') DETERMINED_DATE,
			accepted_lat_long.LAT_LONG_REF_SOURCE,
			accepted_lat_long.LAT_LONG_REMARKS,
			accepted_lat_long.MAX_ERROR_DISTANCE,
			accepted_lat_long.MAX_ERROR_UNITS,
			accepted_lat_long.EXTENT,
			accepted_lat_long.GPSACCURACY,
			accepted_lat_long.GEOREFMETHOD,
			accepted_lat_long.VERIFICATIONSTATUS
		FROM
			geog_auth_rec,
			locality,
			accepted_lat_long,
			preferred_agent_name
		WHERE
			locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
			locality.LOCALITY_ID = accepted_lat_long.LOCALITY_ID (+) AND
			accepted_lat_long.DETERMINED_BY_AGENT_ID = preferred_agent_name.agent_id (+) AND
			locality.locality_id = #locality_id#
	</cfquery>
	--->
	<cfcatch>
	<cfset result = QueryNew("locality_id,msg")>
	<cfset temp = QueryAddRow(result, 1)>
	<cfset temp = QuerySetCell(result, "locality_id", "-1",1)>
	<cfset temp = QuerySetCell(result, "msg", "#cfcatch.detail#",1)>
	</cfcatch>
	</cftry>	
	<cfreturn result>
</cffunction>
<cffunction name="getAttCodeTbl" returntype="query">
	<cfargument name="attribute" type="string" required="yes">
	<cfargument name="collection_cde" type="string" required="yes">
	<cfargument name="element" type="string" required="yes">
	<cfquery name="isCtControlled" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select VALUE_CODE_TABLE,UNITS_CODE_TABLE from ctattribute_code_tables where attribute_type='#attribute#'
	</cfquery>
	<cfif #isCtControlled.recordcount# is 1>
		<!--- there's something --->
		<cfif len(#isCtControlled.VALUE_CODE_TABLE#) gt 0>
			<!--- values code table --->
			<cfquery name="getCols" datasource="uam_god">
				select column_name from sys.user_tab_columns where table_name='#ucase(isCtControlled.value_code_table)#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
			<cfquery name="valCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from #isCtControlled.value_code_table#
			</cfquery>
			<cfset collCode = "">
			<cfset columnName = "">
			<cfloop query="getCols">
					<cfif getCols.column_name is "COLLECTION_CDE">
						<cfset collCode = "yes">
					  <cfelse>
						<cfset columnName = "#getCols.column_name#">
					</cfif>
			</cfloop>
			<cfif len(#collCode#) gt 0>
				<cfquery name="valCodes" dbtype="query">
					SELECT #columnName# as valCodes from valCT
					WHERE collection_cde='#collection_cde#'
				</cfquery>
			  <cfelse>
				<cfquery name="valCodes" dbtype="query">
					SELECT #columnName# as valCodes from valCT
				</cfquery>
			</cfif>
			<!---- should have valid names in valCodes, now put them in a query --->
			<cfset result = QueryNew("v")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "value",1)>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "#element#",2)>
			<!--- put the valid values in the query --->
			<cfset i=3>
			<cfloop query="valCodes">
				<cfset newRow = QueryAddRow(result, 1)>
				<cfset temp = QuerySetCell(result, "v", "#valCodes#",#i#)>
				<cfset i=#i#+1>
			</cfloop>
			
		<cfelseif #isCtControlled.UNITS_CODE_TABLE# gt 0>
			<cfquery name="getCols" datasource="uam_god">
				select column_name from sys.user_tab_columns where table_name='#ucase(isCtControlled.UNITS_CODE_TABLE)#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
			<cfquery name="valCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from #isCtControlled.UNITS_CODE_TABLE#
			</cfquery>
			<cfset collCode = "">
			<cfset columnName = "">
			<cfloop query="getCols">
					<cfif getCols.column_name is "COLLECTION_CDE">
						<cfset collCode = "yes">
					  <cfelse>
						<cfset columnName = "#getCols.column_name#">
					</cfif>
			</cfloop>
			<cfif len(#collCode#) gt 0>
				<cfquery name="valCodes" dbtype="query">
					SELECT #columnName# as valCodes from valCT
					WHERE collection_cde='#collection_cde#'
				</cfquery>
			  <cfelse>
				<cfquery name="valCodes" dbtype="query">
					SELECT #columnName# as valCodes from valCT
				</cfquery>
			</cfif>
			
			
			
			<cfset result = "unit - #isCtControlled.UNITS_CODE_TABLE#">
			<cfset result = QueryNew("v")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "units")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "#element#",2)>
			<cfset i=3>
			<cfloop query="valCodes">
				<cfset newRow = QueryAddRow(result, 1)>
				<cfset temp = QuerySetCell(result, "v", "#valCodes#",#i#)>
				<cfset i=#i#+1>
			</cfloop>
		<cfelse>
			<cfset result = QueryNew("v")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "ERROR")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "#element#",2)>
		</cfif>
	<cfelse>
			<cfset result = QueryNew("v")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "NONE")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "#element#",2)>
	</cfif>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------->
<cffunction name="testArray" returntype="string">
<cfargument name="COLLECTION_OBJECT_ID" type="array" required="yes">
	<cfset result = #COLLECTION_OBJECT_ID#>
	
	<cferror template="/e.cfm" type="exception">
	
		<!---
		<cfargument name="theArray" type="struct" required="yes">
		<cfset result = "some result">
		<cfargument name="theArray" required="false" type="struct"/>
	
		<cftry><cfset result = theArray.aryEntries.collection_object_id>
	<cfset result = theArray.collection_object_id[1]>
		<cfcatch>
			
		</cfcatch>
	</cftry>
	
	--->
		<cfreturn result>
</cffunction>

<!----------------------->
<cffunction name="getcatNumSeq" returntype="string">
	<cfargument name="coll" type="string" required="yes">
	<cfset theSpace = find(" " ,coll)>
	<cfset inst = trim(left(coll,theSpace))>
	<cfset collcde = trim(mid(coll,theSpace,len(coll)))>
	
	
	<cfquery name="collID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection_id from collection where
		institution_acronym='#inst#' and
		collection_cde='#collcde#'
	</cfquery>
	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select max(cat_num + 1) as nextnum
		from cataloged_item 
		where 
		collection_id=#collID.collection_id# 
	</cfquery>
	<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select max(to_number(cat_num) + 1) as nextnum from bulkloader
		where
		institution_acronym='#inst#' and
		collection_cde='#collcde#'
	</cfquery>
	<cfif #q.nextnum# gt #b.nextnum#>
		<cfset result = "#q.nextnum#">
	<cfelse>
		<cfset result = "#b.nextnum#">
	</cfif>
	
	<!---<cfset result = "#coll#=#inst#-#collcde#">
	--->
	
	<cfreturn result>
</cffunction>
<!----------------------->
<cffunction name="getBlankCatNum" returntype="string">
	<cfargument name="coll" type="string" required="yes">
	<cfset theSpace = find(" " ,coll)>
	<cfset inst = trim(left(coll,theSpace))>
	<cfset coll = trim(mid(coll,theSpace,len(coll)))>
	
	<cfquery name="collID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection_id from collection where
		institution_acronym='#inst#' and
		collection_cde='#coll#'
	</cfquery>
	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select min(cat_num + 1) as missingnum
		from cataloged_item t1
		where 
		collection_id=#collID.collection_id# and
		not exists (
		select cat_num
		from cataloged_item t2
		where t2.cat_num = t1.cat_num + 1
		and collection_id=#collID.collection_id#
		)
		and (cat_num + 1) not in (select decode(cat_num,null,999999999,to_number(cat_num)) as cat_num from bulkloader)
	</cfquery>
		
	<!---
		<cfif #q.recordcount# is 1>
			<cfset result = #q.missingmnum#>
		<cfelse>
			<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select max(cat_num) + 1 as nextnum from cataloged_item where
				collection_id=#coll_id#
			</cfquery>
			<cfset result = #q.nextnum#>
		</cfif>
		----->
		<cfif #q.recordcount# is 1>
			<cfset result = "#q.missingnum#">
		<cfelse>
			<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select max(cat_num) + 1 as nextnum from cataloged_item where
				collection_id=#coll_id#
			</cfquery>
			<cfset result = #q.nextnum#>
		</cfif>
		
		<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="getAccn" returntype="query">
	<cfargument name="inst" type="string" required="yes">
	<cfargument name="prefx" type="string" required="yes">
	
	<cfset y = "#dateformat(now(), "yyyy")#">
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			'#y#' as accn_num_prefix,
			decode(max(accn_num),NULL,'1',max(accn_num) + 1) as nan
			from accn,trans
			where 
			accn.transaction_id=trans.transaction_id and
			institution_acronym='#inst#' and
			accn_num_prefix=
			<cfif len(#prefx#) gt 0>
				'#prefx#'
			<cfelse>
				'#y#'
			</cfif>
	</cfquery>
		<cfreturn result>
</cffunction>
<!-------------------------------------------------------------------->
<cffunction name="getLoan" returntype="query">
	<cfargument name="inst" type="string" required="yes">
	<cfset y = "#dateformat(now(), "yyyy")#">
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			'#y#' as loan_num_prefix,
			decode(max(loan_num),NULL,'1',max(loan_num) + 1) as nln
			from loan,trans
			where 
			loan.transaction_id=trans.transaction_id and
			institution_acronym='#inst#' and
			loan_num_prefix='#y#'
	</cfquery>
		<cfreturn result>
</cffunction>
<!-------------------------------------------------------------------->
<cffunction name="getPreviousBox" returntype="query">
	
	<cfargument name="freezer" type="numeric" required="yes">
	<cfargument name="rack" type="numeric" required="yes">
	<cfargument name="box" type="numeric" required="yes">
	<cftry>
	<cftransaction>
	<cfif #box# is 1>
		<cfif #rack# is 1>
			<cfif #freezer# is 1>
				<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select 
						0 as freezer,
						0 as box,
						0 as rack
					from dual
				</cfquery>
			<cfelse>
				<cfset tf = #freezer# -1 >
				<cfquery name="pf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select distinct(freezer) from 
					dgr_locator where freezer = #tf#
				</cfquery>
				<cfif #pf.recordcount# is 1>
					<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select max(rack) as mrack from dgr_locator where 
						freezer = #tf#
					</cfquery>
					<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select 
							freezer,
							rack,
							max(box) as box
						from dgr_locator where 
						freezer = #tf#
					</cfquery>
				</cfif>
			</cfif>
		</cfif>
	</cfif>
	<cfquery name="newLoc" datasource="#Application.uam_dbo#">
	
	</cfquery>
	<cfquery name="v" datasource="#Application.uam_dbo#">
		select dgr_locator_seq.currval as currval from dual
	</cfquery>
	<cfset tv = v.currval>
	<cfquery name="result" datasource="#Application.uam_dbo#">
		select LOCATOR_ID,
			FREEZER,
			RACK,
			BOX,
			PLACE,
			NK,
			TISSUE_TYPE from 
		dgr_locator where LOCATOR_ID =#tv#		
	</cfquery>
	</cftransaction>
	<cfcatch>
		<cfquery name="result" datasource="#Application.uam_dbo#">
			select 99999999 as LOCATOR_ID from dual
		</cfquery>
	</cfcatch>
	</cftry>
		<cfreturn result>
</cffunction>


<!------------------------------------->
<cffunction name="DGRboxlookup" returntype="query">
	<cfargument name="freezer" type="numeric" required="yes">
	<cfargument name="rack" type="numeric" required="yes">
	
	<cfquery name="result" datasource="#Application.uam_dbo#">
		select box from dgr_locator where freezer = #freezer#
		and rack = #rack#
		group by box order by box
	</cfquery>
	<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="DGRracklookup" returntype="query">
	
	<cfargument name="freezer" type="numeric" required="yes">
	
	<cfquery name="result" datasource="#Application.uam_dbo#">
		select rack from dgr_locator where freezer = #freezer#
		group by rack order by rack
	</cfquery>
	<cfreturn result>
</cffunction>

<!------------------------------------->
<cffunction name="remNKFromPosn" returntype="string">
	
	<cfargument name="freezer" type="numeric" required="yes">
	<cfargument name="rack" type="numeric" required="yes">
	<cfargument name="box" type="numeric" required="yes">
	<cfargument name="place" type="numeric" required="yes">
	<cfargument name="tissue_type" type="string" required="yes">
	<cfargument name="nk" type="numeric" required="yes">
	<cfset result=#place#>
	<cftry>
	<cftransaction>
	<cfquery name="newLoc" datasource="#Application.uam_dbo#">
		delete from dgr_locator
		where  
			freezer=#freezer# AND
			rack= #rack# and
			box = #box# AND
			place = #place# AND
			nk = #nk# AND
			tissue_type = '#tissue_type#'
	</cfquery>
	
	</cftransaction>
	<cfcatch>
		<cfset result=999999>
	</cfcatch>
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="saveNewTiss" returntype="query">
	
	<cfargument name="freezer" type="numeric" required="yes">
	<cfargument name="rack" type="numeric" required="yes">
	<cfargument name="box" type="numeric" required="yes">
	<cfargument name="place" type="numeric" required="yes">
	<cfargument name="nk" type="numeric" required="yes">
	<cfargument name="tissue_type" type="string" required="yes">
	<cftry>
	<cftransaction>
	<cfquery name="newLoc" datasource="#Application.uam_dbo#">
		insert into dgr_locator (
			LOCATOR_ID,
			FREEZER,
			RACK,
			BOX,
			PLACE,
			NK,
			TISSUE_TYPE)
		VALUES (
			dgr_locator_seq.nextval,
			#freezer#,
			#rack#,
			#box#,
			#place#,
			#nk#,
			'#tissue_type#')		
	</cfquery>
	<cfquery name="v" datasource="#Application.uam_dbo#">
		select dgr_locator_seq.currval as currval from dual
	</cfquery>
	<cfset tv = v.currval>
	<cfquery name="result" datasource="#Application.uam_dbo#">
		select LOCATOR_ID,
			FREEZER,
			RACK,
			BOX,
			PLACE,
			NK,
			TISSUE_TYPE from 
		dgr_locator where LOCATOR_ID =#tv#		
	</cfquery>
	</cftransaction>
	<cfcatch>
		<cfquery name="result" datasource="#Application.uam_dbo#">
			select 99999999 as LOCATOR_ID from dual
		</cfquery>
	</cfcatch>
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------->

<cffunction name="getContacts" returntype="string">
	<cfquery name="contacts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			collection_contact_id,
			contact_role,
			contact_agent_id,
			agent_name contact_name
		from
			collection_contacts,
			preferred_agent_name
		where
			contact_agent_id = agent_id AND
			collection_id = #collection_id#
		ORDER BY contact_name,contact_role
	</cfquery>
		
		<cfset result = 'success'>
		<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="getCollInstFromCollId" returntype="string">
	<cfargument name="collid" type="numeric" required="yes">
	<cftry>
		<cfquery name="getCollId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select collection_cde, institution_acronym from
			collection where collection_id = #collid#
		</cfquery>
		<cfoutput>
		<cfset result = "#getCollId.institution_acronym#|#getCollId.collection_cde#">
		</cfoutput>
	<cfcatch>
		<cfset result = "QUERY FAILED">
	</cfcatch>
	</cftry>
  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
  <cfreturn result>
</cffunction>

<!------------------------------------->
<cffunction name="bulkEditUpdate" returntype="string">
	<cfargument name="theName" type="string" required="yes">
	<cfargument name="theValue" type="string" required="yes">
	<!--- parse name out
		format is field_name__collection_object_id --->
	<cfset hPos = find("__",theName)>
	<cfset theField = left(theName,hPos-1)>
	<cfset theCollObjId = mid(theName,hPos + 2,len(theName) - hPos)>
	<cfset result="#theName#">
	<cftry>
		<cfquery name="upBulk" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE bulkloader SET #theField# = '#theValue#'
			WHERE collection_object_id = #theCollObjId#
		</cfquery>
	<cfcatch>
		<cfset result = "QUERY FAILED">
	</cfcatch>
	</cftry>
  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
  <cfreturn result>


<!--- update bulkloader...<cfset var MyReturn = "bla">
  <cfset var MyString = "name">
  <cfsavecontent variable="result">
    <cfoutput>
    theName #theValue#
    </cfoutput>
  </cfsavecontent>
  
  <cfset result = "#name#||#value#"> 
		<cfoutput>
		<cfset result = "#name#, result">
		</cfoutput>
		<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
		--->
</cffunction>


<!------------------------------------->

<!------------------------------------->
<cffunction name="checkSessionExists" returntype="boolean">
	<cfif isDefined("session.name") AND session.name NEQ "">
		<cfreturn true>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>