<SCRIPT LANGUAGE="Javascript">
	setTimeout("startClock()", 50000);
	function startClock() {
		//alert("BOOM");
		var theIFrame = document.getElementById('bulkyFrameThingy');
		theIFrame.src='Bulkloader.cfm?action=loadData';
		setTimeout("startClock()", 50000);
	}
</SCRIPT>
Welcome to the bulkloader-loader-loader - errr, something.

Here's the scoop:
<p>
Bulkloading is slow. The queries time out. Users complain. This page uses magic (also known as JavaScript) to reload the bit that times out. The actual bulkloading process usually keeps running in the background. Don't believe everything you see in the results window. Ignore <code>Macromedia][Oracle JDBC Driver][Oracle]ORA-00001: unique constraint (UAM.PKEY_COLL_OBJECT) violated</code> errors in the top frame. Just let it run.
</p>
<div id="bulkloaderGoedHere">
<cfset action="loadData">
<iframe height="300" id="bulkyFrameThingy" width="100%" scrolling="auto" frameborder="1" src="Bulkloader.cfm?action=loadData"></iframe>
</div>
<div id="resultsDiv" style="border:2px solid red;">
Results go here....

</div>
