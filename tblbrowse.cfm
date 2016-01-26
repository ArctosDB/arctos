<!-----



-- create a list of used tables
-- exclude admin stuff,
-- temp stuff,
-- bulkloaders,
-- ct,
-- cf,
-- etc.


create table temp_arctos_tbl_list (tbl varchar2(255));

insert into temp_arctos_tbl_list (tbl) values ('ACCN');
insert into temp_arctos_tbl_list (tbl) values ('ADDRESS');
insert into temp_arctos_tbl_list (tbl) values ('AGENT');
insert into temp_arctos_tbl_list (tbl) values ('AGENT_NAME');
insert into temp_arctos_tbl_list (tbl) values ('AGENT_RELATIONS');
insert into temp_arctos_tbl_list (tbl) values ('AGENT_STATUS');
insert into temp_arctos_tbl_list (tbl) values ('ATTRIBUTES');
insert into temp_arctos_tbl_list (tbl) values ('BORROW');
insert into temp_arctos_tbl_list (tbl) values ('CATALOGED_ITEM');
insert into temp_arctos_tbl_list (tbl) values ('CITATION');
insert into temp_arctos_tbl_list (tbl) values ('COLLECTING_EVENT');
insert into temp_arctos_tbl_list (tbl) values ('COLLECTION');
insert into temp_arctos_tbl_list (tbl) values ('COLLECTOR');
insert into temp_arctos_tbl_list (tbl) values ('COLL_OBJECT');
insert into temp_arctos_tbl_list (tbl) values ('COLL_OBJECT_REMARK');
insert into temp_arctos_tbl_list (tbl) values ('COLL_OBJ_OTHER_ID_NUM');
insert into temp_arctos_tbl_list (tbl) values ('DOI');
insert into temp_arctos_tbl_list (tbl) values ('ENCUMBRANCE');
insert into temp_arctos_tbl_list (tbl) values ('GEOG_AUTH_REC');
insert into temp_arctos_tbl_list (tbl) values ('GROUP_MEMBER');
insert into temp_arctos_tbl_list (tbl) values ('IDENTIFICATION');
insert into temp_arctos_tbl_list (tbl) values ('IDENTIFICATION_AGENT');
insert into temp_arctos_tbl_list (tbl) values ('IDENTIFICATION_TAXONOMY');
insert into temp_arctos_tbl_list (tbl) values ('LOAN');
insert into temp_arctos_tbl_list (tbl) values ('LOAN_ITEM');
insert into temp_arctos_tbl_list (tbl) values ('LOCALITY');
insert into temp_arctos_tbl_list (tbl) values ('MEDIA');
insert into temp_arctos_tbl_list (tbl) values ('MEDIA_LABELS');
insert into temp_arctos_tbl_list (tbl) values ('MEDIA_RELATIONS');
insert into temp_arctos_tbl_list (tbl) values ('OBJECT_CONDITION');
insert into temp_arctos_tbl_list (tbl) values ('PERMIT');
insert into temp_arctos_tbl_list (tbl) values ('PERMIT_SHIPMENT');
insert into temp_arctos_tbl_list (tbl) values ('PERMIT_TRANS');
insert into temp_arctos_tbl_list (tbl) values ('PROJECT');
insert into temp_arctos_tbl_list (tbl) values ('PROJECT_AGENT');
insert into temp_arctos_tbl_list (tbl) values ('PROJECT_PUBLICATION');
insert into temp_arctos_tbl_list (tbl) values ('PROJECT_TAXONOMY');
insert into temp_arctos_tbl_list (tbl) values ('PROJECT_TRANS');
insert into temp_arctos_tbl_list (tbl) values ('PUBLICATION');
insert into temp_arctos_tbl_list (tbl) values ('PUBLICATION_AGENT');
insert into temp_arctos_tbl_list (tbl) values ('SHIPMENT');
insert into temp_arctos_tbl_list (tbl) values ('SPECIMEN_EVENT');
insert into temp_arctos_tbl_list (tbl) values ('SPECIMEN_PART');
insert into temp_arctos_tbl_list (tbl) values ('SPECIMEN_PART_ATTRIBUTE');
insert into temp_arctos_tbl_list (tbl) values ('TAG');
insert into temp_arctos_tbl_list (tbl) values ('TAXON_NAME');
insert into temp_arctos_tbl_list (tbl) values ('TAXON_TERM');
insert into temp_arctos_tbl_list (tbl) values ('TRANS');
insert into temp_arctos_tbl_list (tbl) values ('TRANS_AGENT');
insert into temp_arctos_tbl_list (tbl) values ('TRANS_CONTAINER');



