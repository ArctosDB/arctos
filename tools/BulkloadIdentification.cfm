<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600">

<cfset title="Bulkload Identification">
<!---- make the table

drop table cf_temp_id;
drop public synonym cf_temp_id;

create table cf_temp_id (
	key number,
	collection_object_id number,
	collection_cde varchar2(4),
	institution_acronym varchar2(6),
	other_id_type varchar2(60),
	other_id_number varchar2(60),
	scientific_name varchar2(255),
	made_date date,
	nature_of_id varchar2(30),
	accepted_fg number(1),
	identification_remarks varchar2(255),
	agent_1 varchar2(60),
	agent_2 varchar2(60),
	status varchar2(255),
	taxon_name_id number,
	taxa_formula varchar2(10),
	agent_1_id number,
	agent_2_id number
);

alter table cf_temp_id add guid varchar2(60);

create public synonym cf_temp_id for cf_temp_id;
grant select,insert,update,delete on cf_temp_id to manage_specimens;

CREATE OR REPLACE TRIGGER cf_temp_id_key
 before insert  ON cf_temp_id
 for each row
    begin
    	if :NEW.key is null then
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;
    end;
/

alter table cf_temp_id rename column collection_cde to guid_prefix;
alter table cf_temp_id drop column institution_acronym;
alter table cf_temp_id modify guid_prefix varchar2(30);

sho err
------>
<cfif action is "nothing">
	Upload a comma-delimited text file (csv).Include column headings, spelled exactly as below.
	<br><a href="BulkloadIdentification.cfm?action=makeTemplate">get a template</a>


	<table border>
		<tr>
			<th>Field</th>
			<th>Required?</th>
			<th>Def.</th>
		</tr>
		<tr>
			<td>guid</td>
			<td>conditionally</td>
			<td>You must provide either GUID, or {guid_prefix,other_id_type,other_id_number}.</td>
		</tr>
		<tr>
			<td>guid_prefix</td>
			<td>conditionally</td>
			<td>You must provide either GUID, or {guid_prefix,other_id_type,other_id_number}.</td>
		</tr>
		<tr>
			<td>other_id_type</td>
			<td>conditionally</td>
			<td>
				"catalog number" or value from <a href="/info/ctDocumentation.cfm?table=CTCOLL_OTHER_ID_TYPE">CTCOLL_OTHER_ID_TYPE</a>.
				Must resolve to a single specimen.
			</td>
		</tr>
		<tr>
			<td>other_id_number</td>
			<td>conditionally</td>
			<td>Must resolve to a single specimen.</td>
		</tr>
		<tr>
			<td>scientific_name</td>
			<td>yes</td>
			<td>any valid ID</td>
		</tr>
		<tr>
			<td>nature_of_id</td>
			<td>yes</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTNATURE_OF_ID">CTNATURE_OF_ID</a></td>
		</tr>
		<tr>
			<td>made_date</td>
			<td>no</td>
			<td>ISO8601</td>
		</tr>
		<tr>
			<td>accepted_fg</td>
			<td>yes</td>
			<td>1 (this will become the accepted ID) or 0 (this will not become the accepted ID)</td>
		</tr>
		<tr>
			<td>identification_remarks</td>
			<td>no</td>
			<td>remarkable things</td>
		</tr>
		<tr>
			<td>agent_1</td>
			<td>no</td>
			<td>any unique name</td>
		</tr>
		<tr>
			<td>agent_2</td>
			<td>no</td>
			<td>any unique name</td>
		</tr>
	</table>

	<cfform name="oids" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file"
			name="FiletoUpload"
			size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" #saveClr#>
	</cfform>
</cfif>
<!------------------------------------------------------->
<cfif action is "makeTemplate">
	<cfset header="guid,guid_prefix,other_id_type,other_id_number,scientific_name,made_date,nature_of_id,accepted_fg,identification_remarks,agent_1,agent_2">
	<cffile action = "write"
    file = "#Application.webDirectory#/download/BulkloadIdentification.csv"
    output = "#header#"
    addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadIdentification.csv" addtoken="false">
</cfif>
<!------------------------------------------------------->

