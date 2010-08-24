<cfinclude template="/includes/_header.cfm">
<cfset title="Move a container">
<style>
	.red {background-color:#FF0000;
	}
	.green {background-color:#00FF00;
	}
	.yellow {background-color:#FFFF00;
	}
	
</style>
<script>
	function moveThisOne() {
		var p = document.getElementById('parent_barcode');
		var c = document.getElementById('child_barcode');
		var t = document.getElementById('timestamp');
		p.className='red';
		p.setAttribute('readonly','readonly');
		c.className='red';
		c.setAttribute('readonly','readonly');
		t.className='red';
		t.setAttribute('readonly','readonly');
		var barcode = c.value;
		var parent_barcode = p.value;
		var timestamp = t.value;
		jQuery.getJSON("/component/container.cfc",
			{
				method : "moveContainerLocation",
				barcode : barcode,
				parent_barcode : parent_barcode,
				timestamp : timestamp,
				returnformat : "json",
				queryformat : 'column'
			},
			moveThisOne_success
		);
	}
	function moveThisOne_success(result) {
		var resAry = result.split("|");
		var status = resAry[0];
		var message = resAry[1];
		var theStatusBox = document.getElementById('result');
		var p = document.getElementById('parent_barcode');
		var c = document.getElementById('child_barcode');
		var t = document.getElementById('timestamp');
		var currentStatus= theStatusBox.innerHTML;
		if (status == 'success') {
			document.getElementById('counter').innerHTML=parseInt(document.getElementById('counter').innerHTML)+1;
			theStatusBox.innerHTML = '<div class="green">' + message + '</div>' + currentStatus;
			c.removeAttribute('readonly');
			t.removeAttribute('readonly');
			p.removeAttribute('readonly');
			c.className='';
			p.className ='';
			t.className='';
			c.value='';
			c.focus();
		} else {
			c.removeAttribute('readonly');
			t.removeAttribute('readonly');
			p.removeAttribute('readonly');
			c.className='yellow';
			p.className ='yellow';
			t.className='yellow';
			var isChild = message.indexOf('Child');
			var isParent = message.indexOf('Parent');	
			if (isChild > -1) {
				var theChildBarcode = document.getElementById('child_barcode').value;
				var newMess = '<a href="/EditContainer.cfm?action=newContainer&barcode=' + theChildBarcode + '">' + message + "</a>";
			} else if (isParent > -1) {
				var theParentBarcode = document.getElementById('parent_barcode').value;
				var newMess = '<a href="/EditContainer.cfm?action=newContainer&barcode=' + theParentBarcode + '">' + message + "</a>";
			} else {
				var newMess = message;
			}
			theStatusBox.innerHTML = '<div class="red">' + newMess + '</div>' + currentStatus;
			p.focus();
		}
	}
		function setNow() {
			var thisdate = new Date();
			var y = thisdate.getFullYear();
			var m = thisdate.getMonth() + 1;
			var d = thisdate.getDate();
			var h = thisdate.getHours();
			var mi = thisdate.getMinutes();
			var s = "00";
			var theDateElement = document.getElementById('timestamp');
			months=new Array("01","02","03","04","05","06","07","08","09","10","11","12");
			var Mon = months[m-1];
			var td = y + '-' + Mon + '-' + d  + ' ' + h+ ':' + mi + ':' + s;
			theDateElement.value=td;
		}
		function autosubmit() {
			var theCheck =  document.getElementById('autoSubmit');
			var isChecked = theCheck.checked;
			if (isChecked == true) {
				moveThisOne();
			}
		}
</script>
<cfoutput>
Containers Moved:<span id="counter" style="background-color:green">0</span>
<table>
	<tr>
	<form name="moveIt" onsubmit="moveThisOne(); return false;">
		<input type="hidden" name="action" value="moveIt">
		<td>
			<label for="parent_barcode">Parent Barcode</label>
			<input type="text" name="parent_barcode" id="parent_barcode">
		</td>
		<td>
			<label for="child_barcode">Child Barcode</label>
		  	<input type="text" name="child_barcode" id="child_barcode" onchange="autosubmit();">
		</td>		
		<td>
			<label for="timestamp">Timestamp <img src="/images/clock.gif" class="likeLink" onclick="setNow();" /></label>
			<input type="text" name="timestamp" id="timestamp">
		</td>
		<td>
			<label for="">&nbsp;</label>
			<input type="submit" 
				value="Move Container" 
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'"
				onmouseout="this.className='savBtn'">
		</td>
		<td>
			<label for="">&nbsp;</label>
			<input type="reset" 
				value="Clear Form" 
				class="clrBtn"
				onmouseover="this.className='clrBtn btnhov'"
				onmouseout="this.className='clrBtn'">
		</td>
		<td align="right">
			<label for="autoSubmit">Submit on Child Change</label>
			<input type="checkbox" name="autoSubmit" id="autoSubmit" />
		</td>		
	</form>
</tr>
</table>
<div id="result">
</div>
<script>
	setNow();
</script>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
