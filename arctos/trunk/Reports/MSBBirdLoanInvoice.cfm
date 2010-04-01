<cfinclude template="/includes/_pickHeader.cfm">
<!------------------------------------------------------------------->
<cfif #Action# is "nothing">
<cfdocument 
	format="flashpaper"
	pagetype="letter"
	margintop="0"
	marginbottom="0"
	marginleft="0"
	marginright="0"
	orientation="portrait"
	fontembed="yes" >
	
	<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">


<cf_getLoanFormInfo>
<cfoutput>
	
<center>
<table width="800"><tr>
          <td> <center>
	
		<div align="right">
		  	<font size="1" face="Arial, Helvetica, sans-serif">
		  		<b>Loan ## #getLoan.loan_number#</b>
			</font> 
		</div>
		<center><b>
              <font size="3">SPECIMEN&nbsp;&nbsp;INVOICE</font> 
			  <font size="4">
			  <br>BIRD&nbsp;&nbsp;COLLECTION 
              <br>
              UNIVERSITY&nbsp;of&nbsp;NEW&nbsp;MEXICO&nbsp;&##45;&nbsp;MUSEUM of SOUTHWESTERN BIOLOGY
			  </font>
			  <font size="3">
			<br>#dateformat(getLoan.shipped_date,"dd mmmm yyyy")#</b>
		</center>
			
			 <table cellpadding="0" cellspacing="0" width="600"><tr><td> 
			
            <p> 

  This document acknowledges the loan of 
  specimens 
  <br>from the MSB Bird Collection to:

<p>
	
</p>
<p>
<table width="100%"><tr>
<td align="left" width="60%">

<blockquote>
	#replace(getLoan.shipped_to_address,"#chr(10)#","<br>","all")#
</blockquote>

</td>
<td align="right">
<table border="1" cellpadding="0" cellspacing="0" width="100%">
   <tr><td>
   Loan approved by:
   <br>&nbsp;
   <br>&nbsp;
   <hr>
   <span style="font-size:smaller">
   Robert&nbsp;W.&nbsp;Dickerman,&nbsp;Acting&nbsp;Curator
   </span>
   </td></tr>
  </table>
