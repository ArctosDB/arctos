<!--- no security --->
<cfinclude template="../includes/_pickHeader.cfm">
<script src="/includes/dropzone.js"></script>
<link rel="stylesheet" href="/includes/dropzone.css">

<script>
$(document).ready(function() {

	//Dropzone.autoDiscover = false;

Dropzone.options.myDropzone = {

  // Prevents Dropzone from uploading dropped files immediately
  autoProcessQueue: false,

  init: function() {
    var submitButton = document.querySelector("#submit-all")
        myDropzone = this; // closure

    submitButton.addEventListener("click", function() {
      myDropzone.processQueue(); // Tell Dropzone to process all queued files.
    });

    // You might want to show the submit button only when
    // files are dropped here:
    this.on("addedfile", function() {
      // Show submit button here and/or inform user to click it.
    });

  }
};
});


</script>

<cfoutput>
	<hr>Existing Media for this specimen
	collection_object_id: #collection_object_id#
	<cfquery name="em" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			*
		from
			media_relations,
			media,
			media_labels
		where
			media_relations.media_id=media.media_id and
			media.media_id=media_labels.media_id  (+) and
			media_relations.media_relationship='shows cataloged_item' and
			media_relations.related_primary_key=#collection_object_id#
	</cfquery>
	<cfdump var=#em#>

</cfoutput>

<hr>Upload Media Files
<button id="submit-all">Submit all files</button>
<form action="/component/utilities.cfc?method=loadFile&returnFormat=json" class="dropzone" id="my-dropzone"></form>



 <cfif not isdefined("collection_object_id")>
	Didn't get a collection_object_id.<cfabort>
</cfif>
load some media yo!
<p>
	<hr>Link specimen to existing Arctos Media
	<span class="likeLink" onclick="findMedia('media_id','media_uri');">Click here to pick</span>.




<!----
<form action="/component/utilities.cfc?method=loadFile&returnFormat=json" class="dropzone" id="demo-upload">

  <div class="dz-message">
    Drop files here or click to upload.<br />
    <span class="note">(This is just a demo dropzone. Selected files are <strong>not</strong> actually uploaded.)</span>
  </div>

</form>

<form name="m">
	<input type="text" name="media_uri" id="media_uri">
	<input type="text" name="media_id" id="media_id">
</form>
---->
</p>

<cfinclude template="../includes/_pickFooter.cfm">