<cfif action is "f">
		<cfquery name="a" datasource="uam_god">
			insert into t1 values (#a#,#b#)
		</cfquery>
		<cfquery name="b" datasource="uam_god">
			insert into t2 values (#b#,#a#)
		</cfquery>
</cfif>

<cfif action is "p">
	<cftransaction>
		<cfquery name="a" datasource="uam_god">
			insert into t1 values (#a#,#b#)
		</cfquery>
		<cfquery name="b" datasource="uam_god">
			insert into t2 values (#b#,#a#)
		</cfquery>
	</cftransaction>
</cfif>