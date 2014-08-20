

<!--

	Build a bulkloader of potential reciprocal relationships
	
	create table cf_temp_recipr_proc (
		collection_id number,
		lastdate date
	);
	
	
	
	create table cf_temp_recip_oids (
		key number,
		collection_id number,
		guid_prefix varchar2(20) not null,
		existing_other_id_type varchar2(60) not null,
		existing_other_id_number varchar2(60) not null,
		new_other_id_type varchar2(60) not null,
		new_other_id_number varchar2(60) not null,
		new_other_id_references varchar2(60),
		found_date date
	);
	
	create public synonym cf_temp_recip_oids for cf_temp_recip_oids;
	grant all on cf_temp_recip_oids to manage_specimens;

	 CREATE OR REPLACE TRIGGER cf_temp_recip_oids_key
	 before insert  ON cf_temp_recip_oids
	 for each row
	    begin
	    	if :NEW.key is null then
	    		select somerandomsequence.nextval into :new.key from dual;
	    	end if;
	    end;
	/
	sho err


--->
<cfoutput>
	<!--- how often to check back, in hours ---->
	<cfif not isdefined("interval")>
		<cfset interval=24>
	</cfif>
	<!---- needs a bit of a throttle ---->
	<cfif not isdefined("recordLimit")>
		<cfset recordLimit=1000>
	</cfif>
	
	
	
	
	<!---- allow forcing collection --->
	
	<cfif not isdefined("thisCollectionID") or len(thisCollectionID) is 0>
		<!--- get the "next" collection and do some housekeeping, or die ---->
		<cfquery name="thisCollection" datasource="uam_god">
			select min(collection_id) collection_id from collection where collection_id not in (select collection_id from cf_temp_recipr_proc)
		</cfquery>
		<cfif len(thisCollection.collection_id) is 0>
			<!--- see if we can find any collections that haven't been processed since INTERVAL ---->
			<cfquery name="thisCollection" datasource="uam_god">
				select min(collection_id) collection_id from cf_temp_recipr_proc where lastdate < sysdate-#interval#/24
			</cfquery>
			<cfset thisCollectionID=thisCollection.collection_id>
		<cfelse>
			<cfset thisCollectionID=thisCollection.collection_id>
		</cfif>
		<cfif not isdefined("thisCollectionID") or len(thisCollectionID) is 0>
			up to date - delete from cf_temp_recipr_proc or supply thisCollectionID in the URL to force <cfabort>
		</cfif>
	</cfif>
	<br>running for collection_id #thisCollectionID#
	<cfquery name="deletethisCollection" datasource="uam_god">
		delete from cf_temp_recip_oids where collection_id=#thisCollectionID#
	</cfquery>
	<cfquery name="deletethisCollectionProc" datasource="uam_god">
		delete from cf_temp_recipr_proc where collection_id=#thisCollectionID#
	</cfquery>
	<cfquery name="setLastRun" datasource="uam_god">
		insert into cf_temp_recipr_proc (lastdate,collection_id) values (sysdate,#thisCollectionID#)
	</cfquery>

		
	<!--- hard-code this because we have no better place for it.... --->
	<cfset ctid_references = querynew("r1,r2")>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset i=1>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'ate', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'eaten by', i)>	
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'collected from', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'collected on', i)>
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'collected with', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'collected with', i)>
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'host of', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'parasite of', i)>
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'in amplexus with', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'in amplexus with', i)>
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'littermate or nestmate of', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'littermate or nestmate of', i)>
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'mate of', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'mate of', i)>
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'offspring of', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'parent of', i)>
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'same individual as', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'same individual as', i)>
	<cfset i=i+1>
	<cfset temp = queryaddrow(ctid_references,1)>
	<cfset temp = QuerySetCell(ctid_references, "r1", 'sibling of', i)>
	<cfset temp = QuerySetCell(ctid_references, "r2", 'sibling of', i)>
	
	
	<cfquery name="rCTID_REFERENCES" datasource="uam_god">
		select ID_REFERENCES from CTID_REFERENCES where ID_REFERENCES != 'self'
	</cfquery>
	<cfquery name="c1" dbtype="query">
		select r1 from ctid_references where r1 not in (#QuotedValueList(rCTID_REFERENCES.ID_REFERENCES)# )
	</cfquery>
	<cfif c1.recordcount is not 0>
		<cfthrow message='pendingRelations r1 MIA'>
	</cfif>
	<cfquery name="c2" dbtype="query">
		select r2 from ctid_references where r2 not in (#QuotedValueList(rCTID_REFERENCES.ID_REFERENCES)# )
	</cfquery>
	<cfif c2.recordcount is not 0>
		<cfthrow message='pendingRelations r2 MIA'>
	</cfif>
	<cfquery name="t" dbtype="query">
			select r1 as idtype from ctid_references
			union
			select r2 as idtype from ctid_references
	</cfquery>
	<cfquery name="uidtype" dbtype="query">
		select distinct idtype from t
	</cfquery>
	
	
	<cfset sql="insert all ">
	<cfloop query="uidtype">
		<cfset thisRelationship=uidtype.idtype>
		<cfquery name="rr" dbtype="query">
			select * from ctid_references where r1='#idtype#'
		</cfquery>
		<cfif rr.recordcount is 1>
			<cfset reciprocalRelationship=rr.r2>
		<cfelse>
			<cfquery name="rr" dbtype="query">
				select * from ctid_references where r2='#idtype#'
			</cfquery>
			<cfset reciprocalRelationship=rr.r1>			
		</cfif>
		<cfquery name="missing" datasource="uam_god">
			select 
				my_collection.guid_prefix guid_prefix,
				my_catitem.cat_num existing_other_id_number,
				'catalog number' existing_other_id_type,
				their_catitem.cat_num new_other_id_number,
				their_collection.guid_prefix new_other_id_type,
				'#reciprocalRelationship#' new_other_id_references
			from
				coll_obj_other_id_num,
				collection my_collection,
				cataloged_item my_catitem,
				collection their_collection,
				cataloged_item their_catitem
			where
				coll_obj_other_id_num.ID_REFERENCES='#thisRelationship#' and
				coll_obj_other_id_num.collection_object_id=their_catitem.collection_object_id and
				their_catitem.collection_id=their_collection.collection_id and
				OTHER_ID_TYPE=my_collection.guid_prefix and
				my_collection.collection_id=my_catitem.collection_id and
				my_catitem.cat_num=display_value
				and my_collection.collection_id=#thisCollectionID# and
				my_catitem.collection_object_id not in (
					select
						coll_obj_other_id_num.collection_object_id
					from
						coll_obj_other_id_num,
						cataloged_item
					where
						coll_obj_other_id_num.ID_REFERENCES='#reciprocalRelationship#' and
						coll_obj_other_id_num.collection_object_id=cataloged_item.collection_object_id and
						cataloged_item.collection_id=#thisCollectionID#
				)
				and rownum<#recordLimit#
		</cfquery>
			
		<cfif missing.recordcount gt 0>
			<p>
				Found #missing.recordcount# records.
			</p>
			<table border>
				<tr>
					<td>guid_prefix</td>
					<td>existing_other_id_number</td>
					<td>existing_other_id_type</td>
					<td>new_other_id_number</td>
					<td>new_other_id_type</td>
					<td>new_other_id_references</td>
				</tr>
				<cfloop query="missing">
					<tr>
						<td>#guid_prefix#</td>
						<td>#existing_other_id_number#</td>
						<td>#existing_other_id_type#</td>
						<td>#new_other_id_number#</td>
						<td>#new_other_id_type#</td>
						<td>#new_other_id_references#</td>
					</tr>
					<cfset sql=sql & " into 
										cf_temp_recip_oids 
									(
										collection_id,
										guid_prefix,
										existing_other_id_type,
										existing_other_id_number,
										new_other_id_type,
										new_other_id_number,
										new_other_id_references,
										found_date
									) values (
										#thisCollectionID#,
										'#guid_prefix#',
										'#existing_other_id_type#',
										'#existing_other_id_number#',
										'#new_other_id_type#',
										'#new_other_id_number#',
										'#new_other_id_references#',
										sysdate
									)">
				</cfloop>
			</table>
		</cfif>
	</cfloop>

	<cfif sql is not "insert all ">
		<cfset sql=sql & ' select 1 from dual'>
		<cfquery name="ins" datasource="uam_god">
			#preservesinglequotes(sql)#
		</cfquery>
	</cfif>

</cfoutput>