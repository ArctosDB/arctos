
<cfquery name="d" datasource="uam_god">
	select project_name from project
</cfquery>
<cfoutput>

	<cfloop query="d">
		<hr>#project_name#
		<cfset s=trim(rereplace(project_name,'<[^<>]+>',''))>
		<cfset s=rereplace(s,'[^A-Za-z ]*','')>
		<cfset s=rereplace(s,' ','-','',"all")>
		<cfset s=lcase(s)>
		<cfif len(s) gt 150>
			<cfset s=left(s,150)>
		</cfif>
		<br>S; #s#
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

