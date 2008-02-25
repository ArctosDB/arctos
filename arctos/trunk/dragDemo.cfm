
 <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
	<title>Drag Drop</title>
	<script src="/includes/scriptaculous/prototype.js" type="text/javascript"></script>
  	<script src="/includes/scriptaculous/scriptaculous.js" type="text/javascript"></script>
	<script type='text/javascript' src='/ajax/core/engine.js'></script>
	<script type='text/javascript' src='/ajax/core/util.js'></script>
	<script type='text/javascript' src='/ajax/core/settings.js'></script>	

<style>
	.hideThis {
		display:none;
		}
	.bodyDiv {
		background-color:#CCCC99;
		width:95%;
	}
	
	
	.item {
  cursor: move;
}

#container3 {
  background-color: #e0e0e0;
  width: 33%;
  vertical-align: top;
}
.handle {
	background-color:#FF0000;
	}
.itemHandle {
	background-color:#FF3366;
	}
.cellTable {
	width:100%;
	}
.leftSide {
	float:left;
	padding:10px;
	background-color:#66FFCC;
	width:45%;
	}
.rightSide {
	float:left;
	padding:10px;
	background-color:#330099;
	width:45%;
	}
</style>

<script>

	function addCatItemNumbers() {
		var p = document.getElementById('leftColumn');
		var nTable = document.createElement('table');
		var nTbody = document.createElement('tbody');
		var nTr = document.createElement('tr');
		var nTd = document.createElement('td');
		nTable.className = 'cellTable';
		
		p.appendChild(nTable);
		nTable.appendChild(nTbody);
		nTbody.appendChild(nTr);
		nTr.appendChild(nTd);
		nTd.innerHTML='this is a new cell';
	}
	
	function buildTaxonomy (side) {
		/*
			Build search block containing
			 	Institutional Catalog
				Catalog Number
				CustomID
				Other Identifier Type
				Other Identifying Numbe
				Accession:  	Inst: Pre: Num: Suf:
				Accn. Agency: 
				
				First step: go get dropdown values  
		*/
		
		// build a table to hold the elements we'll get
		 span = Builder.node('span',{id:'containerSpan_1'});
		 table = Builder.node('table', {cellpadding:'2',cellspacing:'0',border:'1',id:'taxonTable'});
		tbody = Builder.node('tbody', {id:'taxonTableBody'});
		tr = Builder.node('tr',{className:'header'});
		td = Builder.node('td',[ Builder.node('strong','Taxa')]);
		td2 = Builder.node('td',[ Builder.node('strong','ttt')]);
		tr.appendChild(td);
		tr.appendChild(td2);
		tbody.appendChild(tr);
		/*
		collR = Builder.node('tr',{id:'collCdrTR',className:'hideThis'});
		collRLabel = Builder.node('td',{id:'collLabelTd'});
		collRData = Builder.node('td',{id:'collDataTd'});
		tbody.appendChild(collR);
		collR.appendChild(collRLabel);
		collR.appendChild(collRData);
		*/
		// add all rows necessary if we do everything, make them invisible
		var rowsToMake = new Array();
		rowsToMake.push('scientific_name');
		rowsToMake.push('common_name');
		for (i=0;i<rowsToMake.length;i++) {
			var thisElement = rowsToMake[i];
			var thisTrName = thisElement + "TR";
			var dataTdName = thisElement + "dataTD";
			var labelTdName = thisElement + "labelTD";
			row = Builder.node('tr',{id:thisTrName,className:'hideThis'});
			label = Builder.node('td',{id:labelTdName});
			data = Builder.node('td',{id:dataTdName});
			
			row.appendChild(label);
			row.appendChild(data);
			tbody.appendChild(row);
		}
		
				
		table.appendChild(tbody);
		var appDiv = side + "Column";
		var d = document.getElementById(appDiv);
		span.appendChild(table);
		d.appendChild(span);
		
		//alert('here we are now');
		//DWREngine._execute(_cfscriptLocation, null,'getCollectionData', getCollectionData_success);
		buildSciNameSearch();
		//DWREngine._execute(_cfscriptLocation, null,'testThis', testThis_success);
		
		serializeAll();
	}
		
	function buildSciNameSearch () {
			
			ns = Builder.node('input',{id:'scientific_name',name:'scientific_name',type:'text'});
			
			var r = document.getElementById('scientific_nameTR');
			var d = document.getElementById('scientific_namedataTD');
			var l = document.getElementById('scientific_namelabelTD');
			r.className = '';
			var lab = Builder.node('strong','Scientific Name');
			l.appendChild(lab);
			d.appendChild(ns);
		}
	
	function sayHi(){alert('hi')}
	
	function serializeAll () {
		Sortable.create("leftColumn", { tag: 'span',ghosting:false,containment:['leftColumn','rightColumn'],constraint:false,dropOnEmpty:true});
		Sortable.create("rightColumn", {tag: 'span',ghosting:false,containment:['leftColumn','rightColumn'],constraint:false,dropOnEmpty:true});
		}
	function buildNumbers (side) {
		/*
			Build search block containing
			 	Institutional Catalog
				Catalog Number
				CustomID
				Other Identifier Type
				Other Identifying Numbe
				Accession:  	Inst: Pre: Num: Suf:
				Accn. Agency: 
				
				First step: go get dropdown values  
		*/
		
		// build a table to hold the elements we'll get
		// put the table in a span to make scriptaculous happy
		span = Builder.node('span',{id:'containerSpan_2'});
		 table = Builder.node('table', {cellpadding:'2',cellspacing:'0',border:'1',id:'numbersTable'});
		tbody = Builder.node('tbody', {id:'numbersTableBody'});
		tr = Builder.node('tr',{className:'header'});
		td = Builder.node('td',{colspan:'2'},[ Builder.node('strong','Identifiers')]);
		//td2 = Builder.node('td',[ Builder.node('strong','c2')]);
		tr.appendChild(td);
		//tr.appendChild(td2);
		tbody.appendChild(tr);
		/*
		collR = Builder.node('tr',{id:'collCdrTR',className:'hideThis'});
		collRLabel = Builder.node('td',{id:'collLabelTd'});
		collRData = Builder.node('td',{id:'collDataTd'});
		tbody.appendChild(collR);
		collR.appendChild(collRLabel);
		collR.appendChild(collRData);
		*/
		// add all rows necessary if we do everything, make them invisible
		var rowsToMake = new Array();
		rowsToMake.push('cat_num');
		rowsToMake.push('collection_id');
		for (i=0;i<rowsToMake.length;i++) {
			var thisElement = rowsToMake[i];
			var thisTrName = thisElement + "TR";
			var dataTdName = thisElement + "dataTD";
			var labelTdName = thisElement + "labelTD";
			row = Builder.node('tr',{id:thisTrName,className:'hideThis'});
			label = Builder.node('td',{id:labelTdName});
			data = Builder.node('td',{id:dataTdName});
			
			row.appendChild(label);
			row.appendChild(data);
			tbody.appendChild(row);
		}
		
		
		
		
		table.appendChild(tbody);
		var appDiv = side + "Column";
		var d = document.getElementById(appDiv);
		span.appendChild(table);
		d.appendChild(span);
		
		//alert('here we are now');
		DWREngine._execute(_cfscriptLocation, null,'getCollectionData', getCollectionData_success);
		buildCatNumSearch();
		//DWREngine._execute(_cfscriptLocation, null,'testThis', testThis_success);
		serializeAll();
	}
		
		function buildCatNumSearch () {
			var tb = document.getElementById('numbersTableBody');
			tr = Builder.node('tr');
			td = Builder.node('td',[ Builder.node('strong','Catalog Number')]);
			td2 = Builder.node('td');
			ns = Builder.node('input',{id:'cat_num',name:'cat_num',type:'text'});
			tr.appendChild(td);
 			tr.appendChild(td2);
			tb.appendChild(tr);
			td2.appendChild(ns);
		}
		
		
		function getCollectionData_success (result){
			// returns query
			// add row to the table
			var r = document.getElementById('collection_idTR');
			var d = document.getElementById('collection_iddataTD');
			var l = document.getElementById('collection_idlabelTD');
			r.className = '';
			var lab = Builder.node('strong','Institutional Catalog');
			l.appendChild(lab);
			
			//tr = Builder.node('tr');
			//td = Builder.node('td',[ ]);
			//td2 = Builder.node('td');
			ns = Builder.node('select',{id:'collection_id',name:'collection_id'});
			no = Builder.node('option',{value:'',selected:'selected'},'');
				ns.appendChild(no);
			for (i = 0; i < result.length; i++) { 
		 		var data = result[i].DATA;
				var display = result[i].DISPLAY;
				no = Builder.node('option',{value:data},display);
				ns.appendChild(no);
				//alert(data);
				//alert(display);
			}
			
			//tr.appendChild(td);
 			//tr.appendChild(td2);
			//tb.appendChild(tr);
			//td2.appendChild(ns);
			d.appendChild(ns);
			document.getElementById('collection_id').value='';
			//alert('back');
			//alert(result);
		}
		function testThis_success (result){
			alert('back');
			alert(result);
		}
		function isTaxonomyThere (){
			if (document.getElementById('taxonTable')) {
				alert('yep');
				} else {
				alert('nope')
				}
		}
		function makedraggy (){
			//a = Builder.node('div',{id:'done'},'Institutional Catalog');
			//b = Builder.node('div',{id:'dtwo'},'Institutional Catlasjdkiabdhfalog');
			//var d = document.getElementById('theBody');
			//d.appendChild(a);
			//d.appendChild(b);
			Sortable.create("leftColumn", {tag: 'div',ghosting:true,containment:'theBody',constraint:false,dropOnEmpty:true});
		
		}
		function serializeMe (){
			//a = Builder.node('div',{id:'done'},'Institutional Catalog');
			//b = Builder.node('div',{id:'dtwo'},'Institutional Catlasjdkiabdhfalog');
			//var d = document.getElementById('theBody');
			//d.appendChild(a);
			//d.appendChild(b);
			var a = Sortable.serialize("leftColumn");
			var b = Sortable.serialize("rightColumn");
			//alert(a);
			//var newString = a.replace("leftColumn[]=",""); 
			leftCol = a.replace(/leftColumn\[\]\=/g,'');
			alert(leftCol);
			rightCol = b.replace(/rightColumn\[\]\=/g,'')
			alert(rightCol);
		
		}
		
		function buildPage (left,right) {
			var left = 2;
			var right = 1;
			/* 
				ID's are serialized as integers, so we have to use the following conversion:
					1: Taxonomy
					2: Cat Num, etc
			*/
			}
		function addAll() {
			buildTaxonomy();
			buildNumbers();
		}
		function allAdd() {
			buildNumbers();
			buildTaxonomy();
		}
		function bla () {
		Sortable.create("leftColumn", { tag: 'span',ghosting:false,containment:['leftColumn','rightColumn'],constraint:false,dropOnEmpty:true});
		}
		
