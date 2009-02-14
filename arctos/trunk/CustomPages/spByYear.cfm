<cfinclude template="/includes/_header.cfm">
Search for species by year. Matches began_date; may not find some specimens where verbatim_date is more 
	descriptive.
<table>
<form name="name" method="post" action="spByYear.cfm">
	<input type="hidden" name="action" value="findIt">
	<tr>
		<td align="right">
			Scientific Name
		</td>
		<td><input type="text" name="scientific_name"></td>
	</tr>
	<tr>
		<td align="right">
			With Skull?
		</td>
		<td><input type="checkbox" name="skull" value="1"></td>
	</tr>
	<tr>
		<td colspan="2">
			<input type="submit" 
				value="Find Data" 
				class="lnkBtn"
   				onmouseover="this.className='lnkBtn btnhov'" 
				onmouseout="this.className='lnkBtn'">	
		</td>
	</tr>
</form>
</table>
<!--------------------------------------------------------------->
<cfif #action# is "findIt">
	<cfif not isdefined("skull")>
		<cfset skull="0">
	</cfif>
	
	<cfquery name="spyr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			count(cat_num) cnt,
			to_char(began_date,'yyyy') yy
		FROM
			cataloged_item,
			collecting_event,
			identification
		WHERE
			cataloged_item.collecting_event_id=collecting_event.collecting_event_id AND
			cataloged_item.collection_object_id=identification.collection_object_id AND
			accepted_id_fg=1 AND
			upper(scientific_name) LIKE '%#UCASE(scientific_name)#%'
			<cfif #skull# is 1>
				AND cataloged_item.collection_object_id IN
					( select 
						derived_from_cat_item 
					FROM specimen_part where upper(part_name) LIKE '%SKULL%')
			</cfif>
		GROUP BY
			to_char(began_date,'yyyy')
		ORDER BY
			to_char(began_date,'yyyy')
	</cfquery>
	<cfoutput>
	Results for #scientific_name#
	<cfif #skull# is 1>
				with skulls
			</cfif>:
	<table border>
		<tr>
			<td>Year</td>
			<td>Count</td>
		</tr>
		<cfloop query="spyr">
			<tr>
				<td>#yy#</td>
				<td>#cnt#</td>
			</tr>
		</cfloop>
	</table>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">