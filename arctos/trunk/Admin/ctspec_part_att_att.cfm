<cfinclude template="/includes/_header.cfm">
<cfset title="part attribute controls">
<cfif action is "nothing">
	<cfoutput>
		<cfquery name="ctAttribute_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
			select distinct(attribute_type) from ctspecpart_attribute_type
		</cfquery>
		<cfquery name="thisRec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
			Select * from ctspec_part_att_att
			order by attribute_type
		</cfquery>
		<cfquery name="allCTs" datasource="uam_god">
			select distinct(table_name) as tablename from sys.user_tables where table_name like 'CT%' order by table_name
		</cfquery>
		<br>Create Attribute Control
		<table class="newRec" border>
			<tr>
				<th>Attribute</th>
				<th>Value Code Table</th>
				<th>unit Code Table</th>
				<th>&nbsp;</th>
			</tr>
			<form method="post" action="ctspec_part_att_att.cfm">
				<input type="hidden" name="action" value="newValue">
				<tr>
					<td>				
						<select name="attribute_type" size="1">
							<option value=""></option>
							<cfloop query="ctAttribute_type">
							<option 
								value="#ctAttribute_type.attribute_type#">#ctAttribute_type.attribute_type#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<cfset thisValueTable = #thisRec.value_code_table#>
						<select name="value_code_table" size="1">
							<option value="">none</option>
							<cfloop query="allCTs">
							<option 
							value="#allCTs.tablename#">#allCTs.tablename#</option>
							</cfloop>
						</select>			
					</td>
					<td>
						<cfset thisunitTable = #thisRec.unit_code_table#>
						<select name="unit_code_table" size="1">
							<option value="">none</option>
							<cfloop query="allCTs">
							<option 
							value="#allCTs.tablename#">#allCTs.tablename#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<input type="submit" value="Create" class="insBtn">	
					</td>
				</tr>
			</form>
		</table>
			<br>Edit Attribute Controls
			<table border>
				<tr>
					<th>Attribute</th>
					<th>Value Code Table</th>
					<th>unit Code Table</th>
					<th>&nbsp;</th>
				</tr>
				<cfset i=1>
				<cfloop query="thisRec">
					<form name="att#i#" method="post" action="ctspec_part_att_att.cfm">
						<input type="hidden" name="action" value="update">
						<input type="hidden" name="oldAttribute_type" value="#Attribute_type#">
						<input type="hidden" name="oldvalue_code_table" value="#value_code_table#">
						<input type="hidden" name="oldunit_code_table" value="#unit_code_table#">
						<tr>
							<td>
								<input type="hidden" name="attribute_type" value="#thisRec.attribute_type#">
								#attribute_type#
							</td>
							<td>
								<cfset thisValueTable = #thisRec.value_code_table#>
								<select name="value_code_table" size="1">
									<option value="">none</option>
									<cfloop query="allCTs">
									<option 
									<cfif #thisValueTable# is "#allCTs.tablename#"> selected </cfif>value="#allCTs.tablename#">#allCTs.tablename#</option>
									</cfloop>
								</select>
							</td>
							<td>
								<cfset thisunitTable = #thisRec.unit_code_table#>
								<select name="unit_code_table" size="1">
									<option value="">none</option>
									<cfloop query="allCTs">
									<option 
									<cfif #thisunitTable# is "#allCTs.tablename#"> selected </cfif>value="#allCTs.tablename#">#allCTs.tablename#</option>
									</cfloop>
								</select>
							</td>
							<td>
								<input type="button" 
									value="Save" 
									class="savBtn"
								 	onclick="att#i#.action.value='saveEdit';submit();">	
								<input type="button" 
									value="Delete" 
									class="delBtn"
								  	onclick="att#i#.action.value='deleteValue';submit();">	
							</td>
						</tr>
					</form>
				<cfset i=#i#+1>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfif action is "saveEdit">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
		update ctspec_part_att_att
		set VALUE_code_table='#value_code_table#',
		unit_code_table='#unit_code_table#'
		 where attribute_type='#attribute_type#'
	</cfquery>
	<cflocation addtoken="false" url="ctspec_part_att_att.cfm">
</cfif>
<cfif action is "deleteValue">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
		delete from ctspec_part_att_att where
    		attribute_type='#attribute_type#'
	</cfquery>
	<cflocation addtoken="false" url="ctspec_part_att_att.cfm">
</cfif>
<cfif action is "newValue">
	<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
		insert into ctspec_part_att_att (
    		attribute_type,
			VALUE_code_table,
			unit_code_table
		) values (
			'#attribute_type#',
			'#value_code_table#',
			'#unit_code_table#'
		)
	</cfquery>
	<cflocation addtoken="false" url="ctspec_part_att_att.cfm">
</cfif>
<cfinclude template="/includes/_footer.cfm">