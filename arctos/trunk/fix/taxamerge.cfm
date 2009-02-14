<cfinclude template="/includes/_header.cfm">
<cfquery name="d" datasource="uam_god">
	select * from taxamerge
</cfquery>
<cfoutput>
	<table border>
	<tr>
	<cfloop list="#d.columnList#" index="c">
		<cfif left(c,1) is not "m" and c is not "full_taxon_name">
			<td>#c#</td>
		</cfif>
	</cfloop>
	</tr>
	<cfloop query="d">
		<tr>
			<cfloop list="#d.columnList#" index="c">
				<cfif left(c,1) is not "m" and c is not "full_taxon_name">
					<cfset uV=evaluate(c)>
					<cfset mV=evaluate("m" & c)>
					<td
						<cfif uV is not mV>
							class="diff"
						</cfif>
					>
						<u>#replace(uV," ","&nbsp;","all")#</u>&nbsp;:&nbsp;#replace(mV," ","&nbsp;","all")#						
					</td>
				</cfif>
			</cfloop>
		</tr>
	</cfloop>
</table>
</cfoutput>


<!---
<cfif not isdefined("rc")>
	<cfset rc=1000>
</cfif>
<cfif not isdefined("scientific_name")>
	<cfset scientific_name=''>
</cfif>
<cfquery name="d" datasource="uam_god">
	select * from tdiff
	where rownum <= #rc#
	and full_taxon_name != mfull_taxon_name
	<cfif len(scientific_name) gt 0>
		and lower(scientific_name) like '%scientific_name(s)%' 
	</cfif>
	order by 
	PHYLCLASS,
PHYLORDER,
SUBORDER,
FAMILY,
SUBFAMILY,
SCIENTIFIC_NAME,
GENUS,
SPECIES,
SUBSPECIES
</cfquery>

<cfoutput>
	
<style>
	.diff {border:2px solid red}
	.u{
		font-style:italic;
		border-bottom:1px solid black;
	}
	.m{}
</style>

uam.scientific_name = mvz.scientific_name and uam.full_taxon_name != mvz.full_taxon_name
<br>
UAM data are <u>underlined</u>
<br>
Cell data is <u>UAM_Value</u> : MVZ_Value, but note that one or both may be null
<br>
Mismatched data have <span class="diff">red bordered cells</span>
<br>
MVZ taxon_name_id is original ID + 4,000,000

<br>
Filter:
<form action="taxamerge.cfm">
	<label for="scientific_name">Scientific Name</label>
	<input type="text" name="scientific_name"  value="#scientific_name#">
	<label for="rc">Display ## records</label>
	<input type="text" name="rc" value="#rc#">
	<input type="submit">
</form>
<br>
Showing #rc# of #d.recordcount# rows
<table border>
	<tr>
	<cfloop list="#d.columnList#" index="c">
		<cfif left(c,1) is not "m" and c is not "full_taxon_name">
			<td>#c#</td>
		</cfif>
	</cfloop>
	</tr>
	<cfloop query="d">
		<tr>
			<cfloop list="#d.columnList#" index="c">
				<cfif left(c,1) is not "m" and c is not "full_taxon_name">
					<cfset uV=evaluate(c)>
					<cfset mV=evaluate("m" & c)>
					<td
						<cfif uV is not mV>
							class="diff"
						</cfif>
					>
						<u>#replace(uV," ","&nbsp;","all")#</u>&nbsp;:&nbsp;#replace(mV," ","&nbsp;","all")#						
					</td>
				</cfif>
			</cfloop>
		</tr>
	</cfloop>
</table>
</cfoutput>
--->