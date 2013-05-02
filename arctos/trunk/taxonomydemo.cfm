<!------------

create table taxon_name (
	taxon_name_id number not null primary key,
	scientific_name varchar2(255) not null
);

create unique index ix_taxon_name_sciname on taxon_name(scientific_name) tablespace uam_idx_1;

create table taxon_term (
	taxon_term_id number not null primary key,
	taxon_name_id number not null,
	classification_id varchar2(4000) null,
	term varchar2(255) not null,
	term_type varchar2(255),
	source varchar2(255) not null,
	gn_score number,
	position_in_classification number,
	lastdate date default (sysdate) not null ,
	CONSTRAINT fk_tnid FOREIGN KEY (taxon_name_id) REFERENCES taxon_name (taxon_name_id)
  );

create sequence sq_taxon_term_id;
create public synonym sq_taxon_term_id for sq_taxon_term_id;
grant select on sq_taxon_term_id to public;
	
CREATE OR REPLACE TRIGGER tr_taxon_term_id before insert ON taxon_term for each row
   begin    
       IF :new.taxon_term_id IS NULL THEN
           select sq_taxon_term_id.nextval into :new.taxon_term_id from dual;
       END IF;
   end;                                                                                           
/
sho err

-------------->

<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfif action is "nothing" and (not isdefined("name") or len(name) is 0)>
		
		
		You need a "?name=NAME" parameter in the URL to use this form.
		<p>
			Try <a href="taxonomydemo.cfm?name=Sorex cinereus">Sorex cinereus</a>.
		</p>
	</cfif>
	<cfif action is "nothing" and isdefined("name") and len(name) gt 0>
		<cfquery name="d" datasource="uam_god">
			select * from taxon_name,taxon_term where 
			taxon_name.taxon_name_id=taxon_term.taxon_name_id (+) and
			upper(scientific_name)='#ucase(name)#'
		</cfquery>
		
		<cfif d.recordcount is 0>
			sorry, we don't see to have data for #name# yet.
			You can <a href="taxonomydemo.cfm?action=createTerm&scientific_name=#name#">create #name#</a>
			<cfabort>
		</cfif>
		<cfquery name="scientific_name" dbtype="query">
			select scientific_name from d group by scientific_name
		</cfquery>
		<cfquery name="taxterms" dbtype="query">
			select 
				gn_score,
				source,
				term,
				term_type,
				position_in_classification
			from 
				d 
			where 
				position_in_classification is not null 
			group by 
				gn_score,
				source,
				term,
				term_type,
				position_in_classification 
			order by 
				gn_score,
				source,
				position_in_classification 
		</cfquery>
		
	
		<cfquery name="nontaxterms" dbtype="query">
			select 
				term,
				term_type,
				source 
			from  
				d 
			where 
				position_in_classification is null 
			order by 
				source,term_type
		</cfquery>
		
		<cfquery name="sources" dbtype="query">
			select 
				source,
				classification_id
			from 
				d 
			where 
				classification_id is not null 
			group by 
				source,
				classification_id
			order by 
				source,
				classification_id
		</cfquery>
		
		
		<cfloop query="sources">
			<cfquery name="notclass" dbtype="query">
				select 
					term,
					term_type 
				from 
					d 
				where 
					position_in_classification is null and 
					source='#source#' 
				group by 
					term,
					term_type 
				order by 
					term_type,
					term
			</cfquery>
			<hr>
			Data from #source# 
			<p>
			<cfloop query="notclass">
				<br>#term_type#: #term#
			</cfloop>
			</p>
			
			<cfquery name="tscore" dbtype="query">
				select gn_score from d where classification_id='#classification_id#'
			</cfquery>
			<p>Classification
			(<cfif len(tscore.gn_score) gt 0>
				globalnames score=#tscore.gn_score#
			<cfelse>
				globalnames score not available
			</cfif>):</p>
			<cfquery name="thisone" dbtype="query">
				select 
					term,
					term_type 
				from 
					d 
				where 
					position_in_classification is not null and 
					classification_id='#classification_id#' 
				group by 
					term,
					term_type 
				order by 
					position_in_classification 
			</cfquery>
			
			
			<cfset indent=1>
			<cfloop query="thisone">
				<div style="padding-left:#indent#em;">
					#term#
					<cfif len(term_type) gt 0>
						(#term_type#)
					</cfif>
				</div>
				<cfset indent=indent+1>
			</cfloop>
		</cfloop>
	</cfif>
	
	
	<cfif action is "createTerm">
		<cfquery name="d" datasource="uam_god">
			select * from taxon_name where 
			scientific_name='#scientific_name#'
		</cfquery>
		<cfif d.recordcount is not 0>
			name exists
			<cfabort>
		</cfif>
		<cfquery name="d" datasource="uam_god">
			select * from taxonomy where scientific_name='#scientific_name#'
		</cfquery>
		<cfquery name="tt" datasource="uam_god">
			insert into taxon_name (taxon_name_id,scientific_name) values (#d.taxon_name_id#,'#d.SCIENTIFIC_NAME#')
		</cfquery>
		<cfset orderedTerms="KINGDOM,PHYLUM,PHYLCLASS,SUBCLASS,PHYLORDER,SUBORDER,SUPERFAMILY,FAMILY,SUBFAMILY,TRIBE,GENUS,SUBGENUS,SPECIES,SUBSPECIES">
		<cfset pos=1>
		<!--- arctos "source_id" is just the taxon_name_id ---->
		<cfloop list="#orderedTerms#" index="termtype">
			<cfset thisTermVal=evaluate("d." & termtype)>
			<cfset thisTermType=termtype>
			<cfif len(thisTermVal) gt 0>
				<cfif thisTermType is "SUBSPECIES" and len(d.INFRASPECIFIC_RANK) gt 0>
					<cfset thisTermType=d.INFRASPECIFIC_RANK>
				</cfif>
				<cfquery name="meta" datasource="uam_god">
					insert into taxon_term (
						taxon_term_id,
						taxon_name_id,
						term,
						term_type,
						source,
						position_in_classification,
						classification_id
					) values (
						sq_taxon_term_id.nextval,
						#d.taxon_name_id#,
						'#thisTermVal#',
						'#lcase(thisTermType)#',
						'Arctos',
						#pos#,
						'#d.taxon_name_id#'
					)
				</cfquery>
				<cfset pos=pos+1>
			</cfif>
		</cfloop>
		<cfset orderedTerms="VALID_CATALOG_TERM_FG|SOURCE_AUTHORITY|AUTHOR_TEXT|TAXON_REMARKS|NOMENCLATURAL_CODE|INFRASPECIFIC_AUTHOR|DISPLAY_NAME|TAXON_STATUS">
		<cfloop list="#orderedTerms#" index="termtype" delimiters="|">
			<cfset thisTermVal=evaluate("d." & termtype)>
			<cfif len(thisTermVal) gt 0>
				<cfquery name="meta" datasource="uam_god">
					insert into taxon_term (
						taxon_term_id,
						taxon_name_id,
						term,
						term_type,
						source
					) values (
						sq_taxon_term_id.nextval,
						#d.taxon_name_id#,
						'#thisTermVal#',
						'#lcase(termtype)#',
						'Arctos'
					)
				</cfquery>
				<cfset pos=pos+1>
			</cfif>
		</cfloop>
		<cfhttp url="http://resolver.globalnames.org/name_resolvers.json?names=#scientific_name#"></cfhttp>
		<cfset x=DeserializeJSON(cfhttp.filecontent)>
		<cfloop from="1" to="#ArrayLen(x.data[1].results)#" index="i">
			<cfset pos=1>
			<!--- because lists are stupid and ignore NULLs.... ---->
			<cfif structKeyExists(x.data[1].results[i],"classification_path") and structKeyExists(x.data[1].results[i],"classification_path_ranks")>
				<cfset cterms=ListToArray(x.data[1].results[i].classification_path, "|", true)>
				<cfset cranks=ListToArray(x.data[1].results[i].classification_path_ranks, "|", true)>
				 
				<cfset thisSource=x.data[1].results[i].data_source_title>
				<!--- try to use something from them to uniquely identify the hierarchy---->
				<!---- failing that, make a local identifier useful only in patching the hierarchy back together ---->
				<cfset thisSourceID=x.data[1].results[i].classification_path_ids>
				<cfif len(thisSourceID) is 0>
					<cfset thisSourceID=CreateUUID()>
				</cfif>
				<cfset thisScore=x.data[1].results[i].score>
				<cfif len(thisScore) is 0><cfset thisScore=0></cfif>
				<cfset thisNameString=x.data[1].results[i].name_string>
				<cfset thisCanonicalFormName=x.data[1].results[i].canonical_form>
				
				<br>thisSource: #thisSource#
				<cfloop from="1" to="#arrayLen(cterms)#" index="listPos">
					<cfset thisTerm=cterms[listpos]>
					<br>thisTerm: #thisTerm#
					<cfif ArrayIsDefined(cranks, listpos)>
						<cfset thisRank=cranks[listpos]>
						exists....
					<cfelse>
						<cfset thisRank=''>
						noexists....
					</cfif>
					
					 ---- thisRank: #thisRank#
					<cfif len(thisTerm) gt 0>
						<cfquery name="meta" datasource="uam_god">
							insert into taxon_term (
								taxon_term_id,
								taxon_name_id,
								term,
								term_type,
								source,
								position_in_classification,
								classification_id,
								gn_score
							) values (
								sq_taxon_term_id.nextval,
								#d.taxon_name_id#,
								'#thisTerm#',
								'#lcase(thisRank)#',
								'#thisSource#',
								#pos#,
								'#thisSourceID#',
								#thisScore#
							)
						</cfquery>
						<cfset pos=pos+1>
					</cfif>
				</cfloop>
				<cfif len(thisNameString) gt 0>
					<cfquery name="meta" datasource="uam_god">
						insert into taxon_term (
							taxon_term_id,
							taxon_name_id,
							term,
							term_type,
							source
						) values (
							sq_taxon_term_id.nextval,
							#d.taxon_name_id#,
							'#thisNameString#',
							'name string',
							'#thisSource#'
						)
					</cfquery>
				</cfif>
				<cfif len(thisCanonicalFormName) gt 0>
					<cfquery name="meta" datasource="uam_god">
						insert into taxon_term (
							taxon_term_id,
							taxon_name_id,
							term,
							term_type,
							source
						) values (
							sq_taxon_term_id.nextval,
							#d.taxon_name_id#,
							'#thisCanonicalFormName#',
							'canonical name',
							'#thisSource#'
						)
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
		<cflocation url="taxonomydemo.cfm?name=#scientific_name#" addtoken="false">
	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">