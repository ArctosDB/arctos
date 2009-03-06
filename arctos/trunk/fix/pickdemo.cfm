<cfinclude template="/includes/_header.cfm">


<cfif action is "nothing">
<cfoutput>
<form method="post" name="test" action="pickdemo.cfm">
	<input type="hidden" name="action" value="#action#">
	<input type="hidden" name="save" value="true">
	<label for="a">This is the text field</label>
	<input type="text" name="a">
	<label for="a">This is the ID field, and is normally hidden</label>
	<input type="text" name="b">
	<br><input type="submit">
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
	<div style="border:2px solid red; width:600px; height:400px; left:50px;top:50px;position:absolute;z-index:2001;">
	<cfif data.recordcount is 1>
		saving....
	<cfelse>
		pick thingee.....
	</cfif>
	</div>
</cfif>
</cfoutput>
</cfif>