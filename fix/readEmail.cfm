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
        action="open"
        secure="yes"
        password = "boogity56"
        connection = "gmail"
		>
    <!--- Retrieve header information from the mailbox. --->
    <cfimap
        action="GetAll"
		folder="the cart"
        connection="gmail"
        name="allmail">
    <cfdump var="#allmail#">
    <cfimap
        action="close"
        connection = "gmail">


</cfoutput>