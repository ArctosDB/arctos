<cfif #action# is "nothing">
	<form name="n" method="post" action="nkify.cfm">
		<input type="hidden" name="action" value="s">
		<br>Min IF<input name="minIf">
		Max IF<input type="text" name="maxIF">
		<br>Min NK: <input type="text" name="minNK">
		Max NK: <input type="text" name="maxNK">
		<input type="submit">
	</form>
</cfif>




<cfif #action# is "s">
<cfset p_minIf = #minIf#>
<cfset p_maxIF = #maxIF#>
<cfset p_minNK = #minNK#>
<cfset p_maxNK = #maxNK#>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
		collection_object_id, other_id_num_1,other_id_num_type_1, other_id_num_5,other_id_num_type_5
		from bulkloader 
		where collection_cde='Mamm' and 
		institution_acronym='MSB' and 
		OTHER_ID_NUM_TYPE_1= 'IF' AND
		other_id_num_5 is null
		order by to_number(other_id_num_1)
	</cfquery>
	<cfoutput>
		<table border>
			<tr>
				<th>CollectionObjectId</th>
				<th>IF</th>
				<th>NK</th>
			</tr>
		
		<cfset r = 0>
		<cfloop query="d">
			<cfif (#p_minIf# lte #p_maxIF#) AND (#p_minNK# lte #p_maxNK#) AND (#p_minIf# eq #other_id_num_1#)>
				<tr>
					<td>#collection_object_id#</td>
					<td>#p_minIf#</td>
					<td>#p_minNK#</td>
				</tr>
				<cfset p_minNK = #p_minNK# + 1>
				<cfset p_minIf = #p_minIf# + 1>
				<cfset r = #r# + 1>
			</cfif>
			
		</cfloop>
		</table>
		There are #r# matches.
		<a href="nkify.cfm?action=doIt&minIf=#minIf#&maxIF=#maxIF#&minNK=#minNK#&maxNK=#maxNK#">Yea, yea, just do it....</a>
	</cfoutput>
</cfif>



<cfif #action# is "doIt">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
		collection_object_id, other_id_num_1,other_id_num_type_1, other_id_num_5,other_id_num_type_5
		from bulkloader 
		where collection_cde='Mamm' and 
		institution_acronym='MSB' and 
		OTHER_ID_NUM_TYPE_1= 'IF' AND
		other_id_num_5 is null
		order by to_number(other_id_num_1)
	</cfquery>
	<cfoutput>	
		<cftransaction >
			<cfloop query="d">
				<cfif (#minIf# lte #maxIF#) AND (#minNK# lte #maxNK#) AND (#minif# eq #other_id_num_1#)>
					<cfquery name="upBl" datasource="#Application.uam_dbo#">
						update bulkloader set other_id_num_5 = '#minNK#',other_id_num_type_5 = 'NK Number'
						WHERE collection_object_id = #collection_object_id#
					</cfquery>
					<cfset minNK = #minNK# + 1>
					<cfset minIf = #minIf# + 1>
				</cfif>
			</cfloop>
		</cftransaction>	
	All Done
	</cfoutput>
</cfif>
