<!----

create table cf_dataentry_settings (
	username varchar2(60) not null,
	numberAgents number
);

create or replace public synonym cf_dataentry_settings for cf_dataentry_settings;
grant all on cf_dataentry_settings to data_entry;

---->
<cfoutput>
	<cfif action is not "">
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from cf_dataentry_settings where username='#session.username#'
		</cfquery>
		<cfif d.recordcount is not 1>
			<cfquery name="seed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into cf_dataentry_settings (
					username
				) values (
					'#session.username#'
				)
			</cfquery>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from cf_dataentry_settings where username='#session.username#'
			</cfquery>
		</cfif>
		<cfquery name="getCols" datasource="uam_god">
			select column_name from sys.user_tab_cols
			where lower(table_name)='cf_dataentry_settings'
			order by internal_column_id
		</cfquery>
		<form name="customize" method="post" action="customizeDataEntry.cfm">
			<input type="hidden" name="action" value="saveChanges">
			<input type="hidden" name="oldaction" value="#action#">
			<table border>
				<cfloop query="getCols">
					<tr>
						<td>#column_name#</td>
						<td>
							<select name="#column_name#" id="#column_name#">
								<option value="0"
									<cfif "d.#column_name#" is 0> selected="selected" </cfif>>hide</option>
								<option value="1"
									<cfif "d.#column_name#" is 1> selected="selected" </cfif>>show</option>
								<option value="2"
									<cfif "d.#column_name#" is 2> selected="selected" </cfif>>carry</option>
							</select>
						</td>
					</tr>
				</cfloop>
			</table>
			<br><input type="submit">
		</form>
	</cfif>
	<cfif action is "saveChanges">
		<!---<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update cf_dataentry_settings set
				numberAgents=#numberAgents#
			where username='#session.username#'
		</cfquery>
		<cflocation url="customizeDataEntry.cfm?action=#oldaction#" addtoken="false">
		--->
		<cfdump var=#form#>
	</cfif>
</cfoutput>