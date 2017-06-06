<!-----
BulkloadSpecimenPartAttribute.cfm


drop table cf_temp_specPartAttr;



create table cf_temp_specPartAttr (
	key number not null,
	status varchar2(255),
	guid varchar2(60) not null,
	part_name varchar2(60) not null,
	ATTRIBUTE_TYPE varchar2(60) not null,
	ATTRIBUTE_VALUE varchar2(60) not null,
	ATTRIBUTE_UNITS  varchar2(60),
	DETERMINED_DATE  varchar2(60),
	determiner  varchar2(60),
	remark  varchar2(4000),
	part_id number,
	spec_id number,
	agnt_id number
);


create or replace public synonym cf_temp_specPartAttr for cf_temp_specPartAttr;

grant all on cf_temp_specPartAttr to coldfusion_user;


CREATE OR REPLACE TRIGGER trg_cf_temp_specprtat_biu
    BEFORE INSERT OR UPDATE ON cf_temp_specPartAttr
    FOR EACH ROW
    BEGIN
  	if :NEW.key is null then
		select somerandomsequence.nextval into :new.key from dual;
    end if;
end;
/
sho err


---->
<cfinclude template="/includes/_header.cfm">
<cfsetting requestTimeOut = "1200">

<cfif action is  "nothing">
	Use this form to ADD specimen part attributes.

	<p>
		This form will only work if GUID + part_name is unique. (File an Issue for more.)
	</p>
	<p>
		This form INSERTs; that is all. "Old" data will not be changed in any way.
	</p>
	<p>
		This form will happily make duplicates. Be careful!
	</p>
	<p>
		<a href="BulkloadSpecimenPartAttribute.cfm?action=makeTemplate">download a CSV template</a>
	</p>
	<table border>
		<tr>
			<th>Column</th>
			<th>Required?</th>
			<th>more</th>
		</tr>
		<tr>
			<td>guid</td>
			<td>yes</td>
			<td>UAM:Mamm:12 format</td>
		</tr>
		<tr>
			<td>part_name</td>
			<td>yes</td>
			<td>existing part name</td>
		</tr>
		<tr>
			<td>ATTRIBUTE_TYPE</td>
			<td>yes</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTSPECPART_ATTRIBUTE_TYPE">CTSPECPART_ATTRIBUTE_TYPE</a></td>
		</tr>
		<tr>
			<td>ATTRIBUTE_VALUE</td>
			<td>yes</td>
			<td>varies</td>
		</tr>

		<tr>
			<td>ATTRIBUTE_UNITS</td>
			<td>conditionally</td>
			<td>varies</td>
		</tr>
		<tr>
			<td>DETERMINED_DATE</td>
			<td>no</td>
			<td>ISO8601</td>
		</tr>
		<tr>
			<td>determiner</td>
			<td>no</td>
			<td>Unique agent name</td>
		</tr>
		<tr>
			<td>remark</td>
			<td>no</td>
			<td>-</td>
		</tr>
	</table>

	Upload CSV:
	<form name="getFile" method="post" action="BulkloadSpecimenPartAttribute.cfm" enctype="multipart/form-data">
		<input type="hidden" name="action" value="getFileData">
		 <input type="file"
			   name="FiletoUpload"
			   size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</form>
</cfif>


<!------------------------------------------------------------------------------------------------>


<cfif action is "makeTemplate">
	<cfset header="guid,part_name,ATTRIBUTE_TYPE,ATTRIBUTE_VALUE,ATTRIBUTE_UNITS,DETERMINED_DATE,determiner,remark">

	<cffile action = "write"
    file = "#Application.webDirectory#/download/BulkloadSpecimenPartAtt.csv"
    output = "#header#"
    addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadSpecimenPartAtt.csv" addtoken="false">
</cfif>


