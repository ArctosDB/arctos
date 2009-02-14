<cfquery name="isGoodUser" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select count(*) as cnt from 
	 group_member m,
	 agent_name ln,
	 agent_name gn
	 where
	 m.GROUP_AGENT_ID = gn.agent_id and
	 gn.agent_name = 'DGR Users' and
	 ln.agent_id = m.MEMBER_AGENT_ID and
	 ln.agent_name_type = 'login' and
	 ln.agent_name = '#session.username#'
</cfquery>
<cfif isGoodUser.cnt lt 1>
	You are not allowed to access this form.
	<cfabort>
</cfif>

<cfinclude template="/includes/_header.cfm">
<script>
	function hideRow(locator_id) {
		var theRowStr = "document.getElementById('row" + locator_id + "')";
		var theRow = eval(theRowStr);
		theRow.style.display = 'none';
	}
	function goPreviousBox () {
		var theFreezer = document.getElementById('freezer').value;
		var theRack = document.getElementById('rack').value;
		var theBox = document.getElementById('box'.value);
		
		alert('go prev');
	}
	function goNextBox () {
		alert('go next');
	}
	
	function IsNumeric(sText) {
		var ValidChars = "0123456789.";
	   	var IsNumber=true;
   		var Char;
	   for (i = 0; i < sText.length && IsNumber == true; i++) { 
			Char = sText.charAt(i); 
	      if (ValidChars.indexOf(Char) == -1) 
    	     {
        	 IsNumber = false;
         	}
      	}
   		return IsNumber;
   }
   
   function saveNewTiss(place) {
		//alert('savnew');
		//alert(place);
		var theNkId = 'nk'  + place;
		var theTissId = 'tiss' + place;
		var theNK = document.getElementById(theNkId);
		var theTiss = document.getElementById(theTissId);
		var nk = theNK.value;
		var tissue_type = theTiss.value;
		var freezer = document.getElementById('freezer').value;
		var rack = document.getElementById('rack').value;
		var box = document.getElementById('box').value;
		if (IsNumeric(nk)) {
			//alert('f: ' + freezer + ' r:' + rack + ' b:' + box + ' p:' + place + ' nk:' + nk + ' tt:' + tissue_type);
			DWREngine._execute(_cfscriptLocation, null, 'saveNewTiss', freezer,rack,box,place,nk,tissue_type, success_SaveNewTiss);
			} else {
			alert('NK must be numeric.');
			}
			
			
		//alert('putting nk ' + theNKVal + ' ' + theTissVal + ' in place ' + place);
		//alert(freezer);
		//alert(rack);
		//alert(box);
		// ,r,  ,,,position,
		//var theVar=12;
		
	}
	function success_SaveNewTiss (result) {
		//alert('back');
		var lid = result[0].LOCATOR_ID;
		if (lid < 99999999) {
			// safe!
			var psn = result[0].PLACE;
			var theID = "posn" + psn; 
			//alert(psn);
			var theDiv = document.getElementById(theID);
			var nk = result[0].NK;
			var tiss = result[0].TISSUE_TYPE;
			var freezer = result[0].FREEZER;
			var rack = result[0].RACK;
			var box = result[0].BOX;
			//alert('p: ' + psn + ' theID:' + theID + ' nk:');
			var theSpan = '<span style="position:absolute; top:0; right:0; background-color:#999999";>';
			theSpan += psn;
			theSpan += '</span>';
			var theImgs = '<img src="/images/del.gif" class="likeLink" onclick="remPartFromBox ';
			theImgs += "('" + freezer + "','" + rack + "','" + box + "','" + psn + "','" + tiss + "','" + nk + "')" + ';">';
			var theLink = '<br>NK <a href="dgr_locator.cfm?nk=' + nk + '&action=findLoc">' + nk + '</a>';
			var theHtml = theImgs + theLink + theSpan + '<br>' + tiss;
			theDiv.innerHTML = theHtml;
		} else {
			var theErr = result[0].FREEZER;
			alert(theErr);
		}
	}
	function remPartFromBox (freezer,rack,box,place,tissue_type,nk) {
		var ruSure = 'Are you sure you wish to permanently remove NK ' + nk + " '" + tissue_type + "'";
		ruSure += ' from freezer ' + freezer + ', rack ' + rack + ', box ' + box;
		ruSure += ', position ' + place + '?';
		yesDelete = window.confirm(ruSure);

		if (yesDelete == true) {
		//alert('yep');
		DWREngine._execute(_cfscriptLocation, null, 'remNKFromPosn', freezer,rack,box,place,tissue_type,nk, success_remNKFromPosn);
		}
	}
	
	
	function success_remNKFromPosn (result) {
		if (result < 999999) { 
			//alert(result);
			// result = position (or place)
			var theID = "posn" + result; 
			var theCell = document.getElementById(theID);
			var theForm = document.getElementById('theForm');
			theCell.innerHTML='';
			mytable = document.createElement("TABLE");
			mytable.cellPadding="0";
			mytable.cellSpacing="0";
			mytable.border="0";
			mytable.width="100%";
			theCell.appendChild(mytable);
			
			mytablebody = document.createElement("TBODY");
			mytable.appendChild(mytablebody);
			
			headTR = document.createElement("TR");
			mytablebody.appendChild(headTR);
			
			headTD = document.createElement("TD");
			headTD.colSpan = "2";
			headTD.align = "right";
			headTR.appendChild(headTD);
			
			myPrettySpan = document.createElement("SPAN");
			myPrettySpan.style.backgroundColor = "#999999";
			headTD.appendChild(myPrettySpan);
			
			currenttext=document.createTextNode(result);
			myPrettySpan.appendChild(currenttext);
			
			myNkTR = document.createElement("TR");
			mytablebody.appendChild(myNkTR);
			
			
			myNkLabelTD = document.createElement("TD");
			myNkTR.appendChild(myNkLabelTD);
			myNkLabel=document.createTextNode("NK:");
			myNkLabelTD.appendChild(myNkLabel);
			
			myNkDataTD = document.createElement("TD");
			myNkTR.appendChild(myNkDataTD);
			
			myNkInput = document.createElement("INPUT");
			myNkInput.type = "text";
			nkName = "nk" + result;
			myNkInput.name = nkName;
			myNkInput.id = nkName;
			myNkInput.size = "6";
			myNkInput.style.fontSize = "10px";
			myNkDataTD.appendChild(myNkInput);
			
			myPartTR = document.createElement("TR");
			mytablebody.appendChild(myPartTR);
			
			myPartLabelTD = document.createElement("TD");
			myPartTR.appendChild(myPartLabelTD);
			myPartLabel=document.createTextNode("PT:");
			myPartLabelTD.appendChild(myPartLabel);
			
			myPartDataTD = document.createElement("TD");
			myPartTR.appendChild(myPartDataTD);
			
			myPartInput = document.createElement("INPUT");
			myPartInput.type = "text";
			tTissName = "tiss" + result;
			myPartInput.name = tTissName;
			myPartInput.id = tTissName;
			myPartInput.size = "6";
			myPartInput.style.fontSize = "10px";
			myPartInput.setAttribute("onchange","saveNewTiss('" + result + "')");
			myPartDataTD.appendChild(myPartInput);
			
		} else {
			alert('Something bad happened! Your delete was not processed. Reload this page to ensure current data.');
		}
	}
	function getRacksForFzr(f) {
		//alert (f);
		DWREngine._execute(_cfscriptLocation, null, 'DGRracklookup', f, getRacksForFzr_result);
	} 
	function getRacksForFzr_result(result) {
		//alert ('yippee');
		DWRUtil.removeAllOptions("seleRack");
		DWRUtil.addOptions("seleRack", result, "RACK");
	} 
	function getBoxForRack(r) {
		//alert (r);
		var f = DWRUtil.getValue("seleFreezer");
		//alert(f);
		DWREngine._execute(_cfscriptLocation, null, 'DGRboxlookup', f,r, getBoxForRack_result);
	}
	function getBoxForRack_result(result) {
		//alert ('yippee');
		DWRUtil.removeAllOptions("seleBox");
		DWRUtil.addOptions("seleBox", result, "BOX");
	} 
	// need almost-duplicates to move boxes at box view
	function getRacksForFzrm(f) {
		//alert (f);
		DWREngine._execute(_cfscriptLocation, null, 'DGRracklookup', f, getRacksForFzr_resultm);
	} 
	function getRacksForFzr_resultm(result) {
		//alert ('yippee');
		DWRUtil.removeAllOptions("seleRackm");
		DWRUtil.addOptions("seleRackm", result, "RACK");
	} 
	function getBoxForRackm(r) {
		//alert (r);
		var f = DWRUtil.getValue("seleFreezerm");
		//alert(f);
		DWREngine._execute(_cfscriptLocation, null, 'DGRboxlookup', f,r, getBoxForRack_resultm);
	}
	function getBoxForRack_resultm(result) {
		//alert ('yippee');
		DWRUtil.removeAllOptions("seleBoxm");
		DWRUtil.addOptions("seleBoxm", result, "BOX");
	} 
	
	function getLoanDetails () {
	//alert('go');
		var inst = document.getElementById('institution_acronym').value;
		var pre = document.getElementById('loan_num_prefix').value;
		var num = document.getElementById('loan_num').value;
		var suf = document.getElementById('loan_num_suffix').value;
		DWREngine._execute(_user_loan_functions, null, 'getLoanDetails', inst,pre,num,suf, success_getLoanDetails);
	}
	function success_getLoanDetails(result) {
		//alert('back');
		var tid = result[0].TRANSACTION_ID;
		//alert(tid);
		if (tid == 0) {
			alert('zero matches');
		} else if (tid == -99999) {
			alert('lotzo matches');
		} else {
			var ltype = result[0].LOAN_TYPE;
			var linst = result[0].LOAN_INSTRUCTIONS;
			var ldesc = result[0].LOAN_DESCRIPTION;
			var recagnt = result[0].REC_AGENT;
			var authagnt = result[0].AUTH_AGENT;
			var natofma = result[0].NATURE_OF_MATERIAL;
			
			var lt = document.getElementById('loan_type');
			var li = document.getElementById('loan_instructions');
			var ld = document.getElementById('loan_description');
			var ra = document.getElementById('rec_agent');
			var aa = document.getElementById('auth_agent');
			var nom = document.getElementById('nature_of_material');
			var el = document.getElementById('editLoanLink');
			lt.innerHTML=ltype;
			li.innerHTML=linst;
			ld.innerHTML=ldesc;
			ra.innerHTML=recagnt;
			aa.innerHTML=authagnt;
			nom.innerHTML=natofma;
			var theLink = '<a href="/Loan.cfm?Action=editLoan&transaction_id=' + tid + '">Edit This Loan</a>';
			el.innerHTML=theLink;
			var theTab = document.getElementById('loanDetails');
			theTab.style.display='';
			//var mfr =  document.getElementById('moveForReal');
			//var theID =  document.getElementById('user_loan_id').value;
			//var tmvlnk = '<a href="manage_user_loan_request.cfm?action=reallyMoveEmNow&user_loan_id=';
			//tmvlnk += theID + "&transaction_id=" + tid + '">Yep, put these specimens in this loan for real</a>';
			//mfr.innerHTML = tmvlnk;
		}
	}
