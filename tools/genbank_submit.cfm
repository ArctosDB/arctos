<cfinclude template="/includes/_header.cfm">
<cfset title="Genbank Submission Form">
<ul>
	<li><a href="genbank_submit.cfm">home</a></li>
	<cfif isdefined("batch_id") and len(batch_id) gt 0>
		<li><a href="genbank_submit.cfm?action=edbatch&batch_id=<cfoutput>#batch_id#</cfoutput>">Edit Batch</a></li>
	</cfif>
</ul>

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

			<div style="margin:1em;padding:1em;border:2px solid green">
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

				<label for="save_to_address">Create or replace "formatted JSON" address with this information?</label>
				<select name="make_addr" id="make_addr" class="reqdClr">
					<option value="no">no</option>
					<option value="yes">yes</option>
				</select>
				<div class="importantNotification">
					When creating a batch, Arctos will attempt to retrieve name and address components. Please correct any "UNKNOWN"
					values above. Select "yes" in <code>Create or replace "formatted JSON" address with this information?</code>
					to save this information as an Agent Address and allow acessing this information in the future.
				</div>
			</div>
			<label for="ref_title">ref_title (publication title or working title)</label>
			<input type="text" name="ref_title" id="ref_title" value="#b.ref_title#" size="80" class="reqdClr">

			<br>"SAMN04505215" from "https://www.ncbi.nlm.nih.gov/biosample/SAMN04505215"
			<label for="biosample">biosample</label>
			<input type="text" name="biosample" id="biosample" value="#b.biosample#" size="80">
			<br>"PRJNA418314" from "https://www.ncbi.nlm.nih.gov/bioproject/418314"
			<label for="bioproject">bioproject</label>
			<input type="text" name="bioproject" id="bioproject" value="#b.bioproject#" size="80" >

			<br><input type="submit" value="save batch edits" class="insBtn">
		</form>
		<hr>
		<h3>People</h3>
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
				<th>-</th>
				<th>-</th>
			</tr>

			<form name="f" method="post" action="genbank_submit.cfm">
				<input type="hidden" name="action" value="add_agent">
				<input type="hidden" name="batch_id" value="#batch_id#">
				<input type="hidden" name="new_agent_id" id="new_p_agent_id">
					<tr class="newRec">
						<td>
							<input type="text" name="new_agent" id="new_p_agent" value=""
								onchange="pickAgentModal('new_p_agent_id',this.id,this.value); return false;"
								onKeyPress="return noenter(event);" placeholder="pick an agent" class="reqdClr minput">
						</td>
						<td>
							<select name="agent_role" id="agent_role" class="reqdClr">
								<option>PICK</option>
								<option value="sequence author">sequence author</option>
								<option value="reference author">reference author</option>
							</select>
						</td>
						<td>
							<input type="text" name="first_name" id="first_name" size="30" >
						</td>
						<td>
							<input type="text" name="middle_initial" id="middle_initial" size="20" >
						</td>
						<td>
							<input type="text" name="last_name" id="last_name" size="30" >
						</td>
						<td>
							<select name="agent_order" id="agent_order" class="reqdClr">
								<option>PICK</option>
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
						<td><input type="button" value="delete" class="delBtn" onclick="document.location='genbank_submit.cfm?action=deleteAgent&batch_id=#batch_id#&GENBANK_PEOPLE_ID=#GENBANK_PEOPLE_ID#'";></td>
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
				SEQUENCE_DATA,
				tissue,
				source_material_id
			from
				genbank_sequence,
				flat
			where
				genbank_sequence.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID(+) and
				genbank_batch_id=#batch_id#
		</cfquery>
		<div class="newRec">
		<form name="f" method="post" action="genbank_submit.cfm">
			<input type="hidden" name="action" value="add_sequence">
			<input type="hidden" name="batch_id" value="#batch_id#">

			<label for="sequence_identifier">sequence_identifier</label>
			<input type="text" name="sequence_identifier" id="sequence_identifier" size="80" class="reqdClr">

			<div style="border:2px solid red; padding:1em;margin:1em;">
				<br>You MUST provide enough information to identify a specimen, and SHOULD provide enough to identify a specific sample.
				<br>Preferred: provide a barcode, Arctos will figure out the rest.
				<br>Acceptable: provide a GUID

				<label for="source_material_id">source_material_id (barcode)</label>
				<input type="text" name="source_material_id" id="source_material_id" size="80" >
				<label for="tissue">tissue (part name)</label>
				<input type="text" name="tissue" id="tissue" size="80" >
				<label for="GUID">GUID (DWC Triplet format)</label>
				<input type="text" name="GUID" id="GUID" size="80" >
			</div>

			<label for="sequence_data">sequence_data</label>
			<textarea name="sequence_data" id="sequence_data" class="hugetextarea"></textarea>


			<br><input type="submit" value="add sequence" class="insBtn">
		</form>
		</div>
		<cfloop query="s">
			<hr>


				<form name="f" method="post" action="genbank_submit.cfm">
			<input type="hidden" name="action" value="edit_sequence">
			<input type="hidden" name="batch_id" value="#batch_id#">
			<input type="hidden" name="SEQUENCE_ID" value="#SEQUENCE_ID#">

			<label for="sequence_identifier">sequence_identifier</label>
			<input type="text" name="sequence_identifier" id="sequence_identifier" value='#sequence_identifier#' size="80" class="reqdClr">

			<div style="border:2px solid red; padding:1em;margin:1em;">
				<br>You MUST provide enough information to identify a specimen, and SHOULD provide enough to identify a specific sample.
				<br>Preferred: provide a barcode, Arctos will figure out the rest.
				<br>Acceptable: provide a GUID

				<label for="source_material_id">source_material_id (barcode)</label>
				<input type="text" name="source_material_id" id="source_material_id" size="80" value='#source_material_id#'>
				<label for="tissue">tissue (part name)</label>
				<input type="text" name="tissue" id="tissue" size="80" value='#tissue#'>
				<label for="GUID">GUID (DWC Triplet format)</label>
				<input type="text" name="GUID" id="GUID" value='#guid#' size="80" >
			</div>


			<label for="sequence_data">sequence_data</label>
			<textarea name="sequence_data" id="sequence_data" class="hugetextarea">#sequence_data#</textarea>


			<br><input type="submit" value="save/edit sequence" class="insBtn">
		</form>
		</cfloop>
		<p>
			Once everything on this page is happy, you can
			<a href="genbank_submit.cfm?action=prepfiles&batch_id=#batch_id#">prepare files</a>
			for GenBank submission.
		</p>
	</cfoutput>
