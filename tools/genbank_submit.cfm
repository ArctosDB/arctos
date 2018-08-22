<cfinclude template="/includes/_header.cfm">
<cfset title="Genbank Submission Form">
<cfif action is "nothing">
	<cfoutput>
		<p>
			<a href="genbank_submit.cfm?action=mkbatch">create a batch (first step)</a>
		</p>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from genbank_batch order by batch_name
		</cfquery>
		<cfloop query="d">
			<br><a href="genbank_submit.cfm?action=edbatch&batch_id=#genbank_batch_id#">edit batch #batch_name#</a>

		</cfloop>
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------->
<cfif action is "edbatch">
	<cfoutput>
		<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				CONTACT_AGENT_ID,
				getPreferredAgentName(CONTACT_AGENT_ID) contactname,
				BATCH_NAME,
				FIRST_NAME,
				MIDDLE_INITIAL,
				LAST_NAME,
				EMAIL,
				ORGANIZATION,
				DEPARTMENT,
				PHONE,
				FAX,
				STREET,
				CITY,
				STATE_PROV,
				POSTAL_CODE,
				COUNTRY,
				REF_TITLE,
				BIOSAMPLE,
				BIOPROJECT
			 from genbank_batch where genbank_batch_id=#batch_id#
		</cfquery>



		<form name="eb" method="post" action="genbank_submit.cfm">
			<input type="hidden" name="action" value="edit_batch">
			<input type="hidden" name="batch_id" value="#batch_id#">
			<input type="hidden" name="CONTACT_AGENT_ID" value="#b.CONTACT_AGENT_ID#">


			<label for="batch_name">batch_name (must be unique; local label, usually for publication)</label>
			<input type="text" name="batch_name" id="batch_name" value="#b.batch_name#" size="80" class="reqdClr">

			<h3>Contact Agent details</h3>


			<label for="new_agent">Agent (pick Arctos agent)</label>
			<input type="text" name="new_agent" id="new_agent"
				onchange="pickAgentModal('CONTACT_AGENT_ID',this.id,this.value); return false;"
				onKeyPress="return noenter(event);" value="#b.contactname#" class="reqdClr minput">




			<label for="first_name">first_name</label>
			<input type="text" name="first_name" id="first_name" value="#b.first_name#" size="80" class="reqdClr">

			<label for="last_name">last_name</label>
			<input type="text" name="last_name" id="last_name" value="#b.last_name#"size="80" class="reqdClr">

			<label for="middle_initial">middle_initial</label>
			<input type="text" name="middle_initial" id="middle_initial" value="#b.middle_initial#" size="80" class="reqdClr">

			<label for="email">email</label>
			<input type="text" name="email" id="email" size="80" value="#b.email#" class="reqdClr">

			<label for="organization">organization</label>
			<input type="text" name="organization" id="organization" value="#b.organization#" size="80" class="reqdClr">

			<label for="department">department</label>
			<input type="text" name="department" id="department" value="#b.department#"  size="80" class="reqdClr">

			<label for="phone">phone</label>
			<input type="text" name="phone" id="phone" value="#b.phone#" size="80" class="reqdClr">

			<label for="fax">fax</label>
			<input type="text" name="fax" id="fax" size="80" value="#b.fax#" class="reqdClr">

			<label for="street">street</label>
			<input type="text" name="street" id="street" value="#b.street#" size="80" class="reqdClr">

			<label for="city">city</label>
			<input type="text" name="city" id="city" value="#b.city#"  size="80" class="reqdClr">

			<label for="state_prov">state_prov</label>
			<input type="text" name="state_prov" id="state_prov" value="#b.state_prov#" size="80" class="reqdClr">

			<label for="postal_code">postal_code</label>
			<input type="text" name="postal_code" id="postal_code" value="#b.postal_code#" size="80" class="reqdClr">

			<label for="country">country</label>
			<input type="text" name="country" id="country" value="#b.country#" size="80" class="reqdClr">

			<label for="ref_title">ref_title (publication title or working title)</label>
			<input type="text" name="ref_title" id="ref_title" value="#b.ref_title#" size="80" class="reqdClr">

			<label for="biosample">biosample</label>
			<input type="text" name="biosample" id="biosample" value="#b.biosample#" size="80">

			<label for="bioproject">bioproject</label>
			<input type="text" name="bioproject" id="bioproject" value="#b.bioproject#" size="80" >

			<br><input type="submit" value="save batch edits" class="insBtn">
		</form>




		<hr>
		<h3>People</h3>
		<br>Add Person

		<p>
			NOTE: Order is for sorting; values are relative, absolute values don't matter.
		</p>
		<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				GENBANK_PEOPLE_ID,
				GENBANK_BATCH_ID,
				AGENT_ID,
				getPreferredAgentName(AGENT_ID) aname,
				AGENT_ROLE,
				FIRST_NAME,
				MIDDLE_INITIAL,
				LAST_NAME,
				AGENT_ORDER
			 from genbank_people where genbank_batch_id=#batch_id#
			 order by AGENT_ORDER
		</cfquery>

		<table border>
			<tr>
				<th>Arctos Agent</th>
				<th>agent_role</th>
				<th>first_name</th>
				<th>middle_initial</th>
				<th>last_name</th>
				<th>agent_order</th>
			</tr>

				<form name="f" method="post" action="genbank_submit.cfm">
			<input type="hidden" name="action" value="add_agent">
			<input type="hidden" name="batch_id" value="#batch_id#">
			<input type="hidden" name="new_agent_id" id="new_agent_id" value="">


					<tr>
						<td>
							<input type="text" name="new_agent" id="new_agent" value=""
								onchange="pickAgentModal('new_agent_id',this.id,this.value); return false;"
								onKeyPress="return noenter(event);" placeholder="pick an agent" class="reqdClr minput">
						</td>
						<td>
							<select name="agent_role" id="agent_role" class="reqdClr">
								<option></option>
								<option value="sequence author">sequence author</option>
								<option value="reference author">reference author</option>
							</select>

						</td>
						<td>
							<input type="text" name="first_name" id="first_name" size="80" class="reqdClr">
						</td>
						<td>
							<input type="text" name="middle_initial" id="middle_initial" size="80" >
						</td>
						<td>
							<input type="text" name="last_name" id="last_name" size="80" class="reqdClr">
						</td>
						<td>
							<select name="agent_order" id="agent_order" class="reqdClr">
								<option></option>
								<cfloop from="1" to="30" index="i">

									<option value="#i#">#i#</option>
								</cfloop>
							</select>
						</td>
						<td><input type="submit" value="add person" class="insBtn"</td>
					</tr>
				</form>



			<cfloop query="p">
				<form name="f" method="post" action="genbank_submit.cfm">
					<input type="hidden" name="action" value="edit_agent">
					<input type="hidden" name="batch_id" value="#batch_id#">
					<input type="hidden" name="GENBANK_PEOPLE_ID" value="#GENBANK_PEOPLE_ID#">
					<input type="hidden" name="AGENT_ID" id="AGENT_ID__#GENBANK_PEOPLE_ID#" value="#AGENT_ID#">
					<tr>
						<td>
							<input type="text" name="agent_name" id="agent_name__#GENBANK_PEOPLE_ID#" value="#aname#"
								onchange="pickAgentModal('AGENT_ID__#GENBANK_PEOPLE_ID#',this.id,this.value); return false;"
								onKeyPress="return noenter(event);" placeholder="pick an agent" class="reqdClr minput">
						</td>
						<td>
							<select name="agent_role" id="agent_role" class="reqdClr">
								<option></option>
								<option <cfif agent_role is "sequence author" > selected="selected" </cfif>value="sequence author">sequence author</option>
								<option <cfif agent_role is "reference author" > selected="selected" </cfif>value="reference author">reference author</option>
							</select>
						</td>
						<td>
							<input type="text" name="first_name" id="first_name" value="#first_name#" size="30" class="reqdClr">
						</td>
						<td>
							<input type="text" name="middle_initial"  value="#middle_initial#" id="middle_initial" size="20" >
						</td>
						<td>
							<input type="text" name="last_name"  value="#last_name#" id="last_name" size="30" class="reqdClr">
						</td>
						<td>
							<select name="agent_order" id="agent_order" class="reqdClr">
								<option></option>
								<cfloop from="1" to="30" index="i">
									<option <cfif agent_order is i > selected="selected" </cfif>value="#i#">#i#</option>
								</cfloop>
							</select>
						</td>
						<td><input type="submit" value="save edits" class="insBtn"></td>
					</tr>
				</form>
			</cfloop>
		</table>

		<h3>Sequences</h3>
		<cfquery name="s" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				SEQUENCE_ID,
				GENBANK_BATCH_ID,
				SEQUENCE_IDENTIFIER,
				genbank_sequence.COLLECTION_OBJECT_ID,
				guid,
				SEQUENCE_DATA
			from
				genbank_sequence,
				flat
			where
				genbank_sequence.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID(+) and
				genbank_batch_id=#batch_id#
		</cfquery>

		<form name="f" method="post" action="genbank_submit.cfm">
			<input type="hidden" name="action" value="add_sequence">
			<input type="hidden" name="batch_id" value="#batch_id#">

			<label for="sequence_identifier">sequence_identifier</label>
			<input type="text" name="sequence_identifier" id="sequence_identifier" size="80" class="reqdClr">


			<label for="GUID">GUID (DWC Triplet format)</label>
			<input type="text" name="GUID" id="GUID" size="80" class="reqdClr">


			<label for="sequence_data">sequence_data</label>
			<textarea name="sequence_data" id="sequence_data" class="hugetextarea"></textarea>


			<br><input type="submit" value="add sequence" class="insBtn">
		</form>
		<cfloop query="s">
			<hr>


				<form name="f" method="post" action="genbank_submit.cfm">
			<input type="hidden" name="action" value="edit_sequence">
			<input type="hidden" name="batch_id" value="#batch_id#">
			<input type="hidden" name="SEQUENCE_ID" value="#SEQUENCE_ID#">

			<label for="sequence_identifier">sequence_identifier</label>
			<input type="text" name="sequence_identifier" id="sequence_identifier" value='#sequence_identifier#' size="80" class="reqdClr">


			<label for="GUID">GUID (DWC Triplet format)</label>
			<input type="text" name="GUID" id="GUID" value='#guid#' size="80" class="reqdClr">


			<label for="sequence_data">sequence_data</label>
			<textarea name="sequence_data" id="sequence_data" class="hugetextarea">#sequence_data#</textarea>


			<br><input type="submit" value="save/edit sequence" class="insBtn">
		</form>





		</cfloop>			    CLOB

		<p>
		<br><a href="genbank_submit.cfm?action=prepfiles&batch_id=#batch_id#">prepare files</a>

		</p>

	</cfoutput>
