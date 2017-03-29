<!----

move to cf_global_settings if this works

create table temp_gmail (pwd varchar2(255));
insert into temp_gmail(pwd)values('xxx');

boogity56
---->

<cfquery name="p" datasource="uam_god">
	select * from temp_gmail
</cfquery>

<cfoutput>

<cfdump var=#p#>
 <cfimap
        server = "imap.gmail.com"
        username = "arctos.is.not.dead"
        action="ListAllFolders"
        secure="yes"
        password = "boogity56"
        connection = "test.cf.gmail"
		>
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