</script>
<!--- floaty thing that always lives over here --->

	<span style="float:right;">
		<input type="button" 
			value="Locator Home" 
			class="qutBtn"
   			onmouseover="this.className='qutBtn btnhov'" 
			onmouseout="this.className='qutBtn'"
			onClick="document.location='/tools/dgr_locator.cfm';">
		<img src="/images/what.gif" border="0" alt="help" class="likeLink" onclick="pageHelp('dgr_locator')">
		
	</span>
<!------------------------------------------------------------------------->
<cfif #action# is "getBox">
	<cfoutput>
	<form name="findLoc" method="post" action="dgr_locator.cfm">
		<input type="hidden" name="action" value="boxView">
		<cfquery name="f" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select distinct(freezer) as f from dgr_locator order by freezer
		</cfquery>
		
		Freezer:
		<select name="freezer" id="seleFreezer" size="1" onchange="getRacksForFzr(this.value);">
			<option value="" selected="selected"></option>
			<cfloop query="f">
				<option value="#f#">#f#</option>
			</cfloop>
		</select>
		Rack: 
		<select name="rack" id="seleRack" size="1" onchange="getBoxForRack(this.value)">
		</select>
		Box: <select name="box" id="seleBox" size="1">
		
		</select>
		<input type="submit" 
			value="GO" 
			class="lnkBtn"
   			onmouseover="this.className='lnkBtn btnhov'" 
			onmouseout="this.className='lnkBtn'">
	</form>
	</cfoutput>
