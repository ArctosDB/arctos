<cfinclude template="/includes/_header.cfm">
<cfset title="Move a container">
<cfquery name="CTCOLL_OBJ_DISP" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP order by COLL_OBJ_DISPOSITION
</cfquery>
<cfquery name="ctcontainer_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
       select container_type from ctcontainer_type where container_type!='collection object' order by container_type
    </cfquery>
<style>
	.red {background-color:#FF0000; } .green {background-color:#00FF00; } .yellow {background-color:#FFFF00; }
</style>
<script>
	if ( !Date.prototype.toISOString ) {
  ( function() {

    function pad(number) {
      var r = String(number);
      if ( r.length === 1 ) {
        r = '0' + r;
      }
      return r;
    }

    Date.prototype.toISOString = function() {
      return this.getUTCFullYear()
        + '-' + pad( this.getUTCMonth() + 1 )
        + '-' + pad( this.getUTCDate() )
        + 'T' + pad( this.getUTCHours() )
        + ':' + pad( this.getUTCMinutes() )
        + ':' + pad( this.getUTCSeconds() )
        + '.' + String( (this.getUTCMilliseconds()/1000).toFixed(3) ).slice( 2, 5 )
        + 'Z';
    };

  }() );
}
	function moveThisOne() {
		$("#child_barcode").removeClass().addClass('red').attr('readonly', true);
		$("#child_barcode").removeClass().addClass('red').attr('readonly', true);

		jQuery.getJSON("/component/container.cfc",
			{
				method : "moveContainerLocation",
				barcode : $("#child_barcode").val(),
				parent_barcode : $("#parent_barcode").val(),
				newdisp: $("#newdisp").val(),
				olddisp: $("#olddisp").val(),
				childContainerType: $("#childContainerType").val(),
				parentContainerType: $("#parentContainerType").val(),
				new_h: $("#new_h").val(),
				new_w: $("#new_w").val(),
				new_l: $("#new_l").val(),
				returnformat : "json",
				queryformat : 'column'
			},
			moveThisOne_success
		);
	}
	function moveThisOne_success(result) {
		var date = new Date();
		var cdate=date.toISOString();

		var resAry = result.split("|");
		var status = resAry[0];
		var message = resAry[1];
		var theStatusBox = document.getElementById('result');
		var p = document.getElementById('parent_barcode');
		var c = document.getElementById('child_barcode');
		var currentStatus= theStatusBox.innerHTML;
		if (status == 'success') {
			document.getElementById('counter').innerHTML=parseInt(document.getElementById('counter').innerHTML)+1;
			theStatusBox.innerHTML = '<div class="green">[' + cdate + ']: ' + message + '</div>' + currentStatus;
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
			theStatusBox.innerHTML = '<div class="red">[' + cdate + ']: ' + newMess + '</div>' + currentStatus;
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
	function setContDim(h,w,l){
		$("#new_h").val(h);
		$("#new_w").val(w);
		$("#new_l").val(l);
	}
</script>
<cfoutput>
	<div class="infoBox" style="display:table;">
		<a href="batchScan.cfm">
			Batch Scan
		</a>
		is available if your network connection and this form cannot play nicely.
	</div>
	<form name="moveIt" onsubmit="moveThisOne(); return false;">
		<br>
		<label for="autoSubmit">
			Check to submit form when ChildBarcode changes (Set scanner to transmit a TAB after the barcode)
		</label>
		<input type="checkbox" name="autoSubmit" id="autoSubmit" />
		<div style="display:table;border:1px solid green;">
			<label for="newdisp">
				When child barcode contains a specimen part, update part disposition to....
			</label>
			<select name="newdisp" id="newdisp">
				<option value="">
					-do not update disposition-
				</option>
				<cfloop query="CTCOLL_OBJ_DISP">
					<option value="#COLL_OBJ_DISPOSITION#">
						#COLL_OBJ_DISPOSITION#
					</option>
				</cfloop>
			</select>
			<label for="olddisp">
				....only when current disposition is....
			</label>
			<select name="olddisp" id="olddisp">
				<option value="">
					-any value-
				</option>
				<cfloop query="CTCOLL_OBJ_DISP">
					<option value="#COLL_OBJ_DISPOSITION#">
						#COLL_OBJ_DISPOSITION#
					</option>
				</cfloop>
			</select>
		</div>
		<div style="border:2px solid red;">
			<strong>
				Use with caution. Updating individual container type is dangerous.
			</strong>
			<label for="parentContainerType">
				Force-Change Parent Container to type....
			</label>
			<select name="parentContainerType" id="parentContainerType" size="1">
				<option value="">
					change nothing
				</option>
				<cfloop query="ctcontainer_type">
					<option value="#container_type#">
						#container_type#
					</option>
				</cfloop>
			</select>
			<label for="childContainerType">
				Force-Change Child Container to type....
			</label>
			<select name="childContainerType" id="childContainerType" size="1">
				<option value="">
					change nothing
				</option>
				<cfloop query="ctcontainer_type">
					<option value="#container_type#">
						#container_type#
					</option>
				</cfloop>
			</select>
			<div style="border:1px solid green; padding:.5em;margin:.5em;">
				<label for="new_h">
					On save, when
					<ul>
						<li>"force-change Parent Container" is "freezer box", and </li>
						<li>ALL of (H, W, L) are provided</li>
					</ul>
					Change parent container	dimensions to....
				</label>
				<table border>
					<tr>
						<td>H</td>
						<td>W</td>
						<td>L</td>
					</tr>
					<tr>
						<td><input type="number" id="new_h" name="new_h" placeholder="H"></td>
						<td><input type="number" id="new_w" name="new_w" placeholder="W"></td>
						<td><input type="number" id="new_l" name="new_l" placeholder="H"></td>
					</tr>
				</table>

				<br><span class="likeLink" onclick="setContDim('5','13','13');">Set dimensions to (5,13,13)</span>
				<br><span class="likeLink" onclick="setContDim('7','13','13');">Set dimensions to (7,13,13)</span>
				<br><span class="likeLink" onclick="setContDim('','','');">reset dimensions</span>
			</div>
		</div>
		Containers Moved:
		<span id="counter" style="background-color:green">
			0
		</span>
		<table>
			<tr>
				<input type="hidden" name="action" value="moveIt">
				<td>
					<label for="parent_barcode">
						Parent Barcode
					</label>
					<input type="text" name="parent_barcode" id="parent_barcode" autofocus>
				</td>
				<td>
					<label for="child_barcode">
						Child Barcode
					</label>
					<input type="text" name="child_barcode" id="child_barcode" onchange="autosubmit();">
				</td>
				<td>
					<label for="">
						&nbsp;
					</label>
					<input type="button" onclick="moveThisOne()" value="Move Container" class="savBtn">
				</td>
				<td>
					<label for="">
						&nbsp;
					</label>
					<input type="reset" value="Clear Form" class="clrBtn">
				</td>
			</tr>
		</table>
	</form>
	<div id="result">
	</div>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