</cfif>











<!--------------------------------------------------------------------------------------------->
<cfif action is "edit_sequence">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update genbank_sequence set
				sequence_identifier='#sequence_identifier#',
				COLLECTION_OBJECT_ID=(select COLLECTION_OBJECT_ID from flat where guid='#guid#'),
				sequence_data='#sequence_data#'
			where SEQUENCE_ID=#SEQUENCE_ID#

		</cfquery>
	</cfoutput>
	<cflocation url="genbank_submit.cfm?action=edbatch&batch_id=#batch_id#" addtoken="false">

</cfif>
<!--------------------------------------------------------------------------------------------->
<cfif action is "edit_agent">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update genbank_people set
				AGENT_ID='#AGENT_ID#',
				agent_role='#agent_role#',
				first_name='#first_name#',
				last_name='#last_name#',
				agent_order='#agent_order#',
				middle_initial='#middle_initial#'
			where GENBANK_PEOPLE_ID=#GENBANK_PEOPLE_ID#

		</cfquery>
	</cfoutput>
	<cflocation url="genbank_submit.cfm?action=edbatch&batch_id=#batch_id#" addtoken="false">

</cfif>
<!--------------------------------------------------------------------------------------------->
<cfif action is "edit_batch">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update genbank_batch set
				CONTACT_AGENT_ID='#CONTACT_AGENT_ID#',
				batch_name='#batch_name#',
				first_name='#first_name#',
				last_name='#last_name#',
				middle_initial='#middle_initial#',
				email='#email#',
				organization='#organization#',
				department='#department#',
				phone='#phone#',
				fax='#fax#',
				street='#street#',
				city='#city#',
				state_prov='#state_prov#',
				postal_code='#postal_code#',
				country='#country#',
				ref_title='#ref_title#',
				biosample='#biosample#',
				bioproject='#bioproject#'
			where
				genbank_batch_id=#batch_id#
		</cfquery>
		<cflocation url="genbank_submit.cfm?action=edbatch&batch_id=#batch_id#" addtoken="false">
	</cfoutput>
