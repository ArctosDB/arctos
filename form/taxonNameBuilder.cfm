<script src="/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js" language="javascript" type="text/javascript"></script>
	
<script>
		jQuery(document).ready(function() {
			jQuery("#t1").autocomplete("/ajax/scientific_name.cfm", {
				width: 320,
				max: 50,
				autofill: false,
				multiple: false,
				scroll: true,
				scrollHeight: 300,
				matchContains: true,
				minChars: 1,
				selectFirst:false
			});
			
			$( "#theForm" ).submit(function( event ) {
				event.preventDefault();

				console.log('hello');
				
			});
			$( "#taxa_formula" ).change(function() {
				var formula=$("#taxa_formula").val();
				var theInp='';

				if (formula=='A' || formula=='A ?' || formula=='A aff.' || formula=='A cf.' || formula=='A ssp.' || formula=='A cspf.'){
					// just create a pick
					theInp='<label for="ti">Taxon Name</label><input type="text" name="t1" class="reqdClr" size="40" id="t1">';
					theInp+='<input type="button" onclick="taxaPickIdentification(\'nothing\',\'t1\',\'theForm\',$(\'#t1\').val())" value="pick">';
					taxaPickIdentification('nothing','t1','theForm',$('#t1').val());
				
} else if (formula=='A / B intergrade' || formula=='A and B' || formula=='A x B' || formula=='A or B' ||){

} else if (formula=='A {string}'){

					// just create a pick
				} else {
					alert('That taxa formula is not handled. File a bug report.');
				}
				$("#btfh").html(theInp);
			});

		});
		
	</script>

	<cfoutput>
		<cfquery name="cttaxa_formula" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select taxa_formula,DESCRIPTION from cttaxa_formula order by taxa_formula
	    </cfquery>
	    <p>
	    	Build a Taxon Name
	    </p>
		<form name="theForm" id="theForm">
			<input type="hidden" name="nothing" id="nothing">
			
			<label for="taxa_formula">Pick a Formula to get started</label>
			<select name="taxa_formula" id="taxa_formula" size="1"  required>
				<option value=""></option>
				<cfloop query="cttaxa_formula">
					<option value="#cttaxa_formula.taxa_formula#">#cttaxa_formula.taxa_formula#</option>
				</cfloop>
			</select>
			<div id="dt1">
				<label for="ti">Taxon Name A</label>
				<input type="text" name="t1" class="reqdClr" size="40" id="t1">
			</div>
			<input type="submit" value="Save To Form">
		</form>
		<hr>Documentation
		<div style="width: 600px;height:400px; overflow:scroll;">
		<table border width="100%">
			<tr>
				<th>Taxa_Formula</th>
				<th>Documentation</th>
			</tr>
			<cfloop query="cttaxa_formula">
				<tr>
					<td>#taxa_formula#</td>
					<td>#DESCRIPTION#</td>
				</tr>
			</cfloop>
		</table>
		</div>
	</cfoutput>
