<!--- no security --->
<cfinclude template="../includes/_pickHeader.cfm">
<script src="/includes/dropzone.js"></script>
<link rel="stylesheet" href="/includes/dropzone.css">

<script>

	 function fileSelected() {
        var file = document.getElementById('fileToUpload').files[0];
        if (file) {
          var fileSize = 0;
          if (file.size > 1024 * 1024)
            fileSize = (Math.round(file.size * 100 / (1024 * 1024)) / 100).toString() + 'MB';
          else
            fileSize = (Math.round(file.size * 100 / 1024) / 100).toString() + 'KB';

          document.getElementById('fileName').innerHTML = 'Name: ' + file.name;
          document.getElementById('fileSize').innerHTML = 'Size: ' + fileSize;
          document.getElementById('fileType').innerHTML = 'Type: ' + file.type;
        }
      }

      function uploadFile() {
        var fd = new FormData();
        fd.append("fileToUpload", document.getElementById('fileToUpload').files[0]);
        var xhr = new XMLHttpRequest();
        xhr.upload.addEventListener("progress", uploadProgress, false);
        xhr.addEventListener("load", uploadComplete, false);
        xhr.addEventListener("error", uploadFailed, false);
        xhr.addEventListener("abort", uploadCanceled, false);
        xhr.open("POST", "/component/utilities.cfc?method=loadFile&returnFormat=json");
        xhr.send(fd);
      }

      function uploadProgress(evt) {
        if (evt.lengthComputable) {
          var percentComplete = Math.round(evt.loaded * 100 / evt.total);
          document.getElementById('progressNumber').innerHTML = percentComplete.toString() + '%';
        }
        else {
          document.getElementById('progressNumber').innerHTML = 'unable to compute';
        }
      }

      function uploadComplete(evt) {
        /* This event is raised when the server send back a response */
        alert(evt.target.responseText);
      }

      function uploadFailed(evt) {
        alert("There was an error attempting to upload the file.");
      }

      function uploadCanceled(evt) {
        alert("The upload has been canceled by the user or the browser dropped the connection.");
      }



</script>

<cfoutput>
	<hr>Existing Media for this specimen
	collection_object_id: #collection_object_id#
	<cfquery name="smed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select distinct
			media.media_id,
			media.MEDIA_URI,
			media.MIME_TYPE,
			media.MEDIA_TYPE,
			media.PREVIEW_URI,
			media.MEDIA_LICENSE_ID,
			media.MEDIA_URI,
			ctmedia_license.DISPLAY,
			ctmedia_license.DESCRIPTION,
			ctmedia_license.URI
		from
			media_relations,
			media,
			ctmedia_license
		where
			media_relations.media_relationship='shows cataloged_item' and
			media_relations.related_primary_key=#collection_object_id# and
			media_relations.media_id=media.media_id and
			media.MEDIA_LICENSE_ID=ctmedia_license.MEDIA_LICENSE_ID (+)
		order by
			media_id
	</cfquery>
	<!----

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


			---->
	<cfset  func = CreateObject("component","component.functions")>

	<cfloop query="smed">
		<cfset relns=func.getMediaRelations(media_id=#media_id#)>

<cfdump var=#relns#>

		 MEDIA_RELATIONS_ID						   NOT NULL NUMBER
 MEDIA_ID							   NOT NULL NUMBER
 MEDIA_RELATIONSHIP						   NOT NULL VARCHAR2(40)
 CREATED_BY_AGENT_ID						   NOT NULL NUMBER
 RELATED_PRIMARY_KEY						   NOT NULL NUMBER

UAM@ARCTEST> desc media_labels
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 MEDIA_LABEL_ID 						   NOT NULL NUMBER
 MEDIA_ID							   NOT NULL NUMBER
 MEDIA_LABEL							   NOT NULL VARCHAR2(255)
 LABEL_VALUE							   NOT NULL VARCHAR2(4000)
 ASSIGNED_BY_AGENT_ID						   NOT NULL NUMBER




		<div>
			<br>media_id: #media_id#
			<br>MEDIA_URI: #MEDIA_URI#
			<br>MIME_TYPE: #MIME_TYPE#
			<br>MEDIA_TYPE: #MEDIA_TYPE#
			<br>PREVIEW_URI: #PREVIEW_URI#
			<br>MEDIA_LICENSE_ID: #MEDIA_LICENSE_ID#
			<br>MEDIA_URI: #MEDIA_URI#
			<br>DISPLAY: #DISPLAY#
			<br>DESCRIPTION: #DESCRIPTION#
			<br>URI: #URI#
		</div>

	</cfloop>

</cfoutput>

<hr>Upload Media Files


 <form id="form1" enctype="multipart/form-data" method="post" action="">
    <div class="row">
      <label for="fileToUpload">Select a File to Upload</label><br />
      <input type="file" name="fileToUpload" id="fileToUpload" onchange="fileSelected();"/>
    </div>
    <div id="fileName"></div>
    <div id="fileSize"></div>
    <div id="fileType"></div>
    <div class="row">
      <input type="button" onclick="uploadFile()" value="Upload" />
    </div>
    <div id="progressNumber"></div>
	bla type stuff
	<input type="text" name="t" id="t" placeholder="typestuff">
  </form>

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