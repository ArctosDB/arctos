<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
	<cfoutput>
		<cfquery name="gb" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from cf_genbank_crawl order by collection,institution
		</cfquery>
		<table border id="t" class="sortable">
			<tr>
				<th>Owner</th>
				<th></th>
			</tr><th>
				
			</th>
		</table>
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
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">