</cfif>



<!--------------------------------------------------------------------------------------------->
<cfif action is "prepfiles">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from genbank_batch where genbank_batch_id=#batch_id#
		</cfquery>
		<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from genbank_people where genbank_batch_id=#batch_id#
		</cfquery>

		<cfquery name="sqa" dbtype="query">
			select * from p where AGENT_ROLE='sequence author' order by agent_order
		</cfquery>
		<cfquery name="srefa" dbtype="query">
			select * from p where AGENT_ROLE='reference author' order by agent_order
		</cfquery>

		<cfquery name="s" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from genbank_sequence where genbank_batch_id=#batch_id#
		</cfquery>
		<cfdump var=#d#>
		<cfdump var=#p#>
		<cfdump var=#s#>

		<!--- make a directory; force-overwrite if necessary --->
		<cfset dir="#application.webDirectory#/temp/#d.batch_name#">
		<cfif directoryexists(dir)>
			<cfdirectory action="delete" directory="#dir#" recurse="true">
		</cfif>
		<cfdirectory mode="777" DIRECTORY="#dir#" action="create">


<cfset rstr="Submit-block ::= {">
<cfset rstr=rstr & chr(10) & chr(9) & "contact {">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & "contact {">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & "name name {">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'last "#d.last_name#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'first "#d.first_name#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'middle "#d.middle_initial#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'initials "",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'suffix "",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'title ""'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & "},">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & "affil std {">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'affil "#d.organization#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'div "#d.department#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'city "#d.city#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'sub "#d.state_prov#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'country "#d.country#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'street "#d.street#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'email "#d.email#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'fax "#d.fax#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'phone "#d.phone#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'postal-code "#d.postal_code#"'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & "}">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & "}">
<cfset rstr=rstr & chr(10) & chr(9) & "},">
<cfset rstr=rstr & chr(10) & chr(9) & "cit {">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & "authors {">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & "names std {">
<cfset l=1>
<cfloop query="sqa">
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & "{">
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & "name name {">
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & 'last "#LAST_NAME#",'>
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & 'first "#FIRST_NAME#",'>
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & 'middle "#MIDDLE_INITIAL#",'>
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & 'initials "",'>
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & 'suffix "",'>
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & 'title ""'>
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & "}">
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & "}">
	<cfif l lt sqa.recordcount>
	 	<cfset rstr=rstr & ",">
	</cfif>
 	<cfset l=l+1>
