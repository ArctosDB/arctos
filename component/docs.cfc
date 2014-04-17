<cfcomponent>
<cffunction name="getPage" access="remote">
	<cfargument name="page" required="yes">
    <cfargument name="pageSize" required="yes">
	<cfargument name="gridsortcolumn" required="yes">
    <cfargument name="gridsortdirection" required="yes">
	<cfset startrow=page * pageSize>
	<cfset stoprow=startrow + pageSize>
	<cfif len(gridsortcolumn) is 0>
		<cfset gridsortcolumn="SSRCH_FIELD_DOC_ID">
	</cfif>
<cfoutput>
	

	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ssrch_field_doc order by #gridsortcolumn# #gridsortdirection#
	</cfquery>
</cfoutput>
	      <cfreturn queryconvertforgrid(data,page,pagesize)/>
</cffunction>

<cffunction name="editRecord" access="remote">
	<cfargument name="cfgridaction" required="yes">
    <cfargument name="cfgridrow" required="yes">
	<cfargument name="cfgridchanged" required="yes">
	<cfoutput>
		<cfset colname = StructKeyList(cfgridchanged)>
		<cfset value = cfgridchanged[colname]>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update ssrch_field_doc set  #colname# = '#value#'
			where SSRCH_FIELD_DOC_ID=#cfgridrow.SSRCH_FIELD_DOC_ID#
		</cfquery>
	</cfoutput>
</cffunction>






<cffunction name="createDocDoc" access="remote" returnformat="plain" queryFormat="column">
	<cfargument name="CF_VARIABLE" type="string" required="true">
	<cfargument name="CONTROLLED_VOCABULARY" type="string" required="false">
	<cfargument name="DATA_TYPE" type="string" required="false">
	<cfargument name="DEFINITION" type="string" required="false">
	<cfargument name="DOCUMENTATION_LINK" type="string" required="false">
	<cfargument name="PLACEHOLDER_TEXT" type="string" required="false">
	<cfif not isdefined("escapeQuotes")>
		<cfinclude template="/includes/functionLib.cfm">
	</cfif>
	<cftry>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into ssrch_field_doc
				(
					CF_VARIABLE,
					DEFINITION,
					CONTROLLED_VOCABULARY,
					DOCUMENTATION_LINK,
					PLACEHOLDER_TEXT
				) values (
					'#CF_VARIABLE#',
					'#DEFINITION#',
					'#CONTROLLED_VOCABULARY#',
					'#DOCUMENTATION_LINK#',
					'#PLACEHOLDER_TEXT#'
				)
		</cfquery>
		<cfquery name="trc" datasource="uam_god">
			Select count(*) c from ssrch_field_doc 
		</cfquery>
		<cfquery name="new" datasource="uam_god">
			select * from ssrch_field_doc where CF_VARIABLE='#CF_VARIABLE#'
		</cfquery>
		
		<cfset x=''>
		<cfset trow="">
		<cfloop list="#new.columnlist#" index="i">
			<cfset temp = '"#i#":"' & evaluate("new." & i) & '"'>
			<cfset trow=listappend(trow,temp)>
		</cfloop>
		<cfset trow="{" & trow & "}">
		<cfset x=listappend(x,trow)>
		<cfset result='{"Result":"OK","Records":[' & x & '],"TotalRecordCount":#trc.c#}'>



		<cfcatch>
			<cfset result='{"Result":"ERROR","Message":"#cfcatch.message#: #cfcatch.detail#"}'>
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!---------------------------------->

<cffunction name="updateDocDoc" access="remote" returnformat="plain" queryFormat="column">
	<cfargument name="SSRCH_FIELD_DOC_ID" type="numeric" required="true">
	<cfargument name="CF_VARIABLE" type="string" required="true">
	<cfargument name="CONTROLLED_VOCABULARY" type="string" required="false">
	<cfargument name="DATA_TYPE" type="string" required="false">
	<cfargument name="DEFINITION" type="string" required="false">
	<cfargument name="DOCUMENTATION_LINK" type="string" required="false">
	<cfargument name="PLACEHOLDER_TEXT" type="string" required="false">
	<cfif not isdefined("escapeQuotes")>
		<cfinclude template="/includes/functionLib.cfm">
	</cfif>
	<cftry>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update 
				ssrch_field_doc 
			set  
				CF_VARIABLE = '#escapeQuotes(CF_VARIABLE)#',
				CONTROLLED_VOCABULARY = '#escapeQuotes(CONTROLLED_VOCABULARY)#',
				DATA_TYPE = '#escapeQuotes(DATA_TYPE)#',
				DEFINITION = '#escapeQuotes(DEFINITION)#',
				DOCUMENTATION_LINK = '#escapeQuotes(DOCUMENTATION_LINK)#',
				PLACEHOLDER_TEXT = '#escapeQuotes(PLACEHOLDER_TEXT)#'	
			where 
				SSRCH_FIELD_DOC_ID=#SSRCH_FIELD_DOC_ID#
		</cfquery>
		<cfset result='{"Result":"OK","Message":"success"}'>
		<cfcatch>
			<cfset result='{"Result":"ERROR","Message":"#cfcatch.message#: #cfcatch.detail#"}'>
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!---------------------------------->
<cffunction name="listDocDoc" access="remote" returnformat="plain" queryFormat="column">

