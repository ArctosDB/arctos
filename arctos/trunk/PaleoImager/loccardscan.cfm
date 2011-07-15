<!---
	create table loc_card_scan (
		id number not null,
		accn_number varchar2(30) not null,
		accn_id number,
		barcode varchar2(255) not null,
		container_id number,
		locid varchar2(255) not null,
		dec_lat number,
		dec_long number,
		error_m number,
		age varchar2(255),
		formation varchar2(255),
		remark varchar2(255),
		who varchar2(255),
		when date
	);
	
	
	create unique index u_pi_l_c_s_barcode on loc_card_scan(barcode) tablespace uam_idx_1;
	
	create sequence sq_loc_card_scan_id;
	
	CREATE OR REPLACE TRIGGER tg_loc_card_scan_key                                         
 		before insert ON loc_card_scan
		 for each row
		    begin
		    	select
		    		sq_loc_card_scan_id.nextval,
		    		sys_context('USERENV', 'SESSION_USER'),
		    		sysdate 
		    	into 
		    		:new.id,
		    		:new.who,
		    		:new.when
		    	from dual;
		    end;                                                                                            
		/
		

		CREATE PUBLIC SYNONYM loc_card_scan FOR loc_card_scan;
		GRANT all ON loc_card_scan to data_entry;
		
--->