</cfloop>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & "},">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & "affil std {">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'affil "#d.organization#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'div "#d.department#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'city "#d.city#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'sub "#d.state_prov#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'country "#d.country#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'street "#d.street#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'email "#d.email#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'fax "#d.fax#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'phone "#d.phone#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'postal-code "#d.postal_code#"'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & "}">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & "}">
<cfset rstr=rstr & chr(10) & chr(9) & "},">
<cfset rstr=rstr & chr(10) & chr(9) & "subtype new">
<cfset rstr=rstr & chr(10) & "}">
<cfset rstr=rstr & chr(10) & "Seqdesc ::= pub {">
<cfset rstr=rstr & chr(10) & chr(9) & "pub {">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & " gen {">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'cit "unpublished",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'authors {'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'names std {'>
<cfset l=1>
<cfloop query="srefa">
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & "{">
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & "name name {">
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & 'last "#LAST_NAME#",'>
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & 'first "#FIRST_NAME#",'>
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & 'middle "#MIDDLE_INITIAL#",'>
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & 'initials "",'>
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & 'suffix "",'>
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & 'title ""'>
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & "}">
	<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & "}">
	<cfif l lt srefa.recordcount>
	 	<cfset rstr=rstr & ",">
	</cfif>
 	<cfset l=l+1>
</cfloop>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & "}">

<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & "},">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'title "#d.REF_TITLE#"'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & '}'>
<cfset rstr=rstr & chr(10) & chr(9) & '}'>
<cfset rstr=rstr & chr(10) & '}'>
<cfset rstr=rstr & chr(10) & 'Seqdesc ::= user {'>
<cfset rstr=rstr & chr(10) & chr(9) & 'type str "DBLink",'>
<cfset rstr=rstr & chr(10) & chr(9) & 'data {'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & '{'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'label str "BioProject",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'num 1,'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'data strs {'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & '"SUB1"'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & '}'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & '},'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & '{'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'label str "BioSample",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'num 1,'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'data strs {'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & '"SAM6"'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & '}'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & '}'>
<cfset rstr=rstr & chr(10) & chr(9) & '}'>
<cfset rstr=rstr & chr(10) & '}'>
<cfset rstr=rstr & chr(10) & 'Seqdesc ::= user {'>
<cfset rstr=rstr & chr(10) & chr(9) & 'type str "Submission",'>
<cfset rstr=rstr & chr(10) & chr(9) & 'data {'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & '{'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'label str "AdditionalComment",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'data str "ALT EMAIL:#d.email#"'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & '}'>
<cfset rstr=rstr & chr(10) & chr(9) & '}'>
<cfset rstr=rstr & chr(10) & '}'>
<cfset rstr=rstr & chr(10) & 'Seqdesc ::= user {'>
<cfset rstr=rstr & chr(10) & chr(9) & 'type str "Submission",'>
<cfset rstr=rstr & chr(10) & chr(9) & 'data {'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & '{'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'label str "AdditionalComment",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'Submission Title:None'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & '}'>
<cfset rstr=rstr & chr(10) & chr(9) & '}'>
<cfset rstr=rstr & chr(10) & '}'>

