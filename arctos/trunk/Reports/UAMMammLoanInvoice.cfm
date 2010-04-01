<cfinclude template="/includes/_frameHeader.cfm">
<!------------------------------------------------------------------->
<cfif #Action# is "nothing">
<!---
	--->
	<cfdocument overwrite="true"
	format="pdf"
	pagetype="letter"
	margintop=".25"
	marginbottom=".25"
	marginleft=".25"
	marginright=".25"
	orientation="portrait"
	fontembed="yes"
	filename="#Application.webDirectory#/temp/UamMammLoanHead.pdf" >
<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">
<cf_getLoanFormInfo>

<cfquery name="sponsor" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		agent_name,
		acknowledgement
	FROM
		project_sponsor,
		project_trans,
		accn,
		cataloged_item,
		agent_name
	WHERE 
		project_sponsor.project_id = project_trans.project_id AND
		project_sponsor.agent_name_id = agent_name.agent_name_id AND
		accn.transaction_id = cataloged_item.accn_id AND 
		 project_trans.transaction_id = accn.transaction_id AND
		 cataloged_item.collection_object_id IN (
			 select 
				specimen_part.derived_from_cat_item
			from 
				loan_item,
				specimen_part
			where 
				loan_item.collection_object_id = specimen_part.collection_object_id AND
				transaction_id = #transaction_id#
			)
	GROUP BY
		agent_name,
		acknowledgement		
</cfquery>
<cfoutput>

<div align="center">
<table width="800" height="1030">
	<tr>
    	<td valign="top">	
			<div align="right">
				<font size="1" face="Arial, Helvetica, sans-serif">
					<b>Loan ## #getLoan.loan_number#</b>
				</font> 
			</div>
			<div align="center" style="font-weight:bold;">
		        <font size="3">SPECIMEN&nbsp;&nbsp;INVOICE</font> 
			  <font size="4">
			  <br>MAMMAL&nbsp;&nbsp;COLLECTION 
              <br>
              UNIVERSITY&nbsp;&nbsp;of&nbsp;&nbsp;ALASKA&nbsp;&nbsp;MUSEUM 
			  </font>
			  <font size="3">
			<br>#dateformat(getLoan.shipped_date,"dd mmmm yyyy")#
			</div>
		</td>
	</tr>
	<tr>
		<td>
			This document acknowledges the loan of specimens from the UAM Mammal Collection to:
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%">
				<tr>
					<td align="left" width="60%">
						<blockquote>
							#replace(getLoan.shipped_to_address,"#chr(10)#","<br>","all")#
						</blockquote>
					</td>
					<td align="right" valign="top">
						<table border="1" cellpadding="0" cellspacing="0" width="100%">
							<tr>
						   		<td>
						   			Loan approved by:
								   <br>&nbsp;
								   <br>&nbsp;
								   <hr>
								   Link&nbsp;E.&nbsp;Olson,&nbsp;Curator&nbsp;of&nbsp;Mammals
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
	<cfif #sponsor.recordcount# gt 0>
		<tr>
			<td>
				<b>Sponsors:</b>
				<blockquote>
					<cfloop query="sponsor">
						#agent_name#&nbsp;#acknowledgement#<br>
					</cfloop>
				</blockquote>
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
						<blockquote> <font size="2">Dr. Link E. Olson <br>
							University of Alaska Museum <br>
							Mammal Collection <br>
							907 Yukon Drive <br>
							Fairbanks, Alaska 99775-6960 <br>
							e-mail: ffleo@uaf.edu <br>
							Office: (907) 474-5998&nbsp;&nbsp;Fax: (907) 474-5468</font> 
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
				 Material 
                loaned from the UAM Mammal Collection must be acknowledged by 
                UAM catalog number in subsequent publications, reports, presentations 
                or GenBank submissions (GenBank now has a field for voucher numbers). A copy of reprints should be provided 
                to the UAM Mammal Collection. Please remember that you may only 
                use these materials for the study outlined in your original proposal. 
                You must obtain written permission from the UAM Curator of Mammals 
                for any use outside of the scope of your proposal, including the 
                transfer of UAM material to a third party. Thank you for your 
                cooperation.
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
						by #getLoan.processed_by_name#</font>
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
<!---