create table arctos_table_names as select * from temp_arctos_tbl_list;

drop table arctos_table_columns;
--- make a nice place to document stuff
create table arctos_table_columns (
	table_name varchar2(255) not null,
	column_name varchar2(255) not null,
	description varchar2(4000)
);

-- and store the keys

drop table arctos_keys;

create table arctos_keys (
	o_table_name varchar2(255) not null,
	o_column_name varchar2(255) not null,
	c_constraint_name varchar2(255) not null,
	r_table_name varchar2(255) not null,
	r_column_name varchar2(255) not null,
	r_constraint_name  varchar2(255) not null
);



delete from arctos_table_columns;
delete from arctos_keys;


begin
	for r in(select tbl from temp_arctos_tbl_list order by tbl) loop
		dbms_output.put_line(r.tbl);

		for c in (select COLUMN_NAME from all_tab_cols where column_name not like 'SYS_%' and owner='UAM' and TABLE_NAME=r.tbl) loop
			dbms_output.put_line('    ' || c.COLUMN_NAME);
			insert into arctos_table_columns (table_name,column_name) values (r.tbl,c.COLUMN_NAME);
		end loop;

		for k in (
			SELECT UC.TABLE_NAME o_table_name,
			       UCC2.CONSTRAINT_NAME o_constraint_name,
			       UCC2.COLUMN_NAME o_column_name,
			       UCC.TABLE_NAME r_table_name,
			       UC.R_CONSTRAINT_NAME r_constraint_name,
			       UCC.COLUMN_NAME r_column_name
			   FROM (SELECT TABLE_NAME, CONSTRAINT_NAME, R_CONSTRAINT_NAME, CONSTRAINT_TYPE FROM USER_CONSTRAINTS) UC,
			        (SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME FROM USER_CONS_COLUMNS) UCC,
			        (SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME FROM USER_CONS_COLUMNS) UCC2
			   WHERE UC.R_CONSTRAINT_NAME = UCC.CONSTRAINT_NAME
			     AND UC.CONSTRAINT_NAME = UCC2.CONSTRAINT_NAME
			     AND uc.constraint_type = 'R'
			     and UC.TABLE_NAME=r.tbl
         ) loop
				insert into arctos_keys (
					o_table_name,
					o_column_name,
					C_CONSTRAINT_NAME,
					r_table_name,
					r_column_name,
					r_constraint_name
				) values (
					k.o_table_name,
					k.o_column_name,
					k.o_constraint_name,
					k.r_table_name,
					k.r_column_name,
					k.r_constraint_name);
		end loop;
	end loop;
end;
/



----->

