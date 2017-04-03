<cfcomponent>


<cffunction name="deleteTerm" access="remote">
	<cfargument name="id" type="numeric" required="true">
	<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from hierarchical_taxonomy where tid=#id#
	</cfquery>
	<cfdump var=#d#>
	<cfif len(d.PARENT_TID) is 0>
		no parent!
	<cfelse>
		got parent....
	</cfif>
	</cfoutput>
</cffunction>

<cffunction name="saveMetaEdit" access="remote">
	 <cfargument name="q" type="string" required="true">
<cfoutput>
	<!----
		de-serialize q
		throw it in a query because easy
	---->
	<cfset qry=queryNew("qtrm,qval")>
	<cfloop list="#q#" delimiters="&?" index="i">
		<cfif listlen(i,"=") eq 2>
			<cfset t=listGetAt(i,1,"=")>
			<cfset v=listGetAt(i,2,"=")>
			<cfset queryAddRow(qry, {qtrm=t,qval=v})>
		</cfif>
	</cfloop>
	<!--- should always have this; fail if no --->
	<cfquery name="x" dbtype="query">
		select qval from qry where qtrm='tid'
	</cfquery>
	<cfset tid=x.qval>
	<cftransaction>
	<cfloop query="qry">
		<cfif left(qtrm,15) is "nctermtype_new_">
			<!--- there should be a corresponding nctermvalue_new_1 ---->
			<cfset thisIndex=listlast(qtrm,"_")>
			<cfquery name="thisval" dbtype="query">
				select QVAL from qry where qtrm='nctermvalue_new_#thisIndex#'
			</cfquery>
			<cfquery name="insone" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into htax_noclassterm (
					NC_TID,
					TID,
					TERM_TYPE,
					TERM_VALUE
				) values (
					somerandomsequence.nextval,
					#tid#,
					'#qval#',
					'#URLDecode(thisval.qval)#'
				)
			</cfquery>
		<cfelseif left(qtrm,11) is "nctermtype_">
			<cfset thisIndex=listlast(qtrm,"_")>
			<cfquery name="thisval" dbtype="query">
				select QVAL from qry where qtrm='nctermvalue_#thisIndex#'
			</cfquery>
			<cfif QVAL is "DELETE">
				<cfquery name="done" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					delete from htax_noclassterm where NC_TID=#thisIndex#
				</cfquery>
			<cfelse>
				<cfquery name="uone" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update htax_noclassterm set TERM_TYPE='#qval#',TERM_VALUE='#URLDecode(thisval.qval)#' where NC_TID=#thisIndex#
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
	</cftransaction>
	<cfreturn 'success'>

	</cfoutput>
</cffunction>

<cffunction name="getSeedTaxSum" access="remote">
	 <cfargument name="source" type="string" required="false">
   <cfargument name="kingdom" type="string" required="false">
   <cfargument name="phylum" type="string" required="false">
   <cfargument name="class" type="string" required="false">
   <cfargument name="order" type="string" required="false">
   <cfargument name="family" type="string" required="false">
   <cfargument name="genus" type="string" required="false">



	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select
				count(distinct(scientific_name)) c
			from
				taxon_name,
				taxon_term
			where
				taxon_name.taxon_name_id=taxon_term.taxon_name_id and
				taxon_term.source='#source#'
				<cfif len(kingdom) gt 0>
					and term_type='kingdom' and term='#kingdom#'
				</cfif>
				<cfif len(phylum) gt 0>
					and term_type='phylum' and term='#phylum#'
				</cfif>
				<cfif len(class) gt 0>
					and term_type='class' and term='#class#'
				</cfif>
				<cfif len(order) gt 0>
					and term_type='order' and term='#order#'
				</cfif>
				<cfif len(family) gt 0>
					and term_type='family' and term='#family#'
				</cfif>
				<cfif len(genus) gt 0>
					and term_type='genus' and term='#genus#'
				</cfif>
		</cfquery>
		<cfreturn d>
	</cfoutput>

</cffunction>

<cffunction name="saveParentUpdate" access="remote">
		<cfargument name="dataset_id" type="numeric" required="true"/>

   <cfargument name="tid" type="numeric" required="true">
   <cfargument name="parent_tid" type="numeric" required="true">

	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			update hierarchical_taxonomy set parent_tid=#parent_tid# where
			dataset_id=#dataset_id# and tid=#tid#
		</cfquery>
		<cfreturn 'success'>
	</cfoutput>

</cffunction>

<cffunction name="getTaxTreeChild" access="remote">
	<cfargument name="dataset_id" type="numeric" required="true"/>
	<cfargument name="id" type="numeric" required="true">
	<cfoutput>
		<cftry>
			<cfquery name="d" datasource="uam_god">
				select term,tid,nvl(parent_tid,0) parent_tid, rank from hierarchical_taxonomy where
				dataset_id=#dataset_id# and parent_tid = #id# order by term
			</cfquery>
			<cfreturn d>
		<cfcatch>
			<cfreturn 'ERROR: ' & cfcatch.message>
		</cfcatch>
		</cftry>


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

	</cfoutput>

</cffunction>


<!-------------------------------------------------->

<cffunction name="getTaxTreeSrch" access="remote">
<cfargument name="dataset_id" type="numeric" required="true"/>
   <cfargument name="q" type="string" required="true">
	<!---- https://goo.gl/TWqGAo is the quest for a better query. For now, ugly though it be..... ---->
	<cfoutput>
		<cftry>
		<!---- first get the terms that match our search ---->
		<cfquery name="dc0" datasource="uam_god">
			select distinct nvl(parent_tid,0) parent_tid, term,tid,rank from hierarchical_taxonomy where
			dataset_id=#dataset_id# and
			upper(term) like '#ucase(q)#%'
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
<cfcatch>
	<cfreturn 'ERROR: ' & cfcatch.message & ' ' & cfcatch.detail>
</cfcatch>
	</cftry>

	</cfoutput>

</cffunction>
<!-------------------------------------------------->

<cffunction name="getInitTaxTree" access="remote">
	<cfargument name="dataset_id" type="numeric" required="true"/>


	<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select nvl(parent_tid,0) parent_tid, term,tid,rank from hierarchical_taxonomy where
		dataset_id=#dataset_id# and parent_tid is null
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
