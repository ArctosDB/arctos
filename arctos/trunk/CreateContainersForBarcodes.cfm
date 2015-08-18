<cfinclude template = "includes/_header.cfm">
<cfset title="Create Containers">

<!----

create table cf_temp_container as select * from container where 1=2;
alter table cf_temp_container drop column container_id;
alter table cf_temp_container drop column PARENT_CONTAINER_ID;
alter table cf_temp_container drop column PRINT_FG;
alter table cf_temp_container drop column NUMBER_POSITIONS;
alter table cf_temp_container drop column LOCKED_POSITION;
alter table cf_temp_container drop column BYPASSCHECK;

alter table cf_temp_container modify barcode not null;

create or replace public synonym cf_temp_container for cf_temp_container;

grant all on cf_temp_container to manage_container;

create unique index iu_cf_temp_cntr_barcode on cf_temp_container (barcode);


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


<cfif action is "nothing">
	<cfoutput>
		<p>
			Before using this form, make sure that the container series you are creating is in the 
			<a href="http://arctosdb.org/documentation/container/##purchase" class="external" target="_blank">
				spreadsheet
			</a> and that there are no potential conflicts with other collections.
		</p>
		<p>
			<a href="CreateContainersForBarcodes?action=makeTemplate">get a template</a>
		</p>
		<cfquery name="ctContainer_Type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select container_type from ctcontainer_type where container_type like '%label%' order by container_type
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
				<td>#valuelist(ctContainer_Type.container_type)#</td>
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
			<tr>
				<td>WIDTH</td>
				<td>no</td>
				<td>
					<a href="http://arctosdb.org/documentation/container/##width_height_length" class="external" target="_blank">
						doc
					</a>
				</td>
			</tr>
			<tr>
				<td>HEIGHT</td>
				<td>no</td>
				<td>
					<a href="http://arctosdb.org/documentation/container/##width_height_length" class="external" target="_blank">
						doc
					</a>
				</td>
			</tr>
			<tr>
				<td>LENGTH</td>
				<td>no</td>
				<td>
					<a href="http://arctosdb.org/documentation/container/##width_height_length" class="external" target="_blank">
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


		<cfdump var=#x#>


<cfabort>




		<cfset sql="insert all ">

<!----
        <cfloop query="x">
            <cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	            insert into cf_temp_container (#cols#) values (
	            <cfloop list="#cols#" index="i">
	            	'#stripQuotes(evaluate(i))#'
	            	<cfif i is not listlast(cols)>
	            		,
	            	</cfif>
	            </cfloop>
	            )
            </cfquery>
        </cfloop>
		
---->		
		
	<cfset theLastColumnName=listlast(cols)>
	 <cfloop query="x">
	 	<cfset sql=sql & " into cf_temp_container  (#cols#) values (">
	 	 <cfloop list="#cols#" index="i">
           <!----
			<cfset sql=sql & "'#evaluate(i)#'">
			---->
			<cfset sql=sql & "'valuegoeshere'">
           	<cfif i is not theLastColumnName>
           		<cfset sql=sql & ",">
           	</cfif>
           </cfloop>
           <cfset sql=sql & ")">
	            
	            
        </cfloop>
		
		
				<cfset sql=sql & "SELECT 1 FROM DUAL">
				
				
				got that too<cfabort>
<cfdump var=#sql#>

<!----
		<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preserveSingleQuotes(sql)#
		</cfquery>
		---->
		
		
		
		<a href="CreateContainersForBarcodes?action=validate">loaded - proceed to validate</a>
	</cfoutput>
</cfif>

<!----------------------------------------------------------------------------------->
<cfif action is "validate">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from cf_temp_container where barcode in (select barcode from container)
	</cfquery>
	<cfif d.c gt 0>
		There are barcodes which already exist in your file; aborting.
		<cfabort>
	</cfif>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from cf_temp_container where barcode != LABEL
	</cfquery>
	<cfif d.c gt 0>
		<p>
			There are records where barcode != label in your file. That's probably a bad idea. Proceed with caution.
		</p>
	</cfif>
	
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from cf_temp_container where barcode != trim(barcode)
	</cfquery>
	<cfif d.c gt 0>
		<p>
			There are spaces in barcode. Aborting.
			<cfabort>
		</p>
	</cfif>
	
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from cf_temp_container where container_type not in (select container_type from ctcontainer_type where container_type like '%label%')
	</cfquery>
	<cfif d.c gt 0>
		<p>
			Invalid container_type. Aborting.
			<cfabort>
		</p>
	</cfif>
	
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from cf_temp_container where institution_acronym not in (select institution_acronym from collection)
	</cfquery>
	<cfif d.c gt 0>
		<p>
			Invalid institution_acronym. Aborting.
			<cfabort>
		</p>
	</cfif>
	
	
	<a href="CreateContainersForBarcodes?action=load">proceed to load</a>
</cfif>

<cfinclude template = "includes/_footer.cfm">