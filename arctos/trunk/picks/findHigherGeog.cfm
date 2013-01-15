<cfinclude template="/includes/_pickHeader.cfm">
<cfset title = "Pick Higher Geog" />
<cfoutput>
	<cfif len(geogString) is 0>
		You must enter search criteria.
		<cfabort />
	</cfif>
	<cfset hg = replace(geogString,"'","''","all") />
	<cfset sql = "select
		GEOG_AUTH_REC_ID,
		HIGHER_GEOG
		from
		geog_auth_rec WHERE
		upper(HIGHER_GEOG) LIKE '%#ucase(hg)#%'
		ORDER BY HIGHER_GEOG" />
	<cfquery name="getGeog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfif getGeog.recordcount is 1>
		<cfset thisName = replace(getGeog.HIGHER_GEOG,"'","\'","all") />
		<script>
			opener.document.#formName#.#geogIdFld#.value='#getGeog.GEOG_AUTH_REC_ID#';
			opener.document.#formName#.#geogStringFld#.value='#thisName#';
			opener.document.#formName#.#geogStringFld#.style.background='##8BFEB9';
			self.close();
		</script>
	<cfelseif getGeog.recordcount is 0>
		<cfoutput>
			Nothing matched #geogString#.
			<a href="javascript:void(0);" onClick="opener.document.#formName#.#geogIdFld#.value='';opener.document.#formName#.#geogStringFld#.value='';opener.document.#formName#.#geogStringFld#.focus();self.close();">Try again.</a>
		</cfoutput>
	<cfelse>
		<script>window.resizeTo(700,400);</script>
		<cfset i=1 />
		<cfloop query="getGeog">
			<cfset thisName = replace(getGeog.HIGHER_GEOG,"'","\'","all") />
			<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))# class="likeLink"
				onClick="javascript: opener.document.#formName#.#geogIdFld#.value='#GEOG_AUTH_REC_ID#';opener.document.#formName#.#geogStringFld#.value='#thisName#';opener.document.#formName#.#geogStringFld#.style.background='##8BFEB9';self.close();">#HIGHER_GEOG#</div>
			<cfset i=i+1 />
		</cfloop>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_pickFooter.cfm">
