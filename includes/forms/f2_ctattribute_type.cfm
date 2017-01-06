<cfinclude template="/includes/_frameHeader.cfm">
<cfif action is "nothing">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ctattribute_type where attribute_type='#attribute_type#'
	</cfquery>
	<cfquery name="ctcollcde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select distinct collection_cde from ctcollection_cde order by collection_cde
	</cfquery>
	<cfquery name="p" dbtype="query">
		select distinct attribute_type from d
	</cfquery>
	<cfquery name="dec" dbtype="query">
		select distinct description from d
	</cfquery>
	<cfoutput>
		<form name="f" method="post" action="">
			<input type="hidden" name="action" value="update">
			<p>
				Editing <strong>#attribute_type#</strong>
			</p>
			<input type="hidden" name="attribute_type" id="attribute_type" value="#p.attribute_type#" size="50">
			<cfset ctccde=valuelist(ctcollcde.collection_cde)>
			<cfloop query="d">
				<cfset ctccde=listdeleteat(ctccde,listfind(ctccde,'#collection_cde#'))>
				<label for="collection_cde_#CTSPNID#">Available for Collection Type</label>

				<!----
				<select name="collection_cde_#CTSPNID#" id="collection_cde_#CTSPNID#" size="1">
					<option value="">Remove from this collection type</option>
					<option selected="selected" value="#d.collection_cde#">#d.collection_cde#</option>
				</select>
				---->
			</cfloop>
			<label for="collection_cde_new">Make available for Collection Type</label>
			<select name="collection_cde_new" id="collection_cde_new" size="1">
				<option value=""></option>
				<cfloop list="#ctccde#" index="ccde">
					<option	value="#ccde#">#ccde#</option>
				</cfloop>
			</select>
			<label for="description">Description</label>
			<textarea name="description" id="description" rows="4" cols="40">#dec.description#</textarea>
			<br>
			<input type="submit" value="Save Changes" class="savBtn">
			<p>
				Removing an attribute from all collection types will delete the record.
			</p>
		</form>
	</cfoutput>
</cfif>
<!----------
<cfif action is "update">
	<cfoutput>
		<cftransaction>
			<!--- first, delete anything that needs deleted ---->
			<cfloop list="#FIELDNAMES#" index="f">
				<cfif left(f,15) is "COLLECTION_CDE_" and f is not "COLLECTION_CDE_NEW">
					<!--- if the value is NULL, we're deleting that record ---->
					<cfset thisCCVal=evaluate(f)>
					<cfif len(thisCCVal) is 0>
						<cfset thisPartID=listlast(f,"_")>
						<cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							delete from ctspecimen_part_name where CTSPNID=#thisPartID#
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
			<!----
				second, update everything that's left
				If we've deleted everything this will just do nothing
			---->
			<cfquery name="upf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update ctspecimen_part_name set DESCRIPTION='#escapeQuotes(DESCRIPTION)#',IS_TISSUE='#IS_TISSUE#' where part_name='#part_name#'
			</cfquery>
			<!--- last, insert new if there's one provided ---->
			<cfif len(COLLECTION_CDE_NEW) gt 0>
				<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into ctspecimen_part_name (PART_NAME,COLLECTION_CDE,DESCRIPTION,IS_TISSUE) values (
					'#part_name#','#COLLECTION_CDE_NEW#','#escapeQuotes(DESCRIPTION)#','#IS_TISSUE#')
				</cfquery>
			</cfif>
		</cftransaction>
		<cflocation url="f2_ctspecimen_part_name.cfm?part_name=#URLEncodedFormat(part_name)#" addtoken="false">

	</cfoutput>
</cfif>
----------->