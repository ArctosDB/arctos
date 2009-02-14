
<cfinclude template="/ajax/core/cfajax.cfm">

<cffunction name="sgs" returntype="string" output="false">
	<cfargument name="d" type="string" required="true">
	<cfset d=replace(d,'##','-hash-','all')>
</cffunction>

<cffunction name="saveMoreInfoChange" returntype="string">
	<cfargument name="docid" type="numeric" required="yes">
	<cfargument name="more_info" type="string" required="yes">
	<cftry>
		<cfquery name="u" datasource="#Application.uam_dbo#">
			update documentation set
			 more_info ='#more_info#'
			where doc_id=#docid#
		</cfquery>
		<cfset result="1|#docid#">
		<cfcatch>
			<cfset result = "0|#cfcatch.message#; #cfcatch.detail#">
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>


<cffunction name="saveDisplayNameChange" returntype="string">
	<cfargument name="docid" type="numeric" required="yes">
	<cfargument name="display_name" type="string" required="yes">
	<cftry>
		<cfquery name="u" datasource="#Application.uam_dbo#">
			update documentation set
			 display_name ='#display_name#'
			where doc_id=#docid#
		</cfquery>
		<cfset result="1|#docid#">
		<cfcatch>
			<cfset result = "0|#cfcatch.message#; #cfcatch.detail#">
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>


<cffunction name="saveColnameChange" returntype="string">
	<cfargument name="docid" type="numeric" required="yes">
	<cfargument name="colname" type="string" required="yes">
	<cftry>
		<cfquery name="u" datasource="#Application.uam_dbo#">
			update documentation set
			 colname ='#colname#'
			where doc_id=#docid#
		</cfquery>
		<cfset result="1|#docid#">
		<cfcatch>
			<cfset result = "0|#cfcatch.message#; #cfcatch.detail#">
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<cffunction name="saveDefnChange" returntype="string">
	<cfargument name="docid" type="numeric" required="yes">
	<cfargument name="definition" type="string" required="yes">
	<cftry>
		<cfquery name="u" datasource="#Application.uam_dbo#">
			update documentation set
			 DEFINITION ='#definition#'
			where doc_id=#docid#
		</cfquery>
		<cfset result="1|#docid#">
		<cfcatch>
			<cfset result = "0|#cfcatch.message#; #cfcatch.detail#">
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>


<cffunction name="deleteOne" returntype="string">
	<cfargument name="docid" type="numeric" required="yes">
	<cftry>
		<cfquery name="u" datasource="#Application.uam_dbo#">
			delete from documentation 
			where doc_id=#docid#
		</cfquery>
		<cfset result="1|#docid#">
		<cfcatch>
			<cfset result = "0|#cfcatch.message#; #cfcatch.detail#">
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
