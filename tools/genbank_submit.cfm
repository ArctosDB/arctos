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

		<h3>Sequences</h3>
		<cfquery name="s" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from genbank_sequence where genbank_batch_id=#batch_id#
		</cfquery>
		<cfdump var=#s#>

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


		<p>
		<br><a href="genbank_submit.cfm?action=prepfiles&batch_id=#batch_id#">prepare files</a>

		</p>

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


<cfset l=1>
<cfsavecontent variable = "pauths">
<cfloop query="srefa">{
                        name name {
                            last "#LAST_NAME#",
                            first "#FIRST_NAME#",
                            middle "#MIDDLE_INITIAL#",
                            initials "",
                            suffix "",
                            title ""
                        }
                    }<cfif l lt srefa.recordcount>,#chr(10)#</cfif>
  		<cfset l=l+1>
	</cfloop>
</cfsavecontent>


====#pauths#====


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
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & chr(9) & 'first "#d.first_name#",'>
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
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & "}">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & "},">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & "affil std {">
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'affil "#d.organization#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'div "#d.department#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'city "#d.city#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'sub "#d.state_prov#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'country "#d.country#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'street "#d.street#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'email "#d.email#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'fax "#d.fax#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'phone "#d.phone#",'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & chr(9) & 'postal-code "#d.postal_code#"'>
<cfset rstr=rstr & chr(10) & chr(9) & chr(9) & "}">
<cfset rstr=rstr & chr(10) & chr(9) & "}">
<cfset rstr=rstr & chr(10) & "},">
<cfset rstr=rstr & chr(10) & "subtype new">
<cfset rstr=rstr & chr(10) & "}">

<!----
}
Seqdesc ::= pub {
  pub {
    gen {
      cit "unpublished",
      authors {
        names std {
		    #pauths#
        }
      },
      title "#d.REF_TITLE#"
    }
  }
}
Seqdesc ::= user {
  type str "Submission",
  data {
    {
      label str "AdditionalComment",
      data str "ALT EMAIL:#d.email#"
    }
  }
}
Seqdesc ::= user {
  type str "Submission",
  data {
    {
      label str "AdditionalComment",
      data str "Submission Title:None"
    }
  }
}


<cfsavecontent variable = "sbt">
Submit-block ::= {
    contact {
        contact {
            name name {
            last "#d.last_name#",
            first "#d.first_name#",
            middle "#d.middle_initial#",
            initials "",
            suffix "",
            title ""
        },
        affil std {
            affil "#d.organization#",
            div "#d.department#",
            city "#d.city#",
            sub "#d.state_prov#",
            country "#d.country#",
            street "#d.street#",
            email "#d.email#",
            fax "#d.fax#",
            phone "#d.phone#",
            postal-code "#d.postal_code#"
        }
    }
},
cit {
    authors {
        names std {
		    #sauths#
        }
    },
    affil std {
        affil "#d.organization#",
        div "#d.department#",
        city "#d.city#",
        sub "#d.state_prov#",
        country "#d.country#",
        street "#d.street#",
        email "#d.email#",
        fax "#d.fax#",
        phone "#d.phone#",
        postal-code "#d.postal_code#"
      }
    }
  },
  subtype new
}
Seqdesc ::= pub {
  pub {
    gen {
      cit "unpublished",
      authors {
        names std {
		    #pauths#
        }
      },
      title "#d.REF_TITLE#"
    }
  }
}
Seqdesc ::= user {
  type str "Submission",
  data {
    {
      label str "AdditionalComment",
      data str "ALT EMAIL:#d.email#"
    }
  }
}
Seqdesc ::= user {
  type str "Submission",
  data {
    {
      label str "AdditionalComment",
      data str "Submission Title:None"
    }
  }
}
</cfsavecontent>


<cfdump var=#sbt#>

---->

<cfset rstr=replace(rstr,chr(10),"  ","all")>
<cffile action="write" file="#application.webDirectory#/temp/#d.batch_name#.sbt" output="#rstr#" addnewline="false">

		<a href="/temp/#d.batch_name#.sbt">/temp/#d.batch_name#.sbt</a>


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
