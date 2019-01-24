
<cfoutput>
<form name="x">
	<label for="inp" value="Input"></label>
	<textarea name="inp" class="hugetextarea"></textarea>
	
	If you have a formatted address, you can paste it in above and <input type="button" value="break input into components">
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
			</form>
			</cfoutput>