<cfset rstr=replace(rstr,chr(9),"  ","all")>

<p>
	#rstr#
</p>
<cffile action="write" mode="777" file="#dir#/#d.batch_name#.sbt" output="#rstr#" addnewline="false">

<a href="/temp/#d.batch_name#/#d.batch_name#.sbt">/temp/#d.batch_name#/#d.batch_name#.sbt</a>

<cfset tmp="Sequence_ID#chr(9)#Collected_by#chr(9)#Collection_date#chr(9)#Country#chr(9)#Lat_Lon#chr(9)#Specimen_voucher#chr(9)#Host#chr(9)#Dev_stage#chr(9)#Sex#chr(9)#Tissue_type">

<cfset tmp_sq="">
<cfset lnum=1>
<cfloop query="s">

	<!--- god-query - this stuff gets loaned etc.--->
	<cfquery name="sd" datasource="uam_god">
		select
			guid,
			COLLECTORS,
			decode(began_date,ended_date,began_date,began_date  || '/' || ended_date) cdate,
			country,
			decode(dec_lat,null,null,dec_lat || '/' || dec_long) dll,
			RELATEDCATALOGEDITEMS,
			ATTRIBUTES,
			sex,
			scientific_name
		from
			flat
		where
			collection_object_id=#collection_object_id#
	</cfquery>

	<cfif lnum gt 1>
		<cfset tmp_sq=tmp_sq & chr(10)>
	</cfif>
	<cfset tmp_sq=tmp_sq & ">#sequence_identifier# [organism=#sd.scientific_name#]#chr(10)##sequence_data#">


	<cfset host="">
	<cfloop list="#sd.RELATEDCATALOGEDITEMS#" index="i" delimiters=";">
		<cfif i contains "parasite of">
			<cfset host=listappend(host,i,';')>
		</cfif>
	</cfloop>
	<cfset dstg="">
	<cfset dev_stage_attributes="age,age class,numeric age,year class">
	<cfloop list="#sd.ATTRIBUTES#" index="i" delimiters=";">
		<cfif listfind(dev_stage_attributes,i)>
			<cfset dstg=listappend(dstg,i,';')>
		</cfif>
	</cfloop>


	<cfset tmp=tmp & chr(10) & s.sequence_identifier>
	<cfset tmp=tmp & chr(9) & sd.COLLECTORS>
	<cfset tmp=tmp & chr(9) & sd.cdate>
	<cfset tmp=tmp & chr(9) & sd.country>
	<cfset tmp=tmp & chr(9) & sd.dll>
	<cfset tmp=tmp & chr(9) & sd.guid>
	<cfset tmp=tmp & chr(9) & host>
	<cfset tmp=tmp & chr(9) & dstg>
	<cfset tmp=tmp & chr(9) & sd.sex>
	<!--- IDK if anyone will have this but we should --->
	<cfset tmp=tmp & chr(9) & "">
	<cfset lnum=lnum+1>



</cfloop>

	<cffile action="write" mode="777" file="#dir#/#d.batch_name#.fsa" output="#tmp_sq#" addnewline="false">
	<cffile action="write" mode="777" file="#dir#/#d.batch_name#.src" output="#tmp#" addnewline="false">

<!----

	<br><a href="/temp/#d.batch_name#/#sequence_identifier#.fsa">/temp/#d.batch_name#/#sequence_identifier#.fsa</a>

<a href="/temp/#d.batch_name#/#sequence_identifier#.src">/temp/#d.batch_name#/#d.batch_name#.src</a>
---->

	<p>
	#tmp#
