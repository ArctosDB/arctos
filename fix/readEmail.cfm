<!----

move to cf_global_settings if this works

create table temp_gmail (pwd varchar2(255));
insert into temp_gmail(pwd)values('xxx');
---->

<cfquery name="p" datasource="uam_god">
	select * from temp_gmail
</cfquery>

<cfoutput>

<cfdump var=#p#>
 <cfimap
        server = "imap.gmail.com"
        username = "arctos.database@gmail.com"
        action="open"
        secure="yes"
        password = "#p.pwd#"
        connection = "test.cf.gmail">
    <!--- Retrieve header information from the mailbox. --->
    <cfimap
        action="getHeaderOnly"
        connection="test.cf.gmail"
        name="queryname">
    <cfdump var="#queryname#">
    <cfimap
        action="close"
        connection = "test.cf.gmail">


</cfoutput>