<!----

move to cf_global_settings if this works

create table temp_gmail (pwd varchar2(255));
insert into temp_gmail(pwd)values('xxx');

boogity56


alter table cf_global_settings add monitor_email_addr varchar2(255);
alter table cf_global_settings add monitor_email_pwd varchar2(255);

---->

<cfquery name="p" datasource="uam_god">
	select monitor_email_addr,monitor_email_pwd from cf_global_settings
</cfquery>

<cfoutput>

<cfdump var=#p#>
 <cfimap
        server = "imap.gmail.com"
        username = "#monitor_email_addr#"
        action="open"
        secure="yes"
        password = "#monitor_email_pwd#"
        connection = "gmail"
		>
    <!--- everything all filtered messages. Should generally be one. --->
    <cfimap
        action="GetAll"
		folder="inbox"
        connection="gmail"
        name="cart">
    <cfdump var="#cart#">

	<!--- loopty. should have something in the last hour. If so, done. If not, send frantic email --->
	<cfset sendAlert="true">
	<cfloop query="cart">
		<cfif subject is "arctos is not dead">
			<p>
				SENTDATE: #SENTDATE#
				<br><cfset tss=datediff('n',SENTDATE,now())>
				tss:#tss#
				<cfif tss lt 60>
					<cfset sendAlert=false>
				</cfif>
				<!---
				move the message
				should probably just delete but oh well
				---->

				<cfimap
			        action="MoveMail"
			        newfolder="was not dead"
			        messagenumber="#MESSAGENUMBER#"
			        stoponerror="true"
			        connection="gmail">
			</cfif>
		</p>
	</cfloop>
    <cfimap
        action="close"
        connection = "gmail">

	<cfif sendAlert is true>
		omg no email panicking now!!
	<cfelse>
		this doesn't need to be here, everything is happy
	</cfif>


</cfoutput>