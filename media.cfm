<cfinclude template="/includes/_header.cfm">
<script>
function addEventListener(instance, eventName, listener) {
    var listenerFn = listener;
    if (instance.addEventListener) {
        instance.addEventListener(eventName, listenerFn, false);
    } else if (instance.attachEvent) {
        listenerFn = function() {
            listener(window.event);
        }
        instance.attachEvent("on" + eventName, listenerFn);
    } else {
        throw new Error("Event registration not supported");
    }
    return {
        instance: instance,
        name: eventName,
        listener: listenerFn
    };
}

function removeEventListener(event) {
    var instance = event.instance;
    if (instance.removeEventListener) {
        instance.removeEventListener(event.name, event.listener, false);
    } else if (instance.detachEvent) {
        instance.detachEvent("on" + event.name, event.listener);
    }
}
/*********************************************************************************/
function clickUpload(){
	alert('clicky!');
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
		var listener = addEventListener(elem, "click", clickUpload());
	</script>
</cfif>
<cfinclude template="/includes/_footer.cfm">