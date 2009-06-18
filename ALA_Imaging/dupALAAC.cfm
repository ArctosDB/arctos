<cfinclude template="/includes/_header.cfm">
	<cfoutput>
		<cffunction name="getRec">
			<cfargument name="dv" type="string" required="yes">
			<cfargument name="minmax" type="string" required="yes">
			<cfquery name="rec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select
					cat_num,
					scientific_name,
					display_value,
					concatEncumbrances(cataloged_item.collection_object_id) encumbrances,
					ConcatOtherId(cataloged_item.collection_object_id) otherids,
					concatRelations(cataloged_item.collection_object_id) relations
				from
					cataloged_item,
					identification,
					coll_obj_other_id_num
				where
					cataloged_item.collection_object_id=identification.collection_object_id and
					identification.accepted_id_fg=1 and
					cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id and
					cataloged_item.collection_object_id=
					(
						select #minmax#(collection_object_id) from coll_obj_other_id_num where
						other_id_type='ALAAC' and
						display_value='#dv#'
					)
			</cfquery>
			<cfreturn rec>
		</cffunction>
		<cfset limit=20>
		<cfquery name="dupRec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from (	
				select 
					count(*) cnt,
					display_value 
				from 
					coll_obj_other_id_num
				where
					other_id_type='ALAAC'
				having
					count(*) > 1
				group by
					display_value
			) where rownum < #limit#
		</cfquery>
		Showing first #limit# rows:
		<table border>
		<cfloop query="dupRec">
			<tr>
				<td>
					#display_value#
				</td>
				<td>
					<cfset recOne=getRec('#display_value#','min')>
					<cfloop query="recOne">
						<table border>
							<tr>
								<td>cat_num: #cat_num#</td>
							</tr>
							<tr>
								<td>scientific_name: #scientific_name#</td>
							</tr>
							<tr>
								<td>encumbrances: #encumbrances#</td>
							</tr>
							<tr>
								<td>otherids: #otherids#</td>
							</tr>
							<tr>
								<td>relations: #relations#</td>
							</tr>
						</table>
					</cfloop>
				</td>
				<td>
					<cfset recTwo=getRec('#display_value#','max')>
					<cfloop query="recTwo">
						<table border>
							<tr>
								<td>cat_num: #cat_num#</td>
							</tr>
							<tr>
								<td>scientific_name: #scientific_name#</td>
							</tr>
							<tr>
								<td>encumbrances: #encumbrances#</td>
							</tr>
							<tr>
								<td>otherids: #otherids#</td>
							</tr>
							<tr>
								<td>relations: #relations#</td>
							</tr>
						</table>
					</cfloop>
				</td>
			</tr>
		</cfloop>
		</table>

	</cfoutput>

<cfinclude template="/includes/_footer.cfm">
