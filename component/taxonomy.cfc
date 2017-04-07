<cfcomponent>

<!--------------------------------------------------------------------------------------->
	<cffunction name="moveTermNewParent" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="term" type="string" required="true">
		<cfoutput>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from hierarchical_taxonomy where term='#term#'
			</cfquery>
			<cfif d.recordcount is 1 and len(d.tid) gt 0>
				<cfquery name="np" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update hierarchical_taxonomy set parent_tid=#d.tid# where tid=#id#
				</cfquery>
				<!--- return
					1) the parent; it's what we'll need to expand;
					2) the child so we can focus it
				---->
				<cfset myStruct = {}>
				<cfset myStruct.status='success'>
				<cfset myStruct.child=id>
				<cfset myStruct.parent=d.tid>

			<cfelse>
				<cfset myStruct = {}>
				<cfset myStruct.status='fail'>
				<cfset myStruct.child=id>
				<cfset myStruct.parent=-1>
			</cfif>
			<cfreturn myStruct>
		</cfoutput>
	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="createTerm" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="newChildTerm" type="string" required="true">
		<cfargument name="newChildTermRank" type="string" required="true">
		<cftry>
			<cfoutput>
				<cfif len(newChildTerm) is 0 or len(newChildTermRank) is 0>
					<cfthrow message="newChildTerm and newChildTermRank are required">
				</cfif>
			<cftransaction>

				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select * from hierarchical_taxonomy where tid=#id#
				</cfquery>
				<cfquery name="i" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into hierarchical_taxonomy (
						TID,
						PARENT_TID,
						TERM,
						RANK,
						DATASET_ID
					) values (
						somerandomsequence.nextval,
						#id#,
						'#newChildTerm#',
						'#newChildTermRank#',
						#d.DATASET_ID#
					)
				</cfquery>
			</cftransaction>
			<cfreturn 'success'>
		</cfoutput>
		<cfcatch>
			<cfreturn cfcatch.message & '; ' & cfcatch.detail >
		</cfcatch>
		</cftry>
	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="deleteTerm" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="id" type="numeric" required="true">
		<cfoutput>
			<cftry>
			<cftransaction>

				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select * from hierarchical_taxonomy where tid=#id#
				</cfquery>

				<cfquery name="deorphan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					delete from htax_noclassterm where tid=#id#
				</cfquery>
				<cfif len(d.PARENT_TID) is 0>
					<cfquery name="udc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update hierarchical_taxonomy set PARENT_TID=NULL where parent_tid=#id#
					</cfquery>
				<cfelse>
					<cfquery name="udc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update hierarchical_taxonomy set PARENT_TID=#d.PARENT_TID# where parent_tid=#id#
					</cfquery>
				</cfif>
				<cfquery name="bye" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					delete from hierarchical_taxonomy where tid=#id#
				</cfquery>
			</cftransaction>
			<cfreturn 'success'>
			<cfcatch>
				<cfreturn 'FAIL: ' & cfcatch.message & '; ' & cfcatch.detail >
			</cfcatch>
			</cftry>
		</cfoutput>
	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="saveMetaEdit" access="remote">
		<!---- hierarchical taxonomy editor ---->
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
		<cftry>
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
		<cfcatch>
			<cfreturn 'FAIL: ' & cfcatch.message & cfcatch.detail>
		</cfcatch>
		</cftry>

		</cfoutput>
	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="getSeedTaxSum" access="remote">
		<!---- hierarchical taxonomy editor ---->
		 <cfargument name="source" type="string" required="false">
	   <cfargument name="kingdom" type="string" required="false">
	   <cfargument name="phylum" type="string" required="false">
	   <cfargument name="class" type="string" required="false">
	   <cfargument name="order" type="string" required="false">
	   <cfargument name="family" type="string" required="false">
	   <cfargument name="genus" type="string" required="false">



		<cfoutput>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
<!--------------------------------------------------------------------------------------->
	<cffunction name="saveParentUpdate" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="dataset_id" type="numeric" required="true"/>
		<cfargument name="tid" type="numeric" required="true">
		<cfargument name="parent_tid" type="numeric" required="true">
		<cfoutput>
			<cftry>
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update hierarchical_taxonomy set parent_tid=#parent_tid# where
					dataset_id=#dataset_id# and tid=#tid#
				</cfquery>
				<cfreturn 'success'>
				<cfcatch>
					<cfreturn 'ERROR: ' & cfcatch.message>
				</cfcatch>
			</cftry>
		</cfoutput>
	</cffunction>
<!--------------------------------------------------------------------------------------->
	<cffunction name="getTaxTreeChild" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="dataset_id" type="numeric" required="true"/>
		<cfargument name="id" type="numeric" required="true">
		<cfoutput>
			<cftry>
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select term,tid,nvl(parent_tid,0) parent_tid, rank from hierarchical_taxonomy where
					dataset_id=#dataset_id# and parent_tid = #id# order by term
				</cfquery>
				<cfreturn d>
				<cfcatch>
					<cfreturn 'ERROR: ' & cfcatch.message>
				</cfcatch>
			</cftry>
		</cfoutput>
	</cffunction>
<!--------------------------------------------------------------------------------------->

	<cffunction name="getTaxTreeSrch" access="remote">
		<!---- hierarchical taxonomy editor ---->
	<cfargument name="dataset_id" type="numeric" required="true"/>
	   <cfargument name="q" type="string" required="true">
		<!---- https://goo.gl/TWqGAo is the quest for a better query. For now, ugly though it be..... ---->
		<cfoutput>
			<cftry>
				<cfset key=RandRange(1, 66)>

			<!---- first get the terms that match our search ---->

			create table htax_srchhlpr (
		-- one-time use key
		key number not null,
		parent_tid number,
		term varchar2(255),
		tid number,
		rank varchar2(255)
	);
			<cfquery name="dc0" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="r_dc0">
				insert into htax_srchhlpr (
					key,
					parent_tid
				) (
					select distinct
						#key#,
						nvl(parent_tid,0)
					from
						hierarchical_taxonomy
					where
						dataset_id=#dataset_id# and
						upper(term) like '#ucase(q)#%'
				)
			</cfquery>

			<cfdump var=#r_dc0#>


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
				<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select nvl(parent_tid,0) parent_tid, term,tid,rank from hierarchical_taxonomy where tid in (#thisIds#)
				</cfquery>

			<!--- this works


			<!---- first get the terms that match our search ---->
			<cfquery name="dc0" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
				<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select nvl(parent_tid,0) parent_tid, term,tid,rank from hierarchical_taxonomy where tid in (#thisIds#)
				</cfquery>


				works----->
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
<!--------------------------------------------------------------------------------------->
	<cffunction name="getInitTaxTree" access="remote">
		<!---- hierarchical taxonomy editor ---->
		<cfargument name="dataset_id" type="numeric" required="true"/>
		<cfoutput>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select nvl(parent_tid,0) parent_tid, term,tid,rank from hierarchical_taxonomy where
				dataset_id=#dataset_id# and parent_tid is null
			</cfquery>
			<cfset x="[">
			<cfset i=1>
			<cfloop query="d">
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
<!--------------------------------------------------------------------------------------->
</cfcomponent>
