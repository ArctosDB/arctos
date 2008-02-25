<!----
<!--- 
	tables will list a lot of junk - that's OK, just ignore and we'll clean it all up evenually (yea right!) 
	
	Store this in
	
	create table user_table_access (
		agent_id number not null,
		table_name varchar2(40) not null,
		select_filter varchar2(255),
		insert_filter varchar2(255),
		update_filter varchar2(255),
		delete_filter varchar2(255)
		);
		
	Database User Roles:
		Alter any collection data
		add georeferences
		Alter any collecting event or locality
	
		
--->

<!--- implement this on selected tables. Adding anything requires manually creating the Oracle bits, 
	no no huge advantages to doing it on the fly --->
<cfquery name="data" datasource="#Application.uam_dbo#">
	select 
		username, 
		agent_name.agent_id,
		preferred_agent_name.agent_name preferred_name
	from
		cf_users, 
		agent_name,
		preferred_agent_name
	where 
		username=agent_name.agent_name and
		agent_name.agent_name_type='login' and
		agent_name.agent_id = preferred_agent_name.agent_id AND
		username = '#thisUsername#'
	order by username
</cfquery>
<cfoutput>
User Access for #data.preferred_name# (#data.username#):
<form name="user_rights" method="post" action="UserAccessLevel.cfm">
	<input type="hidden" name="agent_id" value="#data.agent_id#">
	<table border>
		<tr>
			<td>Table Name</td>
			<td>SELECT rule</td>
			<td>INSERT rule</td>
			<td>UPDATE rule</td>
			<td>DELETE rule</td>
		</tr>
		<cfset thisTableName = "CATALOGED_ITEM">
		<tr>
			<td>
				<input type="hidden" name="table_name" value="#thisTableName#">
				#thisTableName#
			</td>
			<td>
				<select name="#thisTableName#_select_filter" size="1">
					<option value="">ALL</option>
				</select>
			</td>
			<td>
				<select name="#thisTableName#_insert_filter" size="1">
					<option value="">ALL</option>
				</select>
			</td>
			<td>
				<select name="#thisTableName#_update_filter" size="1">
					<option value="">ALL</option>
				</select>
			</td>
			<td>
				<select name="#thisTableName#_delete_filter" size="1">
					<option value="">ALL</option>
				</select>
			</td>
		</tr>
		
	</table>
</form>
</cfoutput>
	<cfset table_list = "">
	<cfset nada = listappend(table_list,'ACCN')>
	<cfset nada = listappend(table_list,'ADDR')>
	<cfset nada = listappend(table_list,'AGENT')>
	<cfset nada = listappend(table_list,'AGENT_NAME')>
	<cfset nada = listappend(table_list,'AGENT_RELATIONS')>
	<cfset nada = listappend(table_list,'ATTRIBUTES')>
	<cfset nada = listappend(table_list,'BOOK')>
	<cfset nada = listappend(table_list,'BORROW')>
	<cfset nada = listappend(table_list,'CITATION')>
	<cfset nada = listappend(table_list,'COLL_OBJECT_REMARK')>
	<cfset nada = listappend(table_list,'COLLECTING_EVENT')>
	<cfset nada = listappend(table_list,'COLLECTION')>
	<cfset nada = listappend(table_list,'COLLECTION_CONTACTS')>
	<cfset nada = listappend(table_list,'COLLECTOR')>
	<cfset nada = listappend(table_list,'COLL_OBJECT')>
	<cfset nada = listappend(table_list,'COLL_OBJECT_ENCUMBRANCE')>
	<cfset nada = listappend(table_list,'COLL_OBJ_CONT_HIST')>
	<cfset nada = listappend(table_list,'COLL_OBJ_OTHER_ID_NUM')>
	<cfset nada = listappend(table_list,'COMMON_NAME')>
	<cfset nada = listappend(table_list,'CONTAINER')>
	<cfset nada = listappend(table_list,'CONTAINER_HISTORY')>
	<cfset nada = listappend(table_list,'CORRESPONDENCE')>
	<cfset nada = listappend(table_list,'DGR_LOCATOR')>
	<cfset nada = listappend(table_list,'ELECTRONIC_ADDRESS')>
	<cfset nada = listappend(table_list,'ENCUMBRANCE')>
	<cfset nada = listappend(table_list,'FLUID_CONTAINER_HISTORY')>
	<cfset nada = listappend(table_list,'GEOG_AUTH_REC')>
	<cfset nada = listappend(table_list,'GROUP_MEMBER')>
	<cfset nada = listappend(table_list,'IDENTIFICATION')>
	<cfset nada = listappend(table_list,'IDENTIFICATION_TAXONOMY')>
	<cfset nada = listappend(table_list,'JOURNAL')>
	<cfset nada = listappend(table_list,'LAT_LONG')>
	<cfset nada = listappend(table_list,'LOAN')>
	<cfset nada = listappend(table_list,'LOAN_ITEM')>
	<cfset nada = listappend(table_list,'LOCALITY')>
	<cfset nada = listappend(table_list,'OBJECT_CONDITION')>
	<cfset nada = listappend(table_list,'PERMIT')>
	<cfset nada = listappend(table_list,'PERSON')>
	<cfset nada = listappend(table_list,'PERMIT_SHIPMENT')>
	<cfset nada = listappend(table_list,'PERMIT_TRANS')>
	<cfset nada = listappend(table_list,'PROJECT')>
	<cfset nada = listappend(table_list,'PROJECT_AGENT')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	<cfset nada = listappend(table_list,'tttt')>
	



