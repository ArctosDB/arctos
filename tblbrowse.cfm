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

create unique index ixu_temp_arc_tab_tbl on temp_arctos_tbl_list (tbl) tablespace uam_idx_1;
drop index ixu_temp_arc_tab_tbl;
create table arctos_table_names as select * from temp_arctos_tbl_list;

select rowid from arctos_table_names where tbl='ACCN';
create unique index ixu_arctos_table_names_tbl on arctos_table_names (tbl) tablespace uam_idx_1;


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


alter table arctos_table_columns add nullable varchar2(255);
alter table arctos_table_columns add DATA_LENGTH varchar2(255);
alter table arctos_table_columns add DATA_PRECISION varchar2(255);
alter table arctos_table_columns add DATA_SCALE varchar2(255);





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
				<!--- flush old constraints, we'll just readd them all below ---->
				<cfquery name="fold" datasource="uam_god">
					delete from arctos_keys
				</cfquery>
				<!--- /flush old constraints ---->
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
					<!---- remove any removed table/columns ---->
					<cfquery name="delmia" datasource="uam_god">
						delete from arctos_table_columns where table_name='#d.tbl#' and COLUMN_NAME not in (
							select
								COLUMN_NAME
							from
								all_tab_cols
							where
								column_name not like 'SYS_%' and
								owner='UAM' and
								TABLE_NAME='#d.tbl#'
						)
					</cfquery>
					<!---- /remove any removed table/columns ---->
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
		<!---------------------------------------------------------->
		<cfif action is "delete">
			Are you absolutely sure you want to remove
			#tbl#?
			<p>
				You should probably be a DBA if you're clicking here.
			</p>
			<a href="tblbrowse.cfm?action=reallydelete&tbl=#tbl#">yea yea nuke it</a>
		</cfif>
		<!---------------------------------------------------------->
		<cfif action is "reallydelete">
			<cftransaction>
				<cfquery name="d" datasource="uam_god">
					delete from arctos_table_names where tbl='#TBL#'
				</cfquery>
				<cfquery name="d" datasource="uam_god">
					delete from arctos_table_columns where TABLE_NAME='#TBL#'
				</cfquery>
			</cftransaction>
			#tbl# removed <a href="tblbrowse.cfm">continue</a>
		</cfif>
		<!---------------------------------------------------------->
		<cfif action is "addtable">
			<cfquery name="d" datasource="uam_god">
				insert into arctos_table_names (tbl) values ('#ucase(TBL)#')
			</cfquery>
			#tbl# added <a href="tblbrowse.cfm">continue</a>
		</cfif>
		<!---------------------------------------------------------->
		<cfif action is "addtablefromnl">
			<cfquery name="d" datasource="uam_god">
				insert into arctos_table_names (tbl) values ('#ucase(TBL)#')
			</cfquery>
			<cflocation url="tblbrowse.cfm?action=uamnotinlist###anchhr#" addtoken="false">
		</cfif>
		<!---------------------------------------------------------->
		<cfif action is "uamnotinlist">
			<cfquery name="d" datasource="uam_god">
				select table_name from all_tables where owner = 'UAM' and table_name not in (select tbl from arctos_table_names)
				order by table_name
			</cfquery>
			<cfset anchhr="">
			<p>
				<a href="tblbrowse.cfm">back to list</a>
			</p>
			<cfloop query="d">
				<div>
					#table_name# <a name=#table_name# href="tblbrowse.cfm?action=addtablefromnl&tbl=#table_name#&anchhr=#anchhr#">add to arctos tables list</a>
				</div>
				<cfset anchhr=table_name>
			</cfloop>
		</cfif>

		<!---------------------------------------------------------->
		<cfif action is "nothing">
			<cfquery name="d" datasource="uam_god">
				select * from arctos_table_names order by tbl
			</cfquery>
			List of data tables in Arctos.
			<p>
				This list should be limited to "primary data tables" and EXCLUDE
				<ul>
					<li>Code tables (ctxxxxx)</li>
					<li>Collection-specific code tables (cctxxxxx)</li>
					<li>ColdFusion/"web app" tables (cfxxxx)</li>
					<li>Project-specific tables (ala, es, etc.)</li>
					<li>"processing" tables (bulkloader)</li>
					<li>Logs</li>
					<li>Temp tables</li>
					<li>"Helper" tables, like common name and geog search terms</li>
					<li>Anything not owned by UAM (schema owner)</li>
					<li>Backups and random garbage</li>
					<li>Anything you're not SURE should be here</li>
				</ul>
			</p>
			<p>
				This list is used in exporting collections and providing structure-based documentation. The table list
				and table.column documentation are user-provided; everything else is derived from DDL.
			</p>
			<p>
				If you feel something is missing or should not have been included, please contact a DBA before adding it. If you're
				really sure and/or are a DBA, use this:
				 <form name="at" method="post" action="tblbrowse.cfm">
					 <input type="hidden" name="action" value="addtable">
					<label for="tbl">Add Table</label>
					<input type="text" name="tbl">
					<br><input type="submit" value="add table">
				</form>
			</p>
			<p>
				Or <a href="tblbrowse.cfm?action=uamnotinlist">click here</a> for a list of all tables owned by UAM and not in the list.
				<br>Read ^^ that stuff up there before clicking this.
				<br>Seriously.
				<br>Read it.
			</p>
			<p>
				DELETE WITH GREAT CAUTION! The data behind this form do other stuff, and there's a lot of blood sweat and tears in
				the documentation. Talk to a DBA before deleting anything.
				If you are a DBA, use the links below.
			</p>
			<p>
				Some of this page is generated by scripts and may be out of date.
				<br><a href="tblbrowse.cfm?action=rebuildDDL">Click here to refresh data</a>
				<br>It'll take a while.
			</p>
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
					<cfif left(tbl,2) is "CT">
						This looks like a code table: Try this link.
						<a href="/info/ctDocumentation.cfm?table=#tbl#<">/info/ctDocumentation.cfm?table=#tbl#</a>
					</cfif>
				</p>
				<p>
					If you think there should be something here, please contact a DBA.
				</p>
				<p>
					If you've recently added a table, try <a href="tblbrowse.cfm?action=rebuildDDL">clicking here to refresh data</a>
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
								<textarea name="description_#column_name#_dammitcf">#description#</textarea>
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
						<!---
							if we don't do this CF's craptacular antique validation idiocy thingee will flip out on
							field names like whatever_date and probably some other stuff.
						---->
						<cfset tf=replace(f,"DESCRIPTION_","")>
						<cfset tf=replace(tf,"_DAMMITCF","")>
						<cfset tv=evaluate(f)>
						<cfquery name="uv" datasource="uam_god">
							update arctos_table_columns set DESCRIPTION='#tv#' where
							TABLE_NAME='#tbl#' and
							COLUMN_NAME='#tf#'
						</cfquery>
					</cfif>
				</cfloop>
			</cftransaction>
			<cflocation url="tblbrowse.cfm?action=tbldetail&tbl=#tbl#" addtoken="false">
		</cfif>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">