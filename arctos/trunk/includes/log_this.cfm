<cfoutput>
		<cfquery name="nv" datasource="#Application.uam_dbo#">
			select search_log_seq.nextval nv from dual
		</cfquery> 
		<cfif isdefined("detail_level")>
			<cfset thisDetailLevel = "#detail_level#">
		<cfelse>
			<cfset thisDetailLevel = "">
		</cfif>
		<cfquery name="makeLog" datasource="#Application.uam_dbo#">
			insert into search_log (
				log_id,
				username,
				form_name,
				detail_level,
				select_clause,
				join_clause,
				where_clause
			) values (
				#nv.nv#,
				'#client.username#',
				'#cgi.SCRIPT_NAME#',
				'#thisDetailLevel#',
				'#basSelect#',
				'#basJoin#',
				'#basWhere#'
			)
		</cfquery>
		<cfloop list="#StructKeyList(url)#" index="key">
			<cfif len(#url[key]#) gt 0>
				<cfquery name="makeLogEntry" datasource="#Application.uam_dbo#">
					insert into search_log_terms (
						log_id,
						term_name,
						term_value
					) values (
						#nv.nv#,
						'#key#',
						'#url[key]#'
					)
				</cfquery>
			</cfif>
		</cfloop>
		<cfloop list="#StructKeyList(form)#" index="key">
			<cfif len(#form[key]#) gt 0>
				<cfquery name="makeLogEntry" datasource="#Application.uam_dbo#">
					insert into search_log_terms (
						log_id,
						term_name,
						term_value
					) values (
						#nv.nv#,
						'#key#',
						'#form[key]#'
					)
				</cfquery>
			</cfif>
		</cfloop>
	</cfoutput>