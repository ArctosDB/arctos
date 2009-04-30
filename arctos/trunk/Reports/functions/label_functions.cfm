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
	
	<cfset colAr = ArrayNew(1)>
	<cfset coorAr = ArrayNew(1)>
	<cfset hAr = ArrayNew(1)>
	<cfset locAr = ArrayNew(1)>
	<cfset cdeAr = ArrayNew(1)>
	<cfset rAr = ArrayNew(1)>
	
	<!--- Data Manipulation --->
	<cfset i = 1>
	<cfloop query="q">
		
		<!--- Collectors (collector_id_num) [, second collector (second collector number)] --->
		
		<cfset firstId = "">
		<cfset secondId = "">
		<cfset restIds = "">	
		<cfloop list="#other_ids#" delimiters=";" index="ids">
			
			<cfset firstIdPos = find("collector number=", ids)>
			<cfset secondIdPos = find("second collector number=", ids)>
			<cfset genbankPos = find("GenBank=", ids)>
			<cfif secondIdPos gt 0>
				<cfset secondId = right(ids, len(ids)-secondIdPos-len("collector number"))>
			<cfelseif firstIdPos gt 0>
				<cfset firstId = right(ids, len(ids)-firstIdPos-len("collector number"))>
			<cfelse>
				<cfif genbankPos is 0>
					<cfif restIds gt 0>			
						<cfset restIds = "#restIds#; #replace(ids, '=', '(', 'one')#)">
					<cfelse>
						<cfset restIds = "#replace(ids, '=', '(', 'one')#)">
					</cfif>
				</cfif>
			</cfif>				
		</cfloop>
		<cfset rAr[i] = "#restIds#">
		
		<cfset format_collectors = "">
		
		<cfset collCommaPos = find(",", "#collectors#")>
		<cfif collCommaPos gt 0>
			<cfset firstCollector = left ("#collectors#", collCommaPos-1)>
			<cfset secondCollector = right("#collectors#", len("#collectors#") - collCommaPos)>

			<cfif firstId is not "">
				<cfset collector = "#firstCollector# (#firstId#)">
			<cfelse>
				<cfset collector = "#firstCollector#">
			</cfif>
			
			<cfif secondId is not "">
				<cfset collector = "#collector#, #secondCollector# (#secondId#)">
			<cfelse>
				<cfset collector = "#collector#, #secondCollector#">
			</cfif>
			
			<cfset format_collectors = listappend(format_collectors, collector)>
		<cfelse>
			<cfif firstId is not "">
				<cfset coll = "#collectors# (#firstId#)">
			<cfelse>
				<cfset coll = "#collectors#">
			</cfif>
			<cfset format_collectors = listappend(format_collectors, coll)>
		</cfif>
		
		<cfset colAr[i] = "#format_collectors#">



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
	<cfset temp=queryAddColumn(q, "format_collectors", "VarChar", colAr)>
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
		<cfset geog=replacenocase(geog, "California", "Calif.", "all")>
		<cfset geogAr[i] = "#geog#">
		
		<!--- If there is a 'label' type agent_name, use that; else, use collector's preferred name'--->
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
		
		<!--- Orig#collector id#--->
		<cfset colIdLabel = "">
		<cfloop list="#other_ids#" delimiters=";" index="ids">
			<cfset pos = find("collector number=", ids)>
			<cfif pos gt 0>
				<cfset colIdLabel = "Orig#right(ids, len(ids)-pos-len("collector number"))#">
			</cfif>			
		</cfloop>
		<cfset colIdAr[i] = "#colIdLabel#">
		
		<!--- Parts Formatting --->
		<cfset formatted_parts = "">
		<!-- Mammals -->
		<cfset colonPos = find(";", parts)>
		<cfset tissueP = find("tissue", parts)>
		<cfset skinP = find("skin", parts)>
		<cfset wholeOrgP = find("whole organism", parts)>
		<cfset preserveP = find("alcohol", parts)>
		<cfset skelP = find ("skeleton", parts)>
		
		<!-- Mamm -->
		<cfif collection_cde is "Mamm">
			<cfset formatted_parts = "#parts#">
		<!-- Bird -->
		<cfelseif collection_cde is "Bird">
			<cfif colonPos gt 0 or (tissueP lte 0 and skinP lte 0 and wholeOrgP lte 0)>
				<cfset formatted_parts = "#parts#">
			</cfif>
			
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
			<cfif tissueP lte 0>
				<cfif len(newParts) gt 0>
					<cfset newParts = "#newParts#; #p#">
				<cfelse>
					<cfset newParts = "#p#">
				</cfif>
			</cfif>
		</cfloop>
		<cfset formatted_parts = "#newParts#">
		
		<cfset pAr[i] = "#formatted_parts#">
		
		<!--- Sex --->
		<cfset formatted_sex = "#sex#">
		<cfif formatted_sex is 'unknown' or formatted_sex is 'recorded as unknown' or formatted_sex is 'not recorded'>
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
	
	<cfset geogAr = ArrayNew(1)>
	<cfset collAr = ArrayNew(1)>
	<cfset colIdAr = ArrayNew(1)>
	<cfset pAr = ArrayNew(1)>
	
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
		<cfset geogAr[i] = "#geog#">
		
		<!--- If there is a 'label' type agent_name, use that; else, use collector's preferred name'--->
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
		
		<!--- Orig#collector id#--->
		<cfset colIdLabel = "">
		<cfloop list="#othercatalognumbers#" delimiters=";" index="ids">
			<cfset pos = find("collector number=", ids)>
			<cfif pos gt 0>
				<cfset colIdLabel = "Orig#right(ids, len(ids)-pos-len("collector number"))#">
			</cfif>			
		</cfloop>
		<cfset colIdAr[i] = "#colIdLabel#">
		
		<!--- Parts Formatting --->
		<cfset formatted_parts = "">
		<!-- Mammals -->
		<cfif collection_cde is "Mamm">
			<cfif parts is not "tissues">
				<cfset formatted_parts = "#parts#">
			</cfif>
		<!-- Bird -->
		<cfelseif collection_cde is "Bird">
			<cfif parts is not "tissues" or parts is not "tissue">
				<cfset formatted_parts = "#parts#">
			</cfif>		
		<!-- Herp -->
		<cfelseif collection_cde is "Herp" >
			<cfif parts is not "tissues" or parts is not "whole organism">
				<cfset formatted_parts = "#parts#">
			</cfif>
		</cfif>
		
		<cfset pAr[i] = "#parts#">
		
		<cfset i = i+1>
	</cfloop>
	
	<cfset temp = queryAddColumn(q, "geography", "VarChar", geogAr)>
	<cfset temp = queryAddColumn(q, "agent", "VarChar", collAr)>
	<cfset temp = queryAddColumn(q, "agent_id", "VarChar", colIdAr)>
	<cfset temp = queryAddColumn(q, "formatted_parts", "VarChar", pAr)>
	<cfreturn q>
</cffunction>
