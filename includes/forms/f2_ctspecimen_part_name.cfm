<cfinclude template="/includes/_frameHeader.cfm">


<cfdump var=#part_name#>
	<cfif action is "nothing">

<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from ctspecimen_part_name where part_name='#part_name#'
</cfquery>
<cfquery name="ctcollcde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select distinct collection_cde from ctcollection_cde order by collection_cde
</cfquery>
<cfquery name="p" dbtype="query">
	select distinct part_name from d
</cfquery>



<cfquery name="t" dbtype="query">
	select distinct is_tissue from d
</cfquery>
<cfquery name="dec" dbtype="query">
	select distinct description from d
</cfquery>

<cfoutput>
	<form name="f" method="post" action="">
		<input type="hidden" name="action" value="update">
		<p>
			The name of used parts cannot be changed; contact a DBA. Type "delete" into part name and save
			to delete this part.
		</p>
		<label for="ppart_name">Part Name</label>
		<input type="text" name="ppart_name" id="ppart_name" value="#p.part_name#" size="50">
		<cfset ctccde=valuelist(ctcollcde.collection_cde)>
		<cfloop query="d">
			<cfset ctccde=listdeleteat(ctccde,listfind(ctccde,'#collection_cde#'))>
			<label for="collection_cde_#CTSPNID#">Available for Collection Type</label>
			<select name="collection_cde_#CTSPNID#" id="collection_cde_#CTSPNID#" size="1">
				<option value="">Remove from this collection type</option>
				<option selected="selected" value="#d.collection_cde#">#d.collection_cde#</option>
			</select>
		</cfloop>
		<label for="collection_cde_new">Make available for Collection Type</label>
		<select name="collection_cde_new" id="collection_cde_new" size="1">
			<option value=""></option>
			<cfloop list="#ctccde#" index="ccde">
				<option	value="#ccde#">#ccde#</option>
			</cfloop>
		</select>

		<label for="is_tissue">Tissue?</label>
		<select name="is_tissue">
			<option <cfif t.is_tissue is 0>selected="selected" </cfif>value="0">no</option>
			<option <cfif t.is_tissue is 1>selected="selected" </cfif>value="1">yes</option>
		</select>
		<label for="description">Description</label>
		<textarea name="description" id="description" rows="4" cols="40">#dec.description#</textarea>
		<input type="submit" value="Save Changes" class="savBtn">
	</form>
</cfoutput>
</cfif>


<cfif action is "update">
<cfoutput>

	<cfdump var=#form#>
	<cfif part_name is "delete">
		delete....
	</cfif>


	<cfabort>




	<cftry>
	<cftransaction>
		<cfquery name="usp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update ctspecimen_part_name set
				collection_cde='#collection_cde#',
				part_name='#part_name#',
				is_tissue=#is_tissue#,
				description='#description#'
			where ctspnid=#ctspnid#
		</cfquery>
		<cfif upAllDesc is 1>
			<cfquery name="upalld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update ctspecimen_part_name set
				description='#description#'
				where
				part_name='#part_name#'
			</cfquery>
		</cfif>
		<cfif upAllTiss is 1>
			<cfquery name="upallt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update ctspecimen_part_name set
				is_tissue=#is_tissue#
				where
				part_name='#part_name#'
			</cfquery>
		</cfif>
		<script>
			var desc=escape('#replace(description,"'","\'","all")#');
			parent.successUpdate('#ctspnid#','#collection_cde#','#part_name#','#is_tissue#',desc,'#upAllDesc#','#upAllTiss#');
		</script>
	</cftransaction>
	<cfcatch><cfdump var=#cfcatch#></cfcatch>
	</cftry>
</cfoutput>
</cfif>
