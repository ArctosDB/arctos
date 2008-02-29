<cfinclude template="/includes/_header.cfm">
<script>
__eventListeners = [];

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
    var event = {
	instance: instance,
	name: eventName,
	listener: listenerFn
    };
    __eventListeners.push(event);
    return event;
}

function removeEventListener(event) {
    var instance = event.instance;
    if (instance.removeEventListener) {
	instance.removeEventListener(event.name, event.listener, false);
    } else if (instance.detachEvent) {
	instance.detachEvent("on" + event.name, event.listener);
    }
    for (var i = 0; i < __eventListeners.length; i++) {
	if (__eventListeners[i] == event) {
	    __eventListeners.splice(i, 1);
	    break;
	}
    }
}

function unregisterAllEvents() {
    while (__eventListeners.length > 0) {
	removeEventListener(__eventListeners[0]);
    }
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