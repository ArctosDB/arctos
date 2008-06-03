<cffunction name="format_ala" access="public" returntype="Query">
    <cfargument name="d" required="true" type="query">

    <cfset geogAry = ArrayNew(1)>
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
        
        <cfset geog="#ucase(state_prov)#">
		<cfif #country# is "United States">
			<cfset geog="#geog#, USA">
		<cfelse>
			<cfset geog="#geog#, #ucase(country)#">
		</cfif>
        <cfset geogAry[i] = "#geog#">
        
	    
		<cfset locality="">
        <cfif include_island is 1>
            <cfif len(#locality#) gt 0>
                <cfset locality = "#locality#, #island#">
            <cfelse>
                <cfset locality = "#island#">
            </cfif>            
		</cfif>
       
        
        <cfif include_island_group is 1>
            <cfif len(#locality#) gt 0>
                <cfset locality = "#locality#, #island_group#">
            <cfelse>
                <cfset locality = "#island_group#">
            </cfif>            
		</cfif>
        <cfif include_feature is 1>
            <cfif len(#locality#) gt 0>
                <cfset locality = "#locality#, #feature#">
            <cfelse>
                <cfset locality = "#feature#">
            </cfif>            
		</cfif>
        
		<cfif len(#quad#) gt 0>
			<cfif len(#locality#) gt 0>
                <cfset locality = "#locality#, #quad# Quad.:">
            <cfelse>
                 <cfset locality = "#quad# Quad.:">
            </cfif>          
		</cfif>
		<cfif len(#spec_locality#) gt 0>
			<cfset locality = "#locality# #spec_locality#">
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
			<cfif att does not contain "abundance">
				<cfif att contains "diploid number">
					<cfset att=replace(att,"diploid number: ","2n=","all")>
				</cfif>
				<cfset sAtt=listappend(sAtt,att)>
			</cfif>
		</cfloop>  
        <cfset attAry[i] = "#sAtt#">
        
        <cfset i=i+1>
	</cfloop>
    
    <cfset temp = QueryAddColumn(d, "geog", "VarChar",geogAry)>
    <cfset temp = QueryAddColumn(d, "locality", "VarChar",locAry)>
    <cfset temp = QueryAddColumn(d, "collector", "VarChar",colAry)>
    <cfset temp = QueryAddColumn(d, "determiner", "VarChar",detrAry)>
    <cfset temp = QueryAddColumn(d, "project", "VarChar",projAry)>
    <cfset temp = QueryAddColumn(d, "ala", "VarChar",alaAry)>
    <cfset temp = QueryAddColumn(d, "formatted_attributes", "VarChar",attAry)>
    <cfset temp = QueryAddColumn(d, "identification", "VarChar",identAry)>
    <cfreturn d>
</cffunction>