<!----
 alter table cf_temp_relations add cf_temp_relations_id number;
create sequence sq_cf_temp_relations_id;

begin
for r in (select rowid rid from cf_temp_relations) loop
	update cf_temp_relations set cf_temp_relations_id = sq_cf_temp_relations_id.nextval where rowid=r.rid;
end loop;
end;
/

alter table cf_temp_relations modify cf_temp_relations_id not null;


CREATE OR REPLACE TRIGGER tr_sq_cf_temp_relations_id BEFORE INSERT ON cf_temp_relations
FOR EACH ROW
BEGIN
SELECT sq_cf_temp_relations_id.NEXTVAL into :new.cf_temp_relations_id FROM dual;
END;

--->
<cfinclude template="/includes/_header.cfm">
<cfparam name="filterForPending" default="true">

<cfif action is "delete">
	<cfquery name="delete" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_relations where CF_TEMP_RELATIONS_ID in (#delthis#)
	</cfquery>
	<cflocation url="pendingRelations.cfm">
</cfif>
<cfset title="Pending Relationships">
<cfquery name="getRels" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select 
		cataloged_item.collection_object_id,
		RELATIONSHIP,
		RELATED_TO_NUMBER,
		RELATED_TO_NUM_TYPE,
		LASTTRYDATE,
		FAIL_REASON,
		RELATED_COLLECTION_OBJECT_ID,
		INSERT_DATE,
		CF_TEMP_RELATIONS_ID,
		cat_num,
		guid_prefix
	from 
		cf_temp_relations,
		cataloged_item,
		collection
	where
		cf_temp_relations.collection_object_id=cataloged_item.collection_object_id and
		cataloged_item.collection_id = collection.collection_id
	<cfif #filterForPending# is "true">
		and related_collection_object_id is null
	</cfif>
</cfquery>
<cfif #getRels.recordcount# is 0>
	There are no pending relationships.
</cfif>
<cfif #filterForPending# is "true">
		Unresolved
</cfif> 
Pending Relationships
<cfif #filterForPending# is "true">
		<br><a href="pendingRelations.cfm?filterForPending=false">Show all relationships</a>
<cfelse>
	<br><a href="pendingRelations.cfm?filterForPending=true">Show only unresolved relationships</a>
</cfif> 
<table border>
	<tr>
		<td>
			Specimen
		</td>
		<td>
			Relationship
		</td>
		<td>
			Related Number
		</td>
		<td>Start Date</td>
		<td>
			Last Try Date
		</td>
		<td>
			Status
		</td>
		<td>Delete</td>
	</tr>
	<form name="d" method="post" action="pendingRelations.cfm">
		<input type="hidden" name="action" value="delete">
	<cfoutput>
		<cfloop query="getRels">
			<tr>
				<td>
					<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">
						#guid_prefix# #cat_num#</a>
				</td>
				<td>
					#relationship#
				</td>
				<td>
					#related_to_num_type# #related_to_number# 
				</td>
				<td>
					#dateformat(insert_date,"yyyy-mm-dd")#
				</td>
				<td>
					#dateformat(lasttrydate,"yyyy-mm-dd")#
				</td>
				<td>
					<cfif #len(fail_reason)# is 0 and len(#related_collection_object_id#) gt 0>
						<!--- spiffy, it's loaded --->
						<a href="/SpecimenDetail.cfm?collection_object_id=#related_collection_object_id#">
						Successfully resolved (click for related specimen)</a>
					<cfelseif #len(fail_reason)# is 0 and len(#related_collection_object_id#) is 0>
						Has not been tried or has failed unexpectedly. That's bad. 
						Click <a href="pendingRelations.cfm">here</a> to try again.
					<cfelseif #len(fail_reason)# gt 0 and len(#related_collection_object_id#) is 0>
						#fail_reason#
					<cfelse>
						Something hinky is going on. File a <a href="/info/bugs.cfm">bug report</a>. Now!
					</cfif>
				</td>
				<td>
					<input type="checkbox" name="delThis" id="r_#CF_TEMP_RELATIONS_ID#" value="#CF_TEMP_RELATIONS_ID#">
				</td>
			</tr>
		</cfloop>
		
		<input type="submit" value="delete checked relationships" class="delBtn">
	</form>
	</cfoutput>
</table>
<cfinclude template="/includes/_footer.cfm">