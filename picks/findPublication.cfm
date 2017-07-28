<cfinclude template="../includes/_pickHeader.cfm">
<cfoutput>

<script>
	function useThisOne(pid,ps){

		console.log(pid);
		console.log(ps);
		ps=ps.replace("'","`");
		console.log(ps);
<!------
			parent.$("###pubIdFld#").val(pid);
			parent.$("###pubStringFld#").val(ps);
			parent.$(".ui-dialog-titlebar-close").trigger('click');

			/*
		console.log(frm);
		var o=opener.document;
		console.log(o);
		var f=o.frm;
		console.log(f);
		*/
		//.frm.pidfld.value=pid;


		//var theform=$(window.opener.document).$("[name=" + frm + "]");

		//console.log(theform);



		//("#form2 input[name=name]").val('Hello World!');



	//	opener.document.$("[name=" + frm + "]").$("[name=" + pidfld + "]").val(pid);
		//opener.$('#' + partFld).val(part_name);
		//opener.document.frm.#pubIdFld#.value='#publication_id#';
		//opener.document.#formName#.#pubStringFld#.value='#jsescape(short_citation)#';
		//opener.document.#formName#.#pubStringFld#.style.background='##8BFEB9';
		//self.close();

		------>
	}
</script>
	<cfparam name="publication_title" default="">
	<!--- make sure we're searching for something --->
	<form name="searchForPub" action="findPublication.cfm" method="post">
		<label for="publication_title">Publication Title</label>
		<input type="text" name="publication_title" id="publication_title" value="#publication_title#">
		<input type="submit"
			value="Search"
			class="lnkBtn"
			onmouseover="this.className='lnkBtn btnhov'"
			onmouseout="this.className='lnkBtn'">
		<cfoutput>
			<input type="hidden" name="pubIdFld" value="#pubIdFld#">
			<input type="hidden" name="pubStringFld" value="#pubStringFld#">
		</cfoutput>
	</form>
	<cfif len(publication_title) gt 0>
		<cfquery name="getPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				publication_id,
				full_citation,
				short_citation
			FROM
				publication
			WHERE
				UPPER(regexp_replace(full_citation,'<[^>]*>')) LIKE '%#trim(ucase(escapeQuotes(publication_title)))#%' or
				UPPER(regexp_replace(short_citation,'<[^>]*>')) LIKE '%#trim(ucase(escapeQuotes(publication_title)))#%'
			ORDER BY
				full_citation
		</cfquery>
		<cfif getPub.recordcount is 0>
			Nothing matched <strong>#publication_title#</strong>
		<cfelseif getPub.recordcount is 1>
			<script>
				useThisOne('#getPub.publication_id#','#getPub.short_citation#');
			</script>
		<cfelse>
			<table border>
				<tr>
					<td>Title</td>
				</tr>
				<cfloop query="getPub">
					<tr>
						<td>
							<span class="likeLink" onclick="useThisOne('#publication_id#','#short_citation#');">
								#short_citation#
							</span>
							<blockquote>
								#full_citation#
							</blockquote>


							<!----
							<a href="##" onClick="javascript: opener.document.#formName#.#pubIdFld#.value='#publication_id#';
								opener.document.#formName#.#pubStringFld#.value='#jsescape(short_citation)#';self.close();">#full_citation#</a>
								--->
						</td>
					</tr>
				</cfloop>
			</table>
		</cfif>
	</cfif>
</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">