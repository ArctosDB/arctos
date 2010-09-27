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
					username,
					numberAgents
				) values (
					'#session.username#',
					5
				)
			</cfquery>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from cf_dataentry_settings where username='#session.username#'
			</cfquery>
		</cfif>
		<form name="customize" method="post" action="customizeDataEntry.cfm">
			<input type="hidden" name="action" value="saveChanges">
			<cfif action is "agent">
				<label for="numberAgents">Show ## Agents</label>
				<select name="numberAgents" id="numberAgents">
					<option value="1" <cfif d.numberAgents is 1> selected="selected" </cfif>>1</option>
					<option value="2" <cfif d.numberAgents is 2> selected="selected" </cfif>>2</option>
					<option value="3" <cfif d.numberAgents is 3> selected="selected" </cfif>>3</option>
					<option value="4" <cfif d.numberAgents is 4> selected="selected" </cfif>>4</option>
					<option value="5" <cfif d.numberAgents is 5> selected="selected" </cfif>>5</option>
				</select>
			
		
		
			</cfif>
		</form>
	</cfif>
</cfoutput>