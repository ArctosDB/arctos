<cfinclude template="/includes/_frameHeader.cfm">
<span class="likeLink" onclick="parent.doneSaving()">[ Remove this window ]</span>
<br>
<cfif action is "nothing">
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from ctspecimen_part_name where ctspnid=#ctspnid#
</cfquery>
<cfquery name="ctcollcde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct collection_cde from ctcollection_cde order by collection_cde
</cfquery>
<cfoutput>
	<form name="f" method="post" action="">
		<input type="hidden" name="action" value="update">
		<input type="hidden" name="ctspnid" value="#ctspnid#">
		<label for="collection_cde">Collection Code</label>
		<select name="collection_cde" id="collection_cde" size="1">
			<cfloop query="ctcollcde">
				<option 
					<cfif d.collection_cde is ctcollcde.collection_cde> selected="selected" </cfif>
					value="#ctcollcde.collection_cde#">#ctcollcde.collection_cde#</option>
			</cfloop>
		</select>
		<label for="part_name">Part Name</label>
		<input type="text" name="part_name" id="part_name" value="#d.part_name#" size="50">
		<label for="is_tissue">Tissue?</label>
		<select name="is_tissue">
			<option <cfif d.is_tissue is 0>selected="selected" </cfif>value="0">no</option>
			<option <cfif d.is_tissue is 1>selected="selected" </cfif>value="1">yes</option>
		</select>
		<label for="upAllTiss">
			Update is_tissue for all parts, regardless of collection, to this value?<br>
			Note: This does not change existing data, only the defaul for new entries
			where is_tissue is not specified.
		</label>
		<select name="upAllTiss">
			<option selected="selected" value="0">Just this one please</option>
			<option value="1">Yes, update all default is_tissue flags</option>
		</select>
		<br>
		<label for="description">Description</label>
		<textarea name="description" id="description" rows="4" cols="40">#d.description#</textarea>
		<label for="upAllDesc">Update description for all parts, regardless of collection, to this value?</label>
		<select name="upAllDesc">
			<option selected="selected" value="0">Just this one please</option>
			<option value="1">Yes, update all part descriptions</option>
		</select>
		<br>
		<input type="submit" value="Save" class="savBtn">	
		<input type="button" value="Quit" class="qutBtn" onclick="parent.doneSaving();">	
	</form>
</cfoutput>
</cfif>

<cfif action is "update">
<cfoutput>
	<cftry>
	<cftransaction>
		<cfquery name="usp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update ctspecimen_part_name set
				collection_cde='#collection_cde#',
				part_name='#part_name#',
				is_tissue=#is_tissue#,
				description='#description#'
			where ctspnid=#ctspnid#
		</cfquery>
		<cfif upAllDesc is 1>
			<cfquery name="upalld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update ctspecimen_part_name set
				description='#description#'
				where
				part_name='#part_name#'			
			</cfquery>
		</cfif>
		<cfif upAllTiss is 1>
			<cfquery name="upallt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update ctspecimen_part_name set
				is_tissue=#is_tissue#
				where
				part_name='#part_name#'			
			</cfquery>
		</cfif>
		<script>
			console.log('escape(#description#)');
			
			//parent.successUpdate('#ctspnid#','#collection_cde#','#part_name#','#is_tissue#','escape(#description#)','#upAllDesc#','#upAllTiss#');
		</script>
	</cftransaction>
	<cfcatch><cfdump var=#cfcatch#></cfcatch>
	</cftry>			
</cfoutput>
</cfif>
