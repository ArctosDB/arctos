<cfinclude template="includes/_pickHeader.cfm">
<!------------------------------------------------------------------->
<cfif #Action# is "nothing">
<cfquery name="getLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT 
		authAgent.agent_name as authAgentName,
		trans_date,
		recAgent.agent_name as recAgentName,
		return_due_date,
		nature_of_material,
		trans_remarks,
		loan_instructions,
		loan_description,
		loan_type,
		loan_num_prefix,
		loan_num,
		loan_num_suffix,
		loan_status,
		loan_instructions		
	FROM 
		loan, 
		trans,
		preferred_agent_name authAgent,
		preferred_agent_name recAgent
	WHERE
		loan.transaction_id = trans.transaction_id AND
		trans.auth_agent_id = authAgent.agent_id (+) AND
		trans.received_agent_id = recAgent.agent_id AND
		loan.transaction_id=#transaction_id#		
</cfquery>

<cfoutput>
	<cfquery name="shipDate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select shipped_date from shipment where transaction_id=#transactioN_id#
	</cfquery>
<center>
<table width="800"><tr>
          <td> <center>
	
		<div align="right">
		  	<font size="1" face="Arial, Helvetica, sans-serif">
		  		<b>Loan ## #getLoan.loan_num_prefix#.#getLoan.loan_num# #getLoan.loan_num_suffix#</b>
			</font> 
		</div>
		<center><b>
              <font size="3">SPECIMEN&nbsp;&nbsp;INVOICE</font> 
			  <font size="4">
			  <br>MAMMAL&nbsp;&nbsp;COLLECTION 
              <br>
              UNIVERSITY&nbsp;&nbsp;of&nbsp;&nbsp;ALASKA&nbsp;&nbsp;MUSEUM 
			  </font>
			  <font size="3">
			<br>#dateformat(shipDate.shipped_date,"dd mmmm yyyy")#</b>
		</center>
			
			 <table cellpadding="0" cellspacing="0" width="600"><tr><td> 
			
            <p> 

  This document acknowledges the loan of specimens from the UAM Mammal Collection to:

<p>
	
</p>
<p>
<table width="100%"><tr>
<td align="left" width="60%">
<cfquery name="shipTo" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select formatted_addr from addr, shipment
	where addr.addr_id = shipment.shipped_to_addr_id AND
	shipment.transaction_id=#transaction_id#
</cfquery>
<blockquote>
	#replace(shipTo.formatted_Addr,"#chr(10)#","<br>","all")#
</blockquote>

</td>
<td align="right">
<table border="1" cellpadding="0" cellspacing="0" width="100%">
   <tr><td>
   Loan approved by:
   <br>&nbsp;
   <br>&nbsp;
   <hr>
   Link&nbsp;E.&nbsp;Olson,&nbsp;Curator&nbsp;of&nbsp;Mammals
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
                loaned from the UAM Mammal Collection should be acknowledged by 
                UAM catalog number in subsequent publications, reports, presentations 
                or GenBank submissions. A copy of reprints should be provided 
                to the UAM Mammal Collection. Please remember that you may only 
                use these materials for the study outlined in your original proposal. 
                You must obtain written permission from the UAM Curator of Mammals 
                for any use outside of the scope of your proposal, including the 
                transfer of UAM material to a third party. Thank you for your 
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
<blockquote> <font size="2">Dr. Link E. Olson <br>
                    University of Alaska Museum <br>
                    Mammal Collection <br>
                    907 Yukon Drive <br>
                    Fairbanks, Alaska 99775-6960 <br>
                    e-mail: ffleo@uaf.edu <br>
                    Office: (907) 474-5998&nbsp;&nbsp;Fax: (907) 474-5468</font> 
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
  <td><cfquery name="procBy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select agent_name from preferred_agent_name, shipment
	where preferred_agent_name.agent_id = shipment.packed_by_agent_id AND
	shipment.transaction_id=#transaction_id#
</cfquery>
                  <div align="right">
                    <font size="1" face="Arial, Helvetica, sans-serif">Loan processed 
                    by #procBy.agent_name#</font> </div></td>
   </tr></table>   
		  </td></tr></table>
