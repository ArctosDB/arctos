<cfinclude template="/includes/_header.cfm">
<script>
function addEvent(obj, evType, fn){ 
 if (obj.addEventListener){ 
   obj.addEventListener(evType, fn, false); 
   return true; 
 } else if (obj.attachEvent){ 
   var r = obj.attachEvent("on"+evType, fn); 
   return r; 
 } else { 
   return false; 
 } 
}

/***************************************************************************************
var elem = document.getElementById('uploadMedia');
var listener = addEventListener(elem, 'click', function() {
    alert('You clicked me!');
});
******/
</script>
<cfif #action# is "newMedia">
	<cfoutput>
		<form name="newMedia" method="post" action="media.cfm">
			<input type="hidden" name="action" value="saveNew">
			<label for="media_uri">Media URI</label>
			<input type="text" name="media_uri" id="media_uri" size="50"><span class="infoLink" id="uploadMedia">Upload</span>
		</form>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">