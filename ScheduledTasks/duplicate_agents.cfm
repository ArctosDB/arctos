<cfinclude template="/includes/_header.cfm">
<!---
create table cf_dup_agent (
	cf_dup_agent_id number not null,
	AGENT_ID number not null,
	RELATED_AGENT_ID number not null,
	agent_pref_name varchar2(255) not null,
	rel_agent_pref_name varchar2(255) not null,
	detected_date timestamp not null,
	resolved_date timestamp not null,
	status varchar2(255)
);

CREATE OR REPLACE TRIGGER tr_cf_dup_agent_key
BEFORE INSERT ON cf_dup_agent
FOR EACH ROW
BEGIN
        IF :new.cf_dup_agent_id IS NULL THEN
        	SELECT somerandomsequence.nextval
    		INTO :new.cf_dup_agent_id
    		FROM dual;
        END IF;
END;
/


--->
<cfif action is "findDups">
	<cfquery name="contacts" datasource="uam_god">
		select 
			AGENT_ID,
			RELATED_AGENT_ID
		from
			agent_relations
		where
			AGENT_RELATIONSHIP='bad duplicate of'
		and agent_id,RELATED_AGENT_ID not in
		(select agent_id,RELATED_AGENT_ID from cf_dup_agent)
	</cfquery>
	
	<cfdump var=#findDups#>
</cfif>


<cfinclude template="/includes/_footer.cfm">