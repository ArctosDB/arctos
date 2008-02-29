<cfinclude template="/includes/_header.cfm">
<script>
function ahah(url, target, delay) {
  var req;
  document.getElementById(target).innerHTML = 'Fetching Data...';
  if (window.XMLHttpRequest) {
    req = new XMLHttpRequest();
  } else if (window.ActiveXObject) {
  	//alert('ms');
    req = new ActiveXObject("Microsoft.XMLHTTP");
  }
  if (req != undefined) {
    req.onreadystatechange = function() {ahahDone(req, url, target, delay);};
    req.open("GET", url, true);
    req.send("");
  }
}  

function ahahDone(req, url, target, delay) {
  if (req.readyState == 4) { // only if req is "loaded"
    if (req.status == 200) { // only if "OK"
      document.getElementById(target).innerHTML = req.responseText;
    } else {
      document.getElementById(target).innerHTML="ahah error:\n"+req.statusText;
    }
    if (delay != undefined) {
       setTimeout("ahah(url,target,delay)", delay); // resubmit after delay
	    //server should ALSO delay before responding
    }
  }
}
function closeUpload(media_uri) {
	var theDiv = document.getElementById('uploadDiv');
	document.body.removeChild(theDiv);
	document.getElementById('media_uri').value=media_uri;
}
function clickUpload(){
	var theDiv = document.createElement('iFrame');
	theDiv.id = 'uploadDiv';
	theDiv.name = 'uploadDiv';
	theDiv.className = 'uploadMediaDiv';
	document.body.appendChild(theDiv);
	var guts = "/info/upMedia.cfm";
	theDiv.src=guts;
	--ahah(guts,'uploadDiv');
}
</script>
<cfif #action# is "newMedia">
	
	<cfoutput>
		<form name="newMedia" method="post" action="media.cfm">
			<input type="hidden" name="action" value="saveNew">
			<label for="media_uri">Media URI</label>
			<input type="text" name="media_uri" id="media_uri" size="50"><span class="infoLink" id="uploadMedia">Upload</span>
		</form>
	</cfoutput>
	<script>
		var elem = document.getElementById('uploadMedia');
		elem.addEventListener('click',clickUpload,false);
	</script>
</cfif>
<cfinclude template="/includes/_footer.cfm">