</script>
</head><body>
<input type="button" value="builder" onClick="newOne();">
<input type="button" value="buildNumbersL" onClick="buildNumbers('left');">
<input type="button" value="buildNumbersR" onClick="buildNumbers('right');">

<input type="button" value="buildTaxonomyL" onClick="buildTaxonomy('left');">
<input type="button" value="buildTaxonomyr" onClick="buildTaxonomy('right');">
<input type="button" value="isTaxonomyThere" onClick="isTaxonomyThere();">
<input type="button" value="makedraggy" onClick="makedraggy();">
<input type="button" value="bla" onClick="bla();">
<input type="button" value="serializeMe" onClick="serializeMe();">
<input type="button" value="allAdd" onClick="allAdd();">
<input type="button" value="addAll" onClick="addAll();">
<form name="stuff" method="post" action="dragDemo.cfm">
<input type="hidden" name="action" value="dumpThis">

<div id="theBody" class="bodyDiv">
	<div id="leftColumn" class="leftSide">	</div>
	<div id="rightColumn" class="rightSide"></div>
</div>
<input type="submit" value="dump">
</form>
</body>

<cfif #action# is "dumpThis">
<cfoutput>
	<cfdump var="#form#">
	<cfdump var="#variables#">
</cfoutput>
</cfif>
<!----

