<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select 
		ip 
	from 
		uam.blacklist 
	where  
		substr(ip,1,instr(ip,'.',1,2)-1) not in (select subnet from blacklist_subnet)
</cfquery>

<cfset iplist=valuelist(d.ip)>



<cfoutput>
<p>


	<cfset startTime = getTickCount()>
	<cfset x=listfindnocase(application.blacklist,request.ipaddress)>
	<cfset endTime = getTickCount()>
	<cfset etime=endtime-starttime>
	listfindnocase: #etime#
</p>

<p>
	<cfset startTime = getTickCount()>
	<cfset x=listfindnocase(application.blacklist,request.ipaddress,",")>
	<cfset endTime = getTickCount()>
	<cfset etime=endtime-starttime>
	listfindnocase delims: #etime#
</p>

<p>
	<cfset startTime = getTickCount()>
	<cfset x=listfind(application.blacklist,request.ipaddress,",")>
	<cfset endTime = getTickCount()>
	<cfset etime=endtime-starttime>
	listfind delims: #etime#
</p>

<p>
	<cfset startTime = getTickCount()>
	<cfset x=ListContains(application.blacklist,request.ipaddress,",")>
	<cfset endTime = getTickCount()>
	<cfset etime=endtime-starttime>
	ListContains delims: #etime#
</p>





</cfoutput>