<cfinclude template="/includes/_header.cfm">


	<cfset title="table browser thingee">
	<script src="/includes/sorttable.js"></script>

	<cfoutput>
		<cfif action is "rebuildDDL">
			<cftransaction>
				<cfquery name="d" datasource="uam_god">
					select tbl from arctos_table_names order by tbl
				</cfquery>
				<cfloop query="d">
					<!--- grab any missing table/columns ---->
					<cfquery name="atc" datasource="uam_god">
						select
							COLUMN_NAME
						from
							all_tab_cols
						where
							column_name not like 'SYS_%' and
							owner='UAM' and
							TABLE_NAME='#d.tbl#' and
							(table_name,column_name) not in (select table_name,column_name from arctos_table_columns)
					</cfquery>
					<cfloop query="atc">
						<cfquery name="insmia" datasource="uam_god">
							insert into arctos_table_columns (table_name,column_name) values ('#d.tbl#','#atc.COLUMN_NAME#')
						</cfquery>
					</cfloop>
					<!--- /grab any missing table/columns ---->
					<!--- flush old constraints ---->
					<cfquery name="fold" datasource="uam_god">
						delete from arctos_keys
					</cfquery>
					<!--- /flush old constraints ---->
					<!--- pull constraints ---->
					<cfquery name="cst" datasource="uam_god">
						SELECT
							UC.TABLE_NAME o_table_name,
					       UCC2.CONSTRAINT_NAME o_constraint_name,
					       UCC2.COLUMN_NAME o_column_name,
					       UCC.TABLE_NAME r_table_name,
					       UC.R_CONSTRAINT_NAME r_constraint_name,
					       UCC.COLUMN_NAME r_column_name
					   	FROM (SELECT TABLE_NAME, CONSTRAINT_NAME, R_CONSTRAINT_NAME, CONSTRAINT_TYPE FROM USER_CONSTRAINTS) UC,
					        (SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME FROM USER_CONS_COLUMNS) UCC,
					        (SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME FROM USER_CONS_COLUMNS) UCC2
					   WHERE UC.R_CONSTRAINT_NAME = UCC.CONSTRAINT_NAME
					     AND UC.CONSTRAINT_NAME = UCC2.CONSTRAINT_NAME
					     AND uc.constraint_type = 'R'
					     and UC.TABLE_NAME='#d.tbl#'
					</cfquery>
					<cfloop query="cst">
						<cfquery name="icst" datasource="uam_god">
							insert into arctos_keys (
								o_table_name,
								o_column_name,
								C_CONSTRAINT_NAME,
								r_table_name,
								r_column_name,
								r_constraint_name
							) values (
								'#o_table_name#',
								'#o_column_name#',
								'#o_constraint_name#',
								'#r_table_name#',
								'#r_column_name#',
								'#r_constraint_name#'
							)
						</cfquery>
					</cfloop>
				</cfloop>
			</cftransaction>
			<a href="tblbrowse.cfm">continue</a>
		</cfif>


		<cfif action is "delete">
			Are you absolutely sure you want to remove
			#tbl#?
			<p>
				You should probably be a DBA if you're clicking here.
			</p>
			<a href="tblbrowse.cfm?action=reallydelete&tbl=#tbl#">yea yea nuke it</a>
		</cfif>
		<cfif action is "reallydelete">
			<cfquery name="d" datasource="uam_god">
				delete from arctos_table_names where tbl='#TBL#'
			</cfquery>
			#tbl# removed <a href="tblbrowse.cfm">continue</a>
		</cfif>


		<cfif action is "addtable">
			<cfquery name="d" datasource="uam_god">
				insert into arctos_table_names (tbl) values ('#ucase(TBL)#')
			</cfquery>
			#tbl# added <a href="tblbrowse.cfm">continue</a>
		</cfif>

		<cfif action is "nothing">
			<cfquery name="d" datasource="uam_god">
				select * from arctos_table_names order by tbl
			</cfquery>
			List of data tables in Arctos.
			<br>Excludes authorities, "working" tables, etc.
			<br>If you feel something is missing or should not have been included, please contact a DBA before adding it;
			 the data behind this form do other stuff.
			 <form name="at" method="post" action="tblbrowse.cfm">
				 <input type="hidden" name="action" value="addtable">
				<label for="tbl">Add Table</label>
				<input type="text" name="tbl">
				<br><input type="submit" value="add table">
			</form>
			<br>Click a table to view details
			<br>DELETE WITH GREAT CAUTION! The data behind this form do other stuff. Talk to a DBA before deleting anything.

			<br>This page is generated by scripts and may be out of date.
			<a href="tblbrowse.cfm?action=rebuildDDL">Click here to refresh data</a>
			<cfloop query="d">
				<div>
					<a href="tblbrowse.cfm?action=tbldetail&tbl=#tbl#">#tbl#</a> -
					<a href="tblbrowse.cfm?action=delete&tbl=#tbl#">delete</a>
				</div>
			</cfloop>
		</cfif>