</p>




<p>
	made some files, review then <a href="genbank_submit.cfm?action=pkgfiles&batch_id=#batch_id#">package them</a>

</p>

	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------->
<cfif action is "pkgfiles">
	<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from genbank_batch where genbank_batch_id=#batch_id#
	</cfquery>



	<cfoutput>
		<cfexecute
			variable="gm"
			errorVariable="errorOut"
			name="/usr/local/bin/linux.tbl2asn"
			arguments="-t #application.webDirectory#/temp/#b.batch_name#/#b.batch_name#.sbt -p #application.webDirectory#/temp/#b.batch_name#/ -V vb -a s" />
		<p>
		some stuff hopefully happened <a href="genbank_submit.cfm?action=reviewResults&batch_id=#batch_id#">reviewResults</a>

	</p>
	</cfoutput>
</cfif>

<!--------------------------------------------------------------------------------------------->
<cfif action is "reviewResults">
	<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from genbank_batch where genbank_batch_id=#batch_id#
	</cfquery>

	<cfoutput>
		<p>
			Files in directory #b.batch_name#....
		</p>
		<cfdirectory name="d" action="list" directory="#application.webDirectory#/temp/#b.batch_name#">
		<cfdump var=#d#>
		<table border>
			<th>
				<td>File Extension</td>
				<td>Whatsit?</td>
				<td>Interpretation</td>
			</th>
			<tr>
				<td>.fsa</td>
				<td>FASTA file</td>
				<td>Generated from the data you provided.[organism] from accepted scientific name of the GUID you provided.</td>
			</tr>
			<tr>
				<td>.sbt</td>
				<td>template file</td>
				<td>Generated from the data you provided; authors and publications and such</td>
			</tr>
			<tr>
				<td>.src</td>
				<td>source file</td>
				<td>Generated from the GUID you provided.</td>
			</tr>
			<tr>
				<td>errorsummary.val</td>
				<td>Summary of compilation errors</td>
				<td>Generated from GenBank tools. Details below.</td>
			</tr>
			<tr>
				<td>.val</td>
				<td>compilation errors and warnings</td>
				<td>Generated from GenBank tools. Details below.</td>
			</tr>
			<tr>
				<td>.gbf</td>
				<td>flatfile format of results. For viewing only.</td>
				<td>Generated from GenBank tools. </td>
			</tr>
			<tr>
				<td>.sqn</td>
				<td>File to submit to GB</td>
				<td>Generated from GenBank tools. </td>
			</tr>
		</table>
		<p>
			errorsummary.val issues
		</p>
		<table border>
			<th>
				<td>Message</td>
				<td>Whatsit?</td>
			</th>
			<tr>
				<td>SEQ_DESCR.BioSourceInconsistency</td>
				<td>IDK</td>
			</tr>
			<tr>
				<td>SEQ_DESCR.BadInstitutionCode</td>
				<td>GB isn't processing this correctly??</td>
			</tr>
			<tr>
				<td>SEQ_DESCR.DBLinkProblem</td>
				<td>Same as BadInstitutionCode??</td>
			</tr>
			<tr>
				<td>SEQ_DESCR.LatLonValue</td>
				<td>format??</td>
			</tr>
			<tr>
				<td>SEQ_DESCR.ShortSeq</td>
				<td>GB doesn't like data</td>
			</tr>
		</table>

		<p>Files</p>
		Click to do whatever your browser wants to do. Right-click, save-as to download. All files are text and viewable in text editors.

		<ul>
		<cfloop query="d">
			<li><a href="/temp/#b.batch_name#/#name#" target="blank">/temp/#b.batch_name#/#name#</a> (new tab/window)</li>

		</cfloop>
		</ul>
</cfoutput>

</cfif>



