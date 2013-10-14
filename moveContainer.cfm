<cfinclude template="/includes/_header.cfm">
<cfset title="Move a container">
<cfquery name="CTCOLL_OBJ_DISP" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP order by COLL_OBJ_DISPOSITION
</cfquery>

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

		var newdisp = document.getElementById('newdisp');
		var olddisp = document.getElementById('olddisp');

		p.className='red';
		p.setAttribute('readonly','readonly');
		c.className='red';
		c.setAttribute('readonly','readonly');
		var barcode = c.value;
		var parent_barcode = p.value;
		jQuery.getJSON("/component/container.cfc",
			{
				method : "moveContainerLocation",
				barcode : barcode,
				parent_barcode : parent_barcode,
				newdisp: newdisp,
				olddisp: olddisp,
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
		var currentStatus= theStatusBox.innerHTML;
		if (status == 'success') {
			document.getElementById('counter').innerHTML=parseInt(document.getElementById('counter').innerHTML)+1;
			theStatusBox.innerHTML = '<div class="green">' + message + '</div>' + currentStatus;
			c.removeAttribute('readonly');
			p.removeAttribute('readonly');
			c.className='';
			p.className ='';
			c.value='';
			c.focus();
		} else {
			c.removeAttribute('readonly');
			p.removeAttribute('readonly');
			c.className='yellow';
			p.className ='yellow';
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
	
		function autosubmit() {
			var theCheck =  document.getElementById('autoSubmit');
			var isChecked = theCheck.checked;
			if (isChecked == true) {
				moveThisOne();
			}
		}
</script>
<cfoutput>
	<form name="moveIt" onsubmit="moveThisOne(); return false;">

<table border>
	<tr>
		<td colspan="2">
			<label for="autoSubmit">Check to submit form when ChildBarcode changes</label>
			<input type="checkbox" name="autoSubmit" id="autoSubmit" />
		</td>
	</tr>
	<tr>
		<td align="right">
			<label for="newdisp">When child barcode contains a specimen part, update part disposition to....</label>
			<select name="newdisp" id="newdisp">
				<option value="">-do not update disposition-</option>
				<cfloop query="CTCOLL_OBJ_DISP">
					<option value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
				</cfloop>
			</select>
		</td>
			<td align="right">

			<label for="olddisp">When current disposition is....</label>
			<select name="olddisp" id="olddisp">
				<option value="">-any value-</option>
				<cfloop query="CTCOLL_OBJ_DISP">
					<option value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
				</cfloop>
			</select>
		</td>
	</tr>
</table>

		
Containers Moved:<span id="counter" style="background-color:green">0</span>
<table>
	<tr>
		<input type="hidden" name="action" value="moveIt">
		<td>
			<label for="parent_barcode">Parent Barcode</label>
			<input type="text" name="parent_barcode" id="parent_barcode" autofocus>
		</td>
		<td>
			<label for="child_barcode">Child Barcode</label>
		  	<input type="text" name="child_barcode" id="child_barcode" onchange="autosubmit();">
		</td>
		<td>
			<label for="">&nbsp;</label>
			<input type="button" onclick="moveThisOne()" value="Move Container" class="savBtn">
		</td>
		<td>
			<label for="">&nbsp;</label>
			<input type="reset" value="Clear Form" class="clrBtn">
		</td>
</tr>
</table>
	</form>

<div id="result">
</div>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">