<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_id
	</cfquery>

	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">

	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				<cfset thisBit=arrResult[o][i]>
				<cfif #o# is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif #o# is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>
		<cfif len(#colVals#) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into cf_temp_id (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	data uploaded - <a href="BulkloadIdentification.cfm?action=validate">continue to validation</a>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "validate">
	<cfoutput>
		<p>
			validating
		</p>
		<p>
			this might take some time....
		</p>
		<p>
			if you have more than ~500 records you might need to reload a few times....
		</p>
		<p>
			if your browser is still spinning after ~5 minutes, it's probably stuck; stop and reload
		</p>
		<cfflush>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_id set status='missing data'
			where
			other_id_type is null or
			other_id_number is null or
			guid_prefix is null or
			scientific_name is null or
			nature_of_id is null or
			accepted_fg is null
		</cfquery>
		<cfquery name="noid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	        update cf_temp_id set status='invalid nature_of_id' where nature_of_id not in (select nature_of_id from ctnature_of_id) and
			status is null
	    </cfquery>
		<cfquery name="accepted_fg" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	        update cf_temp_id set status='invalid accepted_fg' where accepted_fg not in (0,1) and
	        status is null
	    </cfquery>
		<cfquery name="AGENT_1_ID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	        update
			  cf_temp_id
			set
			  AGENT_1_ID=getAgentId(agent_1)
		   where
		   	status is null and
		   	agent_1 is not null
	    </cfquery>
		<cfquery name="AGENT_2_ID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	        update
	          cf_temp_id
	        set
	          AGENT_2_ID=getAgentId(agent_2)
	       where status is null and
		   agent_2 is not null
	    </cfquery>
		<cfquery name="AGENT_1_ST" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	        update
	          cf_temp_id
	        set
	          status='agent_1 not found' where agent_1 is not null and AGENT_1_ID is null and status is null
	    </cfquery>
		<cfquery name="AGENT_2_ST" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	        update
	          cf_temp_id
	        set
	          status='agent_2 not found' where agent_2 is not null and AGENT_2_ID is null and status is null
	    </cfquery>
		<cfquery name="BADFORMULA" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	        update
	          cf_temp_id
	        set
	          status='This form will not handle multi-taxa formulae or A-string IDs. File a bug report.'
			where
			  STATUS IS NULL AND (
			       scientific_name LIKE '% / %' or
	               scientific_name LIKE '% or %' or
	               scientific_name LIKE '% and %' or
	               scientific_name LIKE '% x %' or
	               scientific_name LIKE '%{%' or
	               scientific_name LIKE '%}%'
			  )
	    </cfquery>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_id where status is null
		</cfquery>
		<cfloop query="data">
			<cftransaction>
				<cfset problem="">
				<cfset coid="">
				<cfset tnid="">
				<cfset tf="">
				<cfif other_id_type is not "catalog number">
					<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						SELECT
							coll_obj_other_id_num.collection_object_id
						FROM
							coll_obj_other_id_num,
							cataloged_item,
							collection
						WHERE
							coll_obj_other_id_num.collection_object_id = cataloged_item.collection_object_id and
							cataloged_item.collection_id = collection.collection_id and
							collection.guid_prefix = '#guid_prefix#' and
							coll_obj_other_id_num.other_id_type = '#trim(other_id_type)#' and
							coll_obj_other_id_num.display_value = '#trim(other_id_number)#'
					</cfquery>
				<cfelse>
					<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						SELECT
							collection_object_id
						FROM
							cataloged_item,
							collection
						WHERE
							cataloged_item.collection_id = collection.collection_id and
							collection.guid_prefix = '#guid_prefix#' and
							cataloged_item.cat_num='#other_id_number#'
					</cfquery>
				</cfif>
				<cfif collObj.recordcount is not 1>
					<cfset problem=listappend(problem,"#data.other_id_number# #data.other_id_type# #data.guid_prefix# could not be found",";")>
				<cfelse>
					<cfset coid=collObj.collection_object_id>
				</cfif>
				<cfif right(scientific_name,4) is " sp.">
					<cfset scientific_name=left(scientific_name,len(scientific_name) -4)>
					<cfset tf = "A sp.">
					<cfset TaxonomyTaxonName=left(scientific_name,len(scientific_name) - 4)>
				<cfelseif right(scientific_name,4) is " cf.">
					<cfset scientific_name=left(scientific_name,len(scientific_name) -4)>
					<cfset tf = "A cf.">
					<cfset TaxonomyTaxonName=left(scientific_name,len(scientific_name) - 4)>
				<cfelseif right(scientific_name,2) is " ?">
					<cfset scientific_name=left(scientific_name,len(scientific_name) -2)>
					<cfset tf = "A ?">
					<cfset TaxonomyTaxonName=left(scientific_name,len(scientific_name) - 2)>
				<cfelse>
					<cfset  tf = "A">
					<cfset TaxonomyTaxonName="#scientific_name#">
				</cfif>
				<cfquery name="isTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	                SELECT taxon_name_id FROM taxon_name WHERE scientific_name = '#TaxonomyTaxonName#'
	            </cfquery>
				<cfif isTaxa.recordcount is not 1>
					<cfset problem=listappend(problem,"taxonomy not found",";")>
				<cfelse>
					<cfset tnid=isTaxa.taxon_name_id>
				</cfif>
				<cfif len(problem) is 0>
					<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	                    UPDATE cf_temp_id SET
	                       taxon_name_id = #tnid#,
	                       taxa_formula='#tf#',
	                       collection_object_id=#coid#,
						   status='valid'
	                    where key = #key#
	                </cfquery>
				<cfelse>
					<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	                    UPDATE cf_temp_id SET status = '#problem#' where key = #key#
	                </cfquery>
				</cfif>
			</cftransaction>
		</cfloop>
		validation has either finished or timed out - reload, you should quicky get here - if not, reload again or check the table for status
		<a href="BulkloadIdentification.cfm?action=table">
			view in table
		</a>
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "table">
<script src="/includes/sorttable.js"></script>
<cfoutput>

		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	        select * from cf_temp_id order by status,
	            other_id_type,
	            other_id_number
	    </cfquery>

        <cfquery name="isProb" dbtype="query">
            select count(*) c from d where status != 'valid' and status != 'loaded'
        </cfquery>
        <cfif #isProb.c# is 0 or len(isprob.c) is 0>
            Data validated. Double-check the table. If everything looks OK, <a href="BulkloadIdentification.cfm?action=loadData">proceed to load</a>
        <cfelse>
            The data you loaded do not validate. See STATUS column in the table.
        </cfif>





	<table border id="t" class="sortable">
	   <tr>
          <th>status</th>
		  <th>guid_prefix</th>
          <th>other_id_type</th>
          <th>other_id_number</th>
          <th>scientific_name</th>
          <th>made_date</th>
          <th>nature_of_id</th>
          <th>accepted_fg</th>
          <th>identification_remarks</th>
          <th>agent_1</th>
          <th>agent_2</th>
		</tr>

		<cfloop query="d">
		 <tr>
          <td>#status#</td>
          <td>#guid_prefix#</td>
          <td>#other_id_type#</td>
          <td>#other_id_number#</td>
          <td>#scientific_name#</td>
          <td>#made_date#</td>
          <td>#nature_of_id#</td>
          <td>#accepted_fg#</td>
          <td>#identification_remarks#</td>
          <td>#agent_1#</td>
          <td>#agent_2#</td>
        </tr>
		</cfloop>



	</table>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "loadData">
<cfoutput>
	<p>
	   data are loading
	</p>
	<p>
	   if your browser isn't doing anything after ~5 minutes, it's probably stuck.
	</p>
	<p>
	   If you see the finished message below, and a reload completes quickly, it's probably done.
	</p>
	<p>
	   <a href="BulkloadIdentification.cfm?action=table"> check in table</a> to be sure; all status should be "loaded"
	</p>

	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_id where status='valid'
	</cfquery>

	<cfloop query="getTempData">
		<cftransaction>
		<cfif ACCEPTED_FG is 1>
			<cfquery name="whackOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update identification set ACCEPTED_ID_FG=0 where COLLECTION_OBJECT_ID=#COLLECTION_OBJECT_ID#
			</cfquery>
		</cfif>
		<cfquery name="insert" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into identification (
				IDENTIFICATION_ID,
				COLLECTION_OBJECT_ID,
				MADE_DATE,
				NATURE_OF_ID,
				ACCEPTED_ID_FG,
				IDENTIFICATION_REMARKS,
				TAXA_FORMULA,
				SCIENTIFIC_NAME
			) values (
				sq_identification_id.nextval,
				#COLLECTION_OBJECT_ID#,
				'#MADE_DATE#',
				'#NATURE_OF_ID#',
				#ACCEPTED_FG#,
				'#IDENTIFICATION_REMARKS#',
				'#TAXA_FORMULA#',
				'#SCIENTIFIC_NAME#'
			)
		</cfquery>
		<cfquery name="insertidt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into identification_taxonomy (
				IDENTIFICATION_ID,
				TAXON_NAME_ID,
				VARIABLE
			) values (
				sq_identification_id.currval,
				#TAXON_NAME_ID#,
				'A'
			)
		</cfquery>
		<cfif len(agent_1_id) gt 0>
			<cfquery name="insertida1" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into identification_agent (
					IDENTIFICATION_ID,
					AGENT_ID,
					IDENTIFIER_ORDER
				) values (
					sq_identification_id.currval,
					#agent_1_id#,
					1
				)
			</cfquery>
		</cfif>
		<cfif len(agent_2_id) gt 0>
			<cfquery name="insertida1" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into identification_agent (
					IDENTIFICATION_ID,
					AGENT_ID,
					IDENTIFIER_ORDER
				) values (
					sq_identification_id.currval,
					#agent_2_id#,
					2
				)
			</cfquery>
		</cfif>
		<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_id set status='loaded' where key=#key#
		</cfquery>
		</cftransaction>
	</cfloop>
    <p>If you're seeing this, it's probably done - but check the table</p>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">