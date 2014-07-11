	<script>
		jQuery(document).ready(function() {
			
			
			$( "#theForm" ).submit(function( event ) {
				event.preventDefault();

console.log('hello');
				
		});


		$( "#taxa_formula" ).change(function() {
alert( "Handler for .change() called." );
});


		function pattrChg(i){
			if ($("#part_attribute_type_" + i).val().length > 0) {
				$("#part_attribute_value_" + i).addClass('reqdClr').prop('required',true);
			} else {
				
				$("#part_attribute_value_" + i).removeClass().prop('required',false);
			}
		}
	</script>

	<cfoutput>
		<cfquery name="cttaxa_formula" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select taxa_formula from cttaxa_formula group by taxa_formula order by taxa_formula
	    </cfquery>
	    <label for="theForm"></label>Add Specimen Part</label>
		<form name="theForm" id="theForm">
			<label for="taxa_formula">Pick a Formula to get started</label>
			<select name="taxa_formula" id="taxa_formula" size="1"  required>
				<cfloop query="cttaxa_formula">
					<option value="#cttaxa_formula.taxa_formula#">#cttaxa_formula.taxa_formula#</option>
				</cfloop>
			</select>
		
			<input type="submit" value="Save To Form">
		</form>
	</cfoutput>
