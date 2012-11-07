<!----




drop table ds_temp_date;

create table ds_temp_date (
	key number not null,
	y varchar2(255),
	m varchar2(255),
	d varchar2(255),
	returndate   varchar2(255),
	status varchar2(4000),
	concat  varchar2(255)
	);
	
create public synonym ds_temp_date for ds_temp_date;
grant all on ds_temp_date to coldfusion_user;
grant select on ds_temp_date to public;

 CREATE OR REPLACE TRIGGER ds_temp_date_key                                         
 before insert  ON ds_temp_date
 for each row 
    begin     
    	if :NEW.key is null then                                                                                      
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;                                
    end;                                                                                            
/
sho err




---->
<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
	upload csv with headers....
	<ul>
		
		<li>y</li>
		<li>m</li>
		<li>d</li>
	</ul>
	
	
	<cfform name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>

</cfif>
<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from ds_temp_date
	</cfquery>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset numberOfColumns = ArrayLen(arrResult[1])>
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				 <cfset numColsRec = ArrayLen(arrResult[o])>
				<cfset thisBit=arrResult[o][i]>
				<cfif #o# is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif #o# is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>	
		<cfif len(colVals) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfif numColsRec lt numberOfColumns>
				<cfset missingNumber = numberOfColumns - numColsRec>
				<cfloop from="1" to="#missingNumber#" index="c">
					<cfset colVals = "#colVals#,''">
				</cfloop>
			</cfif>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into ds_temp_date (#colNames#) values (#preservesinglequotes(colVals)#)				
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>
<cflocation url="dateSplit.cfm?action=validate" addtoken="false">

<!---
---->
</cfif>
<cfif action is "validate">
<cfoutput>
	<cfquery name="fu" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update ds_temp_date set
		y=trim(y),
		m=trim(m),
		d=trim(d)
	</cfquery>

	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_date
	</cfquery>
	
	<cfloop query="d">
		<hr>#y# - #m# - #d#
		<cfset status=''>
		<cfif not refind('^[0-9]{4}$',y)>
			<br>#y# isn't a 4-digit thingee
			<cfset status=listappend(status,'year invalid',';')>
		</cfif>
		<cfif m is "January">
			<cfset mm='01'>
		<cfelseif m is "February">
			<cfset mm='02'>
		<cfelseif m is "March">
			<cfset mm='03'>
		<cfelseif m is "April">
			<cfset mm='04'>
		<cfelseif m is "May">
			<cfset mm='05'>
		<cfelseif m is "June">
			<cfset mm='06'>
		<cfelseif m is "July">
			<cfset mm='07'>
		<cfelseif m is "August">
			<cfset mm='08'>
		<cfelseif trim(m) is "September">
			<cfset mm='09'>
		<cfelseif m is "October">
			<cfset mm='10'>
		<cfelseif m is "November">
			<cfset mm='11'>
		<cfelseif m is "December">
			<cfset mm='12'>
		<cfelse>
			<cfset mm=m>
		</cfif>
		<cfif len(mm) gt 0 and not refind('^[0-9]{2}$',mm)>
			<br>#mm# isn't a 2-digit month
			<cfset status=listappend(status,'month invalid',';')>
		</cfif>
		<cfset dd=d>
		<cfif len(dd) gt 0 and not refind('^[0-9]{2}$',dd)>
			<cfset dd='0' & dd>
			<cfif not refind('^[0-9]{2}$',dd)>
				<br>#dd# isn't a 2-digit day
				<cfset status=listappend(status,'day invalid',';')>
			</cfif>
		</cfif>
		<cfif len(status) is 0>
			<cfset iso=y>
			<cfif len(mm) gt 0>
				<cfset iso=iso & '-' & mm>
			</cfif>
			<cfif len(dd) gt 0>
				<cfset iso=iso & '-' & dd>
			</cfif>d<br>iso==#iso#
			
			<cfset cc=d & ' ' & m & ' '  & y>
			<cfset cc=trim(replace(cc,"  ", " ","all"))>
			<br>cc=#cc#
			<cfquery name="fu" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select is_iso8601('#iso#') isiso from dual
			</cfquery>
			<cfset status=listappend(status,'#fu.isiso#',';')>
			<br>status=#status#
			<cfquery name="ss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update ds_temp_date set
					returndate='#iso#',
					status='#status#',
					concat='#cc#'
				where
					key=#key#
			</cfquery>

			<br>#fu.isiso#

		</cfif>
	</cfloop>
	
</cfoutput>
</cfif>


<cfinclude template="/includes/_footer.cfm"><strong></strong>