</cfif>


<!--------------------------------------------------------------------------------------------->
<cfif action is "deleteAgent">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from genbank_people where GENBANK_PEOPLE_ID=#GENBANK_PEOPLE_ID#
		</cfquery>
		<cflocation url="genbank_submit.cfm?action=edbatch&batch_id=#batch_id#" addtoken="false">
	</cfoutput>
</cfif>





<!--------------------------------------------------------------------------------------------->
<cfif action is "edit_sequence">
	<cfoutput>
		<cfif isdefined("source_material_id") and len(source_material_id) gt 0>
			<!--- they provided a barcode, overwrite anything else from it --->
			<cfquery name="gid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					flat.collection_object_id,
					specimen_part.part_name
				from
					flat,
					specimen_part,
					coll_obj_cont_hist,
					container partc,
					container ppc
				where
					flat.collection_object_id=specimen_part.derived_from_cat_item and
					specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
					coll_obj_cont_hist.container_id=partc.container_id and
					partc.parent_container_id=ppc.container_id and
					ppc.barcode='#source_material_id#'
			</cfquery>
			<cfif gid.recordcount is not 1>
				<div class="error">
					barcode did not resolve
					<cfdump var=#gid#>
					<cfabort>
				</div>
			</cfif>
			<cfset tis=gid.part_name>
			<cfset cid=gid.collection_object_id>
		<cfelseif  isdefined("guid") and len(guid) gt 0>
			<cfquery name="gid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					flat.collection_object_id
				from
					flat
				where
					flat.guid='#guid#'
			</cfquery>
			<cfif gid.recordcount is not 1>
				<div class="error">
					barcode did not resolve
					<cfdump var=#gid#>
					<cfabort>
				</div>
			</cfif>
			<cfset tis=''>
			<cfset cid=gid.collection_object_id>
		<cfelse>
			<div class="error">
				You must provide barcode or GUID<cfabort>
			</div>
		</cfif>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update genbank_sequence set
				sequence_identifier='#sequence_identifier#',
				COLLECTION_OBJECT_ID=#cid#,
				tissue='#tis#',
				source_material_id='#source_material_id#',
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

		<cfif make_addr is "yes">
			<!--- make JSON --->
			<cfset j.first_name=first_name>
			<cfset j.last_name=last_name>
			<cfset j.middle_initial=middle_initial>
			<cfset j.email=email>
			<cfset j.organization=organization>
			<cfset j.department=department>
			<cfset j.phone=phone>
			<cfset j.street=street>
			<cfset j.state_prov=state_prov>
			<cfset j.postal_code=postal_code>
			<cfset j.country=country>

			<cfset x=SerializeJSON(j)>
			<cfquery name="addAddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into address (
					ADDRESS_ID,
					AGENT_ID,
					ADDRESS_TYPE,
					ADDRESS,
					VALID_ADDR_FG
				) values (
					sq_address_id.nextval,
					#CONTACT_AGENT_ID#,
					'formatted JSON',
					'#x#',
					1
				)
			</cfquery>
		</cfif>




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
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & '"#d.biosample#"'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & '}'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & '},'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & '{'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'label str "BioSample",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'num 1,'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'data strs {'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & '"#d.bioproject#"'>
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


<cffile action="write" mode="777" file="#dir#/#d.batch_name#.sbt" output="#rstr#" addnewline="false">

<!---
https://www.ncbi.nlm.nih.gov/Sequin/sequin.hlp.html#ModifiersPage
Altitude
Identified-by:
note
tissue-lib
--->

<cfset tmp="Sequence_ID#chr(9)#Collected_by#chr(9)#Collection_date#chr(9)#Country#chr(9)#Identified-by#chr(9)#Lat_Lon#chr(9)#Altitude#chr(9)#Specimen_voucher#chr(9)#Host#chr(9)#Dev_stage#chr(9)#Sex#chr(9)#Tissue-type#chr(9)#tissue-lib#chr(9)#note">

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
			case when dec_lat is not null then
				CASE when dec_lat > 0 then dec_lat || ' N'
				when dec_lat < 0 then (dec_lat*-1) || ' S'
				else ''
				END || ' ' ||
				CASE when dec_long > 0 then dec_long || ' E'
				when dec_long < 0 then (dec_long*-1) || ' W'
				else ''
				END
			else ''
			END DLL,
			RELATEDCATALOGEDITEMS,
			ATTRIBUTES,
			sex,
			scientific_name,
			IDENTIFIEDBY,
			 to_meters(MINIMUM_ELEVATION, ORIG_ELEV_UNITS ) min_elev,
			 to_meters(MAXIMUM_ELEVATION, ORIG_ELEV_UNITS ) max_elev
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

	<cfset thenote="">
	<cfset tmp=tmp & chr(10) & s.sequence_identifier>
	<cfset tmp=tmp & chr(9) & sd.COLLECTORS>
	<cfset tmp=tmp & chr(9) & sd.cdate>
	<cfset tmp=tmp & chr(9) & sd.country>
	<cfset tmp=tmp & chr(9) & sd.identifiedby>
	<cfset tmp=tmp & chr(9) & sd.dll>
	<!----
		https://www.ncbi.nlm.nih.gov/IEB/ToolBox/C_DOC/lxr/source/errmsg/valid.msg
		587 The altitude must be reported as a number followed by a space and the letter m (for meters).
	---->
	<cfif len(sd.min_elev) gt 0>
		<cfset 	altitude=sd.min_elev & ' m'>
		<cfif sd.min_elev is not sd.max_elev>
			<cfset thenote=listappend(thenote,"Elevation: #sd.min_elev#-#sd.max_elev#m","; ")>
		</cfif>
	<cfelse>
		<cfset 	altitude=''>
	</cfif>
	<cfset tmp=tmp & chr(9) & altitude>
	<cfset tmp=tmp & chr(9) & sd.guid>
	<cfset tmp=tmp & chr(9) & host>
	<cfset tmp=tmp & chr(9) & dstg>
	<cfset tmp=tmp & chr(9) & sd.sex>
	<cfset tmp=tmp & chr(9) & s.tissue>
	<cfset tmp=tmp & chr(9) & s.source_material_id>
	<cfif len(s.source_material_id) gt 0>
		<cfset thenote=listappend(thenote,"tissue-lib (#source_material_id#) is specimen part barcode.","; ")>
	</cfif>
	<cfset tmp=tmp & chr(9) & thenote>
	<cfset lnum=lnum+1>

</cfloop>

	<cffile action="write" mode="777" file="#dir#/#d.batch_name#.fsa" output="#tmp_sq#" addnewline="false">
	<cffile action="write" mode="777" file="#dir#/#d.batch_name#.src" output="#tmp#" addnewline="false">

<p>
	These files have been written. You probably don't need to care unless something breaks.

	<ul>
		<li><a href="/temp/#d.batch_name#/#d.batch_name#.sbt">/temp/#d.batch_name#/#d.batch_name#.sbt</a></li>
		<li><a href="/temp/#d.batch_name#/#d.batch_name#.fsa">/temp/#d.batch_name#/#d.batch_name#.fsa</a></li>
		<li><a href="/temp/#d.batch_name#/#d.batch_name#.src">/temp/#d.batch_name#/#d.batch_name#.src</a></li>
	</ul>
</p>

<p>
	Next Step: <a href="genbank_submit.cfm?action=pkgfiles&batch_id=#batch_id#">package files</a>

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
			timeout="120"
			variable="gm"
			errorVariable="errorOut"
			name="/usr/local/bin/linux.tbl2asn"
			arguments="-t #application.webDirectory#/temp/#b.batch_name#/#b.batch_name#.sbt -p #application.webDirectory#/temp/#b.batch_name#/ -V vb -a s" />
		<p>
			This should have just executed:

			<code>
				/usr/local/bin/linux.tbl2asn -t #application.webDirectory#/temp/#b.batch_name#/#b.batch_name#.sbt -p #application.webDirectory#/temp/#b.batch_name#/ -V vb -a s
			</code>
		</p>
		<p>
			Execution Results:
		</p>
		<cfif isdefined("gm")>
			<p>
				 #gm#
			</p>
		</cfif>
		<cfif isdefined("errorOut")>
			<p>
				#errorOut#
			</p>
		</cfif>
		<p>
			<a href="genbank_submit.cfm?action=reviewResults&batch_id=#batch_id#">review results</a>
		</p>
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------->
<cfif action is "reviewResults">
	<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from genbank_batch where genbank_batch_id=#batch_id#
	</cfquery>

	<cfoutput>

		<cfdirectory name="d" action="list" directory="#application.webDirectory#/temp/#b.batch_name#">

		<p>
			There should be some files linked below. Here's what they are:
		</p>
		<table border>
			<tr>
				<th>File Extension</th>
				<th>Whatsit?</th>
				<th>Interpretation</th>
			</tr>
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
			errorsummary.val common issues
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
				<td>SEQ_DESCR.ShortSeq</td>
				<td>GB doesn't like data</td>
			</tr>
		</table>

		<p>
			Files in directory #b.batch_name#.
			Click to do whatever your browser wants to do. Right-click, save-as to download. All files are text and viewable in text editors.
		</p>
		<ol>
			<li>CAREFULLY review the .gbf file; it should look like what you'll see on GenBank after submission</li>
			<li>
				Download the .sqn file and send it to GenBank via email or at
				<a target="_blank" class="external" href="https://www.ncbi.nlm.nih.gov/LargeDirSubs/dir_submit.cgi">
					https://www.ncbi.nlm.nih.gov/LargeDirSubs/dir_submit.cgi
				</a>
			</li>
		</ol>

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
		<cfif isdefined("source_material_id") and len(source_material_id) gt 0>
			<!--- they provided a barcode, overwrite anything else from it --->
			<cfquery name="gid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					flat.collection_object_id,
					specimen_part.part_name
				from
					flat,
					specimen_part,
					coll_obj_cont_hist,
					container partc,
					container ppc
				where
					flat.collection_object_id=specimen_part.derived_from_cat_item and
					specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
					coll_obj_cont_hist.container_id=partc.container_id and
					partc.parent_container_id=ppc.container_id and
					ppc.barcode='#source_material_id#'
			</cfquery>
			<cfif gid.recordcount is not 1>
				<div class="error">
					barcode did not resolve
					<cfdump var=#gid#>
					<cfabort>
				</div>
			</cfif>
			<cfset tis=gid.part_name>
			<cfset cid=gid.collection_object_id>
		<cfelseif  isdefined("guid") and len(guid) gt 0>
			<cfquery name="gid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					flat.collection_object_id
				from
					flat
				where
					flat.guid='#guid#'
			</cfquery>
			<cfif gid.recordcount is not 1>
				<div class="error">
					barcode did not resolve
					<cfdump var=#gid#>
					<cfabort>
				</div>
			</cfif>
			<cfset tis=''>
			<cfset cid=gid.collection_object_id>
		<cfelse>
			<div class="error">
				You must provide barcode or GUID<cfabort>
			</div>
		</cfif>


		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into genbank_sequence (
				sequence_id,
				genbank_batch_id,
				sequence_identifier,
				collection_object_id,
				sequence_data,
				tissue,
				source_material_id
			) values (
				someRandomSequence.nextval,
				#batch_id#,
				'#sequence_identifier#',
				#cid#,
				'#sequence_data#',
				'#tis#',
				'#source_material_id#'
			)
		</cfquery>
		<cflocation url="genbank_submit.cfm?action=edbatch&batch_id=#batch_id#" addtoken="false">
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------->
<cfif action is "add_agent">
	<cfoutput>
		<cfif len(first_name) gt 0>
			<cfset fn=first_name>
		<cfelse>
			<cfquery name="gad" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select agent_name from agent_name where agent_name_type='first name' and agent_id=#new_agent_id#
			</cfquery>
			<cfif gad.recordcount is 1>
				<cfset fn=gad.agent_name>
			<cfelseif gad.recordcount is 0>
				<cfset fn='NOTFOUND'>
			<cfelse>
				<cfset fn='BAD_LOOKUP'>
			</cfif>
		</cfif>

		<cfif len(middle_initial) gt 0>
			<cfset mi=middle_initial>
		<cfelse>
			<cfquery name="gad" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select agent_name from agent_name where agent_name_type='middle name' and agent_id=#new_agent_id#
			</cfquery>
			<cfif gad.recordcount is 1>
				<cfset mi=left(gad.agent_name,1) & ".">
			<cfelseif gad.recordcount is 0>
				<cfset mi='NOTFOUND'>
			<cfelse>
				<cfset mi='BAD_LOOKUP'>
			</cfif>
		</cfif>

		<cfif len(last_name) gt 0>
			<cfset ln=last_name>
		<cfelse>
			<cfquery name="gad" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select agent_name from agent_name where agent_name_type='last name' and agent_id=#new_agent_id#
			</cfquery>
			<cfif gad.recordcount is 1>
				<cfset ln=gad.agent_name>
			<cfelseif gad.recordcount is 0>
				<cfset ln='NOTFOUND'>
			<cfelse>
				<cfset ln='BAD_LOOKUP'>
			</cfif>
		</cfif>

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
				'#fn#',
				'#mi#',
				'#ln#',
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

			<h3>Contact Agent</h3>
			<label for="contact_agent">contact agent (pick Arctos agent)</label>
			<input type="hidden" name="contact_agent_id" id="contact_agent_id" value="">
			<input type="text" name="contact_agent" id="contact_agent" value=""
				onchange="pickAgentModal('contact_agent_id',this.id,this.value); return false;"
				onKeyPress="return noenter(event);" placeholder="contact agent" class="reqdClr minput">

		<!----

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
---->
			<br><input type="submit" value="create batch" class="insBtn">
		</form>
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------->

<cfif action is "create_batch">
	<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select someRandomSequence.nextval k from dual
	</cfquery>

	<!--- see if we can get address info; fake it if not --->
	<cfquery name="adrs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from address where agent_id=#contact_agent_id#
	</cfquery>
	<cfquery name="fj" dbtype="query">
		select address from adrs where address_type='formatted JSON' and VALID_ADDR_FG=1
	</cfquery>

	<cfquery name="an" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from agent_name where agent_id=#contact_agent_id#
	</cfquery>
	<cfif fj.recordcount gt 0 and IsJSON(fj.address)>
		<!--- if there are multiple, just use one... --->
		<cfset fadr=DeserializeJSON(fj.address)>
	<cfelse>
		<cfset fadr="">
	</cfif>

	<cfif isdefined("fadr.COUNTRY")>
		<cfset COUNTRY=fadr.COUNTRY>
	<cfelse>
		<cfset COUNTRY="UNKNOWN">
	</cfif>
	<cfif isdefined("fadr.DEPARTMENT")>
		<cfset DEPARTMENT=fadr.DEPARTMENT>
	<cfelse>
		<cfset DEPARTMENT="UNKNOWN">
	</cfif>
	<cfif isdefined("fadr.EMAIL")>
		<cfset EMAIL=fadr.EMAIL>
	<cfelse>
		<!--- see if we can find it --->
		<cfquery name="e" dbtype="query">
			select address from adrs where address_type='email' and VALID_ADDR_FG=1
		</cfquery>
		<cfif e.recordcount gt 0>
			<cfset EMAIL=valuelist(e.address)>
		<cfelse>
			<cfset EMAIL="UNKNOWN">
		</cfif>
	</cfif>
	<cfif isdefined("fadr.PHONE")>
		<cfset PHONE=fadr.PHONE>
	<cfelse>
		<!--- see if we can find it --->
		<cfquery name="e" dbtype="query">
			select address from adrs where address_type like '%phone%' and VALID_ADDR_FG=1
		</cfquery>
		<cfif e.recordcount gt 0>
			<cfset PHONE=valuelist(e.address)>
		<cfelse>
			<cfset PHONE="UNKNOWN">
		</cfif>
	</cfif>
	<cfif isdefined("fadr.FAX")>
		<cfset FAX=fadr.FAX>
	<cfelse>
		<!--- see if we can find it --->
		<cfquery name="e" dbtype="query">
			select address from adrs where address_type = 'fax' and VALID_ADDR_FG=1
		</cfquery>
		<cfif e.recordcount gt 0>
			<cfset FAX=valuelist(e.address)>
		<cfelse>
			<cfset FAX="UNKNOWN">
		</cfif>
	</cfif>



	<cfif isdefined("fadr.FIRST_NAME")>
		<cfset FIRST_NAME=fadr.FIRST_NAME>
		got fadr
	<cfelse>
		<!--- see if we can find it --->
		<cfquery name="e" dbtype="query">
			select agent_name from an where agent_name_type='first name'
		</cfquery>
		<cfdump var=#e#>
		<cfif e.recordcount gt 0>
			<cfset FIRST_NAME=valuelist(e.agent_name)>
		<cfelse>
			<cfset FIRST_NAME="UNKNOWN">
		</cfif>
	</cfif>

	<cfif isdefined("fadr.LAST_NAME")>
		<cfset LAST_NAME=fadr.LAST_NAME>
	<cfelse>
		<!--- see if we can find it --->
		<cfquery name="e" dbtype="query">
			select agent_name from an where agent_name_type='last name'
		</cfquery>
		<cfif e.recordcount gt 0>
			<cfset LAST_NAME=valuelist(e.agent_name)>
		<cfelse>
			<cfset LAST_NAME="UNKNOWN">
		</cfif>
	</cfif>

	<cfif isdefined("fadr.MIDDLE_INITIAL")>
		<cfset MIDDLE_INITIAL=fadr.MIDDLE_INITIAL>
	<cfelse>
		<!--- see if we can find it --->
		<cfquery name="e" dbtype="query">
			select agent_name from an where agent_name_type='middle name'
		</cfquery>
		<cfif e.recordcount gt 0>
			<cfset MIDDLE_INITIAL=left(e.agent_name,1) & ".">
		<cfelse>
			<cfset MIDDLE_INITIAL="UNKNOWN">
		</cfif>
	</cfif>


	<cfif isdefined("fadr.ORGANIZATION")>
		<cfset ORGANIZATION=fadr.ORGANIZATION>
	<cfelse>
		<cfset ORGANIZATION="UNKNOWN">
	</cfif>

	<cfif isdefined("fadr.POSTAL_CODE")>
		<cfset POSTAL_CODE=fadr.POSTAL_CODE>
	<cfelse>
		<cfset POSTAL_CODE="UNKNOWN">
	</cfif>
	<cfif isdefined("fadr.STATE_PROV")>
		<cfset STATE_PROV=fadr.STATE_PROV>
	<cfelse>
		<cfset STATE_PROV="UNKNOWN">
	</cfif>
	<cfif isdefined("fadr.STREET")>
		<cfset STREET=fadr.STREET>
	<cfelse>
		<cfset STREET="UNKNOWN">
	</cfif>

	<cfif isdefined("fadr.CITY")>
		<cfset CITY=fadr.CITY>
	<cfelse>
		<cfset CITY="UNKNOWN">
	</cfif>


	<cfset ref_title="PENDING">
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
			ref_title
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
			'#ref_title#'
		)
	</cfquery>
	<cflocation url="genbank_submit.cfm?action=edbatch&batch_id=#k.k#" addtoken="false">
</cfif>
<!--------------------------------------------------------------------------------------------->



<cfinclude template="/includes/_footer.cfm">
