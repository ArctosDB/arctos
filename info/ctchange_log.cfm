<cfinclude template="/includes/_header.cfm">
	<cfoutput>
		<cfset title="authority file changes">
		<cfif not isdefined("tbl") or len(tbl) lt 1>
			bad call<cfabort>
		</cfif>
		<cfif tbl contains " " or tbl contains ";" or tbl contains "'">
			bad call<cfabort>
		</cfif>
		<cfset ltn="LOG_#ucase(tbl)#">
		<cfquery name="ctab" datasource="uam_god">
			select * from #ltn# order by change_date
		</cfquery>
		<cfif ctab.recordcount lt 1>
			notfound<cfabort>
		</cfif>
		<p>Table #replace(ltn,'LOG_','','all')#:</p>
		<table border>
			<tr>
			<cfloop list="#ctab.columnlist#" index="c">
				<th>#c#</th>
			</cfloop>
			</tr>
			<cfloop query="#ctab#">
				<tr>
					<cfloop list="#ctab.columnlist#" index="c">
						<td>#evaluate("ctab." & c)#</td>
					</cfloop>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">