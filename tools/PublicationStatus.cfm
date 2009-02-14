<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
<cfparam name="order_by" default="gbi_id">
<cfparam name="order_order" default="DESC">
<cfoutput>

<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from cf_genbank_info
	ORDER BY #order_by# #order_order#
</cfquery>

<!---------------- new record -------------------->
<table border class="newRec">
		<form name="new" method="post" action="PublicationStatus.cfm">
			<input type="hidden" name="action" value="newRec">
		
		<tr>
			<td>
				<font size="-1">Citation<br></font>
				<textarea name="citation" rows="2" cols="50"></textarea>
		  </td>
			<td>
				<font size="-1">PubInArctos<br></font>
				<select name="PubInArctos" size="1">
					<option value="yes">yes</option>
					<option value="no">no</option>
					<option  selected value="unknown">unknown</option>
				</select>
			</td>
			<td>
				<font size="-1">CitationsInGenBank<br></font>
				<select name="CitationsInGenBank" size="1">
					<option value="yes">yes</option>
					<option value="no">no</option>
					<option  selected value="unknown">unknown</option>
				</select>
			</td>
			<td>
				<font size="-1">CitationInPublication<br></font>
				<select name="CitationInPublication" size="1">
					<option value="yes">yes</option>
					<option value="no">no</option>
					<option selected value="unknown">unknown</option>
				</select>
			</td>
			<td>
				<font size="-1">CitationsInArctos<br></font>
				<select name="CitationsInArctos" size="1">
					<option value="yes">yes</option>
					<option value="no">no</option>
					<option selected value="unknown">unknown</option>
				</select>
			</td>
		</tr>
		<tr>
			<td>
				<font size="-1">ArcticleAtUrl<br></font>
				<input type="text" name="ArcticleAtUrl" size="50">
			</td>
			<td colspan="2">
				<font size="-1">comments<br></font>
				<input type="text" name="comments" size="50">
			</td>
			<td>
				<font size="-1">status<br></font>
				<select name="status" size="1">
					<option value="new">new</option>
					<option value="incomplete">incomplete</option>
					<option value="complete">complete</option>
				</select>
			</td>
			<td>
				<input type="submit" value="create" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">
			</td>
		</tr>
		</form>
	</table>
<!---------------- end new ----------------->
<hr>
Existing Publications
<hr>
	<table border>
		
	<cfset i=1>
	<cfloop query="d">
		<form name="p#i#" method="post" action="PublicationStatus.cfm">
			<input type="hidden" name="action" value="saveChanges">
			<input type="hidden" name="order_by" value="#order_by#">
			<input type="hidden" name="order_order" value="#order_order#">
			<input type="hidden" name="gbi_id" value="#gbi_id#">
		
		 <tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
			<td>
				<font size="-1">citation
				<a href="PublicationStatus.cfm?order_by=citation&order_order=desc">
					<img src="/images/down.gif" border="0" class="likeLink"></a>
				<a href="PublicationStatus.cfm?order_by=citation&order_order=asc">
					<img src="/images/up.gif" border="0" class="likeLink"></a>
				<br></font>
				<textarea name="citation" rows="2" cols="50">#Citation#</textarea>
			</td>
			<td>
				<font size="-1">PubInArctos
				<a href="PublicationStatus.cfm?order_by=PubInArctos&order_order=desc">
					<img src="/images/down.gif" border="0" class="likeLink"></a>
				<a href="PublicationStatus.cfm?order_by=PubInArctos&order_order=asc">
					<img src="/images/up.gif" border="0" class="likeLink"></a><br></font>
				<select name="PubInArctos" size="1">
					<option value="yes" <cfif #PubInArctos# is "yes"> selected </cfif>>yes</option>
					<option value="no" <cfif #PubInArctos# is "no"> selected </cfif>>no</option>
					<option value="unknown" <cfif #PubInArctos# neq "yes"
						AND #PubInArctos# neq "no"> selected </cfif>>unknown</option>
				</select>
			</td>
			<td>
				<font size="-1">CitationsInGenBank<br></font>
				<select name="CitationsInGenBank" size="1">
					<option value="yes" <cfif #CitationsInGenBank# is "yes"> selected </cfif>>yes</option>
					<option value="no" <cfif #CitationsInGenBank# is "no"> selected </cfif>>no</option>
					<option value="unknown" <cfif #CitationsInGenBank# neq "yes"
						AND #CitationsInGenBank# neq "no"> selected </cfif>>unknown</option>
				</select>
			</td>
			<td>
				<font size="-1">CitationInPublication<br></font>
				<select name="CitationInPublication" size="1">
					<option value="yes" <cfif #CitationInPublication# is "yes"> selected </cfif>>yes</option>
					<option value="no" <cfif #CitationInPublication# is "no"> selected </cfif>>no</option>
					<option value="unknown" <cfif #CitationInPublication# neq "yes"
						AND #CitationInPublication# neq "no"> selected </cfif>>unknown</option>
				</select>
			</td>
			<td>
				<font size="-1">CitationsInArctos<br></font>
				<select name="CitationsInArctos" size="1">
					<option value="yes" <cfif #CitationsInArctos# is "yes"> selected </cfif>>yes</option>
					<option value="no" <cfif #CitationsInArctos# is "no"> selected </cfif>>no</option>
					<option value="unknown" <cfif #CitationsInArctos# neq "yes"
						AND #CitationsInArctos# neq "no"> selected </cfif>>unknown</option>
				</select>
			</td>
		</tr>
		<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
			<td>
				<font size="-1">ArcticleAtUrl<br></font>
				<input type="text" size="50" name="ArcticleAtUrl" value="#ArcticleAtUrl#">
			</td>
			<td colspan="2">
				<font size="-1">comments<br></font>
				<input type="text" size="50" name="comments" value="#comments#">
			</td>
			<td>
				<font size="-1">status<br></font>
				<select name="status" size="1">
					<option <cfif #status# is ""> selected </cfif>value="new">new</option>
					<option <cfif #status# is "incomplete"> selected </cfif> value="incomplete">incomplete</option>
					<option <cfif #status# is "complete"> selected </cfif> value="complete">complete</option>
				</select>
			</td>
			<td>
				 <input type="submit" value="save" class="savBtn"
   onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">
			</td>
		</tr>
		</form>
		<cfset i=#i#+1>
	</cfloop>
	</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
