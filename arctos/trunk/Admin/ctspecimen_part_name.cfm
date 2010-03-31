<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			part_name,
			description,
			is_tissue,
			collection_cde
		from ctspecimen_part_name
		ORDER BY
			collection_cde,part_name
	</cfquery>
	<cfquery name="ctcollcde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select distinct collection_cde from ctcollection_cde order by collection_cde
	</cfquery>
	<cfoutput>
		Add record:
		<table class="newRec" border="1">
			<tr>
				<th>Collection Type</th>
				<th>Part Name</th>
				<td>IsTissue</td>
				<th>Description</th>
			</tr>
			<form name="newData" method="post" action="">
				<input type="hidden" name="action" value="insert">
				<tr>
					<td>
						<select name="collection_cde" size="1">
							<cfloop query="ctcollcde">
								<option value="#ctcollcde.collection_cde#">#ctcollcde.collection_cde#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<input type="text" name="part_name">
					</td>
					<td>
						<select name="is_tissue">
							<option value="0">no</option>
							<option value="1">yes</option>
						</select>
					</td>
					<td>
						<textarea name="description" id="description" rows="4" cols="40"></textarea>
					</td>
					<td>
						<input type="submit" value="Insert" class="insBtn">	
					</td>
				</tr>
			</form>
		</table>
		<cfset i = 1>
		Edit
		<table border="1">
			<tr>
				<th>Collection Type</th>
				<th>part_name</th>
				<th>IsTissue</th>
				<th>Description</th>
			</tr>
			<cfloop query="q">
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<td>#collection_cde#</td>
					<td>#q.part_name#</td>
					<td>#is_tissue#</td>
					<td>#q.description#</td>				
					<td>
							buttons!	
					</td>
				</tr>
				<cfset i = #i#+1>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfif action is "insert">
	<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		insert into ctspecimen_part_name (
			part_name,
			DESCRIPTION,
			is_tissue
		) values (
			'#part_name#',
			'#description#',
			#is_tissue#
		)
	</cfquery>
	<cflocation url="ctspecimen_part_name.cfm" addtoken="false">
</cfif>	
		





<!----------

	<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from ctspecimen_name_name
			where
				OTHER_ID_TYPE='#origData#' and
				collection_cde='#collection_cde#'
		</cfquery>


<cfelseif tbl is "ctspecimen_name_name">
		<cfquery name="sav" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update ctspecimen_name_name set 
				part_name='#part_name#',
				DESCRIPTION='#description#',
				is_tissue=#is_tissue#
			where
				part_name='#origData#' and
				collection_cde='#origcollection_cde#'
		</cfquery>
	
	<cfelseif tbl is "ctspecimen_name_name">
		
	



<cfset i = 1>
		Edit #tbl#:
		<table border="1">
			<tr>
					<th>Collection Type</th>
				<th>part_name</th>
				<th>IsTissue</th>
					<th>Description</th>
			</tr>
			<cfloop query="q">
				<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<form name="#tbl##i#" method="post" action="CodeTableEditor.cfm">
						<input type="hidden" name="Action">
						<input type="hidden" name="tbl" value="#tbl#">
						<input type="hidden" name="origData" value="#q.part_name#">
							<input type="hidden" name="origcollection_cde" value="#q.collection_cde#">
							<cfset thisColl=#q.collection_cde#>
							<td>
								<select name="collection_cde" size="1">
									<cfloop query="ctcollcde">
										<option 
											<cfif #thisColl# is "#ctcollcde.collection_cde#"> selected </cfif>value="#ctcollcde.collection_cde#">#ctcollcde.collection_cde#</option>
									</cfloop>
								</select>
							</td>
						<td>
							<input type="text" name="part_name" value="#q.part_name#" size="50">
						</td>
					<td>
						<select name="is_tissue">
							<option value="0">no</option>
							<option value="1">yes</option>
						</select>
					</td>
							<td>
								<textarea name="description" rows="4" cols="40">#q.description#</textarea>
							</td>				
						<td>
							<input type="button" 
								value="Save" 
								class="savBtn"
								onclick="#tbl##i#.Action.value='saveEdit';submit();">	
							<input type="button" 
								value="Delete" 
								class="delBtn"
								onclick="#tbl##i#.Action.value='deleteValue';submit();">	
		
						</td>
					</form>
				</tr>
				<cfset i = #i#+1>
			</cfloop>
		</table>
------------>







