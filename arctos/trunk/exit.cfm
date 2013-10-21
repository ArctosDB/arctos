<cfdump var=#form#><cfdump var=#url#>

<cfif not isdefined("target")>
	Improper call of this form.
	
	<cfthrow detail="exit called without target" errorcode="9944" message="A call to the exit form was made without specifying a target.">
	error.....
</cfif>
create table exit_link (
exit_link_id number not null,
username varchar2(255),
ipaddress varchar2(255),
from_page varchar2(255),
to_page varchar2(255),
when_date date
  8  );
