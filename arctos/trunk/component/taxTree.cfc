<cfcomponent>
<cffunction name="getNodes" access="remote" returntype="Array">
    <cfargument name="path" type="String" required="false" default=""/>
    <cfargument name="value" type="String" required="true" default=""/>
    <!--- set up return array --->
        <cfset var result= arrayNew(1)/>
        <cfset var s =""/>
		<!--- need to break PATH apart ---->
		<cfoutput>
			
			<!----
			<cfdump var="#url#">
			<cfdump var="#arguments#">
		-----------#arguments.path#---------------
		<cfif isjson(arguments.path)>
			path is json
			<cfelse>
			no it isn't
		</cfif>
		
		TAXON_NAME_ID									     NOT NULL NUMBER
 PHYLCLASS										      VARCHAR2(20)
 PHYLORDER										      VARCHAR2(30)
 SUBORDER										      VARCHAR2(30)
 FAMILY 										      VARCHAR2(30)
 SUBFAMILY										      VARCHAR2(30)
 GENUS											      VARCHAR2(30)
 SUBGENUS										      VARCHAR2(20)
 SPECIES										      VARCHAR2(40)
 SUBSPECIES										      VARCHAR2(40)
 VALID_CATALOG_TERM_FG								     NOT NULL NUMBER
 SOURCE_AUTHORITY								     NOT NULL VARCHAR2(45)
 FULL_TAXON_NAME								     NOT NULL VARCHAR2(4000)
 SCIENTIFIC_NAME								     NOT NULL VARCHAR2(255)
 AUTHOR_TEXT										      VARCHAR2(255)
 TRIBE											      VARCHAR2(30)
 INFRASPECIFIC_RANK									      VARCHAR2(20)
 TAXON_REMARKS										      VARCHAR2(4000)
 PHYLUM 										      VARCHAR2(30)
 NOMENCLATURAL_CODE									      VARCHAR2(255)
 INFRASPECIFIC_AUTHOR									      VARCHAR2(255)
 SCI_NAME_WITH_AUTHS									      VARCHAR2(255)
 SCI_NAME_NO_IRANK									      VARCHAR2(255)
 SUBCLASS										      VARCHAR2(255)
 SUPERFAMILY										      VARCHAR2(255)
		---->
		<cfset ttl="kingdom,phylum">
		

		<cfif len(arguments.value) is 0>
			<cfset sql="select nvl(kingdom,'not recorded') data from taxonomy group by kingdom order by kingdom">
		<cfelse>
			<cfset sPos=find(arguments.value,"=")>
			<cfset rank=listgetat(arguments.value,1,"=")>
			<cfset term=listgetat(arguments.value,2,"=")>
			<cfset ttlPos=listfind(ttl,rank)>
			<cfset child=listgetat(ttl,ttlPos+1)>
			<cfset sql="select nvl(#child#,'not recorded') data from taxonomy where #rank#='#term#' group by #child# order by #child#">
		</cfif>
		
        <!--- if arguments.value is empty the tree is being built for the first time --->
			<cfquery name="qry" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				#preservesinglequotes(sql)#
			</cfquery>
			<cfset x = 0/>
			<cfloop query="qry">
				<cfset x = x+1/>
				<cfset s = structNew()/>
				<cfset s.value="#child#=#data#">
				<cfset s.display="#data# (#child#)">
				<cfset arrayAppend(result,s)/>
			</cfloop>
			            <!---

			 <cfset x = 0/>
            <cfloop from="1" to="10" index="i">
                <cfset x = x+1/>
                <cfset s = structNew()/>
                <cfset s.value=#x#>
                <cfset s.display="Node #i#">
                <cfset arrayAppend(result,s)/>
            </cfloop>
						---->

      
		</cfoutput>
    <cfreturn result/>
</cffunction>
</cfcomponent>