--->
<cfoutput>
	<a href="#Application.ServerRootUrl#/temp/UamMammLoanHead.pdf">Click to view PDF, or right-click and save to disk</a>
</cfoutput>
</cfif>
<!------------------------------------------------------------------->

<!------------------------------------------------------------------->
<cfif #Action# is "itemList">
<cfoutput>
Splitting pages up is tricky. There is no automatic wrap function, and the data vary widely between loans. 15 rows per page (17 on pages other than the first) works well most of the time. If there are problems with wrapping pages, select a new value in the form below, submit the query, and check the new PDF that will be generated.
<p></p>
Number of rows to print per page:
<p></p>
<form name="a" method="post" action="UAMMammLoanInvoice.cfm">
	<input type="hidden" name="action" value="itemList" />
	<input type="hidden" name="transaction_id" value="#transaction_id#" />
	Rows: <input type="text" name="numRowsFPage" value="15" />
	<input type="submit" />
	
	
</form>
<p>
	<a href="/temp/UAMMammLoanInvoice.pdf" target="_blank">Get the PDF</a>
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
	 filename="#Application.webDirectory#/temp/UAMMammLoanInvoice.pdf"
	 overwrite="yes" >
	
<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">

<cfoutput>
<cfquery name="getItems" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">

select 
		cat_num, 
		cataloged_item.collection_object_id,
		collection.collection_cde,
		collection.institution_acronym,
		concatsingleotherid(cataloged_item.collection_object_id,'AF') as af_num,
		concatsingleotherid(cataloged_item.collection_object_id,'original identifier') as fieldnum,
		concatattributevalue(cataloged_item.collection_object_id,'sex') as sex,
		decode (sampled_from_obj_id,
			null,part_name,
			part_name || ' sample') part_name,
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
		collection_object_id,
		collection_cde,
		institution_acronym,
		af_num,
		fieldnum,
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
		collection_object_id,
		collection_cde,
		institution_acronym,
		af_num,
		fieldnum,
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
		condition,
		item_instructions,
		loan_item_remarks,
		coll_obj_disposition
	from 
		getItems
	GROUP BY
		collection_object_id,
		part_name,
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
    <font size="+2"> MAMMAL&nbsp;&nbsp;COLLECTION <br>
    UNIVERSITY&nbsp;&nbsp;OF&nbsp;&nbsp;ALASKA&nbsp;&nbsp;MUSEUM</font></font></b> <br>
	<cfquery name="shipDate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<span class="times12b">AF</span>
		</td>
		<td align="center">
			<span class="times12b">Field ##</span>
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
			<span class="times10">#institution_acronym#&nbsp;#collection_cde#&nbsp;#cat_num#</span>
		</td>
		<td rowspan="#numItemsForThisSpec#">
			<cfif len(#af_num#) gt 0>
				<span class="times10">AF&nbsp;#af_num#</span>				
			<cfelse>
				<span class="times10">&nbsp;</span>
			</cfif>
		</td>
		<td rowspan="#numItemsForThisSpec#">
			<cfif len(#fieldnum#) gt 0>
				<span class="times10">#fieldnum#</span>				
			<cfelse>
				<span class="times10">&nbsp;</span>
			</cfif>
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
				#items.part_name#
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
			<span class="times12b">AF</span>
		</td>
		<td align="center">
			<span class="times12b">Field ##</span>
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
		collection_cde,
		concatsingleotherid(cataloged_item.collection_object_id,'AF') as af_num,
		part_name,
		condition,
		loan_number
	 from 
		loan_item, 
		loan,
		specimen_part, 
		coll_object,
		cataloged_item
	WHERE
		loan_item.collection_object_id = specimen_part.collection_object_id AND
		loan.transaction_id = loan_item.transaction_id AND
		specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
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
    <font size="+2"> MAMMAL&nbsp;&nbsp;COLLECTION <br>
    UNIVERSITY&nbsp;&nbsp;OF&nbsp;&nbsp;ALASKA&nbsp;&nbsp;MUSEUM</font></font></b> <br>
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
			<span class="times12b">AF</span>
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
			#collection_cde# #cat_num#&nbsp;
			</span>
		</td>
		<td>
			<span class="times10">
			#af_num#&nbsp;
			</span>
		</td>
		
		<td>
			<span class="times10">
			#part_name#
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

