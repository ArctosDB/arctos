
<cfoutput>
	<cfparam name="inp" default="">
	<cfparam name="b.first_name" default="">
	<cfparam name="b.last_name" default="">
	<cfparam name="b.middle_initial" default="">
	<cfparam name="b.email" default="">
	<cfparam name="b.organization" default="">
	<cfparam name="b.department" default="">
	<cfparam name="b.position" default="">
	<cfparam name="b.phone" default="">
	<cfparam name="b.fax" default="">
	<cfparam name="b.street" default="">
	<cfparam name="b.city" default="">
	<cfparam name="b.state_prov" default="">
	<cfparam name="b.postal_code" default="">
	<cfparam name="b.country" default="">

<form name="x" method="post" action="formatted_address.cfm">
	<label for="inp" value="Input"></label>
	<textarea name="inp" class="hugetextarea">#inp#</textarea>


	If you have a formatted address, you can paste it in above and <input type="submit" value="break input into components">

	<cfif len(inp) is 0>
		<br>no input...
	</cfif>
	<cfif len(inp) gt 0 and isjson(inp)>
		<br>got JSON...
		<cfset jinp=DeserializeJSON(inp)>
		<cfdump var=#jinp#>
		<cfif StructKeyExists(jinp, "first_name")>
			<cfset b.first_name=jinp.first_name>
		</cfif>
		<cfif StructKeyExists(jinp, "last_name")>
			<cfset b.last_name=jinp.last_name>
		</cfif>
		<cfif StructKeyExists(jinp, "middle_initial")>
			<cfset b.middle_initial=jinp.middle_initial>
		</cfif>
		<cfif StructKeyExists(jinp, "email")>
			<cfset b.email=jinp.email>
		</cfif>
		<cfif StructKeyExists(jinp, "organization")>
			<cfset b.organization=jinp.organization>
		</cfif>
		<cfif StructKeyExists(jinp, "department")>
			<cfset b.department=jinp.department>
		</cfif>
		<cfif StructKeyExists(jinp, "position")>
			<cfset b.position=jinp.position>
		</cfif>
		<cfif StructKeyExists(jinp, "phone")>
			<cfset b.phone=jinp.phone>
		</cfif>
		<cfif StructKeyExists(jinp, "fax")>
			<cfset b.fax=jinp.fax>
		</cfif>
		<cfif StructKeyExists(jinp, "street")>
			<cfset b.street=jinp.street>
		</cfif>
		<cfif StructKeyExists(jinp, "city")>
			<cfset b.city=jinp.city>
		</cfif>
		<cfif StructKeyExists(jinp, "state_prov")>
			<cfset b.state_prov=jinp.state_prov>
		</cfif>
		<cfif StructKeyExists(jinp, "postal_code")>
			<cfset b.postal_code=jinp.postal_code>
		</cfif>
		<cfif StructKeyExists(jinp, "country")>
			<cfset b.country=jinp.country>
		</cfif>
	</cfif>




				<label for="first_name">first_name </label>
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


				<label for="position">position</label>
				<input type="text" name="position" id="position" value="#b.position#"  size="80" class="reqdClr">

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

<cfif isdefined("form.first_name")>
	<cfset j.first_name=form.first_name>
	<cfset j.last_name=form.last_name>
	<cfset j.middle_initial=form.middle_initial>
	<cfset j.email=form.email>
	<cfset j.organization=form.organization>
	<cfset j.department=form.department>
	<cfset j.phone=form.phone>
	<cfset j.street=form.street>
	<cfset j.state_prov=form.state_prov>
	<cfset j.postal_code=form.postal_code>
	<cfset j.country=form.country>


			<cfdump var=#j#>

			<cfset rslt=SerializeJSON(j)>

			<pre>#rslt#</pre>
			<input type="hidden" name="inp" value="#rslt#">
			<cfdump var=#rslt#>
</cfif>

			---->
			</form>
			</cfoutput>