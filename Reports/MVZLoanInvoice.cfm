<cfinclude template="/includes/_pickHeader.cfm">
<!------------------------------------------------------------------->
<cfif #Action# is "nothing">
<cfdocument 
	format="pdf"
	pagetype="letter"
	margintop=".25"
	marginbottom=".25"
	marginleft=".25"
	marginright=".25"
	orientation="portrait"
	fontembed="yes"
	filename="#Application.webDirectory#/temp/LoanInvoice.pdf" 
	overwrite="true">
<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">


<cf_getLoanFormInfo>
<cfoutput>
	<cfquery name="shipDate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select shipped_date from shipment where transaction_id=#transactioN_id#
	</cfquery>
	<cfquery name="shipTo" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select formatted_addr from addr, shipment
		where addr.addr_id = shipment.shipped_to_addr_id AND
		shipment.transaction_id=#transaction_id#
	</cfquery>
	<cfquery name="procBy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select agent_name from preferred_agent_name, shipment
		where preferred_agent_name.agent_id = shipment.packed_by_agent_id AND
		shipment.transaction_id=#transaction_id#
	</cfquery>
<div align="center">
<table width="800" height="1030">
	<tr>
    	<td valign="top">	
			<!---<div align="right">
				<font size="1" face="Arial, Helvetica, sans-serif">
					<b>Loan ## #getLoan.loan_number#</b>
				</font> 
			</div>--->
			<div align="center" style="font-weight:bold;">
		        <font size="3">SPECIMEN&nbsp;&nbsp;INVOICE</font> 
			  <font size="4">
			 <br />Museum of Vertebrate Zoology
                          <br />University of California, Berkeley
                          </font>
                          <font size="3">
                        <br>#dateformat(shipDate.shipped_date,"dd mmmm yyyy")#</b>
			</div>
		</td>
	</tr>
	<tr>
		<td>
			This document acknowledges the loan of specimens from the MVZ to:
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%">
				<tr>
					<td align="left" width="60%">
						<blockquote>
							<!---
							<cfif len(getLoan.outside_contact_name) is not 0 AND getLoan.outside_contact_name is not getLoan.recAgentName> <!--There is an outside contact-->

								<cfset rec_address_pos = find("#chr(10)#", getLoan.shipped_to_address)> <!--position of the actual address in shipped_to_address-->
								
								<cfset name_title = mid(getLoan.shipped_to_address, 1, rec_address_pos)>
								#replace(name_title, "<br>", "", "all")#<!--Loan Recipient's Name-->
								<br>	
								<!--- #getLoan.recAgentName# --->
								Attn: #getLoan.outside_contact_name# <!--Outside Contact Name-->
								#rereplace(getLoan.shipped_to_address, "#name_title#|#chr(10)#", "<br>", "all")# <!--Removes Loan Recipient's name from full address-->
							<cfelse>
								#replace(getLoan.shipped_to_address,"#chr(10)#","<br>","all")#
							</cfif>
							--->
							#replace(getLoan.shipped_to_address,"#chr(10)#","<br>","all")#
						</blockquote>
					</td>
					<td align="right" valign="top">
						<table border="1" cellpadding="0" cellspacing="0" width="100%">
							<tr>
						   		<td>
						   			Loan #getLoan.loan_number# approved by:
								   <br>&nbsp;
								   <br>&nbsp;
								   <hr>
								   #getLoan.authAgentName#<!--- #getLoan.contact_title# --->
								 </td>
							</tr>
						 </table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<b style="font-style:italic">Loan Type:</b> #getLoan.loan_type#
		</td>
	</tr>
	<tr>
		<td>
			<b>Nature of Material:</b>
			<!--- format for PDF --->
			<cfset nom = replace(getLoan.nature_of_material,"#chr(10)#","<br>","all")>
			<cfset nom = replace(nom,"<i>","","all")>
			<cfset nom = replace(nom,"</i>","","all")>
  					#nom#
		</td>
	</tr>
	<cfif len(#getLoan.loan_description#) gt 0>
		<tr>
			<td>
				<b>Description:</b>
 				&nbsp;#replace(getLoan.loan_description,"#chr(10)#","<br>","all")#
			</td>
		</tr>
	</cfif>
	<cfif len(#getLoan.loan_instructions#) gt 0>
		<tr>
			<td>
				 <b>Instructions:</b>
  				&nbsp;#getLoan.loan_instructions#
			</td>
		</tr>
	</cfif>
	<cfif len(#getLoan.trans_remarks#) gt 0>
		<tr>
			<td>
				<b>Remarks:</b>
 				&nbsp;#getLoan.trans_remarks#
			</td>
		</tr>
	</cfif>
	<tr>
		<td>
			UPON RECEIPT, SIGN AND RETURN ONE COPY TO:
		</td>
	</tr>
	<tr>
		<td>
			<table>
				<tr>
					<td>
						<blockquote> <font size="2">#replace(getLoan.inside_address,"#chr(10)#","<br>","all")#
						<br />Email: #getLoan.inside_email_address#</font> 
						  </blockquote>
					</td>
					<td align="right" width="300" valign="top">
						<div align="left" style="font-weight:bold; font-size:smaller;">
							Expected return date: #dateformat(getLoan.return_due_date,"dd mmmm yyyy")#
						</div>
                 		<table width="100%" border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td colspan="2">
									<div style="border:1px solid black;">
										<font size="2">Signature of recipient, date:</font>
										<br>&nbsp;
										<br>&nbsp;
									</div>									
								</td>
							</tr>
							<tr>
								<td>
									#getLoan.recAgentName#
								</td>
								<td>
									Date
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>			
		</td>
	</tr>
	<tr>
		<td>
			<div style="padding-left:30px; 
				padding-right:30px; 
				font-size:12px; 
				font-family:Verdana, Arial, Helvetica, sans-serif;
				border-bottom:1px solid black; border-top:1px solid black; text-align:justify;">
				<hr>
                <font size="1" face="Verdana, Arial, Helvetica, sans-serif">M<font face="Arial">aterial
                loaned from the MVZ should be acknowledged by
                MVZ catalog number in subsequent publications, reports, presentations
                or GenBank submissions. A copy of reprints should be provided
                to the MVZ. Please remember that you may
                use these materials only for the study outlined in your original proposal.
                You must obtain written permission from the MVZ Curator
                for any use outside of the scope of your proposal, including the
                transfer of MVZ material to a third party. Thank you for your
                cooperation.</font></font>
                <hr>
			</div>
		</td>
	</tr>
	<tr>
		<td>
			 <table width="100%">
			 	<tr>
					<td align="left">
						<font size="1">Printed #dateformat(now(),"dd mmmm yyyy")#</font>
					</td>
					<td>
					  <div align="right">
						<font size="1" face="Arial, Helvetica, sans-serif">Loan processed 
						by #procBy.agent_name#</font>
						</div>
					</td>
				</tr>
			</table>   
		</td>
	</tr>
</table>
</div>

</cfoutput>
</cfdocument>
<cfoutput >
	<cflocation url="/temp/LoanInvoice.pdf">
</cfoutput>
</cfif>
<!------------------------------------------------------------------->





<cfif #Action# is "itemLabels">
<!---
For this action:
Author: Peter DeVore, based on work by Dusty
Email: pdevore@berkeley.edu

Description:
	Used to make printable labels for specimens from Loan page.
Parameters:
	transaction_id
--->
<cfoutput>
<p>
	<a href="/temp/loaninvoice_#cfid#_#cftoken#.pdf" target="_blank">Get the PDF</a>
</p>
<cfparam default="Bird/Mammal" name="format">
Current format: #format#<br/>
<form action='MVZLoanInvoice.cfm' method="POST">
	<input type='hidden' name='action' value='itemLabels'>
	<input type='hidden' name='transaction_id' value='#transaction_id#'>
Change to: <select name="format">
		<option value="Bird/Mammal">Bird/Mammal</option>
		<option value="Herp">Herp</option>
	</select>
	<input type='submit' value='Change Format' />
</form>
</cfoutput>
<cfquery name="getItems" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		cataloged_item.cat_num, 
		cataloged_item.collection_object_id,
		identification.scientific_name,
		loan.loan_number,
		trans.trans_date,
		preferred_agent_name.agent_name
	 from 
		loan_item, 
		loan,
		specimen_part, 
		cataloged_item,
		identification,
		collecting_event,
		preferred_agent_name,
		trans,
		trans_agent
	WHERE
		loan_item.collection_object_id = specimen_part.collection_object_id AND
		loan.transaction_id = loan_item.transaction_id AND
		specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
		cataloged_item.collection_object_id = identification.collection_object_id AND
		identification.accepted_id_fg = 1 AND
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		trans.transaction_id = loan_item.transaction_id AND
		trans.transaction_id = trans_agent.transaction_id and 
		trans_agent.trans_agent_role = 'outside contact' and 
		trans_agent.agent_id = preferred_agent_name.agent_id AND
	    loan_item.transaction_id = #transaction_id#
	ORDER BY cat_num
</cfquery>

<!--- Set up the necessary variables --->

<!--- Layout parameters --->
<cfset maxCol = 2>
<cfif format is "Bird/Mammal">
	<cfset maxRow = 15>
</cfif>
<cfif format is "Herp">
	<cfset maxRow = 30>
</cfif>
<cfset numRecordsPerPage = maxCol * maxRow>
<cfset maxPage = (getItems.recordcount-1) \ numRecordsPerPage + 1>
<cfset curPage = 1>
<cfset curRecord = 1>


<!--- Formatting parameters --->
<cfset labelWidth = 'width: 368px;'>
<cfset labelBorder = 'border: 1px solid black;'>
<cfif format is "Bird/Mammal">
	<cfset textClass = "times10">
	<cfset dateStyle = "dd mmm<br>yyyy">
	<cfset labelStyle = 'height: 32px; #labelWidth# #labelBorder#'>
	<!--- This width is smaller because this date occupies two lines--->
	<cfset dateWidth = "width: 40px;">
	<!---<cfset sciNameWidth = "width: 60px;">--->
</cfif>
<cfif format is "Herp">
	<cfset textClass = "times8">
	<cfset dateStyle = "dd mmm yyyy">
	<cfset labelStyle = 'height: 17px; #labelWidth# #labelBorder#'>
	<!--- This width is larger because this date occupies one line--->
	<cfset dateWidth = "width: 50px;">
	<!---<cfset sciNameWidth = "width: 60px;">--->
</cfif>
<cfset outerTableParams = 'width="100%" cellspacing="0" cellpadding="0" border="0"'>
<cfset innerTableParams = 'width="100%" cellspacing="0" cellpadding="0" border="0"'>

<cfset pageHeader='
<div style="position:static; top:0; left:0; width:100%;">
	<span style="position:relative; left:0px; top:0px;  width:35%; font-size:10px; font-weight:600;">
	Page #curPage# of #maxPage#
	</span>
</div>
<table #outerTableParams#>
<tr>
<td valign="top">
<table #innerTableParams#>
'>
<cfset pageFooter = '
</table>
</td>
</tr>
</table>
'>
	
<!--- Document tags --->
<!--- TODO: figure out WHY the pdf i download from the link above is not getting changed...
sent email to dusty about it.
update -- seems to work now, I have no idea what fixed it... --->
<cfdocument 
	format="pdf"
	pagetype="letter"
	margintop=".25"
	marginbottom=".25"
	marginleft=".25"
	marginright=".25"
	orientation="landscape"
	fontembed="yes"
	filename="#Application.webDirectory#/temp/loaninvoice_#cfid#_#cftoken#.pdf"
	overwrite="yes">
<cfoutput>
<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">
<cfset pageHeader = replace(pageHeader,'Page #curPage-1# of','Page #curPage# of')>
#pageHeader#
<!--- Main loop --->
<cfloop query="getItems">
	
<!--- Data manipulation --->
<cfif format is "Bird/Mammal">
	<cfset sciName = #replace(scientific_name," ","&nbsp;","all")#>
	<!--- complicated and stupid, but it should work.
	The idea is to find all the spaces in the scientific name. Then find the 
	one that is closest to the center of the string. Change that space to a
	newline.
	--Peter DeVore --->
	<!--- Find the space locations --->
	<cfset thingToReplace = "&nbsp;">
	<cfset curLoc = 0>
	<cfset spaceLocs = "">
	<cfset loopin = true>
	<cfloop condition="loopin">
		<cfif find(thingToReplace,sciName,curLoc+1) is 0>
			<cfset loopin = false>
		<cfelse> 
			<cfset curLoc = find(thingToReplace,sciName,curLoc+1)>
			<cfset spaceLocs = ListAppend(spaceLocs,curLoc)>
		</cfif>
	</cfloop>
	
	<!--- If there are no spaces, then no need to do anything else! --->
	<cfif len(spaceLocs) gt 0>
		<!--- Convert the space locations into distances from center --->
		<cfset convertedSpaceLocs = "">
		<cfloop list="#spaceLocs#" index="loc">
			<cfset convertedSpaceLocs = abs(loc - (len(sciName)/2))>
		</cfloop>
		
		<!--- Sort those distances --->
		<cfset convertedSpaceLocs = ListSort(convertedSpaceLocs,"numeric")>
		
		<!--- Have not replaced a space yet --->
		<cfset replacedSpace = false>
		
		<!--- Try inserting newline if the closest space is after the center --->
		<cfset position = (len(sciName)/2) + ListFirst(convertedSpaceLocs)>
		<cfif find(thingToReplace, sciName, position) is position and not replacedSpace>
			<cfset sciName = insert("<br>", sciName, position-1)>
			<cfset replacedSpace = true>
		</cfif>
		
		<!--- Try inserting newline if the closest space is before the center --->
		<cfset position = (len(sciName)/2) - ListFirst(convertedSpaceLocs)>
		<cfif find(thingToReplace, sciName, position) is position and not replacedSpace>
			<cfset sciName = insert("<br>", sciName, position-1)>
			<cfset replacedSpace = true>
		</cfif>
	</cfif>
</cfif>
<cfif format is "Herp">
	<cfset sciName = #replace(scientific_name," ","&nbsp;","all")#>
</cfif>
<!--- End data manipulation --->
	
	<tr><td>
	<!--- here is where I could insert a div tag so that I could limit the space
	allotted per item, but make sure that the div tag size is a function or which format is chosen--->
	<div style="#labelStyle#">
	<table><tr>
		<td>
			<span class="#textClass#">#cat_num#</span>
		</td>
<!--- there is a sciname width problem (sample: transaction_id=11062560 in dev)
where it can be too big and force the slips onto the next line.
not much i can do about it: i tried limiting the width of it, but if you want
one line slips, then its going to take that much room and that's that.
--Peter DeVore--->
		<td>
			<div class="#textClass#"><i>#sciName#</i></span>	
		</td>
		<td>
			<span class="#textClass#">#getItems.loan_number#</span>
		</td>
		<td>
		<!--- mmm is Aug, while mmmm is August (diff formats)--->
			<div class="#textClass#" style="#dateWidth#">#dateformat(trans_date,dateStyle)#</div>	
		</td>
		<td>
			<span class="#textClass#">#agent_name#</span>	
		</td>
	</tr></table>
	</div>
	</td></tr>
	<!--- End Column? Do it after every #maxRow# labels --->
	<cfif curRecord mod maxRow is 0>
		</table></td>
		<!--- But only add a new column if that wasn't the last record AND we aren't at a page break --->
		<cfif curRecord lt getItems.recordCount and curRecord mod numRecordsPerPage is not 0>
			<td valign='top'><table #innerTableParams#>
		</cfif>
	</cfif>
	<!--- Page break? --->
	<cfif curRecord mod numRecordsPerPage is 0 AND curRecord lt getItems.recordcount>
		<cfset curPage = curPage + 1>
		<!--- end the old table, pagebreak, and begin the new one--->
		#pageFooter#<cfdocumentitem type="pagebreak"></cfdocumentitem>
		<cfset pageHeader = replace(pageHeader,'Page #curPage-1# of','Page #curPage# of')>
		#pageHeader#
	</cfif>
	<!--- and finish our current record --->
	<cfset curRecord=#curRecord#+1>
</cfloop>
#pageFooter#
</cfoutput>
</cfdocument>
<cfinclude template = "../includes/_footer.cfm">
</cfif>




<!------------------------------------------------------------------->
<cfif #Action# is "shippingLabel">
<cfinclude template='../includes/_header.cfm'>
<!---
For this action:
Author: Peter DeVore
Email: pdevore@berkeley.edu

Description:
	Used to make printable shipping labels for specimens from Loan.cfm page.
Parameters:
	transaction_id
Based on:
	other actions in this page
--->

<cfparam name="shipped_to_addr" default = "">
<cfparam name="shipped_to_addr_id" default = "">
<cfparam name="shipped_from_addr" default = "">
<cfparam name="shipped_from_addr_id" default = "">
<cfquery name="ship" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from shipment where transaction_id = #transaction_id#
</cfquery>
<!--- Test to see if there are shipping addresses. --->
<cfif ship.recordcount gt 0>
	<cfquery name="shipped_to_addr_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select formatted_addr from addr where 
		addr_id = #ship.shipped_to_addr_id#
	</cfquery>
		<cfset shipped_to_addr = "#shipped_to_addr_id.formatted_addr#">
	<cfquery name="shipped_from_addr_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select formatted_addr from addr where 
		addr_id = #ship.shipped_from_addr_id#
	</cfquery>
		<cfset shipped_from_addr = "#shipped_from_addr_id.formatted_addr#">
<cfoutput>
<p>
	<a href="/temp/loaninvoice_#cfid#_#cftoken#.pdf" target="_blank">Get the PDF</a>
</p>
</cfoutput>


<!--- Define formatting params --->
<cfset fromToClass = "times9b">
<cfset fromAddrClass = "times10">
<cfset toAddrClass = "times12b">
<cfset addrStyle = "text-align: center;">
<cfset checkboxTextClass = 'times10'>
<cfset checkboxStyle = "border: 1px solid black; padding: -.25em 0em -.25em 0em;">
<!--- End formatting params --->
<cfdocument 
	format="pdf"
	pagetype="letter"
	margintop=".25"
	marginbottom=".25"
	marginleft=".25"
	marginright=".25"
	orientation="portrait"
	fontembed="yes"
	filename="#Application.webDirectory#/temp/loaninvoice_#cfid#_#cftoken#.pdf"
	overwrite="yes">
<cfoutput>
<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">
<!--- we want two copies of the label, so we do a loop that runs twice --->
<cfloop from="0" index="whatever" to="1">
<div style="width: 300px; height: 195px; border: 1px black dashed; padding: 5px;">
	<table><tr><td valign="top"><span class="#fromToClass#">From:</span></td>
	<td><div class="#fromAddrClass#" style="#addrStyle#">
		<blockquote>
			#replace(shipped_from_addr,"#chr(10)#","<br>","all")#
		</blockquote>
	</div></td></tr></table>
	<hr>
	<table><tr><td valign="top"><span class="#fromToClass#">To:</span></td>
	<td><div class="#toAddrClass#" style="#addrStyle#">
		<blockquote>
			#replace(shipped_to_addr,"#chr(10)#","<br>","all")#
		</blockquote>
	</div></td></tr></table>
	<!--- It seems that, as of Coldfusion 7, cfdocument does not support Times 
	New Roman White Box character. From this, I assume that it cannot support 
	one other non keyboard characters.Thus to make a checkbox I put in spaces 
	and surround it with a black border. I then adjust the padding until it is 
	the right size/shape. Thankfully, this does not need be cross-browser
	compatible because it is made ONLY at the Arctos server. Thus, this only 
	needs to be updated if the font of the text around it changes or if the 
	server changes its HTML formatting drastically.
	--Peter DeVore, 2008-02-06 --->
	<!--- previously tried any of the following (numbers were for spacing them to test)
	<cfoutput>
	-2 #charsetEncode(binaryDecode("e296a1","hex"),"utf-8")#
	-1 &##9633;
	0 &##x2610;
	1 &##9744;
	2 #charsetEncode(binaryDecode("feff25A1","hex"),"utf-16")#
	3 &##x25a1;
	These are the unicode characters for different boxes. See above comment as 
	to why I don't use them.
	</cfoutput>--->
	<span class="#checkboxTextClass#"><span style='#checkboxStyle#'>&nbsp;&nbsp;</span>
	Printed Matter</span><br/>
	<span class="#checkboxTextClass#"><span style='#checkboxStyle#'>&nbsp;&nbsp;</span>
	Scientific Specimens/No endangered species/No commercial value</span><br/>
	<span class="#checkboxTextClass#"><span style='#checkboxStyle#'>&nbsp;&nbsp;</span>
	Insured</span><br/>
	<div class="#checkboxTextClass#" style="text-align: center;">Value _____________</div>
</div>
</cfloop>
</cfoutput>	
</cfdocument>
<cfelse>
No Addresses for this loan to make a shipping label from!
</cfif>
<cfinclude template = "../includes/_footer.cfm">
</cfif>



<!------------------------------------------------------------------->
<cfif #Action# is "itemList">
<cfoutput>
Splitting pages up is tricky. There is no automatic wrap function, and the data vary widely between loans. 15 rows per page (17 on pages other than the first) works well most of the time. If there are problems with wrapping pages, select a new value in the form below, submit the query, and check the new PDF that will be generated.
<p></p>
Number of rows to print per page:
<p></p>
<form name="a" method="post" action="MVZLoanInvoice.cfm">
	<input type="hidden" name="action" value="itemList" />
	<input type="hidden" name="transaction_id" value="#transaction_id#" />
	Rows: <input type="text" name="numRowsFPage" value="15" />
	<input type="submit" />
	
	
</form>
<p>
	<a href="/temp/LoanInvoice.pdf" target="_blank">Get the PDF</a>
</p>
</cfoutput>
<!----

	
	---->
	<cfdocument 
	format="pdf"
	pagetype="letter"
	margintop=".25"
	marginbottom=".25"
	marginleft=".25"
	marginright=".25"
	orientation="landscape"
	fontembed="yes"
	 filename="#Application.webDirectory#/temp/LoanInvoice.pdf"
	 overwrite="yes" >
	
<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">

<cfoutput>
<cfquery name="getItems" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
select 
		cat_num, 
		cataloged_item.collection_object_id,
		collection.collection,
		concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
		concatattributevalue(cataloged_item.collection_object_id,'sex') as sex,
		decode (sampled_from_obj_id,
			null,part_name,
			part_name || ' sample') part_name,
		 part_modifier,
		 preserve_method,
		condition,
		 item_instructions,
		 loan_item_remarks,
		 coll_obj_disposition,
		 scientific_name,
		 Encumbrance,
		 agent_name,
		 loan_number,
		 spec_locality,
		 higher_geog,
		 orig_lat_long_units,
		 lat_deg, 
		 lat_min,
		 lat_sec,
		 long_deg,
		 long_min,
		 long_sec,
		 dec_lat_min,
		 dec_long_min,
		 lat_dir,
		 long_dir,
		 dec_lat,
		 dec_long,
		 max_error_distance,
		 max_error_units,
		 decode(orig_lat_long_units,
				'decimal degrees',to_char(dec_lat) || '&deg; ',
				'deg. min. sec.', to_char(lat_deg) || '&deg; ' || to_char(lat_min) || '&acute; ' || to_char(lat_sec) || '&acute;&acute; ' || lat_dir,
				'degrees dec. minutes', to_char(lat_deg) || '&deg; ' || to_char(dec_lat_min) || '&acute; ' || lat_dir
			)  VerbatimLatitude,
			decode(orig_lat_long_units,
				'decimal degrees',to_char(dec_long) || '&deg;',
				'deg. min. sec.', to_char(long_deg) || '&deg; ' || to_char(long_min) || '&acute; ' || to_char(long_sec) || '&acute;&acute; ' || long_dir,
				'degrees dec. minutes', to_char(long_deg) || '&deg; ' || to_char(dec_long_min) || '&acute; ' || long_dir
			)  VerbatimLongitude
	 from 
		loan_item, 
		loan,
		specimen_part, 
		coll_object,
		cataloged_item,
		coll_object_encumbrance,
		encumbrance,
		agent_name,
		identification,
		collecting_event,
		locality,
		geog_auth_rec,
		accepted_lat_long,
		collection
	WHERE
		loan_item.collection_object_id = specimen_part.collection_object_id AND
		loan.transaction_id = loan_item.transaction_id AND
		specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
		specimen_part.collection_object_id = coll_object.collection_object_id AND
		coll_object.collection_object_id = coll_object_encumbrance.collection_object_id (+) and
		coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id (+) AND
		encumbrance.encumbering_agent_id = agent_name.agent_id (+) AND
		cataloged_item.collection_object_id = identification.collection_object_id AND
		identification.accepted_id_fg = 1 AND
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		collecting_event.locality_id = locality.locality_id AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		locality.locality_id = accepted_lat_long.locality_id (+) AND
		cataloged_item.collection_id = collection.collection_id AND
	  loan_item.transaction_id = #transaction_id#
	  ORDER BY cat_num
</cfquery>
<cfquery name="one" dbtype="query">
	select 
		cat_num, 
		customid,
		collection_object_id,
		collection,
		sex,
		scientific_name,
		Encumbrance,
		agent_name,
		loan_number,
		spec_locality,
		higher_geog,
		orig_lat_long_units,
		lat_deg, 
		lat_min,
		lat_sec,
		long_deg,
		long_min,
		long_sec,
		dec_lat_min,
		dec_long_min,
		lat_dir,
		long_dir,
		dec_lat,
		dec_long,
		max_error_distance,
		max_error_units,
		VerbatimLatitude,
		VerbatimLongitude
	FROM
		getItems
	GROUP BY
		cat_num, 
		customid,
		collection_object_id,
		collection,
		sex,
		scientific_name,
		Encumbrance,
		agent_name,
		loan_number,
		spec_locality,
		higher_geog,
		orig_lat_long_units,
		lat_deg, 
		lat_min,
		lat_sec,
		long_deg,
		long_min,
		long_sec,
		dec_lat_min,
		dec_long_min,
		lat_dir,
		long_dir,
		dec_lat,
		dec_long,
		max_error_distance,
		max_error_units,
		VerbatimLatitude,
		VerbatimLongitude
	ORDER BY cat_num
</cfquery>
<cfquery name="more" dbtype="query">
	select 
		collection_object_id,
		part_name,
		part_modifier,
		preserve_method,
		condition,
		item_instructions,
		loan_item_remarks,
		coll_obj_disposition
	from 
		getItems
	GROUP BY
		collection_object_id,
		part_name,
		part_modifier,
		preserve_method,
		condition,
		item_instructions,
		loan_item_remarks,
		coll_obj_disposition
</cfquery>
<!--- get number of pages we'll have 
	<cfset lChars = 0>
	<cfset numberOfPages = 1>
	<cfloop query="one">
		<cfset lChars = #lChars# + len(#higher_geog#) + len(#spec_locality#)>
		<cfif #numberOfPages# is 1>
			<cfif #lChars# gte 1000>
				<cfset numberOfPages = #numberOfPages# + 1>
				<cfset lChars=0>
			</cfif>
		<cfelse>
			<cfif #lChars# gte 1100>
				<cfset numberOfPages = #numberOfPages# + 1>
				<cfset lChars=0>
			</cfif>
		</cfif>
	</cfloop>
	
	--->
	<cfif not isdefined("numRowsFPage")>
		<cfset numRowsFPage = 15>
	</cfif>
	<cfif not isdefined("numRowsNPage")>
		<cfset numRowsNPage = #numRowsFPage# + 2>
	</cfif>
	<!--- 12 rows on the first page --->
	<cfif one.recordcount lte #numRowsFPage#>
		<cfset numberOfPages = 1>
	<cfelse>
		<!--- 14 rows on other pages --->
		<cfset numberOfPages = ceiling((one.recordcount + 1) / #numRowsFPage#)>
	</cfif>
	
	<cfset i=1>
	<cfset pageRow = 1>
	<cfset page_num = 1>
	
<div style="position:absolute; left:5px; top:5px;font-size:10px; font-weight:600;">
	Page 1 of #numberOfPages#
</div>
<div style="position:absolute; right:5px; top:5px; font-size:10px; font-weight:600;">
	Loan&nbsp;##&nbsp;#getItems.loan_number#
</div>
<div style=" width:100%; " align="center">
         <b><font face="Arial, Helvetica, sans-serif">SPECIMEN&nbsp;&nbsp;INVOICE <br>
   	
	<font size="+2"> Museum of Vertebrate Zoology <br>
    University of California, Berkeley</font></font></b> <br>
        <cfquery name="shipDate" datasource="#Application.web_user#">
                select shipped_date from shipment where transaction_id=#transactioN_id#
        </cfquery>
   <b> #dateformat(shipDate.shipped_date,"dd mmmm yyyy")#</b>
   <br>
      <font face="Courier New, Courier, mono"><b>Item List</b></font>
</div>
<table width="100%" cellspacing="0" cellpadding="0" id="goodborder">
	<tr>
		<td align="center">
			<span class="times12b">CN</span>
		</td>
		<td align="center">
			<span class="times12b">#session.CustomOtherIdentifier#</span>
		</td>
		<td align="center">
			<span class="times12b">Scientific Name</span>
		</td>
		<td align="center">
			<span class="times12b">Sex</span>
		</td>
		<td align="center">
			<span class="times12b">Locality</span>
		</td>
		<td align="center">
			<span class="times12b">Item</span>
		</td>
		<td align="center">
			<span class="times12b">Condition</span>
		</td>
		
		<td align="center">
			<span class="times12b">More?</span>
		</td>
		
	</tr>
	
	<cfloop query="one">
	<cfquery name="items" dbtype="query">
		select * from more where collection_object_id = #collection_object_id#
	</cfquery>
	<cfset numItemsForThisSpec = #items.recordcount#>
	<cfset isMore = "">
	
	
	
	
	
	
	

	<tr	#iif(i MOD 2,DE("style='background-color:E5E5E5'"),DE("style='background-color:FFFFFF'"))#	>
		<td rowspan="#numItemsForThisSpec#">
			<span class="times10">#collection#&nbsp;#cat_num#</span>
		</td>
		<td rowspan="#numItemsForThisSpec#">
			#CustomID#&nbsp;
		</td>
		
		<td rowspan="#numItemsForThisSpec#">
			<span class="times10"><i>#replace(scientific_name," ","&nbsp;","all")#</i></span>	
		</td>
		<td rowspan="#numItemsForThisSpec#">
			<span class="times10">#sex#</span>	
		</td>
		<td rowspan="#numItemsForThisSpec#">
			<!---
			<cfset p=#p# + len(#higher_geog#) + len(#spec_locality#)>
			--->
			<span class="times10">
				#higher_geog#. <br>#spec_locality#<br />
			<cfif len(#VerbatimLatitude#) gt 0 and len(#VerbatimLongitude#) gt 0>
				#VerbatimLatitude#/#VerbatimLongitude# &##177; #max_error_distance# #max_error_units#
			<cfelse>
				Not georeferenced.
			</cfif>
			</span>			
		</td>
		<cfset thisItemRow = 1>
		<cfloop query="items">
		<cfif #thisItemRow# gt 1>
			<tr	#iif(i MOD 2,DE("style='background-color:CCCCCC'"),DE("style='background-color:FFFFFF'"))#	>
		</cfif>
		<td >
			<span class="times10">
				#items.part_modifier# #items.part_name# 
				<cfif len(#items.preserve_method#) gt 0>
					(#items.preserve_method#)&nbsp;
				</cfif>
			</span>	
			
			
		</td>
		<td >
			<span class="times10">
				<cfif len(#items.Condition#) gt 15>
				See attached.
			  <cfelse>
			  	#items.Condition#	
			</cfif>&nbsp;
			</span>
			
		</td>
		<td >
			<div class="times10" style="width:100%; text-align:center;">
			<cfif len(#items.Condition#) gt 15 OR len(#one.Encumbrance#) gt 0>
				X
			</cfif>
			</div>
		</td>
		<cfif #thisItemRow# gt 1>
			</tr>
		</cfif>
		<cfset thisItemRow = #thisItemRow#+1>
		</cfloop>
	</tr>
	<cfset i=#i#+1>
	<cfset pageRow=#pageRow# + 1>
	<!---
	<cfif #page_num# is 199999 AND #pageRow# is #numRowsFPage#>
		<cfset pageBreakNow = "true">
	<cfelseif #page_num# gt 1 AND #pageRow# is #numRowsNPage#>
		<cfset pageBreakNow = "true">
	<cfelse>
		<cfset pageBreakNow = "false">
	</cfif> 
	--->
	<cfif #page_num# is 1 AND #pageRow# is #numRowsFPage# AND #i# lte #one.recordcount#>
		<cfset pageBreakNow = "true">
	<cfelseif #page_num# gt 1 AND #pageRow# is #numRowsNPage# AND #i# lte #one.recordcount#>
		<cfset pageBreakNow = "true">
	<cfelse>
		<cfset pageBreakNow = "false">
	</cfif> 
	
	
	
	<cfif #pageBreakNow# is "true">
		</table>
		<!---
		
		<hr />#i# - #pageRow# - #page_num# - first pagebreak<hr />
		
		---->
	&nbsp;
		
		
		<cfdocumentitem type="pagebreak"></cfdocumentitem>
		<cfset page_num = #page_num# + 1>
		<cfset pageRow=0>
		<!--- end the old table --->
		<div style="position:static; top:0; left:0; width:100%;">
			<span style="position:relative; left:0px; top:0px;  width:35%; font-size:10px; font-weight:600;">
					Page #page_num# of #numberOfPages#
				</span>
				<span style="position:relative; right:0px; top:0px; float:right;  width:35%; text-align:right; font-size:10px; font-weight:600;">
					Loan ## #getItems.loan_number#
				</span>
		</div>
		
		<!--- start a new page and table
		<div style="position:static; top:0; left:0; width:100%;">
				<span style="position:relative; left:0px; top:0px;  width:35%; font-size:10px; font-weight:600;">
					Page #page_num# of #numberOfPages#
				</span>
				<span style="position:relative; right:0px; top:0px; float:right;  width:35%; text-align:right; font-size:10px; font-weight:600;">
					Loan ## #getItems.loan_num_prefix#.#getItems.loan_num# #getItems.loan_num_suffix#
				</span>
			</div>
 --->
			<table width="100%" border="1" cellspacing="0" cellpadding="0"  id="goodborder">
	<tr>
		<td align="center">
			<span class="times12b">CN</span>
		</td>
		<td align="center">
			<span class="times12b">#session.CustomOtherIdentifier#</span>
		</td>
		<td align="center">
			<span class="times12b">Scientific Name</span>
		</td>
		<td align="center">
			<span class="times12b">Sex</span>
		</td>
		<td align="center">
			<span class="times12b">Locality</span>
		</td>
		<td align="center">
			<span class="times12b">Item</span>
		</td>
		<td align="center">
			<span class="times12b">Condition</span>
		</td>
		
		<td align="center">
			<span class="times12b">More?</span>
		</td>
		
	</tr>
		
	</cfif>
</cfloop></table>

</cfoutput>

</cfdocument>
<!---

--->

</cfif>
<!------------------------------------------------------------------->
<!------------------------------------------------------------------->
<cfif #Action# is "showCondition">
<cfoutput>
<cfdocument 
	format="pdf"
	pagetype="letter"
	margintop=".25"
	marginbottom=".25"
	marginleft=".25"
	marginright=".25"
	orientation="landscape"
	fontembed="yes" >
	
<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">
<cfquery name="getItems" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
select 
		cat_num, 
		collection,
		part_name,
		 part_modifier,
		 preserve_method,
		condition,
		loan_number,
		concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID
	 from 
		loan_item, 
		loan,
		specimen_part, 
		coll_object,
		cataloged_item,
		collection
	WHERE
		loan_item.collection_object_id = specimen_part.collection_object_id AND
		loan.transaction_id = loan_item.transaction_id AND
		specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
		cataloged_item.collection_id = collection.collection_id AND
		specimen_part.collection_object_id = coll_object.collection_object_id AND
		loan_item.transaction_id = #transaction_id#
	ORDER BY cat_num
</cfquery>
<!--- get number of pages we'll have --->
	<cfset lChars = 0>
	<cfset numberOfPages = 1>
	<cfloop query="getItems">
		<cfset lChars = #lChars# + len(#condition#)>
		<cfif #numberOfPages# is 1>
			<cfif #lChars# gte 1200>
				<cfset numberOfPages = #numberOfPages# + 1>
				<cfset lChars=0>
			</cfif>
		<cfelse>
			<cfif #lChars# gte 1100>
				<cfset numberOfPages = #numberOfPages# + 1>
				<cfset lChars=0>
			</cfif>
		</cfif>
	</cfloop>
<div style="position:absolute; left:5px; top:5px; font-size:10px; font-weight:600;">
	Page 1 of #numberOfPages#
</div>
<div style="position:absolute; right:5px; top:5px; font-size:10px; font-weight:600;" >
	Loan&nbsp;##&nbsp;#getItems.loan_number#
</div>

<div style=" width:100%; " align="center">
         <b><font face="Arial, Helvetica, sans-serif">SPECIMEN&nbsp;&nbsp;INVOICE <br>
   <font size="+2"> Museum of Vertebrate Zoology <br>
    University of California, Berkeley</font></font></b> <br>
        <cfquery name="shipDate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
                select shipped_date from shipment where transaction_id=#transactioN_id#
        </cfquery>
   <b> #dateformat(shipDate.shipped_date,"dd mmmm yyyy")#</b>
   <br>
      <font face="Courier New, Courier, mono"><b>Condition Appendix</b></font>
</div>


<table width="100%"  border="1" cellspacing="0" cellpadding="0">
	<tr>
		<td align="center">
			<span class="times12b">CN</span>
		</td>
		<td align="center">
			<span class="times12b">#session.CustomOtherIdentifier#</span>
		</td>
		<td align="center">
			<span class="times12b">Item</span>
		</td>
		<td align="center">
			<span class="times12b">Condition</span>
		</td>
		
	</tr>
	<cfset i=1>
	<cfset p = 1>
	<cfloop query="getItems">

<cfif len(#Condition#) gt 15>
					
			

	<tr>
		<td>
			<span class="times10">
			#collection# #cat_num#&nbsp;
			</span>
		</td>
		<td>
			<span class="times10">
			#customID#&nbsp;
			</span>
		</td>
		
		<td>
			<span class="times10">
			#part_modifier# #part_name# 
			<cfif len(#preserve_method#) gt 0>
				(#preserve_method#)&nbsp;
			</cfif>
			</span>
		</td>
		<td>
				<span class="times10">
				#Condition#
				</span>
		</td>
		
	</tr>
	<cfset i=#i#+1>

</cfif>
</cfloop>
</table>
</cfdocument>
</cfoutput>
</cfif>
<cfinclude template="/includes/_pickFooter.cfm">