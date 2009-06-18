<cfinclude template="/includes/_header.cfm">
	<cffunction name="getRec">
		<cfargument name="colobjid" type="numeric" required="yes">
		<cfquery name="rec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select
				cat_num,
				scientific_name,
				display_value
			from
				cataloged_item,
				identification,
				coll_obj_other_id_num
			where
				cataloged_item.collection_object_id=identification.collection_object_id and
				cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id and
				cataloged_item.collection_object_id=#colobjid#
		</cfquery>
		<cfreturn rec>
	</cffunction>
	<cfset limit=20>
	<cfoutput>
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
					<cfquery name="one" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select min(collection_object_id) collection_object_id from coll_obj_other_id_num where other_id_type='ALAAC' and
						display_value='#display_value#'
					</cfquery>
					<cfset recOne=getRec(one.collection_object_id)>
					<cfloop query="recOne">
						cat_num: #cat_num#
						<br>scientific_name: #scientific_name#
					</cfloop>
				</td>
				<td>
					<cfquery name="two" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select max(collection_object_id) collection_object_id from coll_obj_other_id_num where 
						other_id_type='ALAAC' and
						display_value='#display_value#'
					</cfquery>
					<cfset recTwo=getRec(two.collection_object_id)>
					<cfloop query="recTwo">
						cat_num: #cat_num#
						<br>scientific_name: #scientific_name#
					</cfloop>
				</td>
			</tr>
		</cfloop>
		</table>

	</cfoutput>

<cfinclude template="/includes/_footer.cfm">