</td>
</tr></table>


  <p>
  	<b>Loan Type:</b> #getLoan.loan_type#
  
   <p><b>Nature of Material:</b>
  &nbsp;#replace(getLoan.nature_of_material,"#chr(10)#","<br>","all")#
  <cfif len(#getLoan.loan_description#) gt 0>
<p><b>Description:</b>
 &nbsp;#replace(getLoan.loan_description,"#chr(10)#","<br>","all")#
  </cfif>
  
  
 
  
  <cfif len(#getLoan.loan_instructions#) gt 0>
  <p><b>Instructions:</b>
  &nbsp;#getLoan.loan_instructions#
  </cfif>
  
  <cfif len(#getLoan.trans_remarks#) gt 0>
  <p><b>Remarks:</b>
 &nbsp;#getLoan.trans_remarks#
  </cfif>
  <p>
  </font>
  </td></tr></table></center>
<table width="780" cellpadding="0" cellspacing="0"><tr><td>
 <hr>
                <font size="1" face="Verdana, Arial, Helvetica, sans-serif">M<font face="Arial">aterial 
                loaned from the MSB Bird Collection should be acknowledged by 
                MSB catalog number in subsequent publications, reports, presentations 
                or GenBank submissions. A copy of reprints should be provided 
                to the MSB Bird Collection. Please remember that you may only 
                use these materials for the study outlined in your original proposal. 
                You must obtain written permission from the MSB Curator of Birds 
                for any use outside of the scope of your proposal, including the 
                transfer of MSB material to a third party. Thank you for your 
                cooperation.</font></font> 
                <hr>
	</td></tr></table>
 
  <p>
  <font size="3">
  <center>
  <table width="780" cellpadding="0" cellspacing="0"><tr><td colspan="2">
   
   <p>UPON RECEIPT, SIGN AND RETURN ONE COPY TO:
   </tr></td>
   <tr><td>
<blockquote> <font size="2">
Andrew Johnson<br />
Collection Manager<br />
Division of Birds<br />
Museum of Southwestern Biology<br />
Department of Biology<br />
University of New Mexico<br />
Albuquerque, New Mexico 87131<br />

<!----
 Dr. Joseph Cook, Curator<br>
Department of Biology<br>
Museum of Southwestern Biology<br>
Mammalogy, CERIA 240<br>
MSC03 2020<br>
1 University of New Mexico<br>
Albuquerque, New Mexico USA, 87131-0001<br>
505-277-1358 (fax 277-1351)<br>
cookjose@unm.edu<br>
website: http://msb.unm.edu<br>
---->
                  </blockquote>
  </td>
                <td align="right" width="300" valign="top"> <div align="left"><b>Expected return date: #dateformat(getLoan.return_due_date,"dd mmmm yyyy")#</b> </div>
                  <table width="100%" border="1" cellpadding="0" cellspacing="0">
  <tr>
                      <td> <font size="2">Signature of recipient, date:</font> 
                        <br>
                        &nbsp;
	<br>&nbsp;
	<hr>
	#getLoan.recAgentName#
  </td></tr>
  </table>
  </font>
  </td>
  </tr></table>
  </center>
  
 
   <table width="100%"><tr><td align="left">
    <font size="1">Printed #dateformat(now(),"dd mmmm yyyy")#</font> 
   </td>
  <td>
                  <div align="right">
                    <font size="1" face="Arial, Helvetica, sans-serif">Loan processed 
                    by #getLoan.processed_by_name#</font> </div></td>
   </tr></table>   
		  </td></tr></table>
</center>

</cfoutput>
</cfdocument>
</cfif>
<!------------------------------------------------------------------->











<!------------------------------------------------------------------->
<cfif #Action# is "itemList">
<cfoutput>
<cfquery name="getItems" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">

select 
		cat_num, 
		cataloged_item.collection_object_id,
		collection,
		part_name,
		condition,
		 sampled_from_obj_id,
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
		 concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID
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
		cataloged_item.collection_id = collection.collection_id and
		collecting_event.locality_id = locality.locality_id AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		locality.locality_id = accepted_lat_long.locality_id (+) AND
	  loan_item.transaction_id = #transaction_id#
	  ORDER BY cat_num
</cfquery>
<table width="1100"><tr>
  <td> <div align="right"><font size="-1"> Loan ## #getItems.loan_number# </font> <br>
    </div>
    <center>
    <b><font face="Arial, Helvetica, sans-serif">SPECIMEN&nbsp;&nbsp;INVOICE <br>
    <font size="+2"> BIRD&nbsp;&nbsp;COLLECTION <br>
    UNIVERSITY&nbsp;&nbsp;OF&nbsp;&nbsp;NEW&nbsp;MEXICO&nbsp;&nbsp;MUSEUM</font></font></b> <br>
	<cfquery name="shipDate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select shipped_date from shipment where transaction_id=#transactioN_id#
	</cfquery>
   <b> #dateformat(shipDate.shipped_date,"dd mmmm yyyy")#</b>
   <br>
      <font face="Courier New, Courier, mono"><b>Item List</b></font> 
      <p>
</center>
<table width="100%"border>
	<tr>
		<td align="center">
			<b>CN</b>
		</td>
		<td align="center">
			<b>#session.CustomOtherIdentifier#</b>
		</td>
		<td align="center">
			<b>Scientific Name</b>
		</td>
		<td align="center">
			<b>Item</b>
		</td>
		<td align="center">
			<b>Condition</b>
		</td>
		<td align="center">
			<b>Subsample?</b>
		</td>
		<!----
		<td align="center">
			<b>Item Instructions</b>
		</td>
		<td align="center">
			<b>Item Remarks</b>
		</td>
		---->
		
		<td align="center">
			<b>Locality</b>
		</td>
		<td align="center">
			<b>Encumbrance</b>
		</td>
		
	</tr>
	<cfset i=1>
	<cfset p = 1>
	<cfloop query="getItems">



	<tr>
		<td>
			#collection# #cat_num#&nbsp;
		</td>
		<td>
			#CustomID#&nbsp;
		</td>
		<td>
			<i>#scientific_name#</i>&nbsp;
		</td>
		<td>
			#part_name#
		</td>
		<td>
			<cfif len(#Condition#) gt 15>
				See attached.
			  <cfelse>
			  	#Condition#	
			</cfif>&nbsp;
		</td>
		<td>
			<cfif len(#sampled_from_obj_id#) gt 0>
				yes
			<cfelse>
				no
			</cfif>
		</td>
		<!-----
		<td>
			#Item_Instructions#&nbsp;
		</td>
		<td>
			#loan_Item_Remarks#&nbsp;
		</td>
			----->
		
		<td>
			#higher_geog#. <br>#spec_locality#
			<br>
			<cfif #orig_lat_long_units# is "deg. min. sec.">
				#lat_deg#<sup>0</sup> 
				#lat_min#<sup>'</sup> 
				#lat_sec#<sup>''</sup> 
				#lat_dir# 
				#long_deg#<sup>0</sup> 
				#long_min#<sup>'</sup>
				#long_sec#<sup>''</sup>
				#long_dir# 
				&##177; #max_error_distance# #max_error_units#
				<cfelseif #orig_lat_long_units# is "decimal degrees">
					#dec_lat# #dec_long# &##177; #max_error_distance# #max_error_units#
				<cfelseif #orig_lat_long_units# is "degrees dec. minutes">
					#lat_deg#<sup>0</sup> 
					#dec_lat_min#<sup>'</sup> 
					#lat_dir# 
					#long_deg#<sup>0</sup> 
					#dec_long_min#<sup>'</sup>
					#long_dir# &##177; #max_error_distance# #max_error_units#
				<cfelse>
					Not georeferenced.
			</cfif>
			
		</td>
		<td>
			#Encumbrance# <cfif len(#agent_name#) gt 0> by #agent_name#</cfif>&nbsp;
		</td>
		
		
	</tr>
	<cfset i=#i#+1>


</cfloop></table>
<div align="right"><font size="-1"> Loan ## #getItems.loan_number# </font> 
    </div>
</td></tr></table>
	
</cfoutput>
</cfif>
<!------------------------------------------------------------------->
<!------------------------------------------------------------------->
<cfif #Action# is "showCondition">
<cfoutput>
<cfquery name="getItems" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">

select 
		cat_num, 
		collection,
		part_name,
		condition,
		loan_number,
		concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID
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
</cfquery>
<table width="1200"><tr><td>
<font size="-1">
Loan ## #getItems.loan_number#
</font>
<br>
<center>
    <b><font face="Arial, Helvetica, sans-serif">SPECIMEN&nbsp;&nbsp;INVOICE <br>
    <font size="+2"> BIRD&nbsp;&nbsp;COLLECTION <br>
    UNIVERSITY&nbsp;&nbsp;OF&nbsp;&nbsp;ALASKA&nbsp;&nbsp;MUSEUM</font></font></b> <br>
	<cfquery name="shipDate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select shipped_date from shipment where transaction_id=#transactioN_id#
	</cfquery>
   <b> #dateformat(shipDate.shipped_date,"dd mmmm yyyy")#</b>
   <br>
      <font face="Courier New, Courier, mono"><b>Condition Appendix</b></font> 
      <p>
</center>
<table width="100%"border>
	<tr>
		<td align="center">
			<b>CN</b>
		</td>
		<td align="center">
			<b>#session.CustomOtherIdentifier#</b>
		</td>
		<td align="center">
			<b>Item</b>
		</td>
		<td align="center">
			<b>Condition</b>
		</td>
		
	</tr>
	<cfset i=1>
	<cfset p = 1>
	<cfloop query="getItems">

<cfif len(#Condition#) gt 15>
					
			

	<tr>
		<td>
			#collection# #cat_num#&nbsp;
		</td>
		<td>
			#CustomID#&nbsp;
		</td>		
		<td>
			#part_name# 
		</td>
		<td>
				#Condition#
		</td>
		
	</tr>
	<cfset i=#i#+1>

</cfif>
</cfloop></table>
</cfoutput>
</cfif>
<cfinclude template="/includes/_pickFooter.cfm">

