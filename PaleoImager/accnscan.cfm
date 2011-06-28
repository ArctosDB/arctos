<!---
	create table accn_scan (
		id number not null,
		accn_number varchar2(30) not null,
		accn_id number,
		remark varchar2(255) not null,
		barcode varchar2(255) not null,
		container_id number,
		who varchar2(255),
		when date
	);
	
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
		    		:new.when,
		    		:new.who
		    	from dual;
		    end;                                                                                            
		/
		

		CREATE PUBLIC SYNONYM accn_scan FOR accn_scan;
		GRANT all ON accn_scan to data_entry;
		
--->

<cfinclude template="/includes/_header.cfm">
<cfoutput>
<cfset numAccnRow=10>
<cfif action is "nothing">
	<a href="accnscan.cfm?action=enter">enter data</a>
</cfif>
<cfif action is "enter">
	<form name="f" action="accnscan.cfm" method="post">
		<input type="hidden" name="action" value="saveNew">
		<table border>
			<tr>
				<th>Row</th>
				<th>Barcode</th>
				<th>Accn</th>
				<th>Comment</th>
			</tr>
			<cfloop from="1" to="#numAccnRow#" index="#i#"> 
				<tr>
					<td>#i#</td>
					<td>
						<input type="text" name="barcode_#i#" id="barcode_#i#">
					</td>
					<td>
						<input type="text" name="accn_#i#" id="accn_#i#">
					</td>
					<td>
						<input type="text" name="remark_#i#" id="remark_#i#">
					</td>
				</tr>
			</cfloop>
			<input type="submit">
		</table>
	</form>
</cfif>
<cfif action is "saveNew">
	<!---------
	<cftransaction>
	<cfloop from="1" to="#numAccnRow#" index="i">
		<cfset tBarcode = evaluate("barcode_" & i)>
		<cfif len(tBarcode) gt 0>
			<cfset tAccn = evaluate("accn_" & i)>
			<cfset tRemark = evaluate("remark_" & i)>
			<hr>row #i#
			<br>barcode: #tBarcode#
			<cfquery name="vB" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select container_id from container where barcode='#tBarcode#'
			</cfquery>
			<cfif vB.recordcount is 1>
				is valid (#vB.container_id#)
			<cfelse>
				is invalid. Use your back button.
				<cfabort>
			</cfif>
			
			<br>accn: #tAccn#
			<cfquery name="vA" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select transaction_id from 
					trans,accn where 
					trans.transaction_id=accn.transaction_id and
					trans.collection_id=21 and
					accn.accn_number='#tAccn#'
			</cfquery>
			<cfif vA.recordcount is 1>
				is valid (#vA.transaction_id#)
			<cfelse>
				is invalid Use your back button.
				<cfabort>
			</cfif>
			
			<br>comment: #tRemark#
			<br>inserting....
			<cfquery name="vA" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into accn_scan (
					accn_number,
					accn_id,
					remark,
					barcode,
					container_id
				) values (
					'#tAccn#',
					#vA.transaction_id#,
					'#escapeQuotes(tRemark)#',
					'#tBarcode#',
					#vB.container_id#
				)
			</cfquery>
			<br>success!
		</cfif>
	</cfloop>
	</cftransaction>
	---------------->
</cfif>
</cfoutput>
<cfinclude template="/includes/_header.cfm">
