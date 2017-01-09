<cfinclude template = "includes/_header.cfm">
<cfset title="Create Containers">
<cfsetting requesttimeout="600">


<!----

	create table cf_temp_container as select * from container where 1=2;
	alter table cf_temp_container drop column container_id;
	alter table cf_temp_container drop column PARENT_CONTAINER_ID;
	alter table cf_temp_container drop column PRINT_FG;
	alter table cf_temp_container drop column NUMBER_POSITIONS;
	alter table cf_temp_container drop column LOCKED_POSITION;
	alter table cf_temp_container drop column BYPASSCHECK;
	alter table cf_temp_container drop column WIDTH;
	alter table cf_temp_container drop column HEIGHT;
	alter table cf_temp_container drop column LENGTH;

	alter table cf_temp_container modify barcode not null;

	create or replace public synonym cf_temp_container for cf_temp_container;

	grant all on cf_temp_container to manage_container;

	create unique index iu_cf_temp_cntr_barcode on cf_temp_container (barcode);

	 drop index iu_cf_temp_cntr_barcode;


	drop table cf_temp_container;
---->

<cfif action is "makeTemplate">
	<cfquery name="h" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_container where 1=2
	</cfquery>
	<cfset header=h.columnlist>
	<cffile action = "write"
    file = "#Application.webDirectory#/download/CreateContainerTemplate.csv"
    output = "#header#"
    addNewLine = "no">
	<cflocation url="/download.cfm?file=CreateContainerTemplate.csv" addtoken="false">
</cfif>
<!---------------------------------->
<cfif action is "nothing">
	<cfquery name="buhbyt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_container
	</cfquery>
	<cfoutput>
		<p>
			Before using this form, make sure that the container series (no matter how small)
			<a href="/info/barcodeseries.cfm">
				has been claimed
			</a> and that there are no potential conflicts with other collections.
		</p>
		<p>
			This form has been tested to 50,000 records; with significantly more than that or a slow connection,
			smaller batches may be necessary.
		</p>
		<p>
			<a href="CreateContainersForBarcodes.cfm?action=makeTemplate">get a template</a>
		</p>
		<cfquery name="ctContainer_Type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select container_type from ctcontainer_type order by container_type
		</cfquery>
		<cfquery name="ctinstitution_acronym" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select institution_acronym from collection group by institution_acronym order by institution_acronym
		</cfquery>
		<table border>
			<tr>
				<th>Field</th>
				<th>Required?</th>
				<th>Doc/values</th>
			</tr>
			<tr>
				<td>CONTAINER_TYPE</td>
				<td>yes</td>
				<td>#valuelist(ctContainer_Type.container_type)# </td>
			</tr>
			<tr>
				<td>LABEL</td>
				<td>yes</td>
				<td>
					<a href="http://arctosdb.org/documentation/container/##label" class="external" target="_blank">
						doc
					</a>
				</td>
			</tr>
			<tr>
				<td>BARCODE</td>
				<td>yes</td>
				<td>
					<a href="http://arctosdb.org/documentation/container/##barcode" class="external" target="_blank">
						doc
					</a>
				</td>
			</tr>
			<tr>
				<td>INSTITUTION_ACRONYM</td>
				<td>yes</td>
				<td>#valuelist(ctinstitution_acronym.institution_acronym)#</td>
			</tr>
			<tr>
				<td>DESCRIPTION</td>
				<td>no</td>
				<td>
					<a href="http://arctosdb.org/documentation/container/##description" class="external" target="_blank">
						doc
					</a>
				</td>
			</tr>
			<tr>
				<td>CONTAINER_REMARKS</td>
				<td>no</td>
				<td>
					<a href="http://arctosdb.org/documentation/container/##remarks" class="external" target="_blank">
						doc
					</a>
				</td>
			</tr>
		</table>
  		Upload CSV:
		<cfform name="getFile" method="post" action="CreateContainersForBarcodes.cfm" enctype="multipart/form-data">
			<input type="hidden" name="action" value="getFileData">
			 <input type="file"
				   name="FiletoUpload"
				   size="45" onchange="checkCSV(this);">
			<input type="submit" value="Upload this file" class="savBtn">
		</cfform>
	</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<cfif action is "getFileData">
	<cfoutput>
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
        <cfset  util = CreateObject("component","component.utilities")>
		<cfset x=util.CSVToQuery(fileContent)>
        <cfset cols=x.columnlist>
		<cfset hccols="CONTAINER_TYPE,LABEL,DESCRIPTION,CONTAINER_REMARKS,BARCODE,INSTITUTION_ACRONYM">
		<cfset sql="select ">
		<cfloop list="#hccols#" index="l">
			<cfif listfindnocase(cols,l)>
				<cfset sql=sql & #l#>
			<cfelse>
				<cfset sql=sql & "'' as #l#">
			</cfif>
		 	<cfif l is not listlast(hccols)>
          		<cfset sql=sql & ",">
          	</cfif>
		</cfloop>
		<cfquery name="ss" dbtype="query">
			#sql# from x
		</cfquery>
		<cftransaction>
	        <cfloop query="ss">
				<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into cf_temp_container (CONTAINER_TYPE,LABEL,DESCRIPTION,CONTAINER_REMARKS,BARCODE,INSTITUTION_ACRONYM) values ('#CONTAINER_TYPE#','#LABEL#','#DESCRIPTION#','#CONTAINER_REMARKS#','#BARCODE#','#INSTITUTION_ACRONYM#')
				</cfquery>
			</cfloop>
		</cftransaction>
		<a href="CreateContainersForBarcodes.cfm?action=validate">loaded - proceed to validate</a>
	</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<cfif action is "validate">
	<cfset p="">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from cf_temp_container where barcode in (select barcode from container where barcode is not null)
	</cfquery>
	<cfif d.c gt 0>
		<cfset p=listappend(p,'Existing barcodes detected',';')>
	</cfif>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select barcode, count(barcode) c from cf_temp_container group by barcode having count(barcode) > 1
	</cfquery>
	<cfif d.c gt 0>
		<cfset p=listappend(p,'Duplicate barcodes detected',';')>
	</cfif>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from cf_temp_container where barcode != trim(barcode)
	</cfquery>
	<cfif d.c gt 0>
		<cfset p=listappend(p,'Untrimmed barcodes detected',';')>
	</cfif>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from cf_temp_container where container_type != 'position' and container_type
		 not in (select container_type from ctcontainer_type where container_type like '%label%')
	</cfquery>
	<cfif d.c gt 0>
		<cfset p=listappend(p,'Invalid container_type',';')>
	</cfif>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from cf_temp_container where institution_acronym not in (select institution_acronym from collection)
	</cfquery>
	<cfif d.c gt 0>
		<cfset p=listappend(p,'Invalid institution_acronym',';')>
	</cfif>
	<cfif len(p) gt 0>
		<cfthrow message='#p#; this form is a very bad place to experiment'>
	</cfif>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from cf_temp_container where barcode != LABEL
	</cfquery>
	<cfif d.c gt 0>
		<p>
			Barcode - label mismatch detected. Proceed with great caution.
		</p>
	</cfif>
	<a href="CreateContainersForBarcodes.cfm?action=load">proceed to load</a>
</cfif>
<!------------------------------------------------>
<cfif action is "load">
	<cfstoredproc procedure="batchCreateContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	</cfstoredproc>
	done
</cfif>

<cfinclude template = "includes/_footer.cfm">