<!------------------------------------------------------------------------------------------------>
<cfif action is "getFileData">
	<cfoutput>
		 <cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from cf_temp_specPartAttr
		</cfquery>

		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
        <cfset  util = CreateObject("component","component.utilities")>
		<cfset x=util.CSVToQuery(fileContent)>
        <cfset cols=x.columnlist>
        <cfloop query="x">
            <cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	            insert into cf_temp_specPartAttr (#cols#) values (
	            <cfloop list="#cols#" index="i">
	            	'#stripQuotes(evaluate(i))#'
	            	<cfif i is not listlast(cols)>
	            		,
	            	</cfif>
	            </cfloop>
	            )
            </cfquery>
        </cfloop>
		Loaded to table. Now <a href="BulkloadSpecimenPartAttribute.cfm?action=validate">validate</a>
	</cfoutput>
</cfif>






<!---------------------------------------------------------------------------->
<cfif action is "validate">

	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_specPartAttr
	</cfquery>




	<cfoutput>
		<!--- all-or-nothing for now....--->
		<cftransaction>
			<cfloop query="d">
				<cfset sid=''>
				<cfset pid=''>
				<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select
						flat.collection_object_id sid,
						specimen_part.collection_object_id pid
					from
						collection,
						flat,
						specimen_part
					where
						collection.collection_id=flat.collection_id and
						flat.collection_object_id=specimen_part.derived_from_cat_item and
						flat.guid = '#guid#' and
						specimen_part.part_name='#part_name#'
				</cfquery>
				<cfif a.recordcount is not 1 or len(a.sid) lt 1 or len(a.pid) lt 1>
					<cfquery name="uf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update cf_temp_specPartAttr set status='unique specimen/part combo not found' where key=#key#
					</cfquery>
				<cfelse>
					<cfquery name="uf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update cf_temp_specPartAttr set status='success',part_id=#a.pid#,spec_id =#a.sid# where key=#key#
					</cfquery>
				</cfif>

			</cfloop>
			<cfquery name="ag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update cf_temp_specPartAttr set agnt_id=getAgentID(determiner) where determiner is not null
			</cfquery>
			<cfquery name="ag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update cf_temp_specPartAttr set status='agent_not_found' where determiner is not null and agnt_id is null
			</cfquery>
		</cftransaction>
	</cfoutput>
	<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select distinct(status) from cf_temp_specPartAttr
	</cfquery>
	<cfif r.recordcount is 1 and r.status is "success">
		Successful validation;  <a href="BulkloadSpecimenPartAttribute.cfm?action=load">continue to load</a>
	<cfelse>
		validation failed; <a href="BulkloadSpecimenPartAttribute.cfm?action=getCSV">download CSV</a>, fix problems, and try again
	</cfif>

</cfif>
<!------------------------------------------------------------------------------------------------>

<cfif action is "getCSV">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_specPartAttr
	</cfquery>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=mine,Fields=mine.columnlist)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/BulkloadSpecimenPartAttrs.csv"
    	output = "#csv#"
    	addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadSpecimenPartAttrs.csv" addtoken="false">
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "load">
	<cfoutput>

		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_specPartAttr
		</cfquery>
		<cftransaction>
			<cfloop query="data">
				<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into specimen_part_attribute (
						PART_ATTRIBUTE_ID,
						COLLECTION_OBJECT_ID,
						ATTRIBUTE_TYPE,
						ATTRIBUTE_VALUE,
						ATTRIBUTE_UNITS,
						DETERMINED_DATE,
						DETERMINED_BY_AGENT_ID,
						ATTRIBUTE_REMARK
					) values (
						sq_PART_ATTRIBUTE_ID.nextval,
						#part_id#,
						'#ATTRIBUTE_TYPE#',
						'#escapeQuotes(ATTRIBUTE_VALUE)#',
						'#ATTRIBUTE_UNITS#',
						'#DETERMINED_DATE#',
						decode(#agnt_id#,null,null,#agnt_id#),
						'#escapeQuotes(remark)#'
					)
				</cfquery>
			</cfloop>
		</cftransaction>
	</cfoutput>

	If there are no errors above, load was successful.

	<p>
		If there are errors, the entire load has failed. Fix problems, file Issues, start again.
	</p>
</cfif>
<cfinclude template="/includes/_footer.cfm">