<!--------------------------------------------------------------------------------------------->
<cfif action is "add_sequence">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into genbank_sequence (
				sequence_id,
				genbank_batch_id,
				sequence_identifier,
				collection_object_id,
				sequence_data
			) values (
				someRandomSequence.nextval,
				#batch_id#,
				'#sequence_identifier#',
				(select collection_object_id from flat where guid='#GUID#'),
				'#sequence_data#'
			)
		</cfquery>
		<cflocation url="genbank_submit.cfm?action=edbatch&batch_id=#batch_id#" addtoken="false">
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------->
<cfif action is "add_agent">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into genbank_people (
				genbank_people_id,
				genbank_batch_id,
				agent_id,
				agent_role,
				first_name,
				middle_initial,
				last_name,
				agent_order
			) values (
				someRandomSequence.nextval,
				#batch_id#,
				'#new_agent_id#',
				'#agent_role#',
				'#first_name#',
				'#middle_initial#',
				'#last_name#',
				#agent_order#
			)
		</cfquery>
		<cflocation url="genbank_submit.cfm?action=edbatch&batch_id=#batch_id#" addtoken="false">
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------->
<cfif action is "mkbatch">
	<cfoutput>
		<p>
			Create a "batch" - a way of organizing one or more sequence submissions, usually for a publication.
		</p>
		<form name="f" method="post" action="genbank_submit.cfm">
			<input type="hidden" name="action" value="create_batch">
			<label for="batch_name">batch_name (must be unique; local label, usually for publication)</label>
			<input type="text" name="batch_name" id="batch_name" size="80" class="reqdClr">

			<h3>Contact Agent details</h3>
			<label for="contact_agent">contact agent (pick Arctos agent)</label>
			<input type="hidden" name="contact_agent_id" id="contact_agent_id" value="">
			<input type="text" name="contact_agent" id="contact_agent" value=""
				onchange="pickAgentModal('contact_agent_id',this.id,this.value); return false;"
				onKeyPress="return noenter(event);" placeholder="contact agent" class="reqdClr minput">



			<label for="first_name">first_name</label>
			<input type="text" name="first_name" id="first_name" size="80" class="reqdClr">

			<label for="last_name">last_name</label>
			<input type="text" name="last_name" id="last_name" size="80" class="reqdClr">

			<label for="middle_initial">middle_initial</label>
			<input type="text" name="middle_initial" id="middle_initial" size="80" class="reqdClr">

			<label for="email">email</label>
			<input type="text" name="email" id="email" size="80" class="reqdClr">

			<label for="organization">organization</label>
			<input type="text" name="organization" id="organization" size="80" class="reqdClr">

			<label for="department">department</label>
			<input type="text" name="department" id="department" size="80" class="reqdClr">

			<label for="phone">phone</label>
			<input type="text" name="phone" id="phone" size="80" class="reqdClr">

			<label for="fax">fax</label>
			<input type="text" name="fax" id="fax" size="80" class="reqdClr">

			<label for="street">street</label>
			<input type="text" name="street" id="street" size="80" class="reqdClr">

			<label for="city">city</label>
			<input type="text" name="city" id="xxxx" size="80" class="reqdClr">

			<label for="state_prov">state_prov</label>
			<input type="text" name="state_prov" id="state_prov" size="80" class="reqdClr">

			<label for="postal_code">postal_code</label>
			<input type="text" name="postal_code" id="postal_code" size="80" class="reqdClr">

			<label for="country">country</label>
			<input type="text" name="country" id="country" size="80" class="reqdClr">

			<label for="ref_title">ref_title (publication title or working title)</label>
			<input type="text" name="ref_title" id="ref_title" size="80" class="reqdClr">

			<label for="biosample">biosample</label>
			<input type="text" name="biosample" id="biosample" size="80">

			<label for="bioproject">bioproject</label>
			<input type="text" name="bioproject" id="bioproject" size="80" >

			<br><input type="submit" value="create batch" class="insBtn">
		</form>
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------->

<cfif action is "create_batch">
	<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select someRandomSequence.nextval k from dual
	</cfquery>

	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into genbank_batch (
			genbank_batch_id,
			contact_agent_id,
			batch_name,
			first_name,
			last_name,
			middle_initial,
			email,
			organization,
			department,
			phone,
			fax,
			street,
			city,
			state_prov,
			postal_code,
			country,
			ref_title,
			biosample,
			bioproject
		) values (
			#k.k#,
			#contact_agent_id#,
			'#batch_name#',
			'#first_name#',
			'#last_name#',
			'#middle_initial#',
			'#email#',
			'#organization#',
			'#department#',
			'#phone#',
			'#fax#',
			'#street#',
			'#city#',
			'#state_prov#',
			'#postal_code#',
			'#country#',
			'#ref_title#',
			'#biosample#',
			'#bioproject#'
		)
	</cfquery>
	<cflocation url="genbank_submit.cfm?action=edbatch&batch_id=#k.k#" addtoken="false">
</cfif>
<!--------------------------------------------------------------------------------------------->



<cfinclude template="/includes/_footer.cfm">
