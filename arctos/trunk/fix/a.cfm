<cfoutput>

	
	<cfquery datasource="uam_god" name="cols">
		select * from taxonomy where 1=2		
	</cfquery>
	<cfset c=cols.columnlist>
	
	<cfloop list="#c#" index="fl">
	
		<cfloop list="#c#" index="sl">
			<cfquery datasource="uam_god" name="ttt">
				select count(*) from taxonomy where #fl#=#sl#			
			</cfquery>
			<cfdump var=#ttt#>
		</cfloop>
	</cfloop>	
</cfoutput>