</cfif>
<!---------------------------------------->
<cfif #action# is "newRec">
<cfquery name="nid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select max(gbi_id) gbi_id from cf_genbank_info
</cfquery>
<cfset gbi_id = #nid.gbi_id# + 1>
<cfquery name="new" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	insert into cf_genbank_info (
		gbi_id
		<cfif len(#citation#) gt 0>
			,citation
		</cfif>
		<cfif len(#PubInArctos#) gt 0>
			,PubInArctos
		</cfif>
		<cfif len(#CitationsInGenBank#) gt 0>
			,CitationsInGenBank
		</cfif>
		<cfif len(#CitationInPublication#) gt 0>
			,CitationInPublication
		</cfif>
		<cfif len(#CitationsInArctos#) gt 0>
			,CitationsInArctos
		</cfif>
		<cfif len(#ArcticleAtUrl#) gt 0>
			,ArcticleAtUrl
		</cfif>
		<cfif len(#comments#) gt 0>
			,comments
		</cfif>
		<cfif len(#status#) gt 0>
			,status
		</cfif>
		) VALUES (
			#gbi_id#
			<cfif len(#citation#) gt 0>
			,'#citation#'
		</cfif>
		<cfif len(#PubInArctos#) gt 0>
			,'#PubInArctos#'
		</cfif>
		<cfif len(#CitationsInGenBank#) gt 0>
			,'#CitationsInGenBank#'
		</cfif>
		<cfif len(#CitationInPublication#) gt 0>
			,'#CitationInPublication#'
		</cfif>
		<cfif len(#CitationsInArctos#) gt 0>
			,'#CitationsInArctos#'
		</cfif>
		<cfif len(#ArcticleAtUrl#) gt 0>
			,'#ArcticleAtUrl#'
		</cfif>
		<cfif len(#comments#) gt 0>
			,'#comments#'
		</cfif>
		<cfif len(#status#) gt 0>
			,'#status#'
		</cfif>
		)
</cfquery>
<cflocation url="PublicationStatus.cfm?action=nothing">
</cfif>
<!---------------------------------------->
<cfif #action# is "saveChanges">
<cfoutput>
	<cfquery name="up" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_genbank_info set 
			citation = '#citation#'
		<cfif len(#PubInArctos#) gt 0>
			,PubInArctos = '#PubInArctos#'
		<cfelse>
			,PubInArctos = NULL
		</cfif>
		<cfif len(#CitationsInGenBank#) gt 0>
			,CitationsInGenBank = '#CitationsInGenBank#'
		<cfelse>
			,CitationsInGenBank = NULL
		</cfif>
		<cfif len(#CitationInPublication#) gt 0>
			,CitationInPublication = '#CitationInPublication#'
		<cfelse>
			,CitationInPublication = NULL
		</cfif>
		<cfif len(#CitationsInArctos#) gt 0>
			,CitationsInArctos = '#CitationsInArctos#'
		<cfelse>
			,CitationsInArctos = NULL
		</cfif>
		<cfif len(#ArcticleAtUrl#) gt 0>
			,ArcticleAtUrl = '#ArcticleAtUrl#'
		<cfelse>
			,ArcticleAtUrl = NULL
		</cfif>
		<cfif len(#comments#) gt 0>
			,comments = '#comments#'
		<cfelse>
			,comments = NULL
		</cfif>
		<cfif len(#status#) gt 0>
			,status = '#status#'
		<cfelse>
			,status = NULL
		</cfif>
		where gbi_id = #gbi_id#
	</cfquery>
	<cflocation url="PublicationStatus.cfm?action=nothing&order_by=#order_by#&order_order=#order_order#">
	</cfoutput>
</cfif>