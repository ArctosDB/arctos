<cfset tabList = "ACCN,ADDR,AGENT,AGENT_NAME,AGENT_RELATIONS,ATTRIBUTES,BINARY_OBJECT,BIOL_INDIV_RELATIONS,BOOK,BOOK_SECTION,BORROW,CATALOGED_ITEM,CITATION,COLLECTING_EVENT,COLLECTION,COLLECTION_CONTACTS,COLLECTOR,COLL_OBJECT,COLL_OBJECT_ENCUMBRANCE,COLL_OBJECT_REMARK,COLL_OBJ_CONT_HIST,COLL_OBJ_OTHER_ID_NUM,COMMON_NAME,CONTAINER,CORRESPONDENCE,ELECTRONIC_ADDRESS,ENCUMBRANCE,FLUID_CONTAINER_HISTORY,GEOG_AUTH_REC,GROUP_MEMBER,IDENTIFICATION,IDENTIFICATION_AGENT,IDENTIFICATION_TAXONOMY,JOURNAL,JOURNAL_ARTICLE,LAT_LONG,LOAN,LOAN_ITEM,LOCALITY,OBJECT_CONDITION,PAGE,PERMIT,PERMIT_SHIPMENT,PERMIT_TRANS,PERSON,PROJECT,PROJECT_AGENT,PROJECT_PUBLICATION,PROJECT_REMARK,PROJECT_SPONSOR,PROJECT_TRANS,PUBLICATION,PUBLICATION_AUTHOR_NAME,PUBLICATION_URL,REARING_EVENT,SHIPMENT,SPECIMEN_ANNOTATIONS,SPECIMEN_PART,TAXONOMY,TAXON_RELATIONS,TAX_PROTECT_STATUS,TRANS,TRANS_AGENT_ADDR,VESSEL,VIEWER,VOCAL_SERIES">
<cfoutput>
<cfloop list="#tabList#" index="t">
	<cfquery name="col_names" datasource="#Application.uam_dbo#">
		select COLUMN_NAME from user_tab_cols where table_name='#t#' 
	</cfquery>
	<cfset audName = "aud$#t#">
	create table #audName# as select * from #t# where 1=2;<br>
	alter table #audName# add user_id varchar2(38);<br>
  	alter table #audName# add change_date date;<br>
	create or replace trigger trg_aud_#t# after update or delete on #t#<br>
  	for each row begin<br>
  		insert into #audName# (<br>
			<cfloop query="col_names">
				#column_name#,<br>
			</cfloop>
			user_id,<br>
			change_date<br>
			) values (<br>
			<cfloop query="col_names">
				:OLD.#column_name#,<br>
			</cfloop>
			user,<br>
			sysdate<br>
			);<br>
			end;<br>
			/<br>
			<p></p>
</cfloop>
</cfoutput>