</cfif>


<!------------------------------------------------------------------------->
<cfif #action# is "nothing">
	<form name="findIt" method="post" action="dgr_locator.cfm">
		<input type="hidden" name="action">
		<input type="button" 
			value="Find Location by DGR #" 
			class="lnkBtn"
   			onmouseover="this.className='lnkBtn btnhov'" 
			onmouseout="this.className='lnkBtn'"
			onClick="findIt.action.value='getLocation';submit();">
		<br /><input type="button" 
			value="Browse By Box" 
			class="lnkBtn"
   			onmouseover="this.className='lnkBtn btnhov'" 
			onmouseout="this.className='lnkBtn'"
			onClick="findIt.action.value='getBox';submit();">
		<br />
		<input type="button" 
			value="Create New Freezer" 
			class="insBtn"
   			onmouseover="this.className='insBtn btnhov'" 
			onmouseout="this.className='insBtn'"
			onClick="findIt.action.value='newFreezer';submit();">
	</form>
</cfif>
<!------------------------------------------------------------------------->
<cfif #action# is "getLocation">
	<form name="findLoc" method="post" action="dgr_locator.cfm">
		<input type="hidden" name="action" value="findLoc">
		Comma-delimited list (eg, 1,2,3) OK<br />
		NK: <input type="text" name="nk" size="60">
		<input type="submit" 
			value="GO" 
			class="schBtn"
   			onmouseover="this.className='schBtn btnhov'" 
			onmouseout="this.className='schBtn'">
	</form>
