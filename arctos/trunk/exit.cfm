<cfinclude template="includes/_header.cfm">
<cfset title="You are now leaving Arctos.">
<cfoutput>
<cfif not isdefined("target") or len(target) is 0>
	Improper call of this form.	
	<cfthrow detail="exit called without target" errorcode="9944" message="A call to the exit form was made without specifying a target.">
	<cfabort>
</cfif>
<cfhttp url="#target#" method="head">

</cfhttp>

<cfdump var=#cfhttp#>


</cfoutput>
create table exit_link (
exit_link_id number not null,
username varchar2(255),
ipaddress varchar2(255),
from_page varchar2(255),
to_page varchar2(255),
when_date date
  8  );


<cfinclude template="includes/_footer.cfm">