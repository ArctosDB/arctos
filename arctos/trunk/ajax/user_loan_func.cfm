<!--- hint="type=keyvalue, jsreturn=array , listdelimiter=| , delimiter='='" --->
<cfinclude template="/ajax/core/cfajax.cfm">
<!------------------------------------->
<cffunction name="changeStatus" returntype="string">
	<cfargument name="partid" type="numeric" required="yes">
	<cfargument name="loanid" type="numeric" required="yes">
	<cfargument name="status" type="string" required="yes">
	
	<cfset result="success">
	<cftry>
	<cfquery name="upLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_loan_item set
		APPROVAL_STATUS='#status#'
		where USER_LOAN_ID = #loanid# and
		COLLECTION_OBJECT_ID=#partid#
	</cfquery>
	<cfcatch>
		<cfset result="fail">
	</cfcatch>
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="changeRemark" returntype="string">
	<cfargument name="partid" type="numeric" required="yes">
	<cfargument name="loanid" type="numeric" required="yes">
	<cfargument name="remark" type="string" required="yes">
	
	<cfset result="success">
	<cftry>
	<cfquery name="upLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_loan_item set
		ADMIN_REMARK='#remark#'
		where USER_LOAN_ID = #loanid# and
		COLLECTION_OBJECT_ID=#partid#
	</cfquery>
	<cfcatch>
		<cfset result="fail">
	</cfcatch>
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------->
<cffunction name="getLoanDetails" returntype="query">
	<cfargument name="inst" type="string" required="no">
	<cfargument name="pre" type="string" required="no">
	<cfargument name="num" type="numeric" required="yes">
	<cfargument name="suf" type="string" required="no">
	<cftry>
		<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				trans.transaction_id as transaction_id, 
				loan_type, 
				loan_instructions, 
				loan_description, 
				recAgnt.agent_name as rec_agent, 
				authAgnt.agent_name as auth_agent, 
				nature_of_material
			from 
				loan, 
				trans, 
				preferred_agent_name authAgnt, 
				preferred_agent_name recAgnt
			where 
				loan.transaction_id = trans.transaction_id AND 
				trans.auth_agent_id = authAgnt.agent_id (+) AND 
				trans.received_agent_id = recAgnt.agent_id AND 
				loan_num = #num# 
				<cfif len(#inst#) gt 0>
					AND institution_acronym = '#inst#'
				<cfelse>
					AND institution_acronym IS NULL
				</cfif>
				<cfif len(#pre#) gt 0>
					AND loan_num_prefix = '#pre#'
				<cfelse>
					AND loan_num_prefix IS NULL
				</cfif>
				<cfif len(#suf#) gt 0>
					AND loan_num_suffix = '#suf#'
				<cfelse>
					AND loan_num_suffix IS NULL
				</cfif>
		</cfquery>
		<cfif #result.recordcount# is 0>
			<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
				0 as transaction_id
				from dual
			</cfquery>
		<cfelseif #result.recordcount# gt 1>
			<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
				-99999 as transaction_id
				from dual
			</cfquery>
		</cfif>
		<cfcatch>
			<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
				-1 as transaction_id
				from dual
			</cfquery>
		</cfcatch>
	</cftry>
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
				<cfquery name="result" datasource="#Application.uam_dbo#">
					select 
						0 as freezer,
						0 as box,
						0 as rack
					from dual
				</cfquery>
			<cfelse>
				<cfset tf = #freezer# -1 >
				<cfquery name="pf" datasource="#Application.uam_dbo#">
					select distinct(freezer) from 
					dgr_locator where freezer = #tf#
				</cfquery>
				<cfif #pf.recordcount# is 1>
					<cfquery name="r" datasource="#Application.uam_dbo#">
						select max(rack) as mrack from dgr_locator where 
						freezer = #tf#
					</cfquery>
					<cfquery name="result" datasource="#Application.uam_dbo#">
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