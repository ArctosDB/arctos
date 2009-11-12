<cffunction name="niceURL" returntype="Any">
	<cfargument name="s" type="string" required="yes">
	<cfscript>
		var r=trim(s);
		r=trim(rereplace(r,'<[^>]*>','',"all"));
		r=rereplace(r,'[^A-Za-z ]','',"all");
		r=rereplace(r,' ','-',"all");
		r=lcase(r);
		if (len(r) gt 150) {
			r=left(r,150);
		}
		if (right(r,1) is "-") {
			r=left(r,len(r)-1);
		}
		r=rereplace(r,'-+','-','all');
		return r;
	</cfscript>
	
</cffunction>
<cfquery name="d" datasource="uam_god">
	select project_name from project
</cfquery>
<cfoutput>

	<cfloop query="d">
		<hr>#project_name#
		<cfset s=trim(rereplace(project_name,'<[^>]*>','',"all"))>
		<cfset s=rereplace(s,'[^A-Za-z ]','',"all")>
		<cfset s=rereplace(s,' ','-',"all")>
		<cfset s=lcase(s)>
		<cfif len(s) gt 150>
			<cfset s=left(s,150)>
		</cfif>
		<cfif right(s,1) is "-">
			<cfset s=left(s,len(s)-1)>
		</cfif>
		<cfset s=replace(s,'--','-','all')>
		<br>#s#
		<br>
		<cfset q=niceURL(project_name)>
		#q#
	</cfloop>
</cfoutput>
<br />declare s varchar2(4000);
begin
for r in (select project_name from project) loop
	--dbms_output.put_line('------------------------------');
--	dbms_output.put_line(r.project_name);
	s:=trim(regexp_replace(r.project_name,'<[^<>]+>'));
	s:=regexp_replace(s,);
	s:=regexp_replace(s,);
	s:=lower(s);
	if length(s)>100 then
		dbms_output.put_line('==========================  chopped ======================================');
		s:=substr(s,1,100);
	end if;
	dbms_output.put_line(s);
	
end loop;
end;
/

