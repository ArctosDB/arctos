<cfcomponent>
	<cffunction name="t" access="remote" returnformat="plain" queryFormat="column">
		<cfparam name="jtStartIndex" type="numeric" default="0">
		<cfparam name="jtPageSize" type="numeric" default="10">
		<cfparam name="jtSorting" type="string" default="GUID ASC">
		<cfset jtStopIndex=jtStartIndex+jtPageSize>
		
		<cfset obj = CreateObject("component","component.docs")>


		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			Select * from (
					Select a.*, rownum rnum From (
						select * from #session.SpecSrchTab# order by #jtSorting#
					) a where rownum <= #jtStopIndex#
				) where rnum >= #jtStartIndex#
		</cfquery>
		<cfoutput>
			<!--- 
				CF and jtable don't play well together, so roll our own.... 
				parseJSON makes horrid invalud datatype assumptions, so we can't use that either.	
			---->
			<cfset x=''>
			<cfloop query="d">
				<cfset trow="">
				<cfloop list="#d.columnlist#" index="i">
					<cfset theData=evaluate("d." & i)>
					<cfset theData=obj.jsonEscape(theData)>
					
					<cfif i is "guid">
						<cfset temp ='"GUID":"<div id=\"CatItem_#collection_object_id#\"><a target=\"_blank\" href=\"/guid/' & theData &'\">' &theData & '</a></div>"'>
					<cfelseif i is "media">
						<cfset temp ='"MEDIA":"<div id=\"jsonmedia_#collection_object_id#\">' & theData & '</div>"'>
					<cfelse>
						<cfset temp = '"#i#":"' & theData & '"'>
					</cfif>
					<cfset trow=listappend(trow,temp)>
				</cfloop>
				<cfset trow="{" & trow & "}">
				<cfset x=listappend(x,trow)>
			</cfloop>
			<cfset result='{"Result":"OK","Records":[' & x & '],"TotalRecordCount":#TotalRecordCount#}'>
		</cfoutput>
		<cfreturn result>
	</cffunction>
</cfcomponent>