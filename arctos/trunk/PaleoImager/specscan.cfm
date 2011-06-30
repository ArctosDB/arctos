<!---
	create table accn_scan (
		id number not null,
		accn_number varchar2(30) not null,
		accn_id number,
		remark varchar2(255),
		barcode varchar2(255) not null,
		container_id number,
		who varchar2(255),
		when date
	);
	
	alter table accn_scan modify remark null;
	
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
	<cfabort>
	
<cfset numAccnRow=1>
<cfif action is "nothing">
	<script>
		jQuery(document).ready(function() {
	  		$("##barcode").focus();
		});
	</script>
	<cfset title="ES Imaging: Accn Cards">
	Use this form to attach barcodes to UAM Paleo Accesson Cards.
	<br>Barcode and Accession are exact case-sensitive match.
	<br>Sucessful save will silently redirect to an empty form. Errors will be listed; use your back button to fix them.
	"UI_bla bla bla" errors are Unique Index problems: we've already got one.
	<br>See existing data <a href="accnscan.cfm?action=list">[ here ]</a>
	<hr>
	<form name="f" action="accnscan.cfm" method="post">
		<input type="hidden" name="action" value="saveNew">
		<label for="barcode">Barcode</label>
		<input type="text" name="barcode" id="barcode">
		<label for="accn">Accn</label>
		<input type="text" name="accn" id="accn">
		<label for="remark">Remark</label>
		<input type="text" name="remark" id="remark">
		<br><input type="submit" class="savBtn" value="Save Accn/Barcode">
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
			
			<br>comment: #remark#
			<br>inserting....
			<cfquery name="vA" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into accn_scan (
					accn_number,
					accn_id,
					remark,
					barcode,
					container_id
				) values (
					'#accn#',
					#vA.transaction_id#,
					'#escapeQuotes(remark)#',
					'#barcode#',
					#vB.container_id#
				)
			</cfquery>
			<br>success!
	</cftransaction>
	<cflocation url="accnscan.cfm" addtoken="false">
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
