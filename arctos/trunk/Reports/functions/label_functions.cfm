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
			<cfif #p# contains "(">
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
			<cfset thisDate = #dateformat(verbatim_date,"dd mmm yyyy")#>
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
			<cfif #p# contains "(">
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
			<cfset thisDate = #dateformat(verbatim_date,"dd mmm yyyy")#>
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
		<cfif len(#verbatimLatitude#) gt 0 AND len(#verbatimLongitude#) gt 0>
			<cfset coordinates = "#verbatimLatitude# / #verbatimLongitude#">
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
        <cfset locAry[i] = "#locality#">
        
	    <cfset collector="#collectors# #fieldnum#">
        <cfset colAry[i] = "#collector#">
                
	    <cfset determiner="">
		<cfif #collectors# neq #identified_by# AND #identified_by# is not "unknown">
			<cfset determiner="Det: #identified_by# #dateformat(made_date,"dd mmm yyyy")#">
		</cfif>
        <cfset detrAry[i] = "#determiner#">
        
		<cfset project="#project_name#">	
		<cfif len(#npsa#) gt 0 or len(#npsc#) gt 0>
			<cfif len(#project#) gt 0>
				<cfset project="#project#<br/>">
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
	<!--- Data Manipulation --->
	<cfloop query="q">
		
		<!--- Collectors (collector_id_num) [, second collector (second collector number)] --->
		<!-- Setting Collector Names --> 
		<cfset gapPos = find(",", collectors)>
		<cfset firstColl = #collectors#>
		<cfset secondColl = "">
		<cfif gapPos gt 0>
			<cfset firstColl = left(#collectors#, #gapPos#-1)>
			<cfset secondColl = right (#collectors#, len(#collectors#) - #gapPos#)>
		</cfif>
		
		<!-- Setting Collector Number -->
		<cfset collectors = "">
		<cfloop list="other_ids" delimiters="," index="other_id">
	<!--- 		<cfset gapPos = find(";" other_ids)> --->
			<!--- <cfset firstId = #other_ids#> --->
<!--- 			<cfset firstId = #gapPos#>
			<cfset secondId = "">
			<cfif gapPos gt 0>
				<cfset firstId = left(#other_ids#, #gapPos#-1)>
				<cfset firstId = replace(firstId,"=", ":",one)>
				<cfset secondId = right (#other_ids#, len(#other_ids#) - #gapPos#)>
				<cfset secondId = replace (secondId, "=", ":", one)>
			</cfif> --->
			<cfif collectors gt 0>
				<cfset collectors = replace(other_id, "=", ":", one)>
			<cfelse>
				<cfset collectors = "#collectors#, #replace(other_id, "=", ":", one)#" >
			</cfif>			
		</cfloop>
		
<!--- 		<cfset collectors = #firstColl#>
		<cfif len(#firstId#) gt 0>
			<cfset collectors = "#collectors# (#firstId#)">
		</cfif>
		<cfif len(#secondColl#) gt 0>
			<cfset collectors = "#collectors#, #secondColl#">
			<cfif len(#secondId#) gt 0>
				<cfset collectors = "#collectors#, (#secondId#)">
			</cfif>
		</cfif> --->
		
		
		<!--- Latitude/Longitude (datum) --->
		<!--- Setting Latitude/Longitidue --->
        <cfset coordinates = "">
        <cfif len(#verbatimLatitude#) gt 0 AND len(#verbatimLongitude#) gt 0>
                <cfset coordinates = "#verbatimLatitude# / #verbatimLongitude#">
                <cfset coordinates = replace(coordinates,"d","&##176;","all")>
                <cfset coordinates = replace(coordinates,"m","'","all")>
                <cfset coordinates = replace(coordinates,"s","''","all")>
        </cfif>
		<!--- Setting datum --->
		<cfif len(datum) gt 0>
			<cfset coordinates = "#coordinates# (#datum#)">
		</cfif>
		
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
		<cfset hAr[i] = #highergeog#>
	</cfloop>
	
	<cfset temp=queryAddColumn(q, "coordinates", "VarChar", cAr)>
	<cfset temp=queryAddColumn(q, "highergeog", "VarChar", hAr)>
	
	<cfreturn q>
</cffunction>