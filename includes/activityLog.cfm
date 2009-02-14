<!--- custom tag logs usage based on form conventions.
requires table:

drop table cf_log;

create table cf_log (
log_id number not null,
username varchar2(255),
template varchar2(255),
access_date date,
query_string varchar2(4000),
reported_count number,
referring_url varchar2(4000)
)
;

create or replace public synonym cf_log for cf_log;
grant insert on cf_log to public;
grant select on cf_log to manage_authority,uam_update;

 CREATE OR REPLACE TRIGGER cf_log_id                                         
 before insert  ON cf_log  
 for each row 
    begin     
    	if :NEW.log_id is null then                                                                                      
    		select somerandomsequence.nextval into :new.log_id from dual;
    	end if;
		if :NEW.access_date is null then                                                                                      
    		:NEW.access_date:= sysdate;
    	end if;                                 
    end;                                                                                            
/
sho err

--->
<cfoutput>
<cfparam name="log.template" default="#cgi.SCRIPT_NAME#">
<cfparam name="log.query_string" default="-unknown-">
<cfparam name="log.referring_url" default="#cgi.HTTP_REFERER#">
<cfparam name="log.reported_count" default="-1">
<cfparam name="log.access_date" default="#dateformat(now(),'dd-mmm-yyyy')#">
<cfset log.query_string = replace(log.query_string,"'","''","all")>
<cfif isdefined("session.username") and len(#session.username#) gt 0>
	<cfset log.username=#session.username#>
<cfelse>
	<cfif len(#cgi.HTTP_X_FORWARDED_FOR#) gt 0>
		<cfset log.username = #cgi.HTTP_X_FORWARDED_FOR#>
	<cfelseif len(#cgi.REMOTE_ADDR#) gt 0>
		<cfset log.username = #cgi.REMOTE_ADDR#>
	<cfelse>
		<cfset log.username = 'cannot resolve'>
	</cfif>	
</cfif>
<cfset log.template= #cgi.SCRIPT_NAME#>
<cfset sql = "insert into cf_log (
			username,
			template,
			query_string,
			reported_count,
			referring_url
		) values (
			'#log.username#',
			'#log.template#',
			'#log.query_string#',
			#log.reported_count#,
			'#log.referring_url#')">
		<cftry>
		<cfquery name="log_this" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(sql)#
		</cfquery>
		<cfcatch>
			---nada ---
		</cfcatch>
		</cftry>
	
</cfoutput>