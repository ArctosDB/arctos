<cfinclude template="/includes/_frameHeader.cfm">
<cfif #action# is "nothing">
	<form name="uploadFile" method="post" action="upMedia.cfm">
		<input type="hidden" name="action" value="getFile">
		  <label for="FiletoUpload">Browse...</label>
		  <input type="file" name="FiletoUpload" id="FiletoUpload" size="45">
   
      <input type="submit" 
				value="Upload" 
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'"
				onmouseout="this.className='savBtn'">
	<input type="button" 
				value="Cancel" 
				class="qutBtn"
				onmouseover="this.className='qutBtn btnhov'"
				onmouseout="this.className='qutBtn'"
				onclick="closeUpload()">
	</form>
</cfif>