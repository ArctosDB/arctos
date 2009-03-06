<cfinclude template="/includes/_header.cfm">

<cfform>
Art:
<cfinput type="text"
      name="name"
      autosuggest="cfc:agentName.lookupname({cfautosuggestvalue})">
</cfform>

<hr>


<form method="post" name="test" action="pickdemo.cfm">
	<label for="a">This is the text field</label>
	<input type="text" name="a" onchange="getAgent('b','a','test',this.value);">
	<label for="a">This is the ID field, and is normally hidden</label>
	<input type="text" name="b">
	<br><input type="submit">
</form>