PROJECT_COLL_EVENT
PROJECT_PUBLICATION
PROJECT_REMARK
PROJECT_TRANS
PUBLICATION
PUBLICATION_AUTHOR_NAME
PUBLICATION_URL
PUBLICATION_YEAR
QUEST_COM_PRODUCTS
QUEST_COM_PRODUCTS_USED_BY
QUEST_COM_PRODUCT_PRIVS
QUEST_COM_USERS
QUEST_COM_USER_PRIVILEGES
REARING_EVENT
RELATION_TYPE_CODE
SCANS
SCOPE_NOTES
SEARCHTERMS
SECDET
SECTION
SEQUENCE_REPOSITORY
SEQUENCE_REPOSITORY_ARTICLE
SEQUENCE_REPOS_ARTICLE
SHIPMENT
SHIPMENT030725
SPECIES_TAPE
SPECIMEN_PART
SPECIMEN_PART20040507
SPECIMEN_PART20050502
SPECIMEN_PART20050628
SPECIMEN_PART_20031124
STILL_IMAGE
SYLVIALOADED20040803
TAPE
TAXONBYGEOGINDEX
TAXONOMY
TAXONOMY20040624
TAXONOMY20040705
TAXONOMY20040920
TAXONOMY20040921
TAXONOMY20041004
TAXONOMY20041208
TAXONOMY20060115
TAXONOMYINDEX
TAXON_RELATIONS
TAX_PROTECT_STATUS
TEMP
TEMPCONT
TEST
TISSUES_FORMATTED
TISSUE_COUNT
TISSUE_PREP
TISSUE_PREP030725
TISSUE_SAMPLE_20031124
TISSUE_SAMPLE_TYPE
TOAD_PLAN_SQL
TOAD_PLAN_TABLE
TOKENS
TRANS
TRANS030725
TRANS20031125
TRANS20040108
TRANS20040827
TRANS_AGENT_ADDR
TRANS_CLOSURE
TRANS_ITEM
TRANS_RELATIONS
UAM_TYPES
UPDATE_CATNUMS
URL
USER_DATA
USER_LOAN_ITEM
USER_LOAN_REQUEST
VESSEL
VIEWER
VISITATION
VOCAL_SERIES
VOCAL_SERIES_CUT_HISTORY
VOCAL_SERIES_ON_TAPE
VSVBTableVersions
YLYNX
jdragoo (1008624)
gr_racz (1009596)
cindy (1009195)
kendra (1014259)
achavez4 (1014266)
rsampson (1014305)
cmcclarin (1014306)
edijam5 (1014335)
ahope (1008948)
andy (1010807)
jmalaney (1014257)
dusty (2072)
brandy (1507)
gordon (1545)
sylvia (3984)
fsjlf (4443)
jennifer (4445)
hayley (8526)
AlanBatten (280)
fskkf1 (7851)
Anna (7855)
tucotuco (4237)
link (7718)
fskbh1 (3845)
fstb2 (8295)
fnclp1 (2401)
mread (8296)
slbenson (8542)
aren (8543)
fscmf (7744)
fsjrg10 (7745)
fsamb10 (1014355)
billgannon (1100)
---->