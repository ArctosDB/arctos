<cfquery name="d" datasource="uam_god">
	select 
	accn_number
from 
	accn,
	trans 
where 
	accn.transaction_id=trans.transaction_id and 
	collection_id=14
having count(*) > 1
group by accn_number
</cfquery>
<cfoutput>
	<cfloop query="d">
		<cfquery name="a" datasource="uam_god">
			select * from accn,trans,trans_agent where
			accn.transaction_id=trans.transaction_id and
			accn.transaction_id=trans_agent.transaction_id and
			collection_id=14 and
			accn_number='#accn_number#'
		</cfquery>
		<cfset p="">
		<cfquery name="ta" dbtype="query">
			select count(distinct(transaction_id)) c from a
		</cfquery>
		<cfif ta.c neq 2>
			<cfset p=p & "; not 2 transactions">
		</cfif>
		<cfquery name="mi" dbtype="query">
			select min(transaction_id) n from a
		</cfquery>
		<cfquery name="one" dbtype="query">
			select * from a where transaction_id = #mi.n#
		</cfquery>
		<cfquery name="ma" dbtype="query">
			select max(transaction_id) n from a
		</cfquery>
		<cfquery name="two" dbtype="query">
			select * from a where transaction_id = #ma.n#
		</cfquery>
		<cfquery name="oneA" dbtype="query">
			select distinct(agent_id) agent_id from one
		</cfquery>
		<cfif oneA.agent_id is not 0>
			<cfset p=p & "; one has funky agents">
		</cfif>
		<cfif one.nature_of_material is not 'legacy mammals'>
			<cfset p=p & "; one not legacy mammals">
		</cfif>
		<cfif two.nature_of_material is 'legacy mammals'>
			<cfset p=p & "; dammit - two=legacy">
		</cfif>
		<cfquery name="oneSpec" datasource="uam_god">
			select count(*) c from cataloged_item where accn_id=#one.transaction_id#
		</cfquery>
		<cfif oneSpec.c is 0>
			<cfset p=p & "; one has no spec">
		</cfif>
		<cfquery name="twoSpec" datasource="uam_god">
			select count(*) c from cataloged_item where accn_id=#two.transaction_id#
		</cfquery>
		<cfif twoSpec.c gt 0>
			<cfset p=p & "; two has spec">
		</cfif>
		<cfif len(p) gt 0>
			#one.accn_number# errors: #p#
		<cfelse>
			<cftransaction>
				<cftry>
					<cfquery name="upCI" datasource="uam_god">
						update cataloged_item set accn_id=#two.transaction_id# where accn_id=#one.transaction_id#
					</cfquery>
					<cfquery name="delAg" datasource="uam_god">
						delete from trans_agent where transaction_id=#one.transaction_id#
					</cfquery>
					<cfquery name="delAc" datasource="uam_god">
						delete from accn where transaction_id=#one.transaction_id#
					</cfquery>
					<cfquery name="delT" datasource="uam_god">
						delete from trans where transaction_id=#one.transaction_id#
					</cfquery>
					#one.accn_number#: fixed
				<cfcatch>
					<cftransaction action="rollback" />
					<cfdump var=#cfcatch#>
				</cfcatch>
				</cftry>
			</cftransaction>
		</cfif>
		<hr>
	</cfloop>
</cfoutput>