<div style="background-color:#336699;" id="someDiv"></div>

<div class="container">
	<div class="left">lefty lefty</div>
	<div class="right">righty tighty</div>
</div>
<!----
<table cellpadding="0" cellspacing="0" width="100%">
					<tr>
					<cfquery name="ctInst" datasource="#Application.web_user#">
						SELECT institution_acronym, collection, collection_id FROM collection
						<cfif len(#exclusive_collection_id#) gt 0>
							WHERE collection_id = #exclusive_collection_id#
						</cfif>						
					</cfquery>
			
					<cfif isdefined("collection_id") and len(#collection_id#) gt 0>
						<cfset thisCollId = #collection_id#>
					<cfelse>
						<cfset thisCollId = "">
					</cfif>
					<td align="right" width="250" nowrap>
									<a href="javascript:void(0);" 
									onClick="getHelp('cat_num'); return false;"
									onMouseOver="self.status='Click for Catalog Number help.';return true;" 
									onmouseout="self.status='';return true;">
									Institutional Catalog:</a>&nbsp;
								</td>
								<td>
					<select name="collection_id" size="1">
						<cfif len(#exclusive_collection_id#) is 0>
							<option value="">All</option>
						</cfif>
							<cfoutput query="ctInst">
								<option <cfif #thisCollId# is #ctInst.collection_id#>
								 selected </cfif>
												 
												value="#ctInst.collection_id#">
												#ctInst.institution_acronym# #ctInst.collection#</option>
										</cfoutput>
									</select>				
								</td>
								</tr>
								<tr>
								<td align="right">
									Catalog Number:&nbsp;
								</td>
								<td align="left">
									<cfif #ListContains(client.searchBy, 'bigsearchbox')# gt 0>
										<textarea name="listcatnum" rows="6" cols="40" wrap="soft"></textarea>
									<cfelse>
										<input type="text" name="listcatnum" size="21">
									</cfif>
								</td>
							</tr>	
						
					<cfif len(#Client.CustomOtherIdentifier#) gt 0>
						
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);" 
									onClick="getHelp('customOtherIdentifier'); return false;"
									onMouseOver="self.status='Click for help.';return true;" 
									onmouseout="self.status='';return true;">
									<cfoutput>#Client.CustomOtherIdentifier#</cfoutput>:</a>&nbsp;
							</td>
							<td align="left">
								<select name="CustomOidOper" size="1">
							<option value="=">is</option>
							<option value="LIKE">contains</option>
							<option value="LIST">in list</option>
							<option value="BETWEEN">in range</option>								
						  </select><input type="text" name="CustomIdentifierValue" size="50">
							</td>
						</tr>
					</cfif>
					<cfif len(#exclusive_collection_id#) gt 0>
						<cfset oidTable = "cCTCOLL_OTHER_ID_TYPE#exclusive_collection_id#">
					<cfelse>
						<cfset oidTable = "CTCOLL_OTHER_ID_TYPE">
					</cfif>
					<cfoutput>
					<cfquery name="OtherIdType" datasource="#Application.web_user#">
						select distinct(other_id_type) FROM #oidTable# ORDER BY other_Id_Type
					</cfquery>
					</cfoutput>
					<tr>					
						<td align="right" width="250">
							<a href="javascript:void(0);" 
						onClick="getHelp('other_id_type'); return false;"
						onMouseOver="self.status='Click for Other ID help.';return true;" 
						onmouseout="self.status='';return true;">Other&nbsp;Identifier&nbsp;Type:</a>&nbsp;
						</td>
						<td align="left">
							<select name="OIDType" size="1"
								<cfif isdefined("OIDType") and len(#OIDType#) gt 0>
									class="reqdClr" </cfif>>
								<option value=""></option>
								<cfoutput query="OtherIdType">
									<option 
										<cfif isdefined("OIDType") and len(#OIDType#) gt 0>
											<cfif #OIDType# is #OtherIdType.other_id_type#>
												selected
											</cfif>
										</cfif>
										value="#OtherIdType.other_id_type#">#OtherIdType.other_id_type#</option>
								</cfoutput> 
					  		</select>
							 <img 
								class="likeLink" 
								src="/images/ctinfo.gif"
								onMouseOver="self.status='Code Table Value Definition';return true;"
								onmouseout="self.status='';return true;"
								border="0"
								alt="Code Table Value Definition"
								onClick="getCtDoc('ctcoll_other_id_type',SpecData.OIDType.value)">
						</td>
					</tr>
					<cfquery name="OtherIdType" datasource="#Application.web_user#">
						select distinct(other_id_type) FROM ctColl_Other_Id_Type ORDER BY other_Id_Type
					</cfquery>
					<tr>
						<td align="right" width="250">
							<a href="javascript:void(0);"
								onClick="getHelp('other_id_num'); return false;"
								onMouseOver="self.status='Click for Other ID help.';return true;"
								onmouseout="self.status='';return true;">Other&nbsp;Identifying&nbsp;Number:</a>&nbsp;
						</td>
						<td align="left" valign="middle">
							<select name="oidOper" size="1">
							<option value="LIKE">contains</option>
							<option value="=">is</option>
						  </select>
							<cfif #ListContains(client.searchBy, 'bigsearchbox')# gt 0>
								<textarea name="OIDNum" rows="6" cols="30" wrap="soft"></textarea>
							<cfelse>
								<input type="text" name="OIDNum" size="34">
							</cfif>
						</td>
					</tr>
					<cfif #ListContains(client.searchBy, 'accn_num')# gt 0>		
						<tr>
							<td align="right" width="250">
								<a href="javascript:void(0);" 
							onClick="getHelp('accn_number'); return false;"
							onMouseOver="self.status='Click for Accession Number help.';return true;" 
							onmouseout="self.status='';return true;">Accession:</a>&nbsp;
							</td>
							<td align="left">
								<span style="font-size:9px;">Inst:</span><input type="text" name="accn_inst" size="4">
								<span style="font-size:9px;">Pre:</span><input type="text" name="accn_prefix" size="4">
								<span style="font-size:9px;">Num:</span><input type="text" name="accn_number" size="4">
								<span style="font-size:9px;">Suf:</span><input type="text" name="accn_suffix" size="4">
							</td>
						</tr>
						<tr>
							<td align="right" width="250">
								Accn. Agency:&nbsp;
							</td>
							<td>
								<input type="text" name="accn_agency" size="50" />
							</td>
						</tr>
					</cfif>
				</table>
				---->
<input type="button" value="t" onClick="getGroupOrder();">
<input type="button" onClick="newItem()" value="new">
<input type="button" onClick="addCatItemNumbers()" value="addCatItemNumbers">

addCatItemNumbers
<table width="100%">
<tr>
<td id="leftColumn">
<div class="oneItem"><span class=handle>draggy</span><br>
	<div class="innerDiv" id="oneInner">
		<div class="b" id="b1">
		<span class=itemHandle>draggy</span><input type="text" value="waeoaiweurghauyiwgbwa">
		</div>
		<div class="b" id="b2">
		<span class=itemHandle>draggy</span><input type="text">
		</div>
		
	</div>
</div>
<div class="item">Content Item 2</div>
</td>
<td id="rightColumn">
	
<div class="item">Content Item 3</div>
</td>
</tr>
</table>
---->