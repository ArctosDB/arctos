<cffunction name="get_loan_trunc" access="public" returntype="Query">
    <cf_getLoanFormInfo>
    <cfquery name="d" dbtype="query">
        select * from getLoan
    </cfquery>
	<cfset instrLen=75>
	<cfset snip="<i>... {see attached}</i>">
	<!--- chop off everything right of the first linefeed --->
	<cfif find(chr(10),d.loan_instructions)>
		<cfset d.loan_instructions = left(d.loan_instructions,find(chr(10),d.loan_instructions)-2) & snip>
	</cfif>
	<cfif d.loan_instructions gt instrLen>
		<cfset d.loan_instructions = replace(d.loan_instructions,snip,"")>
		<cfset d.loan_instructions=left(d.loan_instructions,instrLen) & snip>
	</cfif>
    <cfreturn d>
</cffunction>
<!-------------------------------------------------------------->
<cffunction name="format_uam_box" access="public" returntype="Query">
    <cfargument name="d" required="true" type="query">
	<cfset lAr = ArrayNew(1)>
	<cfset sAr = ArrayNew(1)>
	<cfset idAr = ArrayNew(1)>
	<cfset cAr = ArrayNew(1)>
	<cfset aAr = ArrayNew(1)>
	<cfset pAr = ArrayNew(1)>
	<cfset dAr = ArrayNew(1)>
	<cfset i=1>
	<cfloop query="d">
		<cfset geog = "">
		<cfif state_prov is "Alaska">
			<cfset geog = "USA: Alaska">
			<cfif len(island) gt 0>
				<cfset geog = "#geog#, #island#">
			</cfif>
			<cfif len(#sea#) gt 0>
				<cfif len(#quad#) is 0>
					<cfset geog = "#geog#, #sea#">
				</cfif>
			</cfif>
			<cfif len(#quad#) gt 0>
					<cfif not #geog# contains " Quad">
						<cfset geog = "#geog#, #quad# Quad">
					</cfif>
			</cfif>
		<cfif len(#feature#) gt 0>
				<cfset geog = "#geog#, #feature#">
			</cfif>
			<cfif len(#spec_locality#) gt 0>
				<cfset geog = "#geog#; #spec_locality#">
			</cfif>
		<cfelse>
		  	<cfif len(#country#) gt 0>
				<cfif #country# is "United States">
					<cfset geog = "USA: ">
				</cfif>
				<cfset geog = "#country#: ">
			</cfif>
			<cfif len(#sea#) gt 0>
				<cfset geog = "#geog#, #sea#">
			</cfif>
			<cfif len(#state_prov#) gt 0>
				<cfset geog = "#geog#, #state_prov#">
			</cfif>
			<cfif len(#island#) gt 0>
				<cfset geog = "#geog#, #island#">
			</cfif>
			<cfif len(#quad#) gt 0>
				<cfset geog = "#geog#, #quad# Quad">
			</cfif>
			<cfif len(#feature#) gt 0>
				<cfset geog = "#geog#, #feature#">
			</cfif>
			<cfif len(#spec_locality#) gt 0>
				<cfset geog = "#geog#; #spec_locality#">
			</cfif>
		</cfif>
		<cfset geog=replace(geog,": , ",": ","all")>
		<cfset lAr[i] = #geog#>
	
		<cfset sexcode = "">
		<cfif len(#trim(sex)#) gt 0>
			<cfif #trim(sex)# is "male">
				<cfset sexcode = "M">
			<cfelseif #trim(sex)# is "female">
				<cfset sexcode = "F">
			<cfelse>
				<cfset sexcode = "?">
			</cfif>
		</cfif>
		<cfset sAr[i] = #sexcode#>
		
		<cfset idNum = "">
		<cfset af = "">
		<cfset id = "">
		<cfset lo = "">
		<cfloop list="#other_ids#" index="val" delimiters=";">
			<cfif #val# contains "original identifier=">
				<cfset id = "Field##: #replace(val,"original identifier=","")#">
			<cfelseif #val# contains "AF=">
				<cfset af = "#replace(val,"="," ")#">
			<cfelse>
				<cfset lo="#replace(val,"="," ")#">
			</cfif>
		</cfloop>
		<cfif len(af) gt 0>
			<cfset idNum=af>
		<cfelseif len(id) gt 0>
			<cfset idnum=id>
		<cfelseif len(lo) gt 0>
			<cfset idnum=lo>
		</cfif>
		<cfset idAr[i] = #idNum#>
		
		<cfif #collectors# contains ",">
			<Cfset spacePos = find(",",collectors)>
			<cfset thisColl = left(collectors,#SpacePos# - 1)>
			<cfset thisColl = "#thisColl# et al.">
		<cfelse>
			<cfset thisColl = #collectors#>
		</cfif>
		<cfset cAr[i] = #collectors#>
		
		<cfset totlen = "">
		<cfset taillen = "">
		<cfset hf = "">
		<cfset efn = "">
		<cfset weight = "">
		<cfset totlen_val = "">
		<cfset taillen_val = "">
		<cfset hf_val = "">
		<cfset efn_val = "">
		<cfset weight_val = "">
		<cfset totlen_units = "">
		<cfset taillen_units = "">
		<cfset hf_units = "">
		<cfset efn_units = "">
		<cfset weight_units = "">
			

		<cfloop list="#attributes#" index="attind" delimiters=";">
			<cfset sPos=find(":",attind)>
			<cfif sPos gt 0>
				<cfset att=left(attind,sPos-1)>
				<cfset aVal=right(attind,len(attind)-sPos-1)>
				<cfif #trim(att)# is "total length">
					<cfset totlen = "#aVal#">
				<cfelseif #trim(att)# is "tail length">
					<cfset taillen = "#aVal#">
				<cfelseif #trim(att)# is "hind foot with claw">
					<cfset hf = "#aVal#">
				<cfelseif #trim(att)# is "ear from notch">	
					<cfset efn = "#aVal#">
				<cfelseif #trim(att)# is "weight">
					<cfset weight = "#aVal#">
				</cfif>
			</cfif>
		</cfloop>
		<cfif len(#totlen#) gt 0>
			<cfset meas = #totlen#>
		<cfelse>
			<cfset meas="X">
		</cfif>
		<cfif len(#taillen#) gt 0>
			<cfset meas = "#meas#-#taillen#">
		<cfelse>
			<cfset meas = "#meas#-X">
		</cfif>
		<cfif len(#hf#) gt 0>
			<cfset meas = "#meas#-#hf#">
		<cfelse>
			<cfset meas = "#meas#-X">
		</cfif>
		<cfif len(#efn#) gt 0>
			<cfset meas = "#meas#-#efn#">
		<cfelse>
			<cfset meas = "#meas#-X">
		</cfif>
		<cfif len(#weight#) gt 0>
			<cfset meas = "#meas#=#weight#">
		<cfelse>
			<cfset meas = "#meas#=X">
		</cfif>
		<cfset meas=replace(meas,"mm","","all")>
		<cfset aAr[i] = #meas#>
			
		<cfset stripParts = "">
		<cfset tiss = "">
		<cfloop list="#parts#" delimiters=";" index="p">
			<cfif #p# contains "frozen">
				<cfset tiss="tissues (frozen)">
			<cfelse>
				<cfif len(#stripParts#) is 0>
					<cfset stripParts = #p#>
				<cfelse>
					<cfset stripParts = "#stripParts#; #p#">
				</cfif>
			</cfif>
		</cfloop>
		
		<cfif len(#tiss#) gt 0>
			<cfset stripParts = "#stripParts#; #tiss#">
		</cfif>
		<cfif left(stripParts,2) is "; ">
			<cfset stripParts = right(stripParts,len(stripParts) - 2)>
		</cfif>
		<cfset pAr[i] = #stripParts#>
		<cfset thisDate = "">
		<cftry>
			<cfif isdate(verbatim_date)>
				<cfset thisDate = #dateformat(verbatim_date,"dd mmm yyyy")#>
			<cfelse>
				<cfset thisDate = verbatim_date>
			</cfif>	
			<cfcatch>
				<cfset thisDate = #verbatim_date#>
			</cfcatch>
		</cftry>
		<cfset dAr[i] = thisDate>

			<cfset i=i+1>
		</cfloop>
		
		<cfset temp=queryAddColumn(d,"locality","VarChar",lAr)>
		<cfset temp=queryAddColumn(d,"sexcode","VarChar",sAr)>
		<cfset temp=queryAddColumn(d,"idNum","VarChar",idAr)>
		<cfset temp=queryAddColumn(d,"formatted_collectors","VarChar",cAr)>
		<cfset temp=queryAddColumn(d,"measurements","VarChar",aAr)>
		<cfset temp=queryAddColumn(d,"formatted_parts","VarChar",pAr)>	
		<cfset temp=queryAddColumn(d,"formatted_date","VarChar",dAr)>		

	 <cfreturn d>
</cffunction>
<!---------------------------------------------------------------------->
<cffunction name="format_uam_vial" access="public" returntype="Query">
    <cfargument name="d" required="true" type="query">
	<cfset lAr = ArrayNew(1)>
	<cfset sAr = ArrayNew(1)>
	<cfset idAr = ArrayNew(1)>
	<cfset cAr = ArrayNew(1)>
	<cfset aAr = ArrayNew(1)>
	<cfset pAr = ArrayNew(1)>
	<cfset dAr = ArrayNew(1)>
	<cfset i=1>
	<cfloop query="d">
		<cfset geog = "">
		<cfif #state_prov# is "Alaska">
			<cfset geog = "USA: Alaska">
			<cfif len(#island#) gt 0>
				<cfset geog = "#geog#, #island#">
			</cfif>
			<cfif len(#sea#) gt 0>
				<cfif len(#quad#) is 0>
					<cfset geog = "#geog#, #sea#">
				</cfif>
			</cfif>
			<!---
			<cfif len(#quad#) gt 0>
					<cfif not #geog# contains " Quad">
						<cfset geog = "#geog#, #quad# Quad">
					</cfif>
			</cfif>
			---->
			<cfif len(#feature#) gt 0>
				<cfset geog = "#geog#, #feature#">
			</cfif>
			<cfif len(#spec_locality#) gt 0>
				<cfset geog = "#geog#; #spec_locality#">
			</cfif>
		<cfelse>
		  	<cfif len(#country#) gt 0>
				<cfif #country# is "United States">
					<cfset geog = "USA: ">
				</cfif>
				<cfset geog = "#country#: ">
			</cfif>
			<cfif len(#sea#) gt 0>
				<cfset geog = "#geog#, #sea#">
			</cfif>
			<cfif len(#state_prov#) gt 0>
				<cfset geog = "#geog#, #state_prov#">
			</cfif>
			<cfif len(#island#) gt 0>
				<cfset geog = "#geog#, #island#">
			</cfif>
			<!---
			<cfif len(#quad#) gt 0>
				<cfset geog = "#geog#, #quad# Quad">
			</cfif>
			---->
			<cfif len(#feature#) gt 0>
				<cfset geog = "#geog#, #feature#">
			</cfif>
			<cfif len(#spec_locality#) gt 0>
				<cfset geog = "#geog#; #spec_locality#">
			</cfif>
		</cfif>
		<cfset geog=replace(geog,": , ",": ","all")>
		<cfset lAr[i] = #geog#>
	
		<cfset sexcode = "">
		<cfif len(#trim(sex)#) gt 0>
			<cfif #trim(sex)# is "male">
				<cfset sexcode = "M">
			<cfelseif #trim(sex)# is "female">
				<cfset sexcode = "F">
			<cfelse>
				<cfset sexcode = "?">
			</cfif>
		</cfif>
		<cfset sAr[i] = #sexcode#>
		
		<cfset idNum = "">
		<cfset af = "">
		<cfset id = "">
		<cfset lo = "">
		<cfloop list="#other_ids#" index="val" delimiters=";">
			<cfif #val# contains "original identifier=">
				<cfset id = "Field##: #replace(val,"original identifier=","")#">
			<cfelseif #val# contains "AF=">
				<cfset af = "#replace(val,"="," ")#">
			<cfelse>
				<cfset lo="#replace(val,"="," ")#">
			</cfif>
		</cfloop>
		<cfif len(af) gt 0>
			<cfset idNum=af>
		<cfelseif len(id) gt 0>
			<cfset idnum=id>
		<cfelseif len(lo) gt 0>
			<cfset idnum=lo>
		</cfif>
		<cfset idAr[i] = #idNum#>
				
		
		<cfif #collectors# contains ",">
			<Cfset spacePos = find(",",collectors)>
			<cfset thisColl = left(collectors,#SpacePos# - 1)>
			<cfset thisColl = "#thisColl# et al.">
		<cfelse>
			<cfset thisColl = #collectors#>
		</cfif>
		<cfset cAr[i] = #collectors#>
		
		<cfset totlen = "">
		<cfset taillen = "">
		<cfset hf = "">
		<cfset efn = "">
		<cfset weight = "">
		<cfset totlen_val = "">
		<cfset taillen_val = "">
		<cfset hf_val = "">
		<cfset efn_val = "">
		<cfset weight_val = "">
		<cfset totlen_units = "">
		<cfset taillen_units = "">
		<cfset hf_units = "">
		<cfset efn_units = "">
		<cfset weight_units = "">
			

		<cfloop list="#attributes#" index="attind" delimiters=";">
			<cfset sPos=find(":",attind)>
			<cfif sPos gt 0>
				<cfset att=left(attind,sPos-1)>
				<cfset aVal=right(attind,len(attind)-sPos-1)>
				<cfif #trim(att)# is "total length">
					<cfset totlen = "#aVal#">
				<cfelseif #trim(att)# is "tail length">
					<cfset taillen = "#aVal#">
				<cfelseif #trim(att)# is "hind foot with claw">
					<cfset hf = "#aVal#">
				<cfelseif #trim(att)# is "ear from notch">	
					<cfset efn = "#aVal#">
				<cfelseif #trim(att)# is "weight">
					<cfset weight = "#aVal#">
				</cfif>
			</cfif>
		</cfloop>
		<cfif len(#totlen#) gt 0>
			<cfset meas = #totlen#>
		<cfelse>
			<cfset meas="X">
		</cfif>
		<cfif len(#taillen#) gt 0>
			<cfset meas = "#meas#-#taillen#">
		<cfelse>
			<cfset meas = "#meas#-X">
		</cfif>
		<cfif len(#hf#) gt 0>
			<cfset meas = "#meas#-#hf#">
		<cfelse>
			<cfset meas = "#meas#-X">
		</cfif>
		<cfif len(#efn#) gt 0>
			<cfset meas = "#meas#-#efn#">
		<cfelse>
			<cfset meas = "#meas#-X">
		</cfif>
		<cfif len(#weight#) gt 0>
			<cfset meas = "#meas#=#weight#">
		<cfelse>
			<cfset meas = "#meas#=X">
		</cfif>
		<cfset meas=replace(meas,"mm","","all")>
		<cfset aAr[i] = #meas#>
			
		<cfset stripParts = "">
		<cfset tiss = "">
		<cfloop list="#parts#" delimiters=";" index="p">
			<cfif #p# contains "frozen">
				<cfset tiss="tissues (frozen)">
			<cfelse>
				<cfif len(#stripParts#) is 0>
					<cfset stripParts = #p#>
				<cfelse>
					<cfset stripParts = "#stripParts#; #p#">
				</cfif>
			</cfif>
		</cfloop>
		
		<cfif len(#tiss#) gt 0>
			<cfset stripParts = "#stripParts#; #tiss#">
		</cfif>
		<cfif left(stripParts,2) is "; ">
			<cfset stripParts = right(stripParts,len(stripParts) - 2)>
		</cfif>
		<cfset pAr[i] = #stripParts#>
		<cfset thisDate = "">
		<cftry>
			<cfif isdate(verbatim_date)>
				<cfset thisDate = #dateformat(verbatim_date,"dd mmm yyyy")#>
			<cfelse>
				<cfset thisDate = verbatim_date>
			</cfif>	
			<cfcatch>
				<cfset thisDate = #verbatim_date#>
			</cfcatch>
		</cftry>
		<cfset dAr[i] = thisDate>

			<cfset i=i+1>
		</cfloop>
		<cfset temp=queryAddColumn(d,"locality","VarChar",lAr)>
		<cfset temp=queryAddColumn(d,"sexcode","VarChar",sAr)>
		<cfset temp=queryAddColumn(d,"idNum","VarChar",idAr)>
		<cfset temp=queryAddColumn(d,"formatted_collectors","VarChar",cAr)>
		<cfset temp=queryAddColumn(d,"measurements","VarChar",aAr)>
		<cfset temp=queryAddColumn(d,"formatted_parts","VarChar",pAr)>	
		<cfset temp=queryAddColumn(d,"formatted_date","VarChar",dAr)>		

	 <cfreturn d>
</cffunction>
<!-------------------------------------------------------------->		

<cffunction name="get_loan" access="public" returntype="Query">
    <cf_getLoanFormInfo>
    <cfquery name="d" dbtype="query">
        select * from getLoan
    </cfquery>
    <cfreturn d>
</cffunction>
<!-------------------------------------------------------------->
<cffunction name="format_msb" access="public" returntype="Query">
    <cfargument name="d" required="true" type="query">
    <cfset lAr = ArrayNew(1)>
	<cfset gAr = ArrayNew(1)>
	<cfset dAr = ArrayNew(1)>
	<cfset i=1>
	<cfloop query="d">
       <cfset sexcode = "">
		<cfif len(#trim(sex)#) gt 0>
			<cfif #trim(sex)# is "male">
				<cfset sexcode = "M">
			<cfelseif #trim(sex)# is "female">
				<cfset sexcode = "F">
			<cfelse>
				<cfset sexcode = "?">
			</cfif>
		</cfif>
		<cfset sAr[i] = #sexcode#>
        <cfset geog="">
        <cfif #country# is "United States">
			<cfset geog="USA">
		<cfelse>
			<cfset geog="#country#">
		</cfif>
		<cfset geog="#geog#: #state_prov#">
		<cfif len(#county#) gt 0>
			<cfset geog="#geog#; #replace(county,'County','Co.')#">
		</cfif>
		<cfset coordinates = "">
		<cfif len(verbatim_coordinates) gt 0>
			<cfset coordinates = verbatim_coordinates>
			<!---
			<cfset coordinates = replace(coordinates,"d","&##176;","all")>
			<cfset coordinates = replace(coordinates,"m","'","all")>
			<cfset coordinates = replace(coordinates,"s","''","all")>
			--->
		</cfif>
		<cfset locality="#geog#,">
		<cfif len(#quad#) gt 0>
			<cfset locality = "#locality# #quad# Quad.:">
		</cfif>
		<cfif len(#spec_locality#) gt 0>
			<cfset locality = "#locality# #spec_locality#">
		</cfif>
		<cfif len(#coordinates#) gt 0>
		 	<cfset locality = "#locality#, #coordinates#">
		 </cfif>
		 <cfif len(#ORIG_ELEV_UNITS#) gt 0>
		 	<cfif MINIMUM_ELEVATION is MAXIMUM_ELEVATION>
				<cfset locality = "#locality#. Elev. #MINIMUM_ELEVATION# #ORIG_ELEV_UNITS#">
			<cfelse>
				<cfset locality = "#locality#. Elev. #MINIMUM_ELEVATION#-#MAXIMUM_ELEVATION# #ORIG_ELEV_UNITS#">
			</cfif>
		 </cfif>
		 <cfif len(#habitat#) gt 0>
		 	<cfset locality = "#locality#, #habitat#">
		 </cfif>
		 <cfif right(locality,1) is not ".">
			 <cfset locality = "#locality#.">
		</cfif>
		<cfset lAr[i] = #locality#>
		<cftry>
			<cfset fd = #dateformat(verbatim_date,"dd mmmm yyyy")#>
			<cfcatch>
				<cfset fd = #verbatim_date#>
			</cfcatch>
		</cftry>
		<cfset dAr[i] = fd>
		<cfset i=i+1>
		
	</cfloop>
		
	<cfset temp=queryAddColumn(d,"locality","VarChar",lAr)>
	<cfset temp=queryAddColumn(d,"geog","VarChar",gAr)>
	<cfset temp=queryAddColumn(d,"formatted_date","VarChar",dAr)>
  <cfreturn d>
</cffunction>
<!------------------------------>  
<cffunction name="format_ala" access="public" returntype="Query">
    <cfargument name="d" required="true" type="query">

    <cfset locAry = ArrayNew(1)>
    <cfset colAry = ArrayNew(1)>
    <cfset detrAry = ArrayNew(1)>
    <cfset projAry = ArrayNew(1)>
    <cfset alaAry = ArrayNew(1)>
    <cfset attAry = ArrayNew(1)>
    <cfset identAry = ArrayNew(1)>


    <cfset i=1>
    <cfloop query="d">
	    <cfset identification = replace(sci_name_with_auth,"&","&amp;","all")>
        <cfset identAry[i] = "#identification#">
        
        
	    
		<cfset locality="">
		
        
                        
                   
        
		<cfif len(#quad#) gt 0>
			<cfif len(#locality#) gt 0>
                <cfset locality = "#locality#, #quad# Quad.:">
            <cfelse>
                 <cfset locality = "#quad# Quad.:">
            </cfif>          
		</cfif>
			<cfif len(#island#) gt 0>
				 <cfif len(#locality#) gt 0>
		            <cfset locality = "#locality#, #island#">
		        <cfelse>
		            <cfset locality = "#island#">
		        </cfif>    
			</cfif>
			<cfif len(#island_group#) gt 0>
				<cfif len(#locality#) gt 0>
	                <cfset locality = "#locality#, #island_group#">
	            <cfelse>
	                <cfset locality = "#island_group#">
	            </cfif>
			</cfif>
			<cfif len(#feature#) gt 0>
				<cfif len(#locality#) gt 0>
	                <cfset locality = "#locality#, #feature#">
	            <cfelse>
	                <cfset locality = "#feature#">
	            </cfif>     
			</cfif>
		<cfif len(#spec_locality#) gt 0>
			<cfif len(#locality#) gt 0>
	               <cfset locality = "#locality#, #spec_locality#">
	        <cfelse>
	            <cfset locality = "#spec_locality#">
	        </cfif>     
		</cfif>
		<cfif len(#coordinates#) gt 0>
		 	<cfset locality = "#locality#, #coordinates#">
		 </cfif>
		  <cfif len(#ORIG_ELEV_UNITS#) gt 0>
		 	<cfset locality = "#locality#. Elev. #MINIMUM_ELEVATION#-#MAXIMUM_ELEVATION# #ORIG_ELEV_UNITS#">
		 </cfif>
		 <cfif len(#habitat#) gt 0>
		 	<cfset locality = "#locality#, #habitat#">
		 </cfif>
		 <cfif len(#associated_species#) gt 0>
		 	<cfset locality = "#locality#, #associated_species#">
		 </cfif>	
		<cfif len(abundance) gt 0>
			<cfset locality = "#locality#, #abundance#">
		</cfif>
		 <cfif right(locality,1) is not ".">
			 <cfset locality = "#locality#.">
		</cfif>
				<cfset locality = replace(locality,".:,",".: ","all")>
				<cfset locality = replace(locality," & "," &amp; ","all")>
		
        <cfset locAry[i] = "#locality#">
        
	    <cfset collector="#collectors# #fieldnum#">
        <cfset colAry[i] = "#collector#">
                
	    <cfset determiner="">
		<cfif #collectors# neq #identified_by# AND #identified_by# is not "unknown">
			<cfset determiner="Det: #identified_by# #made_date#">
		</cfif>
        <cfset detrAry[i] = "#determiner#">
        
		<cfset project="#project_name#">	
		<cfif len(#npsa#) gt 0 or len(#npsc#) gt 0>
			<cfif len(#project#) gt 0>
				<cfset project="#project#, ">
			</cfif>
			<cfset project="#project#NPS: #npsa# #npsc#">
		</cfif>    
        <cfset projAry[i] = "#project#">
    
	    <cfset alaacString="Herbarium, University of Alaska Museum (ALA) accn #alaac#">
        <cfset alaAry[i] = "#alaacString#">
            
		<cfset sAtt="">
		<cfloop list="#attributes#" index="att">
			<cfif att does not contain "abundance" and att does not contain "number of labels">
				<cfif att contains "diploid number">
					<cfset att=replace(att,"diploid number: ","2n=","all")>
				</cfif>
				<cfset sAtt=listappend(sAtt,att)>
			</cfif>
		</cfloop>  
        <cfset attAry[i] = "#sAtt#">
        
        <cfset i=i+1>
	</cfloop>
    
    <cfset temp = QueryAddColumn(d, "locality", "VarChar",locAry)>
    <cfset temp = QueryAddColumn(d, "collector", "VarChar",colAry)>
    <cfset temp = QueryAddColumn(d, "determiner", "VarChar",detrAry)>
    <cfset temp = QueryAddColumn(d, "project", "VarChar",projAry)>
    <cfset temp = QueryAddColumn(d, "ala", "VarChar",alaAry)>
    <cfset temp = QueryAddColumn(d, "formatted_attributes", "VarChar",attAry)>
    <cfset temp = QueryAddColumn(d, "identification", "VarChar",identAry)>
    <cfreturn d>
</cffunction>

<cffunction name="format_ledger" access="public" returntype="Query">
	<cfargument name="q" required="true" type="query">
	
	<cfset colAr = ArrayNew(1)>
	<cfset coorAr = ArrayNew(1)>
	<cfset hAr = ArrayNew(1)>
	<cfset locAr = ArrayNew(1)>
	<cfset cdeAr = ArrayNew(1)>
	<cfset rAr = ArrayNew(1)>
	
	<!--- Data Manipulation --->
	<cfset i = 1>
	<cfloop query="q">
		
		<!--- Agents and Id Numbers:
		Collector1 (Col1Id), Collector2 (Col2Id), Collector3, Collector4, ... , CollectorN,
		Preparator1 (Prep1Id), Preparator2, Preparator3, Preparator4, ... , PreparatorN --->
		
		<!-- Step 1: Find Col1Id, Col2Id, and Prep1Id. -->
		<!-- Step 2: Find an Agent for each of these Ids. -->
		<!-- Step 3: Append each Agent (Id) to format_agents -->
		<!-- Step 4: Append remaining collectors after last collector,
					 append remaining preparators after last preparator. -->
		
		<!-- These will be added to the query columns at the end. -->
		<cfset format_agents = "">
		<cfset restIds = "">
		
		<!-- The next loop assigns values to these variables. -->
		<cfset firstColId = "">
		<cfset secondColId = "">
		<cfset preparatorId = "">
		
		<!-- The code after the loop assigns values to these variables. -->
		<cfset firstCollector = "">
		<cfset secondCollector = "">
		<cfset preparator = "">
		
		<!-- Obtains relevant ids, and dumps the rest into restIds. -->
		<cfloop list="#other_ids#" delimiters=";" index="ids">
		
			<!-- The only "valuable" ids are first/second collectors, and first preparator. -->
			
			<cfset firstCollectorIdPos = find("collector number=", ids)>
			<cfset secondCollectorIdPos = find("second collector number=", ids)>
			<cfset preparatorIdPos = find("preparator number=", ids)>
		
			<cfif preparatorIdPos gt 0>
				<cfset preparatorId = right(ids, len(ids)-preparatorIdPos-len("preparator number"))>
			<cfelseif secondCollectorIdPos gt 0>
				<cfset secondColId = right(ids, len(ids)-secondCollectorIdPos-len("second collector number"))>
			<cfelseif firstCollectorIdPos gt 0>
				<cfset firstColId = right(ids, len(ids)-firstCollectorIdPos-len("collector number"))>
			<cfelse>
				<cfif restIds gt 0>			
					<cfset restIds = "#restIds#; #replace(ids, '=', '(', 'one')#)">
				<cfelse>
					<cfset restIds = "#replace(ids, '=', '(', 'one')#)">
				</cfif>
			</cfif>
		
		</cfloop>
		
		<!-- Auxiliary variables for collector loop -->
		<cfset usedFirst = false>
		<cfset usedSecond = false>
		<cfif firstColId is "">
			<cfset usedFirst = true>
		</cfif>
		<cfif secondColId is "">
			<cfset usedSecond = true>
		</cfif>
		
		<!-- This loop correctly formats all the collectors. -->
		<cfloop list="#collectors#" delimiters="," index="cols">
			<cfif usedFirst is false >
				<cfset format_agents = "#format_agents# #cols# (#firstColId#),">
				<cfset usedFirst = true>
			<cfelseif usedSecond is false>
				<cfset format_agents = "#format_agents# #cols# (#secondColId#),">
				<cfset usedSecond = true>
			<cfelse>
				<cfset format_agents = "#format_agents# #cols#,">
			</cfif>
		</cfloop>
		
		<!-- Auxiliary variables for preparator loop. -->
		<cfset usedPrepId = false>
		<cfif preparatorId is "">
			<cfset usedPrepId = true>
		</cfif>
		
		<!-- This loop correctly formats all preparators. -->
		<cfloop list="#preparators#" delimiters="," index="preps">
			<cfif usedPrepId is false>
				<cfset format_agents = "#format_agents# #preps# (#preparatorId#),">
				<cfset usedPrepId = true>
			<cfelse>
				<cfset format_agents = "#format_agents# #preps#,">
			</cfif>
		</cfloop>
		
		<!-- Check fringes for whitespace and the terminal comma. -->
		<cfset format_agents = Trim(#format_agents#)>
		<cfset format_agents = left(#format_agents#, len(#format_agents#)-1)>

		<!-- Finally, set the results to the correct query columns. -->
		<cfset colAr[i] = "#format_agents#">
		<cfset rAr[i] = "#restIds#">
		
		<!--- Latitude/Longitude (datum) --->
		<!-- Setting Latitude/Longitidue -->
        <cfset coordinates = "">
        <cfif len(#verbatimLatitude#) gt 0 AND len(#verbatimLongitude#) gt 0>
                <cfset coordinates = "#verbatimLatitude# / #verbatimLongitude#">
                <cfset coordinates = replace(coordinates,"d","#chr(176)#","all")>
                <cfset coordinates = replace(coordinates,"m","'","all")>
                <cfset coordinates = replace(coordinates,"s","''","all")>
        </cfif>
		<!-- Setting datum -->
		<cfif len(datum) gt 0>
			<cfset fDatum = #datum#>
			<cfif fDatum is 'World Geodetic System 1984'>
				<cfset fDatum = "WGS84">
			<cfelseif fDatum is "North American Datum 1927">
				<cfset fDatum = "NAD27">
			<cfelseif fDatum is "North American Datum 1983">
				<cfset fDatum = "NAD83">
			</cfif>
			<cfset coordinates = "#coordinates# (#fDatum#)">
		</cfif>
		<cfset coorAr[i] = "#coordinates#">
		
		<!--- Higher Geography: County; state_prov; County; island)--->
        <cfset highergeog = "">
		<cfif len(#country#) gt 0>
			<cfif len(highergeog) gt 0>
				<cfset highergeog = "#highergeog#; ">
			</cfif>
			<cfset highergeog = "#highergeog##country#">
		</cfif>
		<cfif len(#state_prov#) gt 0>
			<cfif len(highergeog) gt 0>
				<cfset highergeog = "#highergeog#; ">
			</cfif>
			<cfset highergeog = "#highergeog##state_prov#">
		</cfif>
        <cfif len(#county#) gt 0>
				<cfif len(highergeog) gt 0>
					<cfset highergeog = "#highergeog#; ">
				</cfif>
              	<cfset highergeog = "#highergeog##county#">
		</cfif>
        <cfif len(#island#) gt 0>
			<cfif len(highergeog) gt 0>
				<cfset highergeog = "#highergeog#; ">
			</cfif>
              	<cfset highergeog = "#highergeog##island#">
		</cfif>
		<cfset hAr[i] = "#highergeog#">
		
		<cfset locality = "#spec_locality#">
		<cfif maximum_elevation is not "" and
				minimum_elevation is not "" and
				orig_elev_units is not "">
			<cfif maximum_elevation is minimum_elevation>
				<cfset locality = "#locality#; #minimum_elevation#">
			<cfelse>
				<cfset locality = "#locality#; #minimum_elevation#-#maximum_elevation#">
			</cfif>
			<cfset locality = "#locality# #orig_elev_units#">
		</cfif>
		
		<cfset locAr[i] = "#locality#; #coordinates#">
		
		<!--- Collection Code: Should display MVZ {Mammal, Bird, Herp...} ... --->
		<cfset cde = "#collection_cde#">
		<cfif cde is "Mamm">
			<cfset cde = "Mammal">
		</cfif>
		<cfset cdeAr[i] = "#cde#">
		
		<cfset i = i +1>
	</cfloop>
	
	<cfset temp=queryAddColumn(q, "coordinates", "VarChar", coorAr)>
	<cfset temp=queryAddColumn(q, "format_agents", "VarChar", colAr)>
	<cfset temp=queryAddColumn(q, "highergeog", "VarChar", hAr)>
	<cfset temp=queryAddColumn(q, "locality", "VarChar", locAr)>
	<cfset temp=queryAddColumn(q, "cde", "VarChar", cdeAr)>
	<cfset temp=queryAddColumn(q, "restIds", "VarChar", rAr)>
	<cfreturn q>
</cffunction>

<cffunction name="format_label" access="public" returnType="Query">
	<cfargument name="q" required="true" type="query">
	
	<cfset geogAr = ArrayNew(1)>
	<cfset collAr = ArrayNew(1)>
	<cfset colIdAr = ArrayNew(1)>
	<cfset pAr = ArrayNew(1)>
	<cfset sexAr = ArrayNew(1)>
		
	<!--- Data Manipulation --->
	<cfset i = 1>
	<cfloop query="q">

		<!--- Geography = Spec_Locality + State + county + country + other geography attributes--->
		<cfset geog = "#spec_locality#">
		<cfif #country# is "United States">
			<cfif len(#county#) gt 0>string
				<cfset geog = "#geog#, #county#">
			</cfif>
			<cfif len(#state_prov#) gt 0>
				<cfset geog = "#geog#, #state_prov#">
			</cfif>
		<cfelse>
			<cfif len(#state_prov#) gt 0>
				<cfset geog = "#geog#, #state_prov#">
			</cfif>
			<cfif len(#country#) gt 0>
				<cfset geog = "#geog#, #country#">
			</cfif>
		</cfif>
		<cfset geog=replace(geog,": , ",": ","all")>
		<cfset geog=replacenocase(geog, "County", "Co.", "all")>
		<cfset geog=replacenocase(geog, "California", "Calif.", "all")>
		<cfset geogAr[i] = "#geog#">
		
		<!--- If there's a preparator, use preparator's name and ID/PLC#.
		      Else, use the collector's name and ID. --->
		
		<cfset use_preparator = false>
		<cfset use_collector = false>
		
		<!--- If there is a 'label' type agent_name, use that; else, use collector's preferred name'--->
		<cfif len(#preparators#) GT 0>
			<cfset use_preparator = true>
			<cfif #preparators# contains ",">
                <cfset spacePos = find(",", preparators)>
                <cfset thisColl = left(preparators,#spacePos# - 1)>
                <cfset thisColl = "#thisColl# et al.">
        	<cfelse>
                <cfset thisColl = #preparators#>
        	</cfif>
		<cfelseif isdefined('labels_agent_name') and len(labels_agent_name) gt 0>
			<cfset use_collector = true>
			<cfset thisColl = labels_agent_name>
		<cfelse>
			<cfset use_collector = true>
       		<cfif #collectors# contains ",">
                <cfset spacePos = find(",",collectors)>
                <cfset thisColl = left(collectors,#spacePos# - 1)>
                <cfset thisColl = "#thisColl# et al.">
        	<cfelse>
                <cfset thisColl = #collectors#>
        	</cfif>
		</cfif>
		
		<cfset collAr[i] = "#thisColl#">
		

		<!--- Orig#collector id# or PLC nums--->

		<cfset idLabel = "">

		<cfloop list="#other_ids#" delimiters=";" index="ids">

			<cfset CNpos = find("collector number=", ids)/>
			<cfset PNpos = find("preparator number=", ids)/>

			<cfset PLCpos = find("Prep Lab Catalog", ids)/>

			<cfif CNpos gt 0 and #use_collector#>

				<cfset idLabel = "Orig#right(ids, len(ids)-CNpos-len("collector number"))#"/>
			<cfelseif PNpos gt 0 and #use_preparator#>
				<cfset idLabel = "#right(ids, len(ids)-PNpos-len("preparator number"))#"/>

			<cfelseif PLCpos gt 0>

				<cfset idLabel = "#right(ids, len(ids)-PLCpos-len("Prep Lab Catalog"))#"/>
				<!-- If we find this number, we must use it. -->
				<cfbreak>

			</cfif>

		</cfloop>
		

		<cfset colIdAr[i] = "#idLabel#"/>
		
		<!--- Parts Formatting --->
		<cfset formatted_parts = "">
		
		<!-- Get all part names for this collection_object_id -->
		<cfquery name="part_name_all" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select p.part_name 
			from specimen_part p 
				LEFT JOIN ctspecimen_part_list_order c ON (p.part_name = c.partname)
			where p.derived_from_cat_item = #collection_object_id#
			order by c.list_order					
		</cfquery>
			
		<!-- put query from above into a list-->
		<cfset parts = "">
		<cfloop query="part_name_all">
			<cfif len(parts) is 0>
				<cfset parts = part_name>
			<cfelse>
				<cfset parts = "#parts#; #part_name#">
			</cfif>
		</cfloop>
		
		<cfif collection_cde is "Bird">
			<cfset include_list = "">
			<cfset foundSkeleton = 0>
			<cfset foundSkull = 0>
			<cfset foundSkin = 0>
			<cfset foundWing = 0>
			<cfset otherParts = "">
			
			<cfloop list="#parts#" delimiters=";" index="p">
				<cfif find("skeleton", p) gt 0>
					<cfset foundSkeleton = 1>
				<cfelseif find("skull", p) gt 0>
					<cfset foundSkull = 1>
				<cfelseif find("skin", p) gt 0>
					<cfset foundSkin = 1>
				<cfelseif find("wing", p) gt 0>
					<cfset foundWing = 1>
				<cfelseif find("tissue", p) gt 0>
					<!-- Just don't do anything with the tissue. -->
				<cfelse>
					<!-- Put off any other parts for later parsing. -->
					<cfif otherParts is "">
						<cfset otherParts = "#p#">
					<cfelse>
						<cfset otherParts = "#otherParts#; #p#">
					</cfif>
				</cfif>
			</cfloop>
			
			<cfif foundSkeleton gt 0 and foundSkin gt 0 and foundSkull gt 0>
				<cfset formatted_parts = "+skeleton, skull">
			<cfelseif foundSkeleton gt 0 and foundSkin gt 0 and foundSkull lt 1>
				<cfset formatted_parts = "+skeleton">
			<cfelseif foundSkeleton gt 0 and foundSkin lt 1 and foundSkull lt 1>
				<cfset formatted_parts = "skeleton">
			<cfelseif foundSkeleton gt 0 and foundSkin lt 1 and foundSkull gt 0>
				<cfset formatted_parts = "skeleton, skull">
			<cfelseif foundSkeleton lt 1 and foundSkin gt 0 and foundSkull gt 0>
				<cfset formatted_parts = "+skull">
			<cfelseif foundSkeleton lt 1 and foundSkin lt 1 and foundSkull gt 0>
				<cfset formatted_parts = "skull">
			<cfelse>
				<cfset formatted_parts = "">
			</cfif>
			
			<!-- Now we deal with the rest of the parts. -->
			<!-- cfset otherParts = mvz_clean_parts(otherParts) -->
			
			<cfloop list="#otherParts#" delimiters=";" index="part">
				<!-- Regex catches everything up to and including the first open paren. -->
				<cfset regex = "(?i)[\s]*([a-z]+[\s]+)+\({1}">
				<cfset result = REFind(regex, part, 1, True)>
				<cfif result.len[1] is not 0>
					<cfset part = mid(part, result.pos[1], result.len[1]-1)>
				</cfif>
				<cfset part = trim(part)>
				
				<!-- Check to see that the part should be printed at all -->
				<!--- FOR NOW: always have it as true, because include_list is empty. --->
				<cfset is_valid_part = true>
				<cfif listContains(include_list, part)>
					<cfset is_valid_part = true>
				</cfif>
				
				<!-- Add the part to formatted_parts appropriately. -->
				<cfif is_valid_part>
					<cfif len(formatted_parts) GT 0>
						<cfset formatted_parts = "#formatted_parts#, #part#">
					<cfelse>
						<cfset formatted_parts = "#part#">
					</cfif>
				</cfif>
			</cfloop>
	
		<cfelse>
			<!-- Deal with anything but birds. -->
			<cfset colonPos = find(";", parts)>
			<cfset tissueP = find("tissue", parts)>
			<cfset skinP = find("skin", parts)>
			<cfset wholeOrgP = find("whole organism", parts)>
			<cfset preserveP = find("alcohol", parts)>
			<cfset skelP = find ("skeleton", parts)>
		
			<!-- Mamm -->
			<cfif collection_cde is "Mamm">
				<cfset formatted_parts = "#parts#">
				<!-- Herp -->
			<cfelseif collection_cde is "Herp" >
				<cfif colonPos gt 0 or (tissueP lte 0 and skinP lte 0 and wholeOrgP lte 0)>
					<cfset formatted_parts = "#parts#">
				</cfif>
				<!-- Egg -->
			<cfelseif collection_cde is "Egg">
				<cfif colonPos gt 0 or (tissueP lte 0 and skinP lte 0 and wholeOrgP lte 0)>
					<cfset formatted_parts = "#parts#">
				</cfif>
			</cfif>
			<cfset newParts = "">
			<cfloop list="#formatted_parts#" delimiters=";" index="p">
				<cfset tissueP = find("tissue", p)>
				<cfset wholeOrgP = find("whole organism", p)>
				<cfif tissueP lte 0 and wholeOrgP lte 0>
					<cfif len(newParts) gt 0>
						<cfset newParts = "#newParts#; #p#">
					<cfelse>
						<cfset newParts = "#p#">
					</cfif>
				</cfif>
			</cfloop>
			<cfset formatted_parts = "#newParts#">
			<cfset formatted_parts = "#ReplaceNoCase(formatted_parts, 'alcohol', 'ETOH', 'all')#">
		</cfif>
		
		<cfset pAr[i] = "#formatted_parts#">
		
		<!--- Sex --->
		<cfset formatted_sex = "#sex#">
		<cfif trim(formatted_sex) is "unknown" or trim(formatted_sex) is 'recorded as unknown' or trim(formatted_sex) equal 'not recorded'>
			<cfset formatted_sex = "U">
		</cfif>
		<cfset formatted_sex = "#ReplaceNoCase(formatted_sex, 'female', 'F')#">
		<cfset formatted_sex = "#ReplaceNoCase(formatted_sex, 'male', 'M')#">

		<cfset sexAr[i] = "#formatted_sex#">
		
		<cfset i = i+1>
	</cfloop>
	
	<cfset temp = queryAddColumn(q, "geography", "VarChar", geogAr)>
	<cfset temp = queryAddColumn(q, "agent", "VarChar", collAr)>
	<cfset temp = queryAddColumn(q, "agent_id", "VarChar", colIdAr)>
	<cfset temp = queryAddColumn(q, "formatted_parts", "VarChar", pAr)>
	<cfset temp = queryAddcolumn(q, "formatted_sex", "VarChar", sexAr)>
	<cfreturn q>
</cffunction>

<cffunction name="format_label_mammal" access="public" returnType="Query">
	<cfargument name="q" required="true" type="query">
	
	<!--- variable declarations --->
	<cfset geogAr = ArrayNew(1)>
	<cfset collAr = ArrayNew(1)>
	<cfset colIdAr = ArrayNew(1)>
	<cfset pAr = ArrayNew(1)>
	<cfset sexAr = ArrayNew(1)>
	
	<!-- list of ids to be excluded from returned set -->
	<cfset excludeList = "">
	
	<!--- Data Manipulation --->
	<cfset i = 1>
	<cfloop query="q">
		
		<!--- Geography = Spec_Locality + State + county + country + other geography attributes--->
		<cfset geog = "#spec_locality#">
		<cfif #country# is "United States">
			<cfif len(#county#) gt 0>
				<cfset geog = "#geog#, #county#">
			</cfif>
			<cfif len(#state_prov#) gt 0>
				<cfset geog = "#geog#, #state_prov#">
			</cfif>
		<cfelse>
			<cfif len(#state_prov#) gt 0>
				<cfset geog = "#geog#, #state_prov#">
			</cfif>
			<cfif len(#country#) gt 0>
				<cfset geog = "#geog#, #country#">
			</cfif>
		</cfif>
		<cfset geog=replace(geog,": , ",": ","all")>
		<cfset geog=replacenocase(geog, "County", "Co.", "all")>
<!---	<cfset geog=replacenocase(geog, "California", "Calif.", "all")> --->
		<cfset geogAr[i] = "#geog#">
		
		<!--- If there is a 'label' type agent_name, use that; else, use collector's preferred name'--->
		<!--TODO: STILL NEED THIS? HAVE ORACLE FUNCTION? -->
		<cfif isdefined('labels_agent_name') and len(labels_agent_name) gt 0>
			<cfset thisColl = labels_agent_name>
		<cfelse>
       		<cfif #collectors# contains ",">
                <Cfset spacePos = find(",",collectors)>
                <cfset thisColl = left(collectors,#SpacePos# - 1)>
                <cfset thisColl = "#thisColl# et al.">
        	<cfelse>
                <cfset thisColl = #collectors#>
        	</cfif>
		</cfif>
		<cfset collAr[i] = "#thisColl#">
		
		<!--- collector id--->
		<cfset colIdLabel = "">
		<!-- loop through other_ids to find either ""collector number" or "Prep Lab Cataglog" -->
		<!-- If there is collector number, label should print "Orig#<collector_id>"-->
		<!-- If there is no collector number BUT there is PLC, label should print "PLC#<collector_id>"-->
		<!-- Else, print nothing-->
		<cfloop list="#other_ids#" delimiters=";" index="ids">
			<cfset CNpos = find("collector number=", ids)>
			<cfset PLCpos = find("Prep Lab Catalog", ids)>
			<cfif CNpos gt 0>
				<cfset colIdLabel = "Orig#right(ids, len(ids)-CNpos-len("collector number"))#">
			<cfelseif PLCpos gt 0 and len(colIdLabel) lte 0>
				<cfset colIdLabel = "PLC#right(ids, len(ids)-PLCpos-len("Prep Lab Catalog"))#">
			</cfif>
		</cfloop>
		<cfset colIdAr[i] = "#colIdLabel#">
		
		<!--- Parts Formatting --->
		<!-- Mammals -->
		
		<cfset newParts = "">
		<cfif collection_cde is "Mamm">
			<cfset foundSkin = 0>
			<cfset foundSkull = 0>
			<cfset foundTissue = 0>
			<cfset foundOrg = 0>
			<cfset foundSkel = 0>
			<cfset index = 0>
			<cfset include_list = "baculum,glans penis,phallus,carcass">

			<!-- Get all part names for this collection_object_id -->
			<cfquery name="part_name_all" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select p.part_name 
				from specimen_part p 
					LEFT JOIN ctspecimen_part_list_order c ON (p.part_name = c.partname)
				where p.derived_from_cat_item = #collection_object_id#
				order by c.list_order					
			</cfquery>
			
			<!-- put query from above into a list-->
			<cfset parts = "">
			<cfloop query="part_name_all">
				<cfif len(parts) is 0>
					<cfset parts = part_name>
				<cfelse>
					<cfset parts = "#parts#; #part_name#">
				</cfif>
			</cfloop>
			
			<!-- Loop through parts_list -->
			<cfloop list="#parts#" delimiters=";" index="p">
	 			<cfset tissueP = find("tissue", p)>
				<cfset skullP = find("skull", p)>
				<cfset skinP = find("skin", p)>
				<cfset wholeOrgP = find("whole organism", p)>
				<cfset skeletonP = find("skeleton", p)>
 				
				<!-- Don't show skin/skull/tissue/whole organism -->
				<cfif skullP gt 0>    <!-- Found Skull -->
					<cfset foundSkull = 1>
				<cfelseif  skinP gt 0>	<!-- Found Skin -->
					<cfset foundSkin = 1>
	 			<cfelseif tissueP gt 0>	<!-- Found Tissue -->
					<cfset foundTissue = 1>
 				<cfelseif wholeOrgP gt 0>	<!-- Found whole organism -->
					<cfset foundOrg = 1>
				<cfelseif skeletonP gt 0> <!-- Found Skeleton -->
					<cfset foundSkel = 1>
					
				<cfelse> <!-- Safely add part to tentative part lists (for later filtering)-->

					<cfif len(newParts) gt 0>
						<cfset newParts = "#newParts#; #p#">
					<cfelse>
						<cfset newParts = "#p#">
					</cfif>
					
					<!-- Save skull position/index for later re-insert-->
					<cfif foundSkull is 0>
						<cfset index = index+1>
					</cfif>
				</cfif>			

			</cfloop>
			
			<!--- 
			1.) Skin + Skull + NOT Skeleton + NOT Whole organism => Nothing
			2.) Skin + Skull + Skeleton + NOT Whole organism => +skeleton
			3.) Whole organism + skull => +fluid
			4.) Skull + Skeleton + NOT Skin => skull; skeleton
			5.) Skull + NOT Skeleton + NOT Skin => skull only
			6.) [First 5 Choices] + Parts => [First 5], +part1, +part2, ... ,+partn
			--->
			
			<cfset partString = "x">
			
			<cfif foundSkull is 1 and foundSkin is 1 and foundSkel is 0 and foundOrg is 0>
				<cfset partString = "">  <!-- Print nothing -->
			
			<cfelseif foundSkin is 1 and foundSkel is 1>
				<!-- Print +skeleton whether or not we found a skull. -->
				<cfset partString = "+skeleton">
			
			<cfelseif foundSkull is 1 and foundSkin is 0 and foundSkel is 1>
				<cfset partString = "skull, skeleton">
			
			<cfelseif foundSkull is 1 and foundSkin is 0 and foundSkel is 0 and foundOrg is 0>
				<cfset partString = "skull only">
			
			<cfelseif foundSkull is 1 and foundOrg is 1>
				<cfset partString = "+fluid">
			
			</cfif>
			
			<!-- Now we parse newParts to add anything else on. -->
			
			<cfif len(newParts) is not 0>
				<!-- The regex captures spaces/words up to and including the first open paren. -->
				<cfset regex = "(?i)[\s]*([a-z]+[\s]+)+\({1}">
				<cfloop list="#newParts#" delimiters=";" index="part">
					
					<cfset result = REFind(regex, part, 1, True)>
					<cfif result.len[1] is not 0>
						<cfset part = mid(part, result.pos[1], result.len[1]-1)>
					</cfif>
					<cfset part = trim(part)>	
					
					<!-- Check to make sure that the part should be printed at all. -->
					<cfset valid_part = false>
					<cfif listContains(include_list, "#part#")>
						<cfset valid_part = true>
					</cfif>
					
					<cfif len(partString) gt 1 and valid_part is true>
						<!--- Add the part to the current string. --->
						<cfset partString = "#partString#, +#part#">
					<cfelseif valid_part is true>
						<!--- Only the part represents the current string. --->
						<cfset partString = "+#part#">
					<cfelse>
						<!--- Don't add the part, as it isn't valid. --->
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		
		<cfset pAr[i] = "#partString#">
			
<!--- 		<cfif len(newParts) is not 0 and foundSkin is 1 and foundSkull is 1>
				<!-- If there are preservation methods attached, we need to parse them out. -->
				<cfset regex = "(?i)[\s]*([a-z]+[\s]+)+\({1}">
				<cfset result = REFind(regex, newParts, 1, True)>
				<cfif result.len[1] is not 0>
					<cfset newParts = mid(newParts, result.pos[1], result.len[1]-1)>
					<cfset newParts = trim(newParts)>
				</cfif>	
				<!--  "skin, skull, other parts" ==> "+other parts" -->
				<cfset newParts = "+#newParts#">
				
			<cfelseif foundSkull is 1 and foundSkin is 0 and len(newParts) is 0>
				<!--  only "skull" ==> "skull"-->
				<cfset newParts = "skull">
				
			<cfelseif foundSkull is 1 and len(newParts) is not 0>
				<!--  "skull, other parts (no skin/tissue)" ==> "skull, other parts"-->
				<cfset tempIndex = 0>
				<cfset tempNewParts = "">
				<cfloop list="#newParts#" delimiters=";" index="p" >
					<cfif tempIndex is index>
						<cfif len(tempNewParts) is 0>
							<cfset tempNewParts = "skull; #p#">
						<cfelse>
							<cfset tempNewParts = "#tempNewParts#; skull; #p#">
						</cfif>
					<cfelse>
						<cfif len(tempNewParts) is 0>
							<cfset tempNewParts = "#p#">
						<cfelse>
							<cfset tempNewParts = "#tempNewParts#; #p#">
						</cfif>
					</cfif>
					<cfset tempIndex= tempIndex+1>
				</cfloop>
				<cfset newParts = tempNewParts>
			<cfelseif foundSkull is 1 and foundSkin is 1 and len(newParts) is 0>
				<!--  only "skull, skin" => "$@%" (replaced later to "")-->
				<cfset newParts = "$@%">
			</cfif>
		</cfif>
		
		<cfif len(newParts) is 0 or newParts is "whole organism">
			<cfif len(excludeList) is 0>
				<cfset excludeList = "#cat_num#">
			<cfelse>
				<cfset excludeList = "#excludeList#, #cat_num#">
			</cfif>
		</cfif> 
		
		<cfset newParts = "#replace(newParts,"$@%", "", "one")#">		
		<cfset pAr[i] = "#newParts#">
		--->
		
		<!--- Sex --->
		<cfset formatted_sex = "#sex#">
		<cfif trim(formatted_sex) is "unknown" or trim(formatted_sex) is 'recorded as unknown' or trim(formatted_sex) equal 'not recorded'>
			<cfset formatted_sex = "U">
		</cfif>
		<cfset formatted_sex = "#ReplaceNoCase(formatted_sex, 'female', 'F')#">
		<cfset formatted_sex = "#ReplaceNoCase(formatted_sex, 'male', 'M')#">

		<cfset sexAr[i] = "#formatted_sex#">
		
		<cfset i = i+1>
	</cfloop>
	
	<cfset temp = queryAddColumn(q, "geography", "VarChar", geogAr)>
	<cfset temp = queryAddColumn(q, "agent", "VarChar", collAr)>
	<cfset temp = queryAddColumn(q, "agent_id", "VarChar", colIdAr)>
	<cfset temp = queryAddColumn(q, "formatted_parts", "VarChar", pAr)>
	<cfset temp = queryAddcolumn(q, "formatted_sex", "VarChar", sexAr)>
	
	<cfif len(excludeList) is not 0>
		<cfset excludeList = "(#excludeList#)">
	
		<cfquery name = "finalQ" dbtype = "query" debug="Yes">
			SELECT * FROM q	WHERE cat_num NOT IN #excludeList#
		</cfquery>
	<cfelse>
		<cfset finalQ = q>
	</cfif>
	<cfreturn finalQ>
</cffunction>

<cffunction name="format_loan_invoice" access="public" returntype="query">
	<cfargument name="q" required="true" type="query">
	<cfset i = 1>
	<cfset datumAr= ArrayNew(1)>
	
	<cfloop query="q">
		<cfif len(datum) gt 0>
			<cfset fDatum = #datum#>
			<cfif fDatum is 'World Geodetic System 1984'>
				<cfset fDatum = "WGS84">
			<cfelseif fDatum is "North American Datum 1927">
				<cfset fDatum = "NAD27">
			<cfelseif fDatum is "North American Datum 1983">
				<cfset fDatum = "NAD83">
			</cfif>
			<cfset datumAr[i] = "#fDatum#">
		</cfif>
		<cfset i=i+1>
	</cfloop>
	
	<cfset temp = queryAddColumn(q,"fDatum", "VarChar", datumAr)>
	
	<cfreturn q>
</cffunction>
