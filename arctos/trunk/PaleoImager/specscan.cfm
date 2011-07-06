<!---
	create table spec_scan (
		id number not null,
		id_type varchar2(30) not null,
		id_number varchar2(30) not null,
		remark varchar2(255),
		barcode varchar2(255) not null,
		container_id number,
		taxon_name varchar2(255) not null,
		taxon_name_id number,
		part_name varchar2(255),
		who varchar2(255),
		when date
	);
	
	
	create unique index u_pi_accn_barcode on accn_scan(barcode) tablespace uam_idx_1;
	create unique index u_pi_accn_accn on accn_scan(accn_number) tablespace uam_idx_1;
	
	create sequence sq_accn_scan_id;
	
	CREATE OR REPLACE TRIGGER tg_accn_scan_key                                         
 		before insert ON accn_scan
		 for each row
		    begin
		    	select
		    		sq_accn_scan_id.nextval,
		    		sys_context('USERENV', 'SESSION_USER'),
		    		sysdate 
		    	into 
		    		:new.id,
		    		:new.who,
		    		:new.when
		    	from dual;
		    end;                                                                                            
		/
		

		CREATE PUBLIC SYNONYM accn_scan FOR accn_scan;
		GRANT all ON accn_scan to data_entry;
		
--->

<cfinclude template="/includes/_header.cfm">
<cfoutput>
	form will be:
	
	<p>
		AK ## (controlled, must match value entered for locality card)
		<br>Taxon Name (controlled pick)
		<br>Barcode (scan it)
		<br>Part Name (controlled pick, optional)
	</p>
	
<cfif action is "nothing">
	<script>
		jQuery(document).ready(function() {
	  		$("##barcode").focus();
	  		jQuery("##taxon_name").autocomplete("/PaleoImager/data/sciname.cfm", {
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
			if ($("##id_type").val()=='AK') {
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
		}
	</script>
	<cfset title="ES Imaging: Specimens">
	Use this form to enter specimen data.
	<br>Sucessful save will silently redirect to an empty form. Errors will be listed; use your back button to fix them.
	"UI_bla bla bla" errors are Unique Index problems: we've already got one.
	<br>See existing data <a href="specscan.cfm?action=list">[ here ]</a>
	<hr>
	<form name="f" action="specscan.cfm" method="post">
		<input type="hidden" name="action" value="saveNew">
		<label for="barcode">Barcode</label>
		<input type="text" name="barcode" id="barcode">
		<label for="id_type">ID Type</label>
		<select name="id_type" id="id_type">
			<option value="AK">AK</option>
			<option value="ES">ES</option>
		</select>
		<label for="idnum">ID Num (AK## or ES ##)</label>
		<input type="text" name="idnum" id="idnum" class="reqdClr" onblur="checkLoc(this.value)">
		<label for="taxon_name">Taxon Name</label>
		<input type="text" name="taxon_name" id="taxon_name" class="reqdClr">
		<label for="part_name">Part</label>
		<input type="text" name="part_name" id="part_name">
		<label for="remark">Remark</label>
		<input type="text" name="remark" id="remark">
		<br><input type="submit" class="savBtn" value="Save">
	</form>
</cfif>
<cfif action is "saveNew">
	<cfset title="ES Imaging: Specimens: Dammit">
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
			
			<br>locid: #locid#
			<cfset lid=listgetat(locid,2,"-")>
			<cfset typ=listgetat(locid,3,"-")>
			<!---
			select locid,
substr(locid, 1, instr(locid,'-',1,1)-1) first, -- first col
substr(locid, instr(locid,'-',1,1)+1,
instr(locid, '-', 1,2)
- instr(locid, '-', 1,1)-1) secnd, -- second col
substr(locid, instr(locid,'-',1,2)+1,
instr(locid, '-', 1,3)
- instr(locid, '-', 1,2)-1)	thrd
from
loc_card_scan
;

--->
			<cfquery name="vLID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					locid 
				from 
					loc_card_scan 
				where
					substr(locid, instr(locid,'-',1,1)+1,instr(locid, '-', 1,2) - instr(locid, '-', 1,1)-1)='#lid#' and
					substr(locid, instr(locid,'-',1,2)+1,instr(locid, '-', 1,3) - instr(locid, '-', 1,2)-1)='#typ#'
			</cfquery>
			<cfif vLID.recordcount is not 1>
				locid has #vLID.recordcount# matches - <cfdump var=#vLID#>
				<cfabort>
			<cfelse>
				is spiffy
			</cfif>
			taxon_name: #taxon_name#
			<cfquery name="vTID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					taxon_name_id 
				from 
					taxonomy 
				where
					scientific_name='#taxon_name#'
			</cfquery>
			<cfif vTID.recordcount is not 1>
				taxon name (case sensitive string match) has #vTID.recordcount# matches - <cfdump var=#vTID#>
				<cfabort>
			<cfelse>
				is spiffy
			</cfif>
			
			<br>comment: #remark#
			<br>inserting....
			<cfquery name="vA" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into spec_scan (
					id_type,
					id_number,
					remark,
					barcode,
					container_id,
					taxon_name,
					taxon_name_id,
					part_name
				) values (
					'#accn#',
					#vA.transaction_id#,
					'#escapeQuotes(remark)#',
					'#barcode#',
					#vB.container_id#
				)
				
					create table  (
		id number not null,
		 varchar2(30) not null,
		 varchar2(30) not null,
		remark varchar2(255),
		barcode varchar2(255) not null,
		container_id number,
		 varchar2(255) not null,
		 number,
		 varchar2(255),
		who varchar2(255),
		when date
	);
			</cfquery>
			<br>success!
	</cftransaction>
	<cflocation url="specscan.cfm" addtoken="false">
</cfif>
<cfif action is "list">
	<script src="/includes/sorttable.js"></script>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from accn_scan
	</cfquery>
	<table border id="t" class="sortable">
		<tr>
			<th>Barcode</th>
			<th>Accn</th>
			<th>Remark</th>
		</tr>
		<cfloop query="d">
			<tr>
				<td>#barcode#</td>
				<td>#accn_number#</td>
				<td>#remark#</td>
			</tr>
		</cfloop>
	</table>
</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
