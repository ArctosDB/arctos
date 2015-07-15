<!--- no security --->
<cfinclude template="../includes/_pickHeader.cfm">
 <cfif not isdefined("publication_title")>
	Didn't get a publication_title.<cfabort>
</cfif>


<cfoutput>
<form name="additems" method="post" action="findDOI.cfm">
	<label for="publication_title">Title</label>
	<textarea name="publication_title" class="hugetextarea">#publication_title#</textarea>
	<br><input type="submit" value="Find DOI">
</form>
<cfif len(publication_title) gt 0>
	going crossref....

	<br />
<cfhttp url="http://search.crossref.org/dois?q=#publication_title#"></cfhttp>



<cfset x=DeserializeJSON(cfhttp.filecontent)>



<cfloop array="#x#" index="data_index">
	#data_index['fullcitation']#

	<div class="indent">
		<a href="#data_index['doi']#" target="_blank" class="external">#data_index['doi']#</a>
		<br>use this DOI....
	</div>
	<hr>

</cfloop>




</cfif>


</cfoutput>


<!-----
</cfif>

<cfif #Action# is "AddItem">
	<cfoutput>

	<cftransaction action="begin">
		<cftry>

	<cfquery name="addLoanItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">

	INSERT INTO user_loan_item (
		LOAN_REQUEST_ID,
		COLLECTION_OBJECT_ID,
		ITEM_REQUEST_DATE,
		VOLUME_REQUESTED
		<cfif len(#remarks#) gt 0>
			,REMARKS
		</cfif> )
	VALUES (
		#session.loan_request_id#,
		#collection_object_id#,
		'#dateformat(now(),"yyyy-mm-dd")#',
		'#volume#'
		<cfif len(#remarks#) gt 0>
			,'#REMARKS#'
		</cfif> )
		</cfquery>

			<cfcatch type="database">
				#cfcatch.Message#
				<br> You've probably already added this item to your request.
				<br>Please <a href="##" onClick="self.close();">close</a> this window and try again.

				<cfabort>

			</cfcatch>
		</cftry>
	</cftransaction>

		You have added #collection_cde# #cat_num# #item# <cfif not #volume# is "whole item">(#volume# subsample)</cfif> to loan #project_title#
		<br> Click <a href="##" onClick="self.close();">here</a> to close this window.
</cfoutput>
</cfif>
</cfif>
----->
<cfinclude template="../includes/_pickFooter.cfm">