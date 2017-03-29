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