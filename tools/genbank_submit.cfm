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
			select * from genbank_batch where genbank_batch_id=#batch_id#
		</cfquery>
		<cfdump var=#b#>
		<hr>
		<h3>People</h3>
		<br>Add Person
		<form name="f" method="post" action="genbank_submit.cfm">
			<input type="hidden" name="action" value="add_agent">
			<input type="hidden" name="batch_id" value="#batch_id#">





			<input type="hidden" name="new_agent_id" id="new_agent_id" value="">
			<label for="new_agent">Agent (pick Arctos agent)</label>
			<input type="text" name="new_agent" id="new_agent" value=""
				onchange="pickAgentModal('new_agent_id',this.id,this.value); return false;"
				onKeyPress="return noenter(event);" placeholder="pick an agent" class="reqdClr minput">

			<label for="agent_role">agent_role</label>
			<select name="agent_role" id="agent_role" class="reqdClr">
				<option></option>
				<option value="sequence author">sequence author</option>
				<option value="reference author">reference author</option>
			</select>

			<label for="first_name">first_name</label>
			<input type="text" name="first_name" id="first_name" size="80" class="reqdClr">

			<label for="middle_initial">middle_initial</label>
			<input type="text" name="middle_initial" id="middle_initial" size="80" >

			<label for="last_name">last_name</label>
			<input type="text" name="last_name" id="last_name" size="80" class="reqdClr">

			<label for="agent_order">agent_order</label>
			<select name="agent_order" id="agent_order" class="reqdClr">
				<option></option>
				<cfloop from="1" to="30" index="i">

					<option value="#i#">#i#</option>
				</cfloop>
			</select>


			<br><input type="submit" value="add person" class="insBtn">
		</form>
		<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from genbank_people where genbank_batch_id=#batch_id#
		</cfquery>
		<cfdump var=#p#>

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
