<!---
create table cf_genbank_crawl (
	gbcid number not null,
	institution varchar2(38),
	collection varchar2(60),
	link_url varchar2(255) not null,
	found_count number,
	run_date date default sysdate
);

create or replace public synonym cf_genbank_crawl for cf_genbank_crawl;
grant all on cf_genbank_crawl to coldfusion_user;
	
alter table cf_genbank_crawl add query_type varchar2(30);

alter table cf_genbank_crawl drop column institution;
alter table cf_genbank_crawl rename column collection to owner;


CREATE OR REPLACE TRIGGER trg_cf_genbank_crawl                                         
 before insert OR UPDATE ON cf_genbank_crawl
 for each row 
    begin     
    	select somerandomsequence.nextval into :new.gbcid from dual;
    end;                                                                                            
/
sho err
--->
<cfinclude template="/includes/_header.cfm">
<cfset ncbi_resultcount=0>
<cfoutput>
	<cfif action is "nothing">
		<ul>
			<li><a href="genbank_crawl.cfm?action=institution_voucher">institution_voucher</a></li>
			<li><a href="genbank_crawl.cfm?action=collection_voucher">collection_voucher</a></li>
			<li><a href="genbank_crawl.cfm?action=collection_wild1">collection_wild1</a></li>
			<li><a href="genbank_crawl.cfm?action=collection_wild2">collection_wild2</a></li>
			<li><a href="genbank_crawl.cfm?action=institution_wild1">institution_wild1</a></li>
			<li><a href="genbank_crawl.cfm?action=institution_wild2">institution_wild2</a></li>
		</ul>
	</cfif>
	<cfquery name="c" datasource="uam_god">
		select collection, collection_cde,institution_acronym from collection order by institution_acronym,collection_cde
	</cfquery>
	<cfquery name="inst" dbtype="query">
		select institution_acronym from c group by institution_acronym order by institution_acronym
	</cfquery>
	<cfif action is "institution_wild2">
		<cfquery name="do" datasource="uam_god">
			delete from cf_genbank_crawl where query_type='wild2:institution'
		</cfquery>
		<cfloop query="inst">
			<cfset u="http://www.ncbi.nlm.nih.gov/sites/entrez?db=nuccore&cmd=search&term=">
			<cfset u=u & "specimen voucher " & institution_acronym & "*[text word] NOT loprovarctos[filter]">
			<cfhttp url="#u#" method="get" />
			<cfset xmlDoc=xmlParse(cfhttp.filecontent)>
			<cfloop from="1" to="#ArrayLen(xmldoc.html.head.meta)#" index="i">
				<cfset a=xmldoc.html.head.meta[i].xmlattributes>
				<cfif isdefined("a.name") and a.name is 'ncbi_resultcount'>
					<cfset ncbi_resultcount=a.content>
				</cfif>
			</cfloop>
			<cfquery name="in" datasource="uam_god">
				insert into cf_genbank_crawl (
					owner,
					link_url,
					found_count,
					query_type
				) values (
					'#institution_acronym#',
					'#u#',
					#ncbi_resultcount#,
					'wild2:institution'
				)
			</cfquery>
		</cfloop>
	</cfif>
	<cfif action is "institution_wild1">
		<cfquery name="do" datasource="uam_god">
			delete from cf_genbank_crawl where query_type='wild1:institution'
		</cfquery>
		<cfloop query="inst">
			<cfset u="http://www.ncbi.nlm.nih.gov/sites/entrez?db=nuccore&cmd=search&term=">
			<cfset u=u & "specimen voucher " & institution_acronym & " *[text word] NOT loprovarctos[filter]">
			<cfhttp url="#u#" method="get" />
			<cfset xmlDoc=xmlParse(cfhttp.filecontent)>
			<cfloop from="1" to="#ArrayLen(xmldoc.html.head.meta)#" index="i">
				<cfset a=xmldoc.html.head.meta[i].xmlattributes>
				<cfif isdefined("a.name") and a.name is 'ncbi_resultcount'>
					<cfset ncbi_resultcount=a.content>
				</cfif>
			</cfloop>
			<cfquery name="in" datasource="uam_god">
				insert into cf_genbank_crawl (
					owner,
					link_url,
					found_count,
					query_type
				) values (
					'#institution_acronym#',
					'#u#',
					#ncbi_resultcount#,
					'wild1:institution'
				)
			</cfquery>
		</cfloop>
	</cfif>
	<cfif action is "institution_voucher">
		<cfquery name="do" datasource="uam_god">
			delete from cf_genbank_crawl where query_type='specimen_voucher:institution'
		</cfquery>
		<cfloop query="inst">
			<cfset u="http://www.ncbi.nlm.nih.gov/sites/entrez?db=nuccore&cmd=search&term=">
			<cfset u=u & "collection%20" & institution_acronym & "[prop]%20NOT%20loprovarctos[filter]">
			<cfhttp url="#u#" method="get" />
			<cfset xmlDoc=xmlParse(cfhttp.filecontent)>
			<cfloop from="1" to="#ArrayLen(xmldoc.html.head.meta)#" index="i">
				<cfset a=xmldoc.html.head.meta[i].xmlattributes>
				<cfif isdefined("a.name") and a.name is 'ncbi_resultcount'>
					<cfset ncbi_resultcount=a.content>
				</cfif>
			</cfloop>
			<cfquery name="in" datasource="uam_god">
				insert into cf_genbank_crawl (
					owner,
					link_url,
					found_count,
					query_type
				) values (
					'#institution_acronym#',
					'#u#',
					#ncbi_resultcount#,
					'specimen_voucher:institution'
				)
			</cfquery>
		</cfloop>
	</cfif>
	<cfif action is "collection_voucher">
		<cfquery name="do" datasource="uam_god">
			delete from cf_genbank_crawl where query_type='specimen_voucher:collection'
		</cfquery>
		<cfloop query="c">
			<cfset u="http://www.ncbi.nlm.nih.gov/sites/entrez?db=nuccore&cmd=search&term=">
			<cfset u=u & "collection%20" & institution_acronym & ' ' & collection_cde & "[prop]%20NOT%20loprovarctos[filter]">
			<cfhttp url="#u#" method="get" />
			<cfset xmlDoc=xmlParse(cfhttp.filecontent)>
			<cfloop from="1" to="#ArrayLen(xmldoc.html.head.meta)#" index="i">
				<cfset a=xmldoc.html.head.meta[i].xmlattributes>
				<cfif isdefined("a.name") and a.name is 'ncbi_resultcount'>
					<cfset ncbi_resultcount=a.content>
				</cfif>
			</cfloop>
			<cfquery name="in" datasource="uam_god">
				insert into cf_genbank_crawl (
					owner,
					link_url,
					found_count,
					query_type
				) values (
					'#collection#',
					'#u#',
					#ncbi_resultcount#,
					'specimen_voucher:collection'
				)
			</cfquery>
		</cfloop>
	</cfif>
	<cfif action is "collection_wild1">
		<cfquery name="do" datasource="uam_god">
			delete from cf_genbank_crawl where query_type='wild1:collection'
		</cfquery>
		<cfloop query="c">
			<cfset u="http://www.ncbi.nlm.nih.gov/sites/entrez?db=nuccore&cmd=search&term=">
			<cfset u=u & "specimen voucher " & institution_acronym & ' ' & collection_cde & "*[text word] NOT loprovarctos[filter]">
			<cfhttp url="#u#" method="get" />
			<cfset xmlDoc=xmlParse(cfhttp.filecontent)>
			<cfloop from="1" to="#ArrayLen(xmldoc.html.head.meta)#" index="i">
				<cfset a=xmldoc.html.head.meta[i].xmlattributes>
				<cfif isdefined("a.name") and a.name is 'ncbi_resultcount'>
					<cfset ncbi_resultcount=a.content>
				</cfif>
			</cfloop>
			<cfquery name="in" datasource="uam_god">
				insert into cf_genbank_crawl (
					owner,
					link_url,
					found_count,
					query_type
				) values (
					'#collection#',
					'#u#',
					#ncbi_resultcount#,
					'wild1:collection'
				)
			</cfquery>
		</cfloop>
	</cfif>
	<cfif action is "collection_wild2">
		<cfquery name="do" datasource="uam_god">
			delete from cf_genbank_crawl where query_type='wild2:collection'
		</cfquery>
		<cfloop query="c">
			<cfset u="http://www.ncbi.nlm.nih.gov/sites/entrez?db=nuccore&cmd=search&term=">
			<cfset u=u & "specimen voucher " & institution_acronym & ' ' & collection_cde & "* [text word] NOT loprovarctos[filter]">
			<cfhttp url="#u#" method="get" />
			<cfset xmlDoc=xmlParse(cfhttp.filecontent)>
			<cfloop from="1" to="#ArrayLen(xmldoc.html.head.meta)#" index="i">
				<cfset a=xmldoc.html.head.meta[i].xmlattributes>
				<cfif isdefined("a.name") and a.name is 'ncbi_resultcount'>
					<cfset ncbi_resultcount=a.content>
				</cfif>
			</cfloop>
			<cfquery name="in" datasource="uam_god">
				insert into cf_genbank_crawl (
					owner,
					link_url,
					found_count,
					query_type
				) values (
					'#collection#',
					'#u#',
					#ncbi_resultcount#,
					'wild2:collection'
				)
			</cfquery>
		</cfloop>
	</cfif>
</cfoutput>