<cfinclude template="../includes/_pickHeader.cfm">
<cfif #action# is "nothing">
<cfoutput>
	<cfquery name="active_loan_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select  USER_LOAN_ID from 
		cf_user_loan,cf_users where
		cf_user_loan.user_id=cf_users.user_id and
		IS_ACTIVE=1
		and username='#session.username#'
	</cfquery>
	<cfif len(#active_loan_id.USER_LOAN_ID#) is 0>
		You don't have an active loan!
		<p>Did you enter a Project Title and Project Description at 
			<a href="/user_loan_request.cfm" target="_blank">User Loan Request</a></p>
		<p>
			If so, try visiting the above link and coming back here. You've somehow lost your Loan Request Authorization. File a <a href="/info/bugs.cfm" target="_blank">bug report</a>, including anything that may help us track down the problem, and we'll try to fix it. We sincerely apologize for the inconvenience!
		</p>
		<cfabort>
	</cfif>
	<cfset thisLoanId = #active_loan_id.USER_LOAN_ID#>
	<cfquery name="parts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			part_name, part_modifier, preserve_method,
			condition,
			collection.collection_cde,
			cat_num,
			institution_acronym,
			scientific_name,
			specimen_part.collection_object_id as partID
		FROM
			specimen_part,
			coll_object,
			collection,
			cataloged_item,
			identification
		WHERE
			specimen_part.collection_object_id = coll_object.collection_object_id AND
			sampled_from_obj_id is null and
			cataloged_item.collection_object_id = identification.collection_object_id and
			accepted_id_fg = 1 and
			cataloged_item.collection_id = collection.collection_id and
			cataloged_item.collection_object_id = specimen_part.derived_from_cat_item and
			derived_from_cat_item = #collection_object_id#
	</cfquery>
	<cfquery name="id" dbtype="query">
		select 
		collection_cde,
			cat_num,
			institution_acronym,
			scientific_name
			from
			parts
			group by
			collection_cde,
			cat_num,
			institution_acronym,
			scientific_name
	</cfquery>
	<hr>
<table border>
	<tr>
		<td><b>Part</b></td>
		<td><b>Condition</b></td>
		<td><b>Comment</b></td>
		<td><b>Usage</b></td>
		<td>&nbsp;</td>
	</tr>
<cfset p=1>
<cfquery name="ctUse" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from ctcf_loan_use_type
</cfquery>
<cfloop query="parts">
	<cfquery name="isBorrowed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select USER_LOAN_ID,
		REMARK,
		USE_TYPE,
		APPROVAL_STATUS
		from cf_loan_item where USER_LOAN_ID = #thisLoanId# and collection_object_id = #parts.partID#
		and cf_loan_item.user_loan_id = #thisLoanId#
	</cfquery>
	<form name="part#p#" method="post" action="loanItem.cfm">
			<input type="hidden" name="thisLoanId" value="#thisLoanId#" />
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
			<input type="hidden" name="action" value="insert">
			<input type="hidden" name="partID" value="#partID#">
			
		<tr>
		
		<td>
		#preserve_method# #part_modifier# #part_name#</td>
		<td>#condition#</td>
		<td>
		<cfif len(#isBorrowed.USER_LOAN_ID#) is 0>
			<input type="text" name="remark" size="50">
		<cfelse>
			#isBorrowed.remark#
		</cfif>
			
		</td>
		<td>
			<cfif len(#isBorrowed.USER_LOAN_ID#) is 0>
			<select name="use_type" size="1">
				<cfloop query="ctUse">
					<option value="#use_type#">#use_type#</option>
				</cfloop>
			</select>
			<cfelse>
				#isBorrowed.use_type#
			</cfif>
	
		</td>
		<td>
		<cfif len(#isBorrowed.USER_LOAN_ID#) is 0>
		<input type="submit" value="Add" class="insBtn"
				onmouseover="this.className='insBtn btnhov'" 
				onmouseout="this.className='insBtn'">
		<cfelse>
			Requested. <img src="/images/del.gif" border="0" class="likeLink" onclick="part#p#.action.value='delete';part#p#.submit();" />
		</cfif>
		
		</td>
	</tr>
	</form>
	<cfset p=#p#+1>
</cfloop>
</table>
	
</cfoutput>

</cfif>
<cfif #action# is "delete">
<cfoutput>
	<cfquery name="item" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	delete from cf_loan_item
	where
		USER_LOAN_ID=#thisLoanId# and
		collection_object_id = #partID#
		</cfquery>
		<!--- write a check to the SpecimenResults page --->
		<script>
			var theDiv = opener.document.getElementById("shopcart#collection_object_id#");
			theDiv.innerHTML='';
			self.close();
		</script>
</cfoutput>
</cfif>
<cfif #action# is "insert">
<cfoutput>
	<cfquery name="item" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	INSERT INTO cf_loan_item (
		USER_LOAN_ID,
		collection_object_id,
		use_type,
		remark)
	VALUES (
		#thisLoanId#,
		#partID#,
		'#use_type#',
		'#remark#')
		</cfquery>
		<!--- write a check to the SpecimenResults page --->
		<script>
			var theDiv = opener.document.getElementById("shopcart#collection_object_id#");
			//var theImage = opener.document.createElement("IMG");
			//theImage.src='/images/check.gif';
			//var theHtml = theDiv.innerHTML;
			theHtml = '<img src="/images/check.gif" border="0">';
			//theDiv.appendChild(theImage);// = theHtml;
			theDiv.innerHTML = theHtml;
			self.close();
		</script>
</cfoutput>
</cfif>
<p align="right">
<a href="javascript:void(0);" onclick="self.close();">Close this window</a>
</p>
