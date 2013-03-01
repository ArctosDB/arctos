<cfabort>


<cfinclude template="/includes/_header.cfm">

	<script src="/includes/sorttable.js"></script>

<cfoutput>
<!-----------

create table temprelations as select * from cf_temp_relations

create table temprel (
 COLLECTION_OBJECT_ID number,
thisguid VARCHAR2(60),
 RELATIONSHIP  VARCHAR2(60),
 RELATED_TO_NUMBER VARCHAR2(60),
 original_RELATED_TO_NUMBER VARCHAR2(60),
 RELATED_TO_NUM_TYPE VARCHAR2(255),
 KEY NUMBER
);



temprelations
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 COLLECTION_OBJECT_ID						   NOT NULL NUMBER
 RELATIONSHIP							   NOT NULL VARCHAR2(60)
 RELATED_TO_NUMBER						   NOT NULL VARCHAR2(60)
 RELATED_TO_NUM_TYPE						   NOT NULL VARCHAR2(255)
 LASTTRYDATE								    DATE
 FAIL_REASON								    VARCHAR2(255)
 RELATED_COLLECTION_OBJECT_ID						    NUMBER
 INSERT_DATE							   NOT NULL DATE
 KEY								   NOT NULL NUMBER




update temprel set RELATED_TO_NUMBER=trim(RELATED_TO_NUMBER);

update temprel set RELATED_TO_NUM_TYPE='IF: Idaho Frozen Tissue Collection' where RELATED_TO_NUM_TYPE='IF';


update temprel set related_guid=null;


alter table temprel add related_guid VARCHAR2(60);
-------------->


<cfquery name="d" datasource="uam_god">
	select * from temprel
</cfquery>

<cfloop query="d">
	<hr>RELATED_TO_NUM_TYPE=#RELATED_TO_NUM_TYPE#
	<br>RELATED_TO_NUMBER=#RELATED_TO_NUMBER#
	<cfif RELATED_TO_NUM_TYPE is "catalog number">
		<cfset g=replace(RELATED_TO_NUMBER," ",":","all")>
		<cfquery name="f" datasource="uam_god">
			select guid from flat where upper(guid)='#ucase(g)#'
		</cfquery>
	<cfelse>
		<cfquery name="f" datasource="uam_god">
			select guid from
			flat,
			coll_obj_other_id_num
			where
			flat.collection_object_id=coll_obj_other_id_num.collection_object_id and
			other_id_type='#RELATED_TO_NUM_TYPE#' and
			display_value='#RELATED_TO_NUMBER#'
		</cfquery>
	</cfif>
	<br>got guid===#f.guid#
	<cfif f.recordcount is 1>
		<cfquery name="up" datasource="uam_god">
			update temprel set related_guid='#f.guid#' where key=#key# and RELATED_TO_NUMBER='#RELATED_TO_NUMBER#' and RELATED_TO_NUM_TYPE='#RELATED_TO_NUM_TYPE#'
		</cfquery>
	</cfif>

</cfloop>






<!------------------------------------------


BEGIN initial population or temprel

<cfquery name="d" datasource="uam_god">
	select * from temprelations
