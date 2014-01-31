<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select 
		ip 
	from 
		uam.blacklist 
	where  
		substr(ip,1,instr(ip,'.',1,2)-1) not in (select subnet from blacklist_subnet)
</cfquery>

<cfset iplist=valuelist(d.ip)>

<cfset ipla=ListToArray(iplist)>

<cfoutput>
<p>


	<cfset startTime = getTickCount()>
	<cfset x=listfindnocase(application.blacklist,request.ipaddress)>
	<cfset endTime = getTickCount()>
	<cfset etime=endtime-starttime>
	listfindnocase: #etime#
	<br>#x#
</p>

<p>
	<cfset startTime = getTickCount()>
	<cfset x=listfindnocase(application.blacklist,request.ipaddress,",")>
	<cfset endTime = getTickCount()>
	<cfset etime=endtime-starttime>
	listfindnocase delims: #etime#
	<br>#x#
</p>

<p>
	<cfset startTime = getTickCount()>
	<cfset x=listfind(application.blacklist,request.ipaddress,",")>
	<cfset endTime = getTickCount()>
	<cfset etime=endtime-starttime>
	listfind delims: #etime#
	<br>#x#
</p>

<p>
	<cfset startTime = getTickCount()>
	<cfset x=ListContains(application.blacklist,request.ipaddress,",")>
	<cfset endTime = getTickCount()>
	<cfset etime=endtime-starttime>
	ListContains delims: #etime#
	<br>#x#
</p>

<p>
	<cfset startTime = getTickCount()>
	<cfset x=ArrayContains(ipla,request.ipaddress)>
	<cfset endTime = getTickCount()>
	<cfset etime=endtime-starttime>
	ArrayContains delims: #etime#
	<br>#x#
</p>



</cfoutput>
