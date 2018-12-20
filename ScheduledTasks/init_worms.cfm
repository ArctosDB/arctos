<!----

make full classification records including relationships from worms download


first pass: do something with the stuff we just made
 - first-first: accepted

select TAXONOMICSTATUS, count(*) from temp_worms group by TAXONOMICSTATUS;

select NOMENCLATURALCODE, count(*) from temp_worms group by NOMENCLATURALCODE;

select status || '@ ' || count(*) from temp_worms group by status order by status;

update temp_worms set status='valid' where scientificname='Ataxophragmiidae';

select distinct TAXONRANK from temp_worms where TAXONRANK not in (select distinct taxon_term from cttaxon_term);
select scientificname from temp_worms where status='insert_classification_fail';

update temp_worms set status='valid' where status='insert_classification_fail';

update temp_worms set status='valid' where scientificname='Curiotalitrus';
-- speed up setting status
create index ix_tmp_wrms_tmp_sciname on temp_worms(scientificname) tablespace uam_idx_1;
-- speed up hierarchical query
create index ix_tmp_wrms_tmp_pnuid on temp_worms(PARENTNAMEUSAGEID) tablespace uam_idx_1;
create unique index ix_u_tmp_wrms_tmp_pntnid on temp_worms(taxonid) tablespace uam_idx_1;

select TAXONRANK from temp_worms where scientificname='Brachysira brebissonii f. brebissonii';
select TAXONRANK, count(*) from temp_worms group by TAXONRANK;


							prior PARENTNAMEUSAGEID=taxonid

STATUS||'@'||COUNT(*)
------------------------------------------------------------------------------------------------------------------------
"sp" is not a valid name-part@ 1
Contains incertae sedis@ 520
Double spaces detected@ 1
@ 203
.@ 49995
@ 8
@ 10
@ 764
@ 239
s@ 2569
inserted_classification@ 26744
is_in_arctos@ 731022
valid@ 191403


select scientificname from temp_worms where status='xxxx' order by scientificname;
select scientificname from temp_worms where status='xxxx' order by scientificname;
select scientificname from temp_worms where status='xxxx' order by scientificname;
select scientificname from temp_worms where status='xxxx' order by scientificname;
select scientificname from temp_worms where status='xxxx' order by scientificname;
select scientificname from temp_worms where status='"sp" is not a valid name-part' order by scientificname;
select scientificname from temp_worms where status='Double spaces detected' order by scientificname;
select scientificname from temp_worms where status='Invalid abbreviation.' order by scientificname;
select scientificname from temp_worms where status='Invalid characters.' order by scientificname;
select scientificname from temp_worms where status='Looks like a hybrid.' order by scientificname;
select scientificname from temp_worms where status='Names should not be all lower-case' order by scientificname;
select scientificname from temp_worms where status='Too many terms or invalid infraspecific rank' order by scientificname;
select scientificname from temp_worms where status='Too many terms.' order by scientificname;
select scientificname from temp_worms where status='Too many uppercase characters' order by scientificname;
select scientificname from temp_worms where status='xxxx' order by scientificname;





		select count(*) from temp_worms where TAXONOMICSTATUS='unaccepted' and status='valid' ;


select status || ' @ ' || count(*) from temp_worms group by status order by status;

