<cfcomponent>
<cffunction name="getTaxTreeChild" access="remote">
   <cfargument name="id" type="numeric" required="true">

	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select term,tid,nvl(parent_tid,0) parent_tid, rank from hierarchical_taxonomy where parent_tid = #id#
		</cfquery>


		<!----
		<cfset x="[">
		<cfset i=1>
		<cfloop query="d">
			<cfset x=x & '{"#parent_tid#","#tid#","#term#",0,0,0,0}'>

			<cfif i lt d.recordcount>
				<cfset x=x & ",">
			</cfif>
			<cfset i=i+1>
		</cfloop>
		<cfset x=x & "]">
		<cfreturn x>

		---->
		<cfreturn d>
	</cfoutput>

</cffunction>


<!-------------------------------------------------->

<cffunction name="getTaxTreeSrch" access="remote">
   <cfargument name="q" type="string" required="true">
	<!---- https://goo.gl/TWqGAo is the quest for a better query. For now, ugly though it be..... ---->
	<cfoutput>
		<!---- first get the terms that match our search ---->
		<cfquery name="dc0" datasource="uam_god">
			select distinct nvl(parent_tid,0) parent_tid, term,tid,rank from hierarchical_taxonomy where upper(term) like '#ucase(q)#%'
		</cfquery>
		<cfif not dc0.recordcount gt 0>
			<cfreturn 'ERROR: nothing found'>
		</cfif>

		<!---- copy init query---->
		<cfquery name="rsltQry" dbtype="query">
			select * from dc0
		</cfquery>
		<!--- this will die if we ever get more than 100-deep ---->
		<cfset thisIds=valuelist(dc0.parent_tid)>
		<cfloop from="1" to="100" index="i">
			<!---find next parent--->
			<cfquery name="q" datasource="uam_god">
				select nvl(parent_tid,0) parent_tid, term,tid,rank from hierarchical_taxonomy where tid in (#thisIds#)
			</cfquery>
			<!--- next loop --->

			<cfset thisIds=valuelist(q.parent_tid)>

			<cfif len(thisIds) is 0>
				<cfbreak>
			</cfif>


			<cfloop query="q">
				<!--- don't insert if we already have it ---->
				<cfquery dbtype="query" name="alreadyGotOne">
					select count(*) c from rsltQry where tid=#tid#
				</cfquery>
				<cfif not alreadyGotONe.c gt 0>
					<!--- insert ---->
					<cfset queryaddrow(rsltQry,{
						tid=q.tid,
						parent_tid=q.parent_tid,
						term=q.term,
						rank=q.rank
					})>
				</cfif>
			</cfloop>

		</cfloop>

		<cfset x="[">
		<cfset i=1>
		<cfloop query="rsltQry">

			<!----
			<cfset x=x & '{"id":"id_#tid#","text":"#term# (#rank#)","children":true}'>
			---->
			<cfset x=x & '["#tid#","#parent_tid#","#term# (#rank#)"]'>
			<cfif i lt rsltQry.recordcount>
				<cfset x=x & ",">
			</cfif>
			<cfset i=i+1>
		</cfloop>
		<cfset x=x & "]">

		<cfreturn x>


	</cfoutput>

</cffunction>
<!-------------------------------------------------->

<cffunction name="getInitTaxTree" access="remote">

	<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select nvl(parent_tid,0) parent_tid, term,tid,rank from hierarchical_taxonomy where parent_tid is null
	</cfquery>
	<cfset x="[">
	<cfset i=1>
	<cfloop query="d">

		<!----
		<cfset x=x & '{"id":"id_#tid#","text":"#term# (#rank#)","children":true}'>
		---->
		<cfset x=x & '["#tid#","#parent_tid#","#term# (#rank#)"]'>
		<cfif i lt d.recordcount>
			<cfset x=x & ",">
		</cfif>
		<cfset i=i+1>
	</cfloop>
	<cfset x=x & "]">

		<cfreturn x>
	</cfoutput>

</cffunction>
<!-------------------------------------------------->
<cffunction name="test" access="remote">
   <cfargument name="q" type="String" required="false" default=""/>
<cfargument name="t" type="String" required="false" default=""/>

	<cftry>
	<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from agent_name where upper(agent_name) like '#ucase(q)#%'
		<cfif len(t) gt 0>and age_name_type='#t#'</cfif>
	</cfquery>
	<cfreturn t>
	<cfcatch>
		<cfreturn cfcatch.detail>
	</cfcatch>
	</cftry>
</cffunction>

<cffunction name="getNodes" access="remote" returntype="array">
   <cfargument name="path" type="String" required="false" default=""/>
   <cfargument name="value" type="String" required="true" default=""/>
   <!--- set up return array --->
      <cfset var result= arrayNew(1)/>
      <cfset var s =""/>

      <!--- if arguments.value is empty the tree is being built for the first time --->
      <cfif arguments.value is "">
         <cfset x = 0/>
         <cfloop from="1" to="10" index="i">
            <cfset x = x+1/>
            <cfset s = structNew()/>
            <cfset s.value=#x#>
            <cfset s.display="Node #i#">
            <cfset arrayAppend(result,s)/>
         </cfloop>
      <cfelse>
      <!--- arguments.value is not empty --->
      <!--- to keep it simple we will only make children nodes --->
      <cfset y = 0/>
         <cfloop from="1" to="#arguments.value#" index="q">
            <cfset y = y + 1/>
            <cfset s = structNew()/>
            <cfset s.value=#q#>
            <cfset s.display="Leaf #q#">
            <cfset s.leafnode=true/>
            <cfset arrayAppend(result,s)/>
         </cfloop>
      </cfif>
   <cfreturn result/>
</cffunction>
</cfcomponent>
