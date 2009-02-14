<!--- requires:

	media_id
	format (default: list)
	
--->
<cfset supportedFormats="list">
<cfif not isdefined("attribues.format") or not listfind(supportedFormats,attribues.format)>
	<cfset format="list">
<cfelse>
	<cfset format=attributes.format>
</cfif>

<cfquery name="relns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from media_relations where media_id=#attributes.media_id#
</cfquery>
<cfoutput>
	<ul>
		
	<cfloop query="relns">
		<cfset table_name = listlast(media_relationship," ")>
		<cfif #table_name# is "locality">
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select spec_locality data from #table_name# where locality_id=#related_primary_key#
			</cfquery>
			<li>
				#media_relationship#: #d.data#
			</li>
		<cfelseif #table_name# is "agent">
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select agent_name data from preferred_agent_name where agent_id=#related_primary_key#
			</cfquery>
			<li>
				#media_relationship#: #d.data#
			</li>
		<cfelse>
			<li>
				#media_relationship#: #table_name# is not supported.
			</li>
		</cfif>
	</cfloop>
	</ul>
</cfoutput>
<!----
create or replace function get_media_relations_string (mediaID IN number)
	return varchar2
	AS
	the_relation varchar2(4000);
	sep varchar(6);
	tabl varchar2(38);
	theValue varchar2(4000);
begin
	for r in (select * from media_relations,preferred_agent_name where
	media_relations.created_by_agent_id=preferred_agent_name.agent_id and
	media_id=mediaID) loop
		the_relation:=the_relation || sep || r.media_relationship || ': ';
		-- find table name
		tabl := SUBSTR(r.media_relationship,instr(r.media_relationship,' ',-1)+1);
		--the_relation:=the_relation || '; table: ' || tabl;
		case tabl 
			when 'locality' then
				select spec_locality into theValue from locality where locality_id=r.related_primary_key;
				the_relation:=the_relation || theValue;
			when 'collecting_event' then
				select verbatim_locality || ' (' || verbatim_date || ')' into theValue from collecting_event 
				where collecting_event_id=r.related_primary_key;
				the_relation:=the_relation || theValue;
			when 'agent' then
				select agent_name into theValue from preferred_agent_name where agent_id=r.related_primary_key;
				the_relation:=the_relation || theValue;
			when 'media' then
				select media_uri into theValue from media where media_id=r.related_primary_key;
				the_relation:=the_relation || theValue;
			when 'cataloged_item' then
				select collection || ' ' || cat_num into theValue from cataloged_item,
				collection where
				cataloged_item.collection_id=collection.collection_id and
				 collection_object_id=r.related_primary_key;
				the_relation:=the_relation || theValue;
			else
				the_relation:=the_relation || 'Unknown table: ' || tabl || ' (PKEY: ' || r.related_primary_key || ')';
		end case;
		
		     
     
				--dbms_output.put_line(r.media_relationship);
		sep := ';';
	end loop;
	return the_relation;
end;
/
sho err

-- select get_media_relations(24) from dual;
---->

