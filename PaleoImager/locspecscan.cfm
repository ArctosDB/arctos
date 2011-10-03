<cfinclude template="/includes/_header.cfm">
<cfset title="Paleo Imaging: Locality Cards and Specimens">
<cfoutput>
	<div width="20%" align="right" style="float:right;">
		<a href="/PaleoImager/locspecscan.cfm">[ home ]</a>
	</div>
<!--------------------------------------------------------------------------------------------------->
<cfif action is "nothing">
	<script src="/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js" language="javascript" type="text/javascript"></script>
	<script>
		jQuery(document).ready(function() {
	  		jQuery("##accn").autocomplete("/PaleoImager/data/accn.cfm", {
				max: 50,
				autofill: true,
				multiple: false,
				scroll: true,
				scrollHeight: 300,
				matchContains: true,
				minChars: 1,
				selectFirst:true
			});
		});
	</script>
	<a href="locspecscan.cfm?action=enterCard">[ enter new locality card ]</a>
	<p></p>
	Find existing locality cards....
	<form name="f" method="post" action="locspecscan.cfm">
		<input name="action" type="hidden" value="findLoc">
		<label for="barcode">Card Barcode</label>
		<input name="barcode" id="barcode">
		<br><input type="submit" value="go">
	</form>
</cfif>
<!--------------------------------------------------------------------------------------------------->
<cfif action is "deleteCard">
	<cfquery name="la" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from loc_card_scan where loc_id=#loc_id#
	</cfquery>
	you killed it!
</cfif>
<!--------------------------------------------------------------------------------------------------->
<cfif action is "delSpec">
	<cfquery name="la" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from spec_scan where id=#id#
	</cfquery>
	you killed it! <a href="locspecscan.cfm?action=findLoc&barcode=#barcode#">[ back to card ]</a>
</cfif>
<!--------------------------------------------------------------------------------------------------->
<cfif action is "findLoc">
	<cfquery name="la" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from loc_card_scan <cfif len(barcode) gt 0> where barcode='#barcode#'</cfif>
	</cfquery>
	<cfloop query="la">
		<hr>
		<a href="locspecscan.cfm?action=enterSpec&loc_id=#loc_id#">[ enter more specimens for this card ]</a>
		<cfquery name="sp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from spec_scan where loc_id=#loc_id#
		</cfquery>
		<cfif sp.recordcount is 0>
			<br><a href="locspecscan.cfm?action=deleteCard&loc_id=#loc_id#">[ delete this card ]</a>
		<cfelse>
			<br>This card has specimens and cannot be deleted.
		</cfif>
		<label for="lcard">Locality Card</label>
		<table border id="lcard">
			<tr>
				<td align="right">Locality ID</td>
				<td>#localityID#</td>
			</tr>
			<tr>
				<td align="right">Accession</td>
				<td>#accn_number#</td>
			</tr>
			<tr>
				<td align="right">Card Barcode</td>
				<td>#barcode#</td>
			</tr>
			<tr>
				<td align="right">Coordinates</td>
				<td>
					<cfif len(dec_lat) gt 0>
						#dec_lat#/#dec_long# #chr(177)# #error_m#
					</cfif>
				</td>
			</tr>
			<tr>
				<td align="right">ErathemEra</td>
				<td>#ErathemEra#</td>
			</tr>
			<tr>
				<td align="right">Age</td>
				<td>#age#</td>
			</tr>
			<tr>
				<td align="right">SeriesEpoch</td>
				<td>#SeriesEpoch#</td>
			</tr>
			<tr>
				<td align="right">SystemPeriod</td>
				<td>#SystemPeriod#</td>
			</tr>
			<tr>
				<td align="right">Formation</td>
				<td>#formation#</td>
			</tr>
			<tr>
				<td align="right">WhoWhen</td>
				<td>#who#@#when#</td>
			</tr>
		</table>
		
		<label for="spec">Specimens</label>
		<table border id="spec">
			<tr>
				<th>ID</th>
				<th>Barcode</th>
				<th>TaxonName</th>
				<th>PartName</th>
				<th>Who</th>
				<th>When</th>
				<td></td>
			</tr>
			<cfloop query="sp">
				<tr>
					<td>#idnum#</td>
					<td>#barcode#</td>
					<td>#taxon_name#</td>
					<td>#part_name#</td>
					<td>#who#</td>
					<td>#when#</td>
					<td><a href="locspecscan.cfm?action=delSpec&id=#id#&barcode=#la.barcode#">DELETE</a></td>
				</tr>
			</cfloop>
		</table>
	</cfloop>
	<hr>
