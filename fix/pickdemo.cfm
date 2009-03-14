<cfinclude template="/includes/_header.cfm">
<script type='text/javascript' src='/includes/checkForm.js'></script>
<cfif action is "nothing">
<cfoutput>
<form method="post" name="test" id="test" action="pickdemo.cfm">
	<input type="hidden" name="action" value="#action#">
	<input type="hidden" name="save" value="true">
	
	<label for="a">This is the text field</label>
	<input type="text" name="a" id="a"  onchange="getAgent('a_id','a','test',this.value);" class="reqdClr">
	<input type="text" name="a_id" id="a_id" class="reqdClr">
	
	<label for="a1">This is the text field</label>
	
	<input type="text" name="a1" id="a1"  class="reqdClr">


	<label for="a3">This is the text field</label>
	<input type="text" name="a3" id="a3"  onchange="getAgent('a3_id','a3','test',this.value);" class="reqdClr">
	<input type="text" name="a3_id" id="a3_id" class="reqdClr red">


	
	<br><input type="submit" id="test_submit" title="submit" value="submit">
</form>

<cfif isdefined("save") and save is true>
<script>
	var bgDiv=document.createElement('div');
	bgDiv.id='bgDiv';
	bgDiv.className='bgDiv';
	document.body.appendChild(bgDiv);
</script>
	<cfquery datasource="uam_god" name="data">
		SELECT agent_name,agent_id
		FROM agent_name
		WHERE upper(agent_name) LIKE ('#ucase(a)#%')
		ORDER BY agent_name
	</cfquery>
	<div class="saver">
	<cfif data.recordcount is 1>
		saving....
	<cfelse>
		pick thingee.....
		<cfdump var=#form#>
	</cfif>
	</div>
</cfif>
</cfoutput>
</cfif>