<cfinclude template="/includes/_header.cfm">
<cfoutput>
<cfset numAccnRow=1>
<cfif action is "nothing">
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
	</script>
	<cfset title="ES Imaging: Locality Cards">
	Use this form to attach barcodes to UAM Paleo Locality Cards.
	<br>Barcode and Accession are exact case-sensitive match.
	<br>AK number must be formatted "AK-{1-999}-{one of (V,P,I,G,M)}{dash if anything follows}{0 to 4 integers}{dash if anything follows}{0 to 4 integers}
	<br>Sucessful save will silently redirect to an empty form. Errors will be listed; use your back button to fix them.
	"UI_bla bla bla" errors are Unique Index problems: we've already got one.
	<br>See existing data <a href="loccardscan.cfm?action=list">[ here ]</a>
	<hr>
	<form name="f" action="loccardscan.cfm" method="post">
		<input type="hidden" name="action" value="saveNew">
		<label for="barcode">Barcode</label>
		<input type="text" name="barcode" id="barcode" class="reqdClr">
		<label for="accn">Accn</label>
		<input type="text" name="accn" id="accn" class="reqdClr">
		<label for="locid">Locality ID (AK##)</label>
		<input type="text" name="locid" id="locid" class="reqdClr" onblur="checkLoc(this.value)">
		<label for="cBox">Coordinates: enter all or none</label>
		<div id="cBox" style="width:40%;border:1px solid green;padding-left:1em";>
		<label for="declat">Decimal Latitude (N is positive)</label>
		<input type="text" name="declat" id="declat" >
		<label for="declong">Decimal Longitude</label>
		<input type="text" name="declong" id="declong" >
		<label for="error_m">error (meters)</label>
		<input type="text" name="error_m" id="error_m" >
		</div>
		<label for="age">Age</label>
		<select name="age">
			<option value=""></option>
			<cfloop query="ctage">
				<option value="#ATTRIBUTE_VALUE#">#ATTRIBUTE_VALUE#</option>
			</cfloop>
		</select>
		<label for="formation">formation</label>
		<select name="formation">
			<option value=""></option>
			<cfloop query="ctFormation">
				<option value="#ATTRIBUTE_VALUE#">#ATTRIBUTE_VALUE#</option>
			</cfloop>
		</select>
		<label for="remark">Remark</label>
		<input type="text" name="remark" id="remark">
		<br><input type="submit" class="savBtn" value="Save LocalityCard">
	</form>
</cfif>
<cfif action is "saveNew">
	<cfset title="ES Imaging: Accn Cards: Dammit">
	<cftransaction>
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
			
			<br>accn: #accn#
			<cfquery name="vA" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select accn.transaction_id from 
					trans,accn where 
					trans.transaction_id=accn.transaction_id and
					trans.collection_id=21 and
					accn.accn_number='#accn#'
			</cfquery>
			<cfif vA.recordcount is 1>
				is valid (#vA.transaction_id#)
			<cfelse>
				is invalid Use your back button.
				<cfabort>
			</cfif>
			<cfif listlen(locid,"-") lt 3>
				locid must be of the format ......
				<cfabort>
			</cfif>
			<cfset p=listgetat(locid,1,"-")>
			<cfset ld=listgetat(locid,2,"-")>
			<cfset cc=listgetat(locid,3,"-")>
			<cfif listlen(locid,"-") gte 4>
				<cfset misp=listgetat(locid,4,"-")>
			</cfif>
			<cfif listlen(locid,"-") gte 5>
				<cfset masp=listgetat(locid,5,"-")>
			</cfif>
			<cfif p is not "AK">
				locid must be of the format ......
				<cfabort>
			</cfif>
			<cfif not isnumeric(ld) or ld lt 1 or ld gt 999>
				locid must be of the format ......
				<cfabort>
			</cfif>
			<cfif cc is not "V" and cc is not "P" and cc is not "I" and cc is not "G" and cc is not "M" >
				locid must be of the format ......
				<cfabort>
			</cfif>
			<cfif isdefined("misp")>
				<cfif not isnumeric(misp) or misp lt 1 or misp gt 999>
					locid must be of the format ......
					<cfabort>
				</cfif>
			</cfif>
			<cfif isdefined("masp")>
				<cfif not isnumeric(masp) or misp lt 1 or misp gt 999>
					locid must be of the format ......
					<cfabort>
				</cfif>
			</cfif>
			<cfif len(declat) + len(declong)  + len(error_m) gt 0>
				<cfif len(declat) is 0 or  len(declong) is 0 or  len(error_m) is 0>
					You must provide all or none of the three coordinate options
					<cfabort>
				</cfif>
				<cfif declat lt -90 or declat gt 90 or declong lt -180 or declong gt 180 or error_m lt 1>
					coordinates hosed
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
					locid,
					<cfif len(declat) gt 0>
						dec_lat,
						dec_long,
						error_m,
					</cfif>
					age,
					formation,
					remark
				) values (
					'#accn#',
					#vA.transaction_id#,
					'#barcode#',
					#vB.container_id#,
					'#locid#',
					<cfif len(declat) gt 0>
						#declat#,
						#declong#,
						#error_m#,
					</cfif>
					'#age#',
					'#formation#',
					'#escapeQuotes(remark)#'
				)
			</cfquery>
			<br>success!
	</cftransaction>
	<cflocation url="loccardscan.cfm" addtoken="false">
</cfif>
<cfif action is "list">
	<script src="/includes/sorttable.js"></script>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from loc_card_scan
	</cfquery>
	No edit here - delete and re-enter.
	
	<table border id="t" class="sortable">
		<tr>
			<th>Barcode</th>
			<th>Accn</th>
			<th>LocID</th>
			<th>Lat</th>
			<th>Lng</th>
			<th>Err</th>
			<th>age</th>
			<th>fmn</th>
			<th>Remark</th>
		</tr>
		<cfloop query="d">
			<tr>
				<td>#barcode#</td>
				<td>#accn_number#</td>
				<td>#locid#</td>
				<td>#dec_lat#</td>
				<td>#dec_long#</td>
				<td>#error_m#</td>
				<td>#age#</td>
				<td>#formation#</td>
				<td>#remark#</td>
				<td>
					<form name="die" method="post" action="loccardscan.cfm">
						<input type="hidden" name="action" value="delete">
						<input type="hidden" name="id" value="#id#">
						<input type="submit" value="delete">
					</form>
				</td>
			</tr>
		</cfloop>
	</table>
</cfif>
<cfif action is "delete">
	<cfset title="Ha-Ha: deleting">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from loc_card_scan where id=#id#
	</cfquery>
	deleted #id#
	<br><a href="loccardscan.cfm?action=list">back to list</a> or <a href="loccardscan.cfm?action=nothing">enter locality card data</a>
</cfif>


</cfoutput>
<cfinclude template="/includes/_footer.cfm">
