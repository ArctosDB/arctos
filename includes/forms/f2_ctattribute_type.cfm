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

			<br>#ctccde#
			<cfset c=1>
			<cfloop query="d">
				<br>before: #ctccde#
				<br>#collection_cde#
				<cfset ctccde=listdeleteat(ctccde,listfind(ctccde,'#collection_cde#'))>
				<br>after: #ctccde#
				<label for="collection_cde_#c#">Available for Collection Type</label>

				<select name="collection_cde_#c#" id="collection_cde_#c#" size="1">
					<option value="DELETE__#d.collection_cde#">Remove from this collection type</option>
					<option selected="selected" value="#d.collection_cde#">#d.collection_cde#</option>
				</select>
				<cfset c=c+1>
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
<cfif action is "update">

	<cfoutput>
		<cftransaction>
			<cfloop list="#FIELDNAMES#" index="f">
				<cfif left(f,15) is "COLLECTION_CDE_" and f is not "COLLECTION_CDE_NEW">
					<cfset thisCCVal=evaluate(f)>
					<cfif left(thisCCVal,8) is 'DELETE__'>
						<cfset thisCCVal=mid(thisCCVal,9,500)>
						<cfquery name="del" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							delete from ctattribute_type where attribute_type='#ATTRIBUTE_TYPE#' and collection_cde='#thisCCVal#'
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
			<!----
				second, update everything that's left
				If we've deleted everything this will just do nothing
			---->
			<cfquery name="upf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update ctattribute_type set DESCRIPTION='#escapeQuotes(DESCRIPTION)#' where attribute_type='#attribute_type#'
			</cfquery>
			<!--- last, insert new if there's one provided ---->
			<cfif len(COLLECTION_CDE_NEW) gt 0>
				<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into ctattribute_type (attribute_type,COLLECTION_CDE,DESCRIPTION
						) values (
					'#attribute_type#','#COLLECTION_CDE_NEW#','#escapeQuotes(DESCRIPTION)#')
				</cfquery>
			</cfif>
		</cftransaction>
		<cflocation url="f2_ctattribute_type.cfm?attribute_type=#URLEncodedFormat(attribute_type)#" addtoken="false">
	</cfoutput>
</cfif>