<!---------------------------------------------->
		<cfif action is "tbldetail">
			<cfquery name="tcols" datasource="uam_god">
				select * from arctos_table_columns where table_name='#tbl#'
			</cfquery>
			<cfif tcols.recordcount lt 1>
				Notfound.
				<p>
					This application deals only with "data tables."
				</p>
				<p>
					Code tables are excluded and may be accessed at <a href="/info/ctDocumentation.cfm">/info/ctDocumentation.cfm</a>
				</p>
				<p>
					If you think there should be something here, please contact a DBA.
				</p>
				<p>
					<a href="tblbrowse.cfm">back to list</a>
				</p>
				<cfabort>
			</cfif>
			<cfquery name="trels" datasource="uam_god">
				select * from arctos_keys where o_table_name='#tbl#' or r_table_name='#tbl#'
			</cfquery>
			<p>
				<a href="tblbrowse.cfm">back to list</a>
			</p>
			<h2>
				Constraints on #tbl#
			</h2>
			<table border>
				<tr>
					<th>ConstraintName</th>
					<th>OriginatesFrom</th>
					<th>ReferencesConstraint</th>
					<th>ReferencesColumn</th>
				</tr>
				<cfloop query="trels">
					<tr>
						<td>
							#C_CONSTRAINT_NAME#
						</td>
						<td>
							<a href="tblbrowse.cfm?action=tbldetail&tbl=#o_table_name#">#o_table_name#</a>.#o_column_name#
						</td>
						<td>
							#r_constraint_name#
						</td>
						<td>
							<a href="tblbrowse.cfm?action=tbldetail&tbl=#r_table_name#">#r_table_name#</a>.#r_column_name#
						</td>
					</tr>
				</cfloop>
			</table>

			<h2>
				#tbl# columns
			</h2>
			<cfquery name="utc" datasource="uam_god">
				select * from user_tab_cols where table_name='#tbl#'
			</cfquery>
			<form method="post" action="tblbrowse.cfm">
				<input type="hidden" name="action" value="saveColDescr">
				<input type="hidden" name="tbl" value="#tbl#">
				<table border>
					<tr>
						<th>Column Name</th>
						<th>Description</th>
						<th>DATA_TYPE</th>
						<th>NULLABLE</th>
						<th>DATA_LENGTH</th>
						<th>PRECISION</th>
						<th>SCALE</th>
					</tr>
					<cfloop query="tcols">
						<cfquery name="tutc" dbtype="query">
							select * from utc where column_name='#column_name#'
						</cfquery>


						<tr>
							<td>#column_name#</td>
							<td>
								<textarea name="description_#column_name#">#description#</textarea>
							</td>
							<td>#tutc.DATA_TYPE#</td>
							<td>#tutc.NULLABLE#</td>
							<td>#tutc.DATA_LENGTH#</td>
							<td>#tutc.DATA_PRECISION#</td>
							<td>#tutc.DATA_SCALE#</td>
						</tr>
					</cfloop>
				</table>
				<input type="submit" value="save descriptions">
			</form>
		</cfif>
		<cfif action is "saveColDescr">
			<cftransaction>
				<cfloop list="#form.FIELDNAMES#" index="f">
					<cfif left(f,11) is "DESCRIPTION">
						<cfset tf=replace(f,"DESCRIPTION_","")>
						<cfset tv=evaluate(f)>
						<cfquery name="uv" datasource="uam_god">
							update arctos_table_columns set DESCRIPTION='#tv#' where
							TABLE_NAME='#tlb#' and
							COLUMN_NAME='#tf#'
						</cfquery>

					</cfif>
				</cfloop>
			</cftransaction>
			<cflocation url="tblbrowse.cfm?action=tbldetail&tbl=#tbl#" addtoken="false">
		</cfif>


		<!----
		<form name="s" method="get" action="tblbrowse.cfm">
			<input type="hidden" name="action" id="action" value="srch">
			<input type="hidden" name="tbl" id="tbl" value="#tbl#">
			<cfloop query="tcols">
				<cfif structkeyexists(url,"#COLUMN_NAME#")>
					<cfset v=structfind(url,"#COLUMN_NAME#")>
				<cfelse>
					<cfset v="">
				</cfif>
				<label for="#COLUMN_NAME#">#COLUMN_NAME#</label>
				<input type="text" name="#COLUMN_NAME#" value="#v#" id="#COLUMN_NAME#">
			</cfloop>
			<br>
			<input type="submit" value="search">
		</form>
	<cfif action is "srch">
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from #tbl# where 1=1
			<cfloop collection="#url#" item="key">
				<cfif key is not "tbl" and key is not "action" and len(url[key]) gt 0>
					and upper(#key#) like '%#ucase(url[key])#%'
				</cfif>
			</cfloop>
			and rownum<1001
		</cfquery>
		<cfif d.recordcount gt 0>
			max 1k rows
			<table border id="t" class="sortable">
				<tr>
					<cfloop query="tcols">
						<th>#COLUMN_NAME#</th>
					</cfloop>
				</tr>
				<cfloop query="d">
					<tr>
						<cfloop query="tcols">
							<td>#evaluate("d." & COLUMN_NAME)#</td>
						</cfloop>
					</tr>
				</cfloop>
			</table>
		<cfelse>
			notfound
		</cfif>
	</cfif>
	---->
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">