</cfif>

<!------------------------------------------------------------------------->
<cfif #action# is "newFreezer">
<cfoutput>
	<form name="nf" method="post" action="dgr_locator.cfm">
		<input type="hidden" name="action" value="makeFreezer" />
		Freezer Number:<input type="text" name="freezer" />
		<br />Number of Racks: <input type="text" name="numrack" />
		<br />Number of boxes per rack: <input type="text" name="numBox" />
		<input type="submit" />
	</form>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------->
<cfif #action# is "makeFreezer">
<cfoutput>

	<!--- this query is very slow, so use stored procedure
	
		makeDGRFreezerPositions ( f in integer, r in integer, b in integer)
		
		eg,
		
		makeDGRFreezerPositions (1,40,11)
		
		creates freezer one which contains 40 racks, eash of which contains 11 boxes, each containing 100 slots
		--->
		
		<cfstoredproc datasource="#Application.uam_dbo#" procedure="makeDGRFreezerPositions">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="f" value="#freezer#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="r" value="#numrack#">
			<cfprocparam cfsqltype="cf_sql_integer" dbvarname="b" value="#numBox#">
		</cfstoredproc>
	<!----
	
	<cfquery name="makeFreezer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			exec makeDGRFreezerPositions (#freezer#,#numrack#,#numBox#)
		</cfquery>
		
		
	<cfset numSlots = #numrack# * #numBox# * 100>
	Freezer Number:#freezer#
		<br />Number of Racks: #numrack#
		<br />Number of boxes per rack: #numBox#
		<br />
		--#numSlots# slots--
		<hr />
	<cfset r=1>
	<cfset b=1>
	<cfset sc = 1><!--- current slot count --->
	<cftransaction>
	<cfloop from="1" to="#numSlots#" index="s">
		<cfquery name="ns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		insert into dgr_locator (
			LOCATOR_ID,
			FREEZER,
			RACK,
			BOX,
			PLACE
		) values (
			dgr_locator_seq.nextval,
			#freezer#,
			#r#,
			#b#,
			#sc#)
		</cfquery>
			<br />
			<cfset sc = #sc# + 1>
			<cfif #sc# is 101>
				<cfset b = #b# + 1>
				<!--- need new rack? --->
				<cfif #b# gt #numBox#>
					<cfset b=1>
					<cfset r=#r#+1>			
				</cfif>
				<cfset sc=1>
			</cfif>			
	</cfloop>
	</cftransaction>
	
	
	<form name="nf" method="post" action="dgr_locator.cfm">
		<input type="hidden" name="action" value="" />
		Freezer Number:<input type="text" name="freezer" />
		<br />Number of Racks: <input type="text" name="numrack" />
		<br />Number of boxes per rack: <input type="text" name="numBox" />
		<input type="submit" />
	</form>
	---->
	spiffy
</cfoutput>
</cfif>
<!------------------------------------------------------------------------->
<cfif #action# is "findLoc">
	<cfoutput>
	<cfif not isdefined("order_by") or len(#order_by#) is 0>
		<cfset order_by = "freezer,rack,box,nk">
	</cfif>
	<cfif not isdefined("order_order") or len(#order_order#) is 0>
		<cfset order_order = "ASC">
	</cfif>
	<form name="order" method="post" action="dgr_locator.cfm">
		<input type="hidden" name="action" value="findLoc" />
		<input type="hidden" name="nk" value="#nk#" />
		Order by: <select name="order_by" size="1">
			<option value="freezer,rack,box,nk" 
				<cfif #order_by# is "nk,freezer,rack,box"> selected </cfif>
				>nk,freezer,rack,box</option>
			<option value="freezer,rack,box,nk" 
				<cfif #order_by# is "freezer,rack,box,nk"> selected </cfif>
				>freezer,rack,box,nk</option>
			<option value="nk" 
				<cfif #order_by# is "nk"> selected </cfif>
				>nk</option>
		</select>
		<select name="order_order">
			<option value="ASC" <cfif #order_order# is "ASC"> selected </cfif>>Ascending</option>
			<option value="DESC" <cfif #order_order# is "DESC"> selected </cfif>>Descending</option>
		</select>
		<input type="submit" 
			value="Sort" 
			class="lnkBtn"
			onmouseover="this.className='lnkBtn btnhov'" 
			onmouseout="this.className='lnkBtn'">
	</form>
		<cfquery name="locs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select locator_id,
				freezer,
				rack,
				box,
				place,
				nk,
				tissue_type
			from dgr_locator
			 where nk IN (#nk#)
			 order by #order_by# #order_order#
		</cfquery>
		<cfif #locs.recordcount# is 0>
			Your search returned no results!
		<cfelse>
			<table border>
			<tr>
				<td>&nbsp;</td>
				<td>NK</td>
				<td>FZ</td>
				<td>RK</td>
				<td>Box</td>
				<td>Place</td>
				<td>Tissue</td>
				<td>Probable Cataloged Item</td>
				<td>ID</td>
				<td>Geog</td>
				<td>Date</td>
				<td>Collector</td>
				<td>SNV</td>
				
			</tr>
			
			<cfloop query="locs">
				<!--- see if there's something in the main DB --->
				<cfquery name="thisRec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select 
						institution_acronym,
						collection.collection_cde,
						cat_num,
						cataloged_item.collection_object_id,
						scientific_name,
						concatAttributeValue(cataloged_item.collection_object_id,'SNV results') as snv,
						higher_geog,
						spec_locality,
						verbatim_date,
						concatColl(cataloged_item.collection_object_id) collectors
					from 
						coll_obj_other_id_num
						inner join cataloged_item ON (cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id)
						inner join collection ON (cataloged_item.collection_id = collection.collection_id)
						inner join identification on (cataloged_item.collection_object_id = identification.collection_object_id)
						inner join collecting_event on (cataloged_item.collecting_event_id = collecting_event.collecting_event_id)
						inner join locality on (collecting_event.locality_id = locality.locality_id)
						inner join geog_auth_rec on (locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id)	
					WHERE
						other_id_type='NK'
						and accepted_id_fg=1
						and DISPLAY_VALUE='#nk#'
				</cfquery>
				<tr id="row#locator_id#">
					<td><img src="/images/del.gif" class="likeLink" onclick="hideRow('#locator_id#');" /></td>
					<td>#nk#</td>
					<td>#freezer#</td>
					<td>#rack#</td>
					<td>
						<input type="button" 
							value="#box#" 
							class="lnkBtn"
							onmouseover="this.className='lnkBtn btnhov'" 
							onmouseout="this.className='lnkBtn'"
							onClick="document.location='dgr_locator.cfm?action=boxView&freezer=#freezer#&rack=#rack#&box=#box#';">
			
					</td>
					<td>#place#</td>
					<td>#tissue_type#</td>
					<td nowrap="nowrap">
						<cfif #thisRec.recordcount# is 0>
							NOTHING MATCHED!
						<cfelseif #thisRec.recordcount# is 1>
							<a href="/SpecimenDetail.cfm?collection_object_id=#thisRec.collection_object_id#">
								#thisRec.institution_acronym# #thisRec.collection_cde# #thisRec.cat_num#</a>						
						<cfelse>
							<cfloop query="thisRec">
								<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">
									#institution_acronym#&nbsp;#collection_cde#&nbsp;#cat_num#</a><br />
							</cfloop>
						</cfif>
						</td>
						<td>
						<cfif #thisRec.recordcount# is 0>
							NOTHING MATCHED!
						<cfelseif #thisRec.recordcount# is 1>
							#thisRec.scientific_name# 
						<cfelse>
							<cfloop query="thisRec">
									#scientific_name# 
							</cfloop>
						</cfif>
						</td>
						<td>
						<cfif #thisRec.recordcount# is 0>
							NOTHING MATCHED!
						<cfelseif #thisRec.recordcount# is 1>
							#thisRec.higher_geog#
								<i>#thisRec.spec_locality#</i>
						<cfelse>
							<cfloop query="thisRec">
								#higher_geog#
									<em>#spec_locality#</em>
							</cfloop>
						</cfif>
						</td>
						<td>
						<cfif #thisRec.recordcount# is 0>
							NOTHING MATCHED!
						<cfelseif #thisRec.recordcount# is 1>
							#thisRec.verbatim_date#
						<cfelse>
							<cfloop query="thisRec">
								#verbatim_date#
							</cfloop>
						</cfif>
						</td>
						<td>
						<cfif #thisRec.recordcount# is 0>
							NOTHING MATCHED!
						<cfelseif #thisRec.recordcount# is 1>
								#thisRec.collectors#						
						<cfelse>
							<cfloop query="thisRec">
								#collectors#
							</cfloop>
						</cfif>
						</td>
						<td>
						<cfif #thisRec.recordcount# is 0>
							NOTHING MATCHED!
						<cfelseif #thisRec.recordcount# is 1>
							#thisRec.snv#
						<cfelse>
							<cfloop query="thisRec">
								#snv# 
							</cfloop>
						</cfif>
						</td>
				</tr>
			</cfloop>
			</table>
		</cfif>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------->
<cfif #action# is "boxView">
	<!--- need freezer, rack, and box to do this --->
	<cfquery name="bView" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select place, nk, tissue_type from 
		dgr_locator
		where 
		freezer = '#freezer#' and
		rack = '#rack#' and
		box = '#box#'
	</cfquery>	
	
	<cfoutput>
	<cfquery name="f" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select distinct(freezer) as f from dgr_locator order by freezer
	</cfquery>
	<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select distinct(rack) as r from dgr_locator
		where freezer = #freezer#
		 order by rack
	</cfquery>
	<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select distinct(box) as b from dgr_locator
		where freezer = #freezer# and
		rack=#rack#
		 order by box
	</cfquery>
	
	
	
	<table border cellpadding="0" cellspacing="0">
		<cfset thisID=1>
		<tr>
			<td colspan="4" align="left" style="border:none;">
			<span style="font-size:14px; font-weight:700;">Current Position: Freezer #freezer#; Rack #rack#; Box #box#</span>
			</td>
			<td colspan="7" align="right" style="border:none;">
			<form name="findLoc" method="post" action="dgr_locator.cfm">
		<input type="hidden" name="action" value="boxView">
			<span style="font-size:18px; font-weight:900;">Jump To:&nbsp;		
		Freezer:
		<select name="freezer" id="seleFreezer" size="1" onchange="getRacksForFzr(this.value);">
			<cfloop query="f">
				<option <cfif #f# is #freezer#> selected </cfif>value="#f#">#f#</option>
			</cfloop>
		</select>
		Rack: 
		<select name="rack" id="seleRack" size="1" onchange="getBoxForRack(this.value)">
			<cfloop query="r">
				<option <cfif #r# is #rack#> selected </cfif>value="#r#">#r#</option>
			</cfloop>
		</select>
		Box: <select name="box" id="seleBox" size="1">
				<cfloop query="b">
					<option <cfif #b# is #box#> selected </cfif>value="#b#">#b#</option>
				</cfloop>
			</select>
		<input type="submit" 
			value="GO" 
			class="schBtn"
			onmouseover="this.className='schBtn btnhov'" 
			onmouseout="this.className='schBtn'">
			
	
	</span>
	</form>
			</td>
		</tr>
		<form name="theForm" method="post" action="dgr_locator.cfm" id="theForm">
		<input type="hidden" name="freezer" value="#freezer#" id="freezer">
		<input type="hidden" name="rack" value="#rack#" id="rack">
		<input type="hidden" name="box" value="#box#" id="box">
		<!---
		<input type="hidden" name="action" value="test" />
			<input type="hidden" name="place" value="13" />
		
		NK: <input type="text" name="nk" size="6" style="font-size:8px;" >
						Part: <input type="text" name="tissue_type" size="6" >
					<input type="submit" />
					--->
		<cfloop from="1" to="10" index="a">
			<tr>
				<cfloop from="1" to="10" index="i">
					
					<td>
					<div style="position:relative; width:80px; height:60px; font-size:12px;" id="posn#thisID#">
						<table width="100%" cellpadding="0" cellspacing="0">
							<tr>
								<td colspan="2"  align="right">
									<span style="background-color:##999999">
										#thisID#
									</span>									
								</td>
							</tr>
							<tr>
								<td align="right">NK:</td>
								<td><input type="text" size="5" style="font-size:10px;" name="nk#thisID#" id="nk#thisID#"></td>
							</tr>
							<tr>
								<td align="right">PT:</td>
								<td><input type="text" size="5" style="font-size:10px;" name="tiss#thisID#" id="tiss#thisID#"
						onchange="saveNewTiss('#thisID#');"></td>
							</tr>
						</table>
					</div>
					</td>
					<cfset thisID=#thisID# + 1>
				</cfloop>
				</form>
			</tr>
		</cfloop>
		<tr>
			<td colspan="10">
				
				<form name="moveBox" method="post" action="dgr_locator.cfm">
		<input type="hidden" name="action" value="moveABox">
		<input type="hidden" name="oldFreezer" value="#freezer#" />
		<input type="hidden" name="oldRack" value="#rack#" />
		<input type="hidden" name="oldBox" value="#box#" />
			<span style="font-size:18px; font-weight:900;">Move this box to:&nbsp;		
		Freezer:
		<select name="freezer" id="seleFreezerm" size="1" onchange="getRacksForFzrm(this.value);">
			<option value="" selected="selected"></option>
			<cfloop query="f">
				<option value="#f#">#f#</option>
			</cfloop>
		</select>
		Rack: 
		<select name="rack" id="seleRackm" size="1" onchange="getBoxForRackm(this.value)">
			
		</select>
		Box: <select name="box" id="seleBoxm" size="1">
				
			</select>
		<input type="submit" 
			value="GO" 
			class="schBtn"
			onmouseover="this.className='schBtn btnhov'" 
			onmouseout="this.className='schBtn'">
			
	
	</span>
	</form>
			</td>
		</tr>
	</table>
	<cfloop query="bView">
		<cfif len(#nk#) gt 0><!--- got something in this slot --->
		<script>
			var theSpan = '<span style="position:absolute; top:0; right:0; background-color:##999999";">';
			theSpan += "#place#";
			theSpan += '</span>';
			var theDiv = document.getElementById('posn#place#');
			var theImgs = '<img src="/images/del.gif" class="likeLink" onclick="remPartFromBox ';
			theImgs += "('#freezer#','#rack#','#box#','#place#','#tissue_type#','#nk#')" + ';">';
			var theLink = '<br>NK <a href="dgr_locator.cfm?nk=#nk#&action=findLoc">#nk#</a>';
			var theHtml = theImgs + theLink + theSpan + '<br>#tissue_type#';
			//alert(theHtml);
			theDiv.innerHTML = theHtml;
		</script>
		</cfif>
	</cfloop>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------->
<cfif #action# is "moveABox">
	<cfoutput>
		<cfset theNewFreezer = #freezer#>
		<cfset theNewRack = #rack#>
		<cfset theNewBox = #box#>
		<!--- see if there's anything already there --->
		<cfquery name="isItThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select count(*) as cnt from dgr_locator where 
			freezer=#freezer# 
			and rack=#rack# 
			and box=#box#
			and NK is not null
		</cfquery>
		<cfif #isItThere.cnt# gt 0>
			There are #isItThere.cnt# items in freezer #freezer#, rack #rack#, box #box#!
			
			<br />The move has been aborted.  
			<br /><a href="dgr_locator.cfm?action=boxView&freezer=#oldFreezer#&rack=#oldRack#&box=#oldBox#">Return</a> to freezer #oldFreezer#, rack #oldRack#, box #oldBox#
		<cfelse>
			<!--- switch the old out to the (empty) new, then the new out to the empty old --->
			<cfquery name="contents" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from dgr_locator where 
				freezer=#oldFreezer# and
					rack=#oldRack# and
					box=#oldBox#
			</cfquery>
			loopy....
			<cftransaction>
			<cfloop query="contents">
				<!--- move the tissue to the new box if there is an NK and a tissue. 
					If there's one or the other, die --->
					<cfif len(#NK#) gt 0 and len(#TISSUE_TYPE#) gt 0>
						<!--- spiffy --->
						<cfquery name="old" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						update dgr_locator set NK=null, tissue_type=null where
						LOCATOR_ID=#LOCATOR_ID#
						</cfquery>
						update dgr_locator set NK=null, tissue_type=null where
						LOCATOR_ID=#LOCATOR_ID#
						<br />
						<cfquery name="new" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						update dgr_locator set nk=#nk#,tissue_type='#tissue_type#'
						where freezer=#theNewFreezer# and
						rack=#theNewRack# and
						box=#theNewBox# and
						place=#place#
						</cfquery>
						update dgr_locator set nk=#nk#,tissue_type='#tissue_type#'
						where freezer=#theNewFreezer# and
						rack=#theNewRack# and
						box=#theNewBox# and
						place=#place#
						<hr />
					<cfelseif (len(#NK#) is 0 and len(#TISSUE_TYPE#) gt 0) OR (len(#TISSUE_TYPE#) is 0 and len(#NK#) gt 0)>
						<!-- die --->
						There is an NK (#NK#) with no tissue type, or a tissue type (#TISSUE_TYPE#) with no NK!
						Aborting!
						<cfabort>
					</cfif>				
			</cfloop>
			</cftransaction>
			<!---
			<cfquery name="moveBox" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE dgr_locator
					set freezer=#freezer#,
					rack=#rack#,
					box=#box#
					WHERE
					freezer=#oldFreezer# AND
					rack=#oldRack# AND
					box=#oldBox#
			</cfquery>
			<!--- and make an empty replacement --->
			<cfquery name="newLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into dgr_locator (
					LOCATOR_ID,
					FREEZER,
					RACK,
					BOX)
				VALUES (
					dgr_locator_seq.nextval,
					#oldFreezer#,
					#oldRack#,
					#oldBox#)		
			</cfquery>	
			insert into dgr_locator (
					LOCATOR_ID,
					FREEZER,
					RACK,
					BOX)
				VALUES (
					dgr_locator_seq.nextval,
					#oldFreezer#,
					#oldRack#,
					#oldBox#)
					--->		
			Successful move!
			<br />
			<a href="dgr_locator.cfm?action=boxView&freezer=#freezer#&rack=#rack#&box=#box#">New Location</a>
		</cfif> 
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------->


<cfif #action# is "test">
<cfoutput>
<cftransaction>
	<cfquery name="newLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		insert into dgr_locator (
			LOCATOR_ID,
			FREEZER,
			RACK,
			BOX,
			PLACE,
			NK,
			TISSUE_TYPE)
		VALUES (
			dgr_locator_seq.nextval,
			#freezer#,
			#rack#,
			#box#,
			#place#,
			#nk#,
			'#tissue_type#')		
	</cfquery>
	<cfquery name="v" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select dgr_locator_seq.currval as currval from dual
	</cfquery>
	<cfset tv = v.currval>
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select LOCATOR_ID,
			FREEZER,
			RACK,
			BOX,
			PLACE,
			NK,
			TISSUE_TYPE from 
		dgr_locator where LOCATOR_ID =#tv#		
	</cfquery>
	</cftransaction>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------->
<cfif #action# is "makeLoanItems">
<cfoutput>
<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select distinct(institution_acronym)  from collection
	</cfquery>
	<cfquery name="ctcoll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection_cde from ctcollection_cde
	</cfquery>
	First, select a pre-existing loan:
	<table border>
	<form name="loan" method="post" action="dgr_locator.cfm">
		<tr>
			<td>
				<label for="institution_acronym">Institution</label>
				<select name="institution_acronym" size="1" id="institution_acronym" >
					<cfloop query="ctInst">
						<option value="#ctInst.institution_acronym#">#ctInst.institution_acronym#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<label for="loan_num_prefix">Prefix</label>
				<input type="text" name="loan_num_prefix" class="reqdClr" size="5" id="loan_num_prefix">
			</td>
			<td>
				<label for="loan_num">Number</label>
				<input type="text" name="loan_num" class="reqdClr" size="6" id="loan_num">
			</td>
			<td>
				<label for="loan_num_suffix">Suffix</label>
				<select name="loan_num_suffix" size="1" id="loan_num_suffix">
					<cfloop query="ctcoll">
						<option value="#ctcoll.collection_cde#">#ctcoll.collection_cde#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<input type="button" value="Get Details" onclick="getLoanDetails()" />
			</td>
		
		</tr>
	</form>
	</table>
	<div id="loanDetails" style="display:none;">
		<table border>
			<tr>
				<td align="right">Loan Type:</td>
				<td><div id="loan_type"></div></td>
			</tr>
			<tr>
				<td align="right">Loan Instructions:</td>
				<td><div id="loan_instructions"></div></td>
			</tr>
			<tr>
				<td align="right">Loan Description:</td>
				<td><div id="loan_description"></div></td>
			</tr>
			<tr>
				<td align="right">To Agent:</td>
				<td><div id="rec_agent"></div></td>
			</tr>
			<tr>
				<td align="right">Authorized By:</td>
				<td><div id="auth_agent"></div></td>
			</tr>
			<tr>
				<td align="right">Nature of Material:</td>
				<td><div id="nature_of_material"></div></td>
			</tr>
			<tr>
				<td colspan="2">
					<div id="editLoanLink" align="center"></div>
				</td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<div id="moveForReal"></div>
				</td>
			</tr>
		</table>
	</div>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