</cfif>
<!--------------------------------------------------------------------------------------------------->
<cfif action is "enterCard">
	<script src="/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js" language="javascript" type="text/javascript"></script>
	<cfquery name="ctAge" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			ATTRIBUTE_VALUE 
		from 
			geology_attribute_hierarchy 
		where 
			ATTRIBUTE='Stage/Age' and
			USABLE_VALUE_FG=1
		group by
			ATTRIBUTE_VALUE
		order by
			ATTRIBUTE_VALUE
	</cfquery>
	<cfquery name="ctFormation" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			ATTRIBUTE_VALUE 
		from 
			geology_attribute_hierarchy 
		where 
			ATTRIBUTE='formation' and
			USABLE_VALUE_FG=1
		group by
			ATTRIBUTE_VALUE
		order by
			ATTRIBUTE_VALUE
	</cfquery>
	<cfquery name="ctSeriesEpoch" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			ATTRIBUTE_VALUE 
		from 
			geology_attribute_hierarchy 
		where 
			ATTRIBUTE='Series/Epoch' and
			USABLE_VALUE_FG=1
		group by
			ATTRIBUTE_VALUE
		order by
			ATTRIBUTE_VALUE
	</cfquery>
	<cfquery name="ctSystemPeriod" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			ATTRIBUTE_VALUE 
		from 
			geology_attribute_hierarchy 
		where 
			ATTRIBUTE='System/Period' and
			USABLE_VALUE_FG=1
		group by
			ATTRIBUTE_VALUE
		order by
			ATTRIBUTE_VALUE
	</cfquery>
	<cfquery name="ctSystemPeriod" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			ATTRIBUTE_VALUE 
		from 
			geology_attribute_hierarchy 
		where 
			ATTRIBUTE='System/Period' and
			USABLE_VALUE_FG=1
		group by
			ATTRIBUTE_VALUE
		order by
			ATTRIBUTE_VALUE
	</cfquery>
	<cfquery name="ctErathemEra" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			ATTRIBUTE_VALUE 
		from 
			geology_attribute_hierarchy 
		where 
			ATTRIBUTE='Erathem/Era' and
			USABLE_VALUE_FG=1
		group by
			ATTRIBUTE_VALUE
		order by
			ATTRIBUTE_VALUE
	</cfquery>
	
	<script>
		jQuery(document).ready(function() {
	  		$("##barcode").focus();
	  		jQuery("##accn").autocomplete("/PaleoImager/data/accn.cfm", {
				max: 50,
				autofill: true,
				multiple: false,
				scroll: true,
				scrollHeight: 300,
				matchContains: true,
				minChars: 1,
				selectFirst:true
			});
		});
		function checkLoc(v){
			if (! v.match(/^AK-[1-9][0-9]{0,2}-[VPIGM]-?[1-9]?[0-9]{0,3}-?[1-9]?[0-9]{0,3}$/)){
				var err='AK number must be formatted as AK-{1-999}-(V,P,I,G, or M)[-{1-9999}-{1-9999}]';
				err+='\nExamples:';
				err+='\n\tAK-1-V\n\tEx: AK-999-P\n\tEX: AK-1-V-1-1674';
				
				alert(err);
				// AK-1-V
				// AK-999-P
				// AK-1-V-1-9999
			}
		}
		function flipCoord(v) {
			$("##DMS").hide();
				$("##las").hide();
				$("##los").hide();
				$("##DD").hide();
			if (v==''){
				$("##coordErr").hide();
				$("##dms_latd").val('');
				$("##dms_latm").val('');
				$("##dms_lats").val('');
				$("##dms_lond").val('');
				$("##dms_lonm").val('');
				$("##dms_lons").val('');
				$("##declat").val('');
				$("##declong").val('');
				$("##error_m").val('');
			} else if (v=='DD'){
				("##dms_lonm").val('');
			}			
		}
		function convertCoords(){
			var dms_latd=$("##dms_latd").val();
			var dms_latm=$("##dms_latm").val();
			var dms_lats=$("##dms_lats").val();
			var dms_latdir=$("##dms_latdir").val();
			var dms_lond=$("##dms_lond").val();
			var dms_lonm=$("##dms_lonm").val();
			var dms_lons=$("##dms_lons").val();
			var dms_londir=$("##dms_londir").val();
			
			if (dms_lats==''){dms_lats=0;}
			var seconds=parseFloat(dms_latm) * 60 + parseFloat(dms_lats);
			var frac=parseFloat(seconds)/3600;
			var dlat=parseFloat(dms_latd) + parseFloat(frac);
			if (dms_latdir=='S'){
				dlat=dlat*-1;
			}
			$("##declat").val(dlat);
			if (dms_lons==''){dms_lons=0;}
			var seconds=parseFloat(dms_lonm) * 60 + parseFloat(dms_lons);
			var frac=parseFloat(seconds)/3600;
			var dlon=parseFloat(dms_lond) + parseFloat(frac);
			if (dms_londir=='W'){
				dlon=dlon*-1;
			}
			$("##declong").val(dlon);
		}
	</script>
	<cfset title="ES Imaging: Locality Cards & Specimens">
	Enter Locality Card:
	<form name="f" action="locspecscan.cfm" method="post">
		<input type="hidden" name="action" value="saveNew">
		<label for="barcode">Locality Card Barcode</label>
		<input type="text" name="barcode" id="barcode" class="reqdClr">
		<label for="accn">Accession</label>
		<input type="text" name="accn" id="accn" class="reqdClr">
		<label for="LocalityID">LocalityID (AK##)</label>
		<input type="text" name="LocalityID" id="LocalityID" class="reqdClr">	
		
		<label for="formation">formation</label>
		<select name="formation">
			<option value=""></option>
			<cfloop query="ctFormation">
				<option value="#ATTRIBUTE_VALUE#">#ATTRIBUTE_VALUE#</option>
			</cfloop>
		</select>
		<label for="ErathemEra">ErathemEra</label>
		<select name="ErathemEra">
			<option value=""></option>
			<cfloop query="ctErathemEra">
				<option value="#ATTRIBUTE_VALUE#">#ATTRIBUTE_VALUE#</option>
			</cfloop>
		</select>
		<label for="age">Age</label>
		<select name="age">
			<option value=""></option>
			<cfloop query="ctage">
				<option value="#ATTRIBUTE_VALUE#">#ATTRIBUTE_VALUE#</option>
			</cfloop>
		</select>
		<label for="SeriesEpoch">Series/Epoch</label>
		<select name="SeriesEpoch">
			<option value=""></option>
			<cfloop query="ctSeriesEpoch">
				<option value="#ATTRIBUTE_VALUE#">#ATTRIBUTE_VALUE#</option>
			</cfloop>
		</select>
		
		<label for="SystemPeriod">System/Period</label>
		<select name="SystemPeriod">
			<option value=""></option>
			<cfloop query="ctSystemPeriod">
				<option value="#ATTRIBUTE_VALUE#">#ATTRIBUTE_VALUE#</option>
			</cfloop>
		</select>
		<table border>
			<tr>
				<td>
					<div id="DD">
						<label for="declat">Decimal Latitude (N is positive)</label>
						<input type="text" name="declat" id="declat">
						<label for="declong">Decimal Longitude (E is positive)</label>
						<input type="text" name="declong" id="declong">
						<label for="error_m">error (m)</label>
						<input type="text" name="error_m" id="error_m" >
					</div>
				</td>
				<td>&nbsp;&nbsp;&nbsp;</td>
				<td>
					<label for="conversion_calculator">conversion calculator</label>
					<table id="conversion_calculator">
						<tr>
							<td>
								<label for="dms_latd">Latitude D</label>
								<input type="text" name="dms_latd" id="dms_latd" size="3">
							</td>
							<td>
								<label for="dms_latm">Latitude M</label>
								<input type="text" name="dms_latm" id="dms_latm" size="4">
							</td>
							<td>
								<label for="dms_lats">Latitude S</label>
								<input type="text" name="dms_lats" id="dms_lats" size="4">
							</td>
							<td>
								<label for="dms_latdir">Latitude N/S</label>
								<select name="dms_latdir" id="dms_latdir">
									<option value="N">N</option>
									<option value="S">S</option>
								</select>
							</td>
						</tr>
						<tr>
							<td>
								<label for="dms_lond">Longitude D</label>
								<input type="text" name="dms_lond" id="dms_lond" size="3">
							</td>
							<td>
								<label for="dms_lonm">Longitude M</label>
								<input type="text" name="dms_lonm" id="dms_lonm" size="4">
							</td>
							<td>
								<label for="dms_lond">Longitude S</label>
								<input type="text" name="dms_lons" id="dms_lons" size="4">
							</td>
							<td>
								<label for="dms_londir">Longitude E/W</label>
								<select name="dms_londir" id="dms_londir">
									<option value="W">W</option>
									<option value="E">E</option>
								</select>
							</td>
						</tr>
						<tr>
							<td colspan="3" align="middle">
								<input type="button" value="<--convert ^^ coordinates to decimal degrees" onclick="convertCoords()">
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<label for="remark">Remark</label>
		<input type="text" name="remark" id="remark" size="50">
		<br><input type="submit" class="savBtn" value="Save LocalityCard">
	</form>
</cfif>
<!--------------------------------------------------------------------------------------------------->
<cfif action is "saveNew">
	<cfset title="ES Imaging: Accn Cards: Dammit">
	<cftransaction>
		<h2>If you're reading this, you haven't saved anything.</h2>
		<br>barcode: #barcode#
			<cfquery name="vB" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select container_id from container where barcode='#barcode#'
			</cfquery>
			<cfif vB.recordcount is 1>
				<br>is valid (#vB.container_id#)
			<cfelse>
				<br>is invalid. Use your back button.
				<cfabort>
			</cfif>
			
			<br>accn: #accn#
			<cfquery name="vA" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select accn.transaction_id from 
					trans,accn where 
					trans.transaction_id=accn.transaction_id and
					trans.collection_id=21 and
					accn.accn_number='#accn#'
			</cfquery>
			<cfif vA.recordcount is 1>
				<br>is valid (#vA.transaction_id#)
			<cfelse>
				<br>is invalid
				<cfabort>
			</cfif>
			<cfif len(declat) + len(declong)  + len(error_m) gt 0>
				<cfif len(declat) is 0 or  len(declong) is 0>
					<br>You must provide dec lat and dec long together
					<cfabort>
				</cfif>
				<cfif declat lt -90 or declat gt 90 or declong lt -180 or declong gt 180>
					<br>coordinates invalid
					<cfabort>
				</cfif>
			</cfif>
			<br>comment: #remark#
			<br>inserting....
			<cfquery name="vA" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into loc_card_scan (
					accn_number,
					accn_id,
					barcode,
					container_id,
					<cfif len(declat) gt 0>
						dec_lat,
						dec_long,
						error_m,
					</cfif>
					age,
					formation,
					remark,
					LocalityID,
					SeriesEpoch,
					SystemPeriod,
					ErathemEra
				) values (
					'#accn#',
					#vA.transaction_id#,
					'#barcode#',
					#vB.container_id#,
					<cfif len(declat) gt 0>
						#declat#,
						#declong#,
						<cfif len(error_m) gt 0>
							#error_m#,
						<cfelse>
							NULL,
						</cfif>
					</cfif>
					'#age#',
					'#formation#',
					'#escapeQuotes(remark)#',
					'#LocalityID#',
					'#SeriesEpoch#',
					'#SystemPeriod#',
					'#ErathemEra#'
				)
			</cfquery>
			<cfquery name="lid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select sq_loc_card_scan_id.currval cid from dual
			</cfquery>
				insert into loc_card_scan (
			<br>success!
	</cftransaction>
	<cflocation url="locspecscan.cfm?action=enterSpec&loc_id=#lid.cid#" addtoken="false">
</cfif>
<!--------------------------------------------------------------------------------------------------->
<cfif action is "enterSpec">
	<script src="/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js" language="javascript" type="text/javascript"></script>
	<cfquery name="card" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from loc_card_scan where loc_id=#loc_id#
	</cfquery>
	<script>
		jQuery(document).ready(function() {
	  		$("##barcode").focus();
	  		jQuery("##part_name").autocomplete("/PaleoImager/data/part.cfm", {
				mustMatch:true,
				width: 320,
				autofill: true,
				multiple: false,
				scroll: true,
				scrollHeight: 300,
				matchContains: true,
				minChars: 3,
				selectFirst:true
			});
		});
		function lookupBarcode(v){
			$.getJSON("/component/DSFunctions.cfc",
				{
					method : "getGuidByPartBarcode",
					barcode : v,
					returnformat : "json",
					queryformat : 'column'
				},
				function(r) {
					if (r.ROWCOUNT==1){
						$('##idnum').val(r.DATA.GUID).attr('readonly', true).removeClass().addClass("readClr");
						$('##taxon_name').val('-entered-').attr('readonly', true).removeClass().addClass("readClr");
						$('##part_name').val('-entered-').attr('readonly', true).removeClass().addClass("readClr");
						$('##remark').val('-entered-').attr('readonly', true).removeClass().addClass("readClr");
					} else {
						$('##idnum').attr('readonly', false).removeClass().addClass("reqdClr");
						$('##taxon_name').val('').attr('readonly', false).removeClass().addClass("reqdClr");
						$('##part_name').val('').attr('readonly', false).removeClass().addClass("reqdClr");
						$('##remark').val('').attr('readonly', false).removeClass();
					}
				}
			);
		}
	</script>
	<label for="locTBl">Enter specimen data for locality...</label>
	<table id="locTBl" border>
		<tr>
			<td align="right">Accn:</td>
			<td>#card.accn_number#</td>
		</tr>
		<tr>
			<td align="right">Locality Card Barcode:</td>
			<td>#card.barcode#</td>
		</tr>
		
		<tr>
			<td align="right">Locality ID:</td>
			<td>#card.localityid#</td>
		</tr>
		<tr>
			<td align="right">Coordinates:</td>
			<td>
				<cfif len(card.dec_lat) gt 0>
					#card.dec_lat#/#card.dec_long# #chr(177)# #card.error_m#
				</cfif>
			</td>
		</tr>
		<tr>
			<td align="right">formation:</td>
			<td>#card.formation#</td>
		</tr>
		<tr>
			<td align="right">ErathemEra:</td>
			<td>#card.ErathemEra#</td>
		</tr>
		<tr>
			<td align="right">age:</td>
			<td>#card.age#</td>
		</tr>
		
		<tr>
			<td align="right">SeriesEpoch:</td>
			<td>#card.SeriesEpoch#</td>
		</tr>
		<tr>
			<td align="right">SystemPeriod:</td>
			<td>#card.SystemPeriod#</td>
		</tr>
		<tr>
			<td align="right">remark:</td>
			<td>#card.remark#</td>
		</tr>
	</table>
	<form name="f" action="locspecscan.cfm" method="post">
		<input type="hidden" name="action" value="saveNewSpec">
		<input type="hidden" name="loc_id" value="#loc_id#">
		<label for="barcode">SpecimenBarcode</label>
		<input type="text" name="barcode" id="barcode" class="reqdClr" onchange="lookupBarcode(this.value)">
		<label for="idnum">ID Number (eg, AK##)</label>
		<input type="text" name="idnum" id="idnum" class="reqdClr" value="#card.localityid#">
		<label for="taxon_name">Taxon Name</label>
		<input type="text" name="taxon_name" id="taxon_name" class="reqdClr"
			onchange="taxaPick('nothing',this.id,'f',this.value)">
		<input id="nothing" name="nothing" type="hidden">
		<label for="part_name">Part</label>
		<input type="text" name="part_name" id="part_name" class="reqdClr">
		<label for="remark">Remark</label>
		<input type="text" name="remark" id="remark" size="50">
		<br><input type="submit" class="savBtn" value="Save">
	</form>
	<cfquery name="sp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from spec_scan where loc_id=#loc_id#
	</cfquery>
	<br>You can delete specimens from <a href="locspecscan.cfm?action=findLoc&barcode=#card.barcode#">the locality card page</a> and re-enter to fix mistakes
	<label for="tblD">Existing specimens in this locality card</label>
	<table id="tblD" border>
		<tr>
			<th>ID</th>
			<th>Barcode</th>
			<th>TaxonName</th>
			<th>PartName</th>
			<th>Who</th>
			<th>When</th>
		</tr>
		<cfloop query="sp">
			<tr>
				<td>#idnum#</td>
				<td>#barcode#</td>
				<td>#taxon_name#</td>
				<td>#part_name#</td>
				<td>#who#</td>
				<td>#when#</td>
			</tr>
		</cfloop>
	</table>
</cfif>
<!--------------------------------------------------------------------------------------------------->
<cfif action is "saveNewSpec">
	<br>barcode: #barcode#
	<cfquery name="vB" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select container_id from container where barcode='#barcode#'
	</cfquery>
	<cfif vB.recordcount is 1>
		is valid (#vB.container_id#)
	<cfelse>
		is invalid. Use your back button.
		<cfabort>
	</cfif>
	<cfif left(idnum,7) neq 'UAM:ES:'>
	<br>taxon_name	
		<cfquery name="vT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select taxon_name_id from taxonomy where scientific_name='#taxon_name#'
		</cfquery>
		<cfif vT.recordcount is 1>
			is valid (#vT.taxon_name_id#)
			<cfset taxon_name_id=vT.taxon_name_id>
		<cfelse>
			is invalid. Use your back button.
			<cfabort>
		</cfif>
		<cfquery name="vP" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select part_name from ctspecimen_part_name where collection_cde='ES' and part_name='#part_name#'
		</cfquery>
		<br>part_name 
		<cfif vP.recordcount is 1>
			is valid
		<cfelse>
			is invalid.
			<cfabort>
		</cfif>
	<cfelse>
		<cfset taxon_name_id=-1>
	</cfif>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		insert into spec_scan (
			loc_id,
			idnum,
			remark,
			barcode,
			container_id,
			taxon_name,
			taxon_name_id,
			part_name
		) values (
			#loc_id#,
			'#idnum#',
			'#remark#',
			'#barcode#',
			#vB.container_id#,
			'#taxon_name#',
			#taxon_name_id#,
			'#part_name#'
		)
	</cfquery>
	<cflocation url="locspecscan.cfm?action=enterSpec&loc_id=#loc_id#" addtoken="false">
</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">