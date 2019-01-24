	<cfinclude template="/includes/alwaysInclude.cfm">
<script>
	function breakInputUp(){
		$(':input','#x').not(':button, :submit, :reset, :hidden').val('');
		var inp=$("#inp").val();
		var j=$.parseJSON(inp);
		var lk;
		$.each(j, function(key, value){
		    lk=key.toLowerCase();
		    if ($('#' + lk).length){
		    	$('#' + lk).val(value);
		    } else {
		    	$('#perr').append('<div>Unable to handle ' + key + '; proceed with caution</div>');
		    }
		});
	}
	function form2json(){
		var fd=$( "#x" ).serializeArray() ;
		var json = {};
		jQuery.each(fd, function() {
	        json[this.name] = this.value || '';
	    });
		var jsonstr=JSON.stringify(json);
    	$('#r_inp').val(jsonstr);
		var str = JSON.stringify(json, null, 2);
		$("#jdp").html('<pre>' + str + '</pre>');
	}
</script>
<cfoutput>
	<p>
		This form helps manage and format addresses as JSON. These are used by the GenBank packager and various other components. "Standard" fields are handled;
		any JSON can be used as an address, but this form won't help.
	</p>
	<label for="inp" value="Paste an existing address here"></label>
	<textarea name="inp" id="inp"  class="hugetextarea"></textarea>
	<input type="button" onclick="breakInputUp()" value="Click here"> to break a pasted-in address into components which can be edited.
	<p>
		<div id="perr"></div>
	</p>
	<form name="x" id="x" method="post" action="formatted_address.cfm">
		<label for="first_name">first_name </label>
		<input type="text" name="first_name" id="first_name" size="80" >

		<label for="last_name">last_name</label>
		<input type="text" name="last_name" id="last_name" size="80" >

		<label for="middle_initial">middle_initial</label>
		<input type="text" name="middle_initial" id="middle_initial"  size="80">

		<label for="email">email</label>
		<input type="text" name="email" id="email"  size="80">

		<label for="organization">organization</label>
		<input type="text" name="organization" id="organization"  size="80">

		<label for="department">department</label>
		<input type="text" name="department" id="department"  size="80">


		<label for="position">position</label>
		<input type="text" name="position" id="position"  size="80">

		<label for="phone">phone</label>
		<input type="text" name="phone" id="phone"  size="80">

		<label for="fax">fax</label>
		<input type="text" name="fax" id="fax" size="80" size="80">

		<label for="street">street</label>
		<input type="text" name="street" id="street" size="80">

		<label for="city">city</label>
		<input type="text" name="city" id="city"  size="80">

		<label for="state_prov">state_prov</label>
		<input type="text" name="state_prov" id="state_prov"  size="80">

		<label for="postal_code">postal_code</label>
		<input type="text" name="postal_code" id="postal_code"  size="80">

		<label for="country">country</label>
		<input type="text" name="country" id="country"  size="80">
		<p>
			<input type="button" onclick="form2json()" value="create JSON from form components">
		</p>
	</form>
	<label for="r_inp">After clicking the button, you can copy and paste the JSON from this box.</label>
	<textarea name="r_inp" class="hugetextarea" id="r_inp"></textarea>
	<p>
		Formatted JSON view:
	</p>
	<div style="border:2px solid red;margin:1em;border:1em;" id="jdp"></div>
</cfoutput>