---->
<cfoutput>

	<cfquery name="cttaxon_term" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select taxon_term from cttaxon_term
	</cfquery>
	<cfquery name="CTTAXON_STATUS" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select TAXON_STATUS from CTTAXON_STATUS
	</cfquery>
	<cfquery name="d" datasource="uam_god">
		select * from temp_worms where TAXONOMICSTATUS='unaccepted' and status='valid' and rownum<300
	</cfquery>
	<!----
	<cfdump var=#d#>
	---->
	<cfset sdate=now()>
	<cfloop query="d">
		<cftry>
			<cftransaction>
				<cfquery name="tnid" datasource="uam_god">
					select taxon_name_id from taxon_name where scientific_name='#scientificname#'
				</cfquery>
				<!----
				<cfdump var=#tnid#>
				---->
				<p>
					<a href="/name/#scientificname#">#scientificname#</a>
				</p>
				<cfset taxon_name_id=tnid.taxon_name_id>

				<cfset thisClassID='aphiaid::#TAXONID#'>

				<cfquery name="meta" datasource="uam_god">
					insert into taxon_term (
						taxon_term_id,
						taxon_name_id,
						term_type,
						term,
						source,
						position_in_classification,
						classification_id
					) values (
						sq_taxon_term_id.nextval,
						#taxon_name_id#,
						'aphiaid',
						'#TAXONID#',
						'WoRMS (via Arctos)',
						NULL,
						'#thisClassID#'
					)
				</cfquery>

				<cfif len(ACCEPTEDNAMEUSAGE) gt 0 and ACCEPTEDNAMEUSAGE is not scientificname>
					<!--- see if we have an existing relationship --->
					<!--- first need the related name --->
					<cfquery name="rname" datasource="uam_god">
						select taxon_name_id from taxon_name where scientific_name='#ACCEPTEDNAMEUSAGE#'
					</cfquery>
					<!----
					<br>rname:::
					<cfdump var=#rname#>
					---->
					<cfif len(rname.taxon_name_id) gt 0>
						<!---
							got it; see if the relationship exists
							https://github.com/ArctosDB/arctos/issues/1136
							we are using "synonym of" for everything, so just ignore type for this for now
						---->
						<cfquery name="er" datasource="uam_god">
							select
								count(*) c
							from
								taxon_relations
							where
								taxon_name_id=#taxon_name_id# and
								related_taxon_name_id=#rname.taxon_name_id#
						</cfquery>
						<!----
						<br>er:::
						<cfdump var=#er#>
						---->
						<cfif er.c is 0>
							<br>creating relationship
							<!--- create the relationship ---->
							<cfquery name="mkreln" datasource="uam_god">
								insert into taxon_relations (
									TAXON_RELATIONS_ID,
									TAXON_NAME_ID,
									RELATED_TAXON_NAME_ID,
									TAXON_RELATIONSHIP,
									RELATION_AUTHORITY,
									STALE_FG
								) values (
									sq_TAXON_RELATIONS_ID.nextval,
									#taxon_name_id#,
									#rname.taxon_name_id#,
									'synonym of',
									'WoRMS',
									1
								)
							</cfquery>
						</cfif>
						<!---- now see if the reciprocal exists --->
						<cfquery name="err" datasource="uam_god">
							select
								count(*) c
							from
								taxon_relations
							where
								taxon_name_id=#rname.taxon_name_id# and
								related_taxon_name_id=#taxon_name_id#
						</cfquery>
						<!----
						<br>err:::
						<cfdump var=#err#>
						----->
						<cfif err.c is 0>
							<br>creating reciprocal relationship
							<!--- create the relationship ---->
							<cfquery name="mkreln" datasource="uam_god">
								insert into taxon_relations (
									TAXON_RELATIONS_ID,
									TAXON_NAME_ID,
									RELATED_TAXON_NAME_ID,
									TAXON_RELATIONSHIP,
									RELATION_AUTHORITY,
									STALE_FG
								) values (
									sq_TAXON_RELATIONS_ID.nextval,
									#rname.taxon_name_id#,
									#taxon_name_id#,
									'synonym of',
									'WoRMS',
									1
								)
							</cfquery>
						</cfif>
					</cfif>
				</cfif>

				<cfif len(NOMENCLATURALCODE) gt 0>
					<cfset t="nomenclatural_code">
					<cfset d=NOMENCLATURALCODE>
					<cfif d is "ICN">
						<cfset d='ICBN'>
					</cfif>
					<cfquery name="meta" datasource="uam_god">
						insert into taxon_term (
							taxon_term_id,
							taxon_name_id,
							term_type,
							term,
							source,
							position_in_classification,
							classification_id
						) values (
							sq_taxon_term_id.nextval,
							#taxon_name_id#,
							'#t#',
							'#d#',
							'WoRMS (via Arctos)',
							NULL,
							'#thisClassID#'
						)
					</cfquery>
				</cfif>
				<cfif len(TAXONOMICSTATUS) gt 0>
					<cfset t="taxon_status">
					<cfif TAXONOMICSTATUS is 'accepted'>
						<cfset d='valid'>
					<cfelseif TAXONOMICSTATUS is 'unaccepted'>
						<cfset d='invalid'>
					<cfelse>
						<cfset d=TAXONOMICSTATUS>
					</cfif>
					<cfif len(d) gt 0 and listfind(valuelist(CTTAXON_STATUS.TAXON_STATUS),d)>
						<cfquery name="meta" datasource="uam_god">
							insert into taxon_term (
								taxon_term_id,
								taxon_name_id,
								term_type,
								term,
								source,
								position_in_classification,
								classification_id
							) values (
								sq_taxon_term_id.nextval,
								#taxon_name_id#,
								'#t#',
								'#d#',
								'WoRMS (via Arctos)',
								NULL,
								'#thisClassID#'
							)
						</cfquery>
					</cfif>
				</cfif>


				<!---- isExtinct ?? got it from the weird dagger thing---->
				<!---- unacceptreason ?? ---->




				<cfif len(BIBLIOGRAPHICCITATION) gt 0>
					<cfset t="source_authority">
					<cfset d=BIBLIOGRAPHICCITATION>
					<cfif len(d) gt 0>
						<cfquery name="meta" datasource="uam_god">
							insert into taxon_term (
								taxon_term_id,
								taxon_name_id,
								term_type,
								term,
								source,
								position_in_classification,
								classification_id
							) values (
								sq_taxon_term_id.nextval,
								#taxon_name_id#,
								'#t#',
								'#d#',
								'WoRMS (via Arctos)',
								NULL,
								'#thisClassID#'
							)
						</cfquery>
					</cfif>
					<cfif BIBLIOGRAPHICCITATION contains "&##8224;">
						<cfset t="taxon_status">
						<cfset d='extinct'>
						<cfquery name="meta" datasource="uam_god">
							insert into taxon_term (
								taxon_term_id,
								taxon_name_id,
								term_type,
								term,
								source,
								position_in_classification,
								classification_id
							) values (
								sq_taxon_term_id.nextval,
								#taxon_name_id#,
								'#t#',
								'#d#',
								'WoRMS (via Arctos)',
								NULL,
								'#thisClassID#'
							)
						</cfquery>
					</cfif>
				</cfif>

				<cfif len(SCIENTIFICNAMEAUTHORSHIP) gt 0>
					<cfset t="author_text">
					<cfset d=SCIENTIFICNAMEAUTHORSHIP>
					<cfif len(d) gt 0>
						<cfquery name="meta" datasource="uam_god">
							insert into taxon_term (
								taxon_term_id,
								taxon_name_id,
								term_type,
								term,
								source,
								position_in_classification,
								classification_id
							) values (
								sq_taxon_term_id.nextval,
								#taxon_name_id#,
								'#t#',
								'#d#',
								'WoRMS (via Arctos)',
								NULL,
								'#thisClassID#'
							)
						</cfquery>
					</cfif>
				</cfif>

				<cfquery name="classh" datasource="uam_god">
					select
						*
					from (
						select
							scientificname,
							PARENTNAMEUSAGEID,
							TAXONRANK,
							level lvl
						from
							temp_worms
						where
							PARENTNAMEUSAGEID is not null
						connect by
							prior PARENTNAMEUSAGEID=taxonid
						start with
							taxonid='#taxonid#'
						) order by lvl desc
				</cfquery>
				<!----
				<cfdump var=#classh#>
				---->
				<cfset pic=1>
				<cfloop query="classh">
					<cfset thisrank=lcase(TAXONRANK)>
					<cfif thisrank is "form">
						<cfset thisrank='forma'>
					</cfif>


					<cfif listfind(valuelist(cttaxon_term.taxon_term),thisrank)>
						<cfquery name="meta" datasource="uam_god">
							insert into taxon_term (
								taxon_term_id,
								taxon_name_id,
								term_type,
								term,
								source,
								position_in_classification,
								classification_id
							) values (
								sq_taxon_term_id.nextval,
								#taxon_name_id#,
								'#thisrank#',
								'#scientificname#',
								'WoRMS (via Arctos)',
								#pic#,
								'#thisClassID#'
							)
						</cfquery>
						<cfset pic=pic+1>
					</cfif>
				</cfloop>

				<cfquery name="gotit" datasource="uam_god">
					update temp_worms set status='inserted_classification' where scientificname='#scientificname#'
				</cfquery>

			</cftransaction>
			<cfcatch>
				<cfquery name="gotit" datasource="uam_god">
					update temp_worms set status='insert_classification_fail' where scientificname='#scientificname#'
				</cfquery>
				<p>
					fail!! #cfcatch.Message# #cfcatch.detail#
				</p>
			</cfcatch>
		</cftry>
	</cfloop>

	<cfset fdate=now()>

	<cfset ctime=datediff('s',sdate,fdate)>

	<p>
		elapsed time: #ctime# s
	</p>
</cfoutput>