</cfquery>
		<table border id="t" class="sortable">
	<tr>
		<th>key</th>
		<th>COLLECTION_OBJECT_ID</td>
		<th>thois</th>
		<th>RELATIONSHIP</th>
		<th>RELATED_TO_NUMBER</th>
		<th>RELATED_TO_NUM_TYPE</th>
		<th>newrows</th>
	</tr>
	<cfloop query="d">
		<cfquery name="g" datasource="uam_god">
		select guid from flat where COLLECTION_OBJECT_ID=#COLLECTION_OBJECT_ID#
		</cfquery>

		<tr>
			<td>#key#</td>
			<td>#COLLECTION_OBJECT_ID#</td>
			<td>#g.guid#</td>
			<td>#RELATIONSHIP#</td>
			<td>#RELATED_TO_NUMBER#</td>
			<td>#RELATED_TO_NUM_TYPE#</td>
			<td>

				<cfif isnumeric(RELATED_TO_NUMBER)>
					#RELATED_TO_NUMBER#
					<cfquery name="insone" datasource="uam_god">
						insert into temprel (
						key,COLLECTION_OBJECT_ID,thisguid,RELATIONSHIP,original_RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,RELATED_TO_NUMBER) values (
						#key#,#COLLECTION_OBJECT_ID#,'#g.guid#','#RELATIONSHIP#','#RELATED_TO_NUMBER#','#RELATED_TO_NUM_TYPE#','#RELATED_TO_NUMBER#')
					</cfquery>
				<cfelseif RELATED_TO_NUMBER contains "," and RELATED_TO_NUMBER does not contain "-">
					<cfset n=replace(RELATED_TO_NUMBER," and ",",","all")>
					<cfloop list="#n#" delimiters="," index="x">
						<br>#x#
						<cfquery name="insone" datasource="uam_god">
							insert into temprel (
							key,COLLECTION_OBJECT_ID,thisguid,RELATIONSHIP,original_RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,RELATED_TO_NUMBER) values (
							#key#,#COLLECTION_OBJECT_ID#,'#g.guid#','#RELATIONSHIP#','#RELATED_TO_NUMBER#','#RELATED_TO_NUM_TYPE#','#x#')
						</cfquery>
					</cfloop>
				<cfelseif RELATED_TO_NUMBER contains "," and RELATED_TO_NUMBER contains "-">
					<cfif refind('[A-Za-z]',RELATED_TO_NUMBER)>
						(nonnumeric)-#RELATED_TO_NUMBER#
						<cfquery name="insone" datasource="uam_god">
							insert into temprel (
							key,COLLECTION_OBJECT_ID,thisguid,RELATIONSHIP,original_RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,RELATED_TO_NUMBER) values (
							#key#,#COLLECTION_OBJECT_ID#,'#g.guid#','#RELATIONSHIP#','#RELATED_TO_NUMBER#','#RELATED_TO_NUM_TYPE#','#RELATED_TO_NUMBER#')
						</cfquery>
					<cfelse>
						<cfset n=replace(RELATED_TO_NUMBER," and ",",","all")>
						<cfloop list="#n#" delimiters="," index="x">
							<cfif x contains "-">
								<cfset begin=listgetat(x,1,"-")>
								<cfset end=listgetat(x,2,"-")>
								<cfif isnumeric(begin) and isnumeric(end)>
									<cfif end - begin lte 20>
										<cfloop from="#begin#" to="#end#" index="z">
											<br>#z#
											<cfquery name="insone" datasource="uam_god">
												insert into temprel (
												key,COLLECTION_OBJECT_ID,thisguid,RELATIONSHIP,original_RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,RELATED_TO_NUMBER) values (
												#key#,#COLLECTION_OBJECT_ID#,'#g.guid#','#RELATIONSHIP#','#RELATED_TO_NUMBER#','#RELATED_TO_NUM_TYPE#','#z#')
											</cfquery>
										</cfloop>
									<cfelse>
										too_many_numbers
										<cfquery name="insone" datasource="uam_god">
											insert into temprel (
											key,COLLECTION_OBJECT_ID,thisguid,RELATIONSHIP,original_RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,RELATED_TO_NUMBER) values (
											#key#,#COLLECTION_OBJECT_ID#,'#g.guid#','#RELATIONSHIP#','#RELATED_TO_NUMBER#','#RELATED_TO_NUM_TYPE#','too_many_numbers')
										</cfquery>
									</cfif>
								<cfelse>
									<cfquery name="insone" datasource="uam_god">
										insert into temprel (
										key,COLLECTION_OBJECT_ID,thisguid,RELATIONSHIP,original_RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,RELATED_TO_NUMBER) values (
										#key#,#COLLECTION_OBJECT_ID#,'#g.guid#','#RELATIONSHIP#','#RELATED_TO_NUMBER#','#RELATED_TO_NUM_TYPE#','#RELATED_TO_NUMBER#')
									</cfquery>
								</cfif>
							<cfelse>
								<cfquery name="insone" datasource="uam_god">
									insert into temprel (
									key,COLLECTION_OBJECT_ID,thisguid,RELATIONSHIP,original_RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,RELATED_TO_NUMBER) values (
									#key#,#COLLECTION_OBJECT_ID#,'#g.guid#','#RELATIONSHIP#','#RELATED_TO_NUMBER#','#RELATED_TO_NUM_TYPE#','#RELATED_TO_NUMBER#')
								</cfquery>
							</cfif>
	<!----
					<cfelse>
						<br>#x#
						<cfquery name="insone" datasource="uam_god">
							insert into temprel (
							COLLECTION_OBJECT_ID,thisguid,RELATIONSHIP,original_RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,RELATED_TO_NUMBER) values (
							#COLLECTION_OBJECT_ID#,'#g.guid#','#RELATIONSHIP#','#RELATED_TO_NUMBER#','#RELATED_TO_NUM_TYPE#','#x#')
						</cfquery>
					</cfif>
					---->
					</cfloop>
				</cfif>
			<cfelseif RELATED_TO_NUMBER contains "-" and RELATED_TO_NUMBER does not contain ",">
			{-no,}
				<cfset begin=listgetat(RELATED_TO_NUMBER,1,"-")>
				<cfset end=listgetat(RELATED_TO_NUMBER,2,"-")>
				<cfif isnumeric(begin) and isnumeric(end)>
					<cfif end - begin lte 20 and end gt begin>
						<cfloop from="#begin#" to="#end#" index="x">
							<br>#x#
							<cfquery name="insone" datasource="uam_god">
								insert into temprel (
								key,COLLECTION_OBJECT_ID,thisguid,RELATIONSHIP,original_RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,RELATED_TO_NUMBER) values (
								#key#,#COLLECTION_OBJECT_ID#,'#g.guid#','#RELATIONSHIP#','#RELATED_TO_NUMBER#','#RELATED_TO_NUM_TYPE#','#x#')
							</cfquery>
						</cfloop>
					<cfelse>
						wtf....
						<cfquery name="insone" datasource="uam_god">
							insert into temprel (
							key,COLLECTION_OBJECT_ID,thisguid,RELATIONSHIP,original_RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,RELATED_TO_NUMBER) values (
							#key#,#COLLECTION_OBJECT_ID#,'#g.guid#','#RELATIONSHIP#','#RELATED_TO_NUMBER#','#RELATED_TO_NUM_TYPE#','#RELATED_TO_NUMBER#')
						</cfquery>
						</cfif>
					<cfelse>

					#RELATED_TO_NUMBER#
					<cfquery name="insone" datasource="uam_god">
						insert into temprel (
						key,COLLECTION_OBJECT_ID,thisguid,RELATIONSHIP,original_RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,RELATED_TO_NUMBER) values (
						#key#,#COLLECTION_OBJECT_ID#,'#g.guid#','#RELATIONSHIP#','#RELATED_TO_NUMBER#','#RELATED_TO_NUM_TYPE#','#RELATED_TO_NUMBER#')
					</cfquery>
				</cfif>
			<cfelseif RELATED_TO_NUMBER contains " and ">
						<cfset n=replace(RELATED_TO_NUMBER," and ",",","all")>
						<cfloop list="#n#" delimiters="," index="x">
							<br>#x#
							<cfquery name="insone" datasource="uam_god">
								insert into temprel (
								key,COLLECTION_OBJECT_ID,thisguid,RELATIONSHIP,original_RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,RELATED_TO_NUMBER) values (
								#key#,#COLLECTION_OBJECT_ID#,'#g.guid#','#RELATIONSHIP#','#RELATED_TO_NUMBER#','#RELATED_TO_NUM_TYPE#','#x#')
							</cfquery>
						</cfloop>
				<cfelse>
					#RELATED_TO_NUMBER#
					<cfquery name="insone" datasource="uam_god">
						insert into temprel (
						key,COLLECTION_OBJECT_ID,thisguid,RELATIONSHIP,original_RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,RELATED_TO_NUMBER) values (
						#key#,#COLLECTION_OBJECT_ID#,'#g.guid#','#RELATIONSHIP#','#RELATED_TO_NUMBER#','#RELATED_TO_NUM_TYPE#','#RELATED_TO_NUMBER#')
					</cfquery>
				</cfif>
			</td>
		</tr>
	</cfloop>
</table>





END initial population or temprel
	--------------------------------------------->
</cfoutput>