<cfparam name="jtStartIndex" type="numeric" default="0">
<cfparam name="jtPageSize" type="numeric" default="10">
<cfparam name="jtSorting" type="string" default="CF_VARIABLE ASC">

<cfset jtStopIndex=jtStartIndex+jtPageSize>

	
<!----

	
	CF_VARIABLE,CONTROLLED_VOCABULARY,DATA_TYPE,DEFINITION,DOCUMENTATION_LINK,PLACEHOLDER_TEXT
	
	--->
	
			
		<cfquery name="trc" datasource="uam_god">
		Select count(*) c from ssrch_field_doc 
	</cfquery>
	
	<cfquery name="d" datasource="uam_god">
		Select * from (
				Select a.*, rownum rnum From (
					select * from ssrch_field_doc order by #jtSorting#
				) a where rownum <= #jtStopIndex#
			) where rnum >= #jtStartIndex#
	</cfquery>
	<!----
	<cfdump var=#d#>
--->
<cfoutput>
	<!--- CF and jtable don't play well together, so roll our own.... ---->
	
	<cfset x=''>
	<cfloop query="d">
		<cfset trow="">
		<cfloop list="#d.columnlist#" index="i">
		
				<cfset temp = '"#i#":"' & evaluate("d." & i) & '"'>
			
			<cfset trow=listappend(trow,temp)>
		</cfloop>
		<cfset trow="{" & trow & "}">
		<cfset x=listappend(x,trow)>
	</cfloop>
<cfset result='{"Result":"OK","Records":[' & x & '],"TotalRecordCount":#trc.c#}'>

<!----



{
	"Result":"OK",
	"Records":[
		{,"AGE":"2163","NAME":"S. Miller","PERSONID":"2163","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4025","NAME":"Dixon H. Landers","PERSONID":"4025","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4026","NAME":"Brenda K. Lasorsa","PERSONID":"4026","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4028","NAME":"Lawrence R. Curtis","PERSONID":"4028","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4029","NAME":"T. L. Wade","PERSONID":"4029","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4031","NAME":"John A. Kirsch","PERSONID":"4031","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4032","NAME":"Francois-Joseph Lapointe","PERSONID":"4032","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4034","NAME":"Sibile Pardue","PERSONID":"4034","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4035","NAME":"Sverre Pedersen","PERSONID":"4035","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4036","NAME":"Grant Keddie","PERSONID":"4036","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4038","NAME":"Anna V. Goropashnaya","PERSONID":"4038","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4039","NAME":"Nils C. Stenseth","PERSONID":"4039","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4040","NAME":"Charles J. Krebs","PERSONID":"4040","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4041","NAME":"D. Ehrich","PERSONID":"4041","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4042","NAME":"A. Kenney","PERSONID":"4042","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4043","NAME":"Eric P. Hoberg","PERSONID":"4043","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4045","NAME":"Natalya Abramson","PERSONID":"4045","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4046","NAME":"Christine Adkins","PERSONID":"4046","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4047","NAME":"William Akersten","PERSONID":"4047","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4048","NAME":"Lois F. Alexander","PERSONID":"4048","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4049","NAME":"Sergio Ticul Alvarez-Casta–eda","PERSONID":"4049","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4050","NAME":"M. Angaiak","PERSONID":"4050","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4053","NAME":"Daniel Bachteler","PERSONID":"4053","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4054","NAME":"Robert J. Baker","PERSONID":"4054","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4055","NAME":"Brian Barnes","PERSONID":"4055","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4058","NAME":"Sheran L. Benerth","PERSONID":"4058","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4059","NAME":"Michael A. Castellini","PERSONID":"4059","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4060","NAME":"Elaina Tuttle","PERSONID":"4060","RECORDDATE":"2013-12-05 12:18:40.0"},{,"AGE":"4063","NAME":"Amy Geiger","PERSONID":"4063","RECORDDATE":"2013-12-05 12:18:40.0"}]}



<cfset x='{
 "Result":"OK",
 "Records":[
  {"PersonId":1,"Name":"Benjamin Button","Age":17,"RecordDate":"\/Date(1320259705710)\/"},
  {"PersonId":2,"Name":"Douglas Adams","Age":42,"RecordDate":"\/Date(1320259705710)\/"},
  {"PersonId":3,"Name":"Isaac Asimov","Age":26,"RecordDate":"\/Date(1320259705710)\/"},
  {"PersonId":4,"Name":"Thomas More","Age":65,"RecordDate":"\/Date(1320259705710)\/"}
 ]
}'>

<cfreturn x>

---->


</cfoutput>

<cfreturn result>
</cffunction>

</cfcomponent>