</center>

</cfoutput>
</cfif>
<!------------------------------------------------------------------->











<!------------------------------------------------------------------->
<cfif #Action# is "itemList">
<cfoutput>
<cfquery name="getItems" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">

select 
		cat_num, 
		cataloged_item.collection_object_id,
		collection.collection_cde,
		collection.institution_acronym,
		af_num.af_num,
		part_name,
		 part_modifier,
		 preserve_method,
		condition,
		 sampled_from_obj_id,
		 item_instructions,
		 loan_item_remarks,
		 coll_obj_disposition,
		 scientific_name,
		 Encumbrance,
		 agent_name,
		 loan_num,
		 loan_num_prefix,
		 loan_num_suffix,
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
		 max_error_units
	 from 
		loan_item, 
		loan,
		af_num,
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
		cataloged_item.collection_object_id = af_num.collection_object_id (+) AND
		identification.accepted_id_fg = 1 AND
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		collecting_event.locality_id = locality.locality_id AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		locality.locality_id = accepted_lat_long.locality_id (+) AND
		cataloged_item.collection_id = collection.collection_id AND
	  loan_item.transaction_id = #transaction_id#
	  ORDER BY cat_num
</cfquery>
<table width="1100"><tr>
  <td> <div align="right"><font size="-1"> Loan ## #getItems.loan_num_prefix#.#getItems.loan_num# #getItems.loan_num_suffix# </font> <br>
    </div>
    <center>
    <b><font face="Arial, Helvetica, sans-serif">SPECIMEN&nbsp;&nbsp;INVOICE <br>
    <font size="+2"> MAMMAL&nbsp;&nbsp;COLLECTION <br>
    UNIVERSITY&nbsp;&nbsp;OF&nbsp;&nbsp;ALASKA&nbsp;&nbsp;MUSEUM</font></font></b> <br>
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
			<b>AF</b>
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
			#institution_acronym# #collection_cde# #cat_num#&nbsp;
		</td>
		<td>
			<cfif len(#af_num#) gt 0>
				AF&nbsp;#af_num#
			<cfelse>
				&nbsp;
			</cfif>
		</td>
		<td>
			<i>#scientific_name#</i>&nbsp;
		</td>
		<td>
			#part_modifier# #part_name# 
			<cfif len(#preserve_method#) gt 0>
				(#preserve_method#)&nbsp;
			</cfif>
			
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
<div align="right"><font size="-1"> Loan ## #getItems.loan_num_prefix#.#getItems.loan_num# #getItems.loan_num_suffix# </font> 
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
		collection_cde,
		af_num.af_num,
		part_name,
		 part_modifier,
		 preserve_method,
		condition,
		loan_num,
		 loan_num_prefix,
		 loan_num_suffix
	 from 
		loan_item, 
		loan,
		af_num,
		specimen_part, 
		coll_object,
		cataloged_item
	WHERE
		loan_item.collection_object_id = specimen_part.collection_object_id AND
		loan.transaction_id = loan_item.transaction_id AND
		specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
		specimen_part.collection_object_id = coll_object.collection_object_id AND
		cataloged_item.collection_object_id = af_num.collection_object_id (+) AND
		loan_item.transaction_id = #transaction_id#
</cfquery>
<table width="1200"><tr><td>
<font size="-1">
Loan ## #getItems.loan_num_prefix#.#getItems.loan_num# #getItems.loan_num_suffix#
</font>
<br>
<center>
    <b><font face="Arial, Helvetica, sans-serif">SPECIMEN&nbsp;&nbsp;INVOICE <br>
    <font size="+2"> MAMMAL&nbsp;&nbsp;COLLECTION <br>
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
			<b>AF</b>
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
			#collection_cde# #cat_num#&nbsp;
		</td>
		<td>
			#af_num#&nbsp;
		</td>
		
		<td>
			#part_modifier# #part_name# 
			<cfif len(#preserve_method#) gt 0>
				(#preserve_method#)&nbsp;
			</cfif>
			
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
<cfinclude template="includes/_pickFooter.cfm">

