<cfinclude template="includes/_header.cfm">
<a target="_blank" class="external" href="https://docs.google.com/document/d/1J1B7NKfaWl1A1wVQUe5rlm6FsfA7-VVUHsCqH-gHA_E/edit">editing guidelines</a>
<!------------------------------------------------------------------------------->
<cfif action is "cloneClassificationNewName">
	<cfquery name="cttaxonomy_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select source from cttaxonomy_source order by source
	</cfquery>
	<cfoutput>
		<p>
		Use this form to create a clone of a name and classification as another (e.g., local and editable) Source.
		</p>
		<p>
			You are creating a new namestring.
		</p>
		<p>
			You should not do that if the namestring (scientific name) exists, even if it's currently used for some other 
			biological entity. That is, Diptera (flies) and Diptera (plants) share a namestring, and a new name is not necessary (or possible).
		</p>
		<p>
			Pick a source below, enter the new namestring, click the button, and then you'll have a chance to edit the classification you've created.
		</p>
		<form name="x" method="post" action="editTaxonomy.cfm">
			<input type="hidden" name="action" value="cloneClassificationNewName_insert">
			<input type="hidden" name="classification_id" value="#classification_id#">
			<label for="newName">New Namestring/Scientific Name</label>
			<input type="text" name="newName" id="newName" class="reqdClr">
			<label for="source">Clone into Source</label>
			<select name="source" id="source" class="reqdClr">
				<cfloop query="cttaxonomy_source">
					<option value="#source#">#source#</option>
				</cfloop>
			</select>
			<input type="submit" value="create name and classification">
		</form>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif action is "cloneClassificationNewName_insert">
	<cfoutput>
		<cfquery name="seedClassification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select 
				TAXON_NAME_ID,
				CLASSIFICATION_ID,
				TERM,
				TERM_TYPE,
				POSITION_IN_CLASSIFICATION 
			from taxon_term where classification_id='#classification_id#'
		</cfquery>
		<cfset thisSourceID=CreateUUID()>
		<cftransaction>
			<!---  new name --->
			<cfquery name="nnID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select sq_taxon_name_id.nextval tnid from dual
			</cfquery>
			<cfquery name="newName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into taxon_name (taxon_name_id,scientific_name) values (#nnID.tnid#,'#newName#')
			</cfquery>			
			<cfloop query="seedClassification">
				<cfquery name="seedClassification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into taxon_term (
						TAXON_NAME_ID,
						CLASSIFICATION_ID,
						TERM,
						TERM_TYPE,
						SOURCE,
						POSITION_IN_CLASSIFICATION
					) values (
						#nnID.tnid#,
						'#thisSourceID#',
						'#TERM#',
						'#TERM_TYPE#',
						'#SOURCE#',
						<cfif len(POSITION_IN_CLASSIFICATION) is 0>
							NULL
						<cfelse>
							#POSITION_IN_CLASSIFICATION#
						</cfif>
					)
				</cfquery>
			</cfloop>
		</cftransaction>
		<cflocation url="/editTaxonomy.cfm?action=editClassification&classification_id=#thisSourceID#" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif action is "cloneClassification">
	<cfquery name="cttaxonomy_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select source from cttaxonomy_source order by source
	</cfquery>
	<cfoutput>
		<p>
		Use this form to create a clone of a classification as another (e.g., local and editable) Source.
		</p>
		<p>
			Do NOT try to use this form to create names - use "create name" or "clone classification into new name" for that.
		</p>
		<p>
			Do NOT use this form to assert taxon relationships - use "edit non-classification data" for that.
		</p>
		<p>
			Pick a source below, click the button, and then you'll have a chance to edit the classification you've created.
		</p>
		<form name="x" method="post" action="editTaxonomy.cfm">
			<input type="hidden" name="action" value="cloneClassification_insert">
			<input type="hidden" name="classification_id" value="#classification_id#">
			<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">			
			<label for="source">Clone into Source</label>
			<select name="source" id="source" class="reqdClr">
				<cfloop query="cttaxonomy_source">
					<option value="#source#">#source#</option>
				</cfloop>
			</select>
			<input type="submit" value="create classification">
		</form>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif action is "cloneClassification_insert">
	<cfoutput>
		<cfquery name="seedClassification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select 
				TAXON_NAME_ID,
				CLASSIFICATION_ID,
				TERM,
				TERM_TYPE,
				POSITION_IN_CLASSIFICATION 
			from 
				taxon_term 
			where 
				taxon_name_id=#taxon_name_id# and 
				classification_id='#classification_id#'
			group by
				TAXON_NAME_ID,
				CLASSIFICATION_ID,
				TERM,
				TERM_TYPE,
				POSITION_IN_CLASSIFICATION
		</cfquery>
		<cfset thisSourceID=CreateUUID()>
		<cftransaction>
			<cfloop query="seedClassification">
				<cfquery name="seedClassification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into taxon_term (
						TAXON_NAME_ID,
						CLASSIFICATION_ID,
						TERM,
						TERM_TYPE,
						SOURCE,
						POSITION_IN_CLASSIFICATION
					) values (
						#TAXON_NAME_ID#,
						'#thisSourceID#',
						'#TERM#',
						'#TERM_TYPE#',
						'#SOURCE#',
						<cfif len(POSITION_IN_CLASSIFICATION) is 0>
							NULL
						<cfelse>
							#POSITION_IN_CLASSIFICATION#
						</cfif>
					)
				</cfquery>
			</cfloop>
		</cftransaction>
		<cflocation url="/editTaxonomy.cfm?action=editClassification&classification_id=#thisSourceID#" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif action is "forceDeleteNonLocal">
	<cfoutput>
		Are you sure you want to delete all source-derived metadata?
		
		<p>
			You should probably use the "refresh from globalnames" link when you're done here.
		</p>
		<p>
			Use your back button to get out of here.
		</p>
		<p>
			<a href="editTaxonomy.cfm?action=yesReally_forceDeleteNonLocal&taxon_name_id=#taxon_name_id#">
				Click here to finalize the delete of all non-local metadata
			</a>
		</p>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif action is "yesReally_forceDeleteNonLocal">
	<cfoutput>
		<cfquery name="insRow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from taxon_term where source not in (select source from cttaxonomy_source) and taxon_name_id=#taxon_name_id#
		</cfquery>
		<cflocation url="/taxonomy.cfm?taxon_name_id=#taxon_name_id#" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif action is "saveNewClass">
	<cfoutput>		
		<cfif len(source) is 0>
			Source is required.
			<cfabort>
		</cfif>
		<cfset thisSourceID=CreateUUID()>
		<cftransaction>
			<cfloop from="1" to="10" index="i">
				<cfset thisTerm=evaluate("ncterm_" & i)>
				<cfset thisTermType=evaluate("ncterm_type_" & i)>
				<cfif len(thisTerm) gt 0 and len(thisTermType) gt 0>
					<cfquery name="insRow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into taxon_term (
							taxon_term_id,
							taxon_name_id,
							term,
							term_type,
							source,
							classification_id
						) values (
							sq_taxon_term_id.nextval,
							#taxon_name_id#,
							'#thisTerm#',
							'#thisTermType#',
							'#Source#',
							'#thisSourceID#'
						)
					</cfquery>
				</cfif>
			</cfloop>
			<cfset pos=1>
			<cfloop from="1" to="10" index="i">
				<!--- deal with yahoos leaving empty cells.... ---->
				<cfset thisTerm=evaluate("term_" & i)>
				<cfset thisTermType=evaluate("term_type_" & i)>
				<cfif len(thisTerm) gt 0>
					<cfquery name="insRow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into taxon_term (
							taxon_term_id,
							taxon_name_id,
							term,
							term_type,
							source,
							position_in_classification,
							classification_id
						) values (
							sq_taxon_term_id.nextval,
							#taxon_name_id#,
							'#thisTerm#',
							'#lcase(thisTermType)#',
							'#source#',
							#pos#,
							'#thisSourceID#'
						)
					</cfquery>
					<cfset pos=pos+1>
				</cfif>
			</cfloop>
		</cftransaction>
		<cflocation url="/editTaxonomy.cfm?action=editClassification&classification_id=#thisSourceID#" addtoken="false">
		<!----
		---->
	</cfoutput>
</cfif>
<!--------------------------------------------->
<cfif action is "newClassification">
	<script>
		// copy this with edit classification
		$(function() {
			// suggest some defaults
			$("#ncterm_type_1").val('author_text');
			$("#ncterm_type_2").val('display_name');
			$("#ncterm_type_3").val('nomenclatural_code');
			$("#ncterm_type_4").val('taxon_status');
			$("#ncterm_type_5").val('infraspecific_author');
			$( "#sortable" ).sortable({
				handle: '.dragger'
			});
			var ac_isclass_ttoptions = {
	       		source: '/component/functions.cfc?method=ac_isclass_tt',
				width: 320,
				max: 50,
				autofill: false,
				multiple: false,
				scroll: true,
				scrollHeight: 300,
				matchContains: true,
				minChars: 1,
				selectFirst:false
		    };
			var ac_noclass_ttoptions = {
	       		source: '/component/functions.cfc?method=ac_noclass_tt',
				width: 320,
				max: 50,
				autofill: false,
				multiple: false,
				scroll: true,
				scrollHeight: 300,
				matchContains: true,
				minChars: 1,
				selectFirst:false
		    };
		    $("input.ac_isclass_tt").live("keydown.autocomplete", function() {
		        $(this).autocomplete(ac_isclass_ttoptions);
		    });
			$("input.ac_noclass_tt").live("keydown.autocomplete", function() {
		        $(this).autocomplete(ac_noclass_ttoptions);
		    });

		});
		function requirePair(i){
			var tt=$("#ncterm_type_" + i).val().length;
			var t=$("#ncterm_" + i).val().length;
			if (tt>0 || t>0){
				$("#ncterm_type_" + i).addClass('reqdClr');
				$("#ncterm_" + i).addClass('reqdClr');
			} else {
				$("#ncterm_type_" + i).removeClass('reqdClr');
				$("#ncterm_" + i).removeClass('reqdClr');	
			}
		}
	</script>
	<p>
		Create classifications here. This form is limited - you can edit classifications (after creating them here) to do more.	
	</p>
	<p>"Classifications" consist of hierarchical "taxonomy" data and nonhierarchical, non-classification data attributable to a Source.
	
	"Nomenclatural code according to Arctos" is part of a Clasification (so it can be linked to the potentially-ranked taxonomy) but is NOT part of the 
	taxonomic classification.</p>
	<p>
		There are no true hierarchies, and there are no data rules. You can type anything here. Be exceedingly careful.
	</p>
	<cfquery name="thisName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select scientific_name from taxon_name where taxon_name_id=#taxon_name_id#
	</cfquery>
	<cfquery name="cttaxonomy_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select source from cttaxonomy_source order by source
	</cfquery>
	<cfoutput>
		<cfset title="Create Classification for #thisName.scientific_name#">
		<h3>Create Classification for #thisName.scientific_name#</h3>
	
		<form name="f1" id="f1" method="post" action="editTaxonomy.cfm">
			<input type="hidden" name="action" value="saveNewClass">
			<input type="hidden" name="taxon_name_id" id="taxon_name_id" value="#taxon_name_id#">
			
			<label for="source">Source</label>
			<select name="source" id="source" class="reqdClr">
				<cfloop query="cttaxonomy_source">
					<option value="#source#">#source#</option>
				</cfloop>
			</select>
			<h3>
				Non-Classification Terms
			</h3>
			<p style="font-size:small;">
				These are paired terms; unpaired terms will be ignored. That means you can ignore the defaulted-in suggestions if you want.
			</p>
			<table id="clastbl" border="1">
				<thead>
					<tr>
						<th>
							Term Type
							<a target="_blank" href="/component/functions.cfc?method=ac_noclass_tt&term">[ view all (JSON)]</a>
						</th>
						<th>Term</th>
					</tr>
				</thead>
				<tbody id="notsortable">
					<cfloop from="1" to="10" index="i">
						<tr id="nccell_#i#">
							<td>
								<input class="ac_noclass_tt" size="60" type="text" id="ncterm_type_#i#" name="ncterm_type_#i#" onchange="requirePair(#i#);">
							</td>
							<td>
								<input size="60" type="text" id="ncterm_#i#" name="ncterm_#i#" onchange="requirePair(#i#);">
							</td>
						</tr>
					</cfloop>
				</tbody>
			</table>
			<h3>
				Classification Terms
			</h3>		
			<p style="font-size:small;">
				 Order is important here - "large" (eg, kingdom) at top to "small" (eg, subspecies) at bottom.
				Use as many cells as you need; leave the rest empty. 
				 TermType will be ignored if Term is empty. Term will be saved regardless of TermType; unranked terms are OK.
				 Add more via Edit (after you save here) if necessary.	
			</p>
			<table id="clastbl" border="1">
				<thead>
					<tr><th>Term Type
					<a target="_blank" href="/component/functions.cfc?method=ac_isclass_tt&term">[ view all (JSON)]</a>
					</th><th>Term</th></tr>
				</thead>
				<tbody id="sortable">
					<cfloop from="1" to="10" index="i">
							
							<td>							
								<input size="60" class="ac_isclass_tt" type="text" id="term_type_#i#" name="term_type_#i#">
							</td>
							<td>
								<input size="60" type="text" id="term_#i#" name="term_#i#" >
							</td>
						</tr>
					</cfloop>
				</tbody>
			</table>
			<p>
				<input type="submit" value="Create Classification">
			</p>
		</form>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------->
<cfif action is "editClassification">
	<style>
		.dragger {
			cursor:move;
		}
		.isterm {
			font-weight:bold;
			font-style:italics;
		}
	</style>
	<script>
		// copy this with create classification
		$(function() {
			$( "#sortable" ).sortable({
				handle: '.dragger'
			});
			var ac_isclass_ttoptions = {
	       		source: '/component/functions.cfc?method=ac_isclass_tt',
				width: 320,
				max: 50,
				autofill: false,
				multiple: false,
				scroll: true,
				scrollHeight: 300,
				matchContains: true,
				minChars: 1,
				selectFirst:false
		    };
			var ac_noclass_ttoptions = {
	       		source: '/component/functions.cfc?method=ac_noclass_tt',
				width: 320,
				max: 50,
				autofill: false,
				multiple: false,
				scroll: true,
				scrollHeight: 300,
				matchContains: true,
				minChars: 1,
				selectFirst:false
		    };		
		    $("input.ac_isclass_tt").live("keydown.autocomplete", function() {
		        $(this).autocomplete(ac_isclass_ttoptions);
		    });
			$("input.ac_noclass_tt").live("keydown.autocomplete", function() {
		        $(this).autocomplete(ac_noclass_ttoptions);
		    });
			guessAtDisplayName();
		});
		function submitForm() {
			var linkOrderData=$("#sortable").sortable('toArray').join(',');
			$( "#classificationRowOrder" ).val(linkOrderData);
			var nccellary = new Array();
			$.each($("tr[id^='nccell_']"), function() {
				nccellary.push(this.id);
		    });
			var ncls=nccellary.join(',');
			$( "#noclassrows" ).val(ncls);
			$( "#f1" ).submit();
		}
		function deleteThis(r) {
			$( "#cell_" + r ).remove();
		}
		function nc_deleteThis(r) {
			$( "#nccell_" + r ).remove();
		}
		function addARow() {
			var n=parseInt($("#maxposn").val());
			++n;
			var x='<tr id="cell_' + n + '">';
			x+='<td class="dragger">(drag row here)</td>';
			x+='<td><input size="60" class="ac_isclass_tt" type="text" id="term_type_' + n + '" name="term_type_' + n + '" onchange="guessAtDisplayName(this.id)"></td>';
			x+='<td><input size="60" type="text" id="term_' + n + '" name="term_' + n + '" onchange="guessAtDisplayName(this.id)"></td>';
			x+='<td><span class="likeLink" onclick="deleteThis(\'' + n + '\');">[ Delete this row ]</span></td>';
			x+='</tr>';
			$("#sortable").append(x);
			$("#maxposn").val(n);
		}
		function nc_addARow() {
			var n=parseInt($("#numnoclassrs").val());
			++n;
			var x='<tr id="nccell_' + n + '">';
			x+='<td><input class="ac_noclass_tt" size="60" type="text" id="ncterm_type_' + n + '" name="ncterm_type_' + n + '" onchange="guessAtDisplayName(this.id)"></td>';
			x+='<td><input size="60" type="text" id="ncterm_' + n + '" name="ncterm_' + n + '" onchange="guessAtDisplayName(this.id)"></td>';
			x+='<td><span class="likeLink" onclick="nc_deleteThis(\'' + n + '\');">[ Delete this row ]</span></td>';
			x+='</tr>';
			$("#notsortable").append(x);
			$("#numnoclassrs").val(n);
		}
		function deleteClassification(cid,tnid) {
			var msg='Are you sure you want to delete this classification?\nDo NOT delete classifications because you do not agree with them or because they';
			msg+=' do not fit your collection or taxonomy preferences.\nDeleted classifications from GlobalNames will come back; fix them at the source.';
			msg+='\nIf you did not create the classification you are trying to delete, you should probably click "cancel" now.';
			var r=confirm(msg);
			if (r==true) {
				document.location='/editTaxonomy.cfm?action=deleteClassification&classification_id=' + cid + '&taxon_name_id=' + tnid;
			}
		}

		function guessAtDisplayName(caller) {
			// if this is being called by an element, check if that element is the value
			// of display_name. If so, just exit. Otherwise, rock on.
			if(caller && caller.substring(0, 2) == "nc") {
				var cary=caller.split('_');
				var theIdInt=cary[cary.length-1];
				var theType=$("#ncterm_type_" + theIdInt).val();
				if (theType == 'display_name'){
					return false;
				}
			}
			var genus; // just so that we can italicize @fallback
			var species;
			var infraspecific_term;
			var infraspecific_rank;
			var speciesauthor;
			var subspeciesauthor;
			var dv_element=""; // element of the term type
			var dv_value=""; // contents of the term
			var dv_value_element=""; // element of the term
			var formatstyle = 'iczn'; // default to simple....
			var formattedname; // with HTML
			var lowestclassificationterm;
			$("input[name^='ncterm_type_']").each(function() {
				var thisval = $(this).val();
				var relatedElementID=this.id.replace("type_","");    
				var relatedElement=$("#" + relatedElementID).val();
				
				/*
				if(thisval == "display_name") {
					dv_value_element=relatedElementID;
					dv_value=relatedElement;
					dv_element=this.id;
			    }
			    
			    */
				if(thisval == "author_text") {			
					speciesauthor=relatedElement;
			    }
				if(thisval == "infraspecific_author") {
					subspeciesauthor=relatedElement;
			    }
				if(thisval == "nomenclatural_code" && relatedElement=='ICBN') {
					formatstyle='icbn';			
				}
			});
			
			/*
			
			if (! dv_element){
				// add a row for display_name	
				nc_addARow();
				var n=parseInt($("#numnoclassrs").val());
				$('#ncterm_type_' + n).val('display_name');
				dv_element='ncterm_type_' + n;
			}
			
			*/
			// and this point, there should be a display_name and we should know it's ID.
			$("input[name^='term_type_']").each(function() {
		    	var thisval = $(this).val();
				var relatedElementID=this.id.replace("type_","");
				var relatedElement=$("#" + relatedElementID).val();	
				if(thisval == "kingdom" && relatedElement=='Plantae') {
					formatstyle='icbn';
				}
				if(thisval == "species" || thisval == "sp" || thisval == "sp.") {
					species=relatedElement;
				}
				if(thisval == "genus" || thisval == "gen.") {
					genus=relatedElement;
				}		
				if(thisval == "subsp." || thisval == "variety" || thisval == "var." || thisval == "varietas" || thisval == "subvar." || thisval == "subspecies") {
					infraspecific_term=relatedElement;
					infraspecific_rank=thisval;
				}
				lowestclassificationterm=relatedElement;
			});
			if (species) {
				formattedname = ' <i>' + species + '</i>';
				if (formatstyle=='icbn'){
					if (speciesauthor) {
						formattedname += ' ' + speciesauthor;
					}
					if (infraspecific_rank) {
						formattedname += ' ' + infraspecific_rank;
					}
					if (infraspecific_term) {
						infraspecific_term=infraspecific_term.replace(species,"").trim();
						infraspecific_term=infraspecific_term.replace(infraspecific_rank,"").trim();
						formattedname += ' <i>' + infraspecific_term + '</i>';
					}
					if (subspeciesauthor) {
						formattedname += ' ' + subspeciesauthor;
					}
				}
				if (formatstyle=='iczn'){
					if (infraspecific_term) {
						infraspecific_term=infraspecific_term.replace(species,"").trim();
						formattedname += ' <i>' + infraspecific_term + '</i>';
					}
					if (speciesauthor) {
						formattedname += ' ' + speciesauthor;
					}
				}
			}
			if (! formattedname) {
				if (genus) {
					formattedname='<i>' + genus + '</i>';
					if (speciesauthor) {
						formattedname += ' ' + speciesauthor;
					}
				} else {
					formattedname=lowestclassificationterm;
				}
			}
			if (formattedname) {
				formattedname=formattedname.replace(/<\/i> <i>/g, ' ').trim();
				$("#dng").val(formattedname);
			}
		}
		function useDNG(){
			var dn=$("#dng").val();
			$('input').each(function(){
   				 if( $(this).val()=='display_value' ){
   				 	console.log($(this).val());
   				 	var idOfDisplayRow=this.id;
   				 }	
   				 	
			});


			
			
			if (typeof idOfDisplayRow === 'undefined') {
				console.log('make a row');
} else {
	
					console.log('row exists');
								console.log(idOfDisplayRow);
					
	
	
				}	
		}
	</script>
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select 
				* 
			from 
				taxon_name,
				taxon_term 
			where 
				taxon_name.taxon_name_id=taxon_term.taxon_name_id and
				classification_id='#classification_id#'
		</cfquery>
		<cfquery name="thisname" dbtype="query">
			select 
				source,
				scientific_name,
				taxon_name_id
			from
				d 
			group by 
				source,
				scientific_name,
				taxon_name_id
		</cfquery>
		
		<cfquery name="noclass" dbtype="query">
			select * from d where POSITION_IN_CLASSIFICATION is null order by term_type
		</cfquery>
		<cfquery name="hasclass" dbtype="query">
			select * from d where POSITION_IN_CLASSIFICATION is not null order by  POSITION_IN_CLASSIFICATION
		</cfquery>		
		<cfquery name="maxclass" dbtype="query">
			select max(POSITION_IN_CLASSIFICATION) m from hasclass
		</cfquery>
		<cfquery name="maxnoclass" dbtype="query">
			select count(*) m from noclass
		</cfquery>
		<p>
			Editing <strong>#thisName.source#</strong> classification for <strong>#thisName.scientific_name#</strong> (classification_id=#classification_id#)
			<cfset title="Edit Classification: #thisName.scientific_name#">
			<br>
			<a href="/name/#thisname.scientific_name#">[ View Taxon Page ]</a>
			<a href="/editTaxonomy.cfm?action=editnoclass&taxon_name_id=#thisname.taxon_name_id#">[ Edit Non-Classification Data ]</a>
			<span class="likeLink" onclick="deleteClassification('#classification_id#','#thisname.taxon_name_id#');">[ Delete Classification ]</span>
		</p>
		<p>
			Important randomness:
			<ul>
				<li>
					Term type <span class="isterm">display_name</span> is (when appropriate and available) stored as FLAT.FORMATTED_SCIENTIFIC_NAME. 
					This form will suggest display names
					based on other data, including <span class="isterm">kingdom</span>, <span class="isterm">nomenclatural_code</span>, 
					<span class="isterm">genus</span>, <span class="isterm">species</span>, 
					"<span class="isterm">subspecies</span>" 
					(including <span class="isterm">var.</span>, <span class="isterm">forma</span>, etc.), infraspecific rank (
					such as <span class="isterm">var.</span>, <span class="isterm">forma</span>, etc.), and <span class="isterm">infraspecific_author</span>. 
					Click the link at the bottom of the page to reset and stop suggestions for this editing session.
					 <span class="isterm">Display_name</span> should include HTML markup, which can be easily stripped off when appropriate.
				</li>
				<li>
					<span class="isterm">Species</span> are binomials, not specific epithets: "Poa abbreviata" rather than "abbreviata."
				</li>
				<li>
					ICZN-like subspecific terms (which should with rare exception be <span class="isterm">subspecies</span>) are trinomials: 
					"Alces alces shirasi," not "shirasi." 
				</li>
				<li>
					ICBN-like subspecific terms (<span class="isterm">subspecies</span>, <span class="isterm">subsp.</span>, <span class="isterm">var.</span>, etc.) 
					are ranked trinomials: "Poa abbreviata subsp. jordalii," not "jordalii."
				</li>
			</ul>
		</p>
		<form name="f1" id="f1" method="post" action="editTaxonomy.cfm">
		
			<input type="button" onclick="submitForm();" value="Save Edits">
			<input type="hidden" name="action" value="saveClassEdits">
			<input type="hidden" name="classification_id" id="classification_id" value="#classification_id#">
			<input type="hidden" name="taxon_name_id" id="taxon_name_id" value="#thisname.taxon_name_id#">
			<input type="hidden" name="source" id="source" value="#thisname.source#">
			<cfif len(maxclass.m) is 0>
				<cfset mc=0>
			<cfelse>
				<cfset mc=maxclass.m>
			</cfif>
			<input type="hidden" name="maxposn" id="maxposn" value="#mc#">
			<cfif len(maxnoclass.m) is 0>
				<cfset mc=0>
			<cfelse>
				<cfset mc=maxnoclass.m>
			</cfif>
			<input type="hidden" name="numnoclassrs" id="numnoclassrs" value="#mc#">
			<input type="hidden" name="classificationRowOrder" id="classificationRowOrder">
			<input type="hidden" name="noclassrows" id="noclassrows">
			<h3>
				Non-Classification Terms
			</h3>
			<p style="font-size:small;">
				These are paired terms; unpaired terms will be ignored (=deleted).
			</p>
			<table id="clastbl" border="1">
				<thead>
					<tr><th>Term Type</th><th>Term</th><th>Delete</th></tr>
				</thead>
				<tbody id="notsortable">
					<cfset thisrow=1>
					<cfloop query="noclass">
						<tr id="nccell_#thisrow#">
							<td>
								<input class="ac_noclass_tt" size="60" type="text" id="ncterm_type_#thisrow#" name="ncterm_type_#thisrow#" value="#term_type#" onchange="guessAtDisplayName(this.id)">
							</td>
							<td>
								<input size="60" type="text" id="ncterm_#thisrow#" name="ncterm_#thisrow#" value="#stripQuotes(term)#" onchange="guessAtDisplayName(this.id)">
							</td>
							<td>
								<span class="likeLink" onclick="nc_deleteThis('#thisrow#');">[ Delete this row ]</span>
							</td>
						</tr>
						<cfset thisrow=thisrow+1>
					</cfloop>
				</tbody>
			</table>
			<span class="likeLink" onclick="nc_addARow();">[ add a row ]</span>
			<h3>
				Classification Terms
			</h3>
			<p style="font-size:small;">
				 Order is important here - "large" (eg, kingdom) at top to "small" (eg, subspecies) at bottom. Drag rows to sort.
				 TermType will be ignored if Term is empty. Term will be saved regardless of TermType; unranked terms are OK.
			</p>
			<table id="clastbl" border="1">
				<thead>
					<tr><th>Drag Handle</th><th>Term Type</th><th>Term</th><th>Delete</th></tr>
				</thead>
				<tbody id="sortable">
					<cfloop query="hasclass">
						<tr id="cell_#POSITION_IN_CLASSIFICATION#">
							<td class="dragger">
								(drag row here)
							</td>
							<td>
								<input size="60" class="ac_isclass_tt" type="text" id="term_type_#POSITION_IN_CLASSIFICATION#" name="term_type_#POSITION_IN_CLASSIFICATION#" value="#term_type#" onchange="guessAtDisplayName(this.id)">
							</td>
							<td>
								<input size="60" type="text" id="term_#POSITION_IN_CLASSIFICATION#" name="term_#POSITION_IN_CLASSIFICATION#" value="#term#" onchange="guessAtDisplayName(this.id)">
							</td>
							<td>
								<span class="likeLink" onclick="deleteThis('#POSITION_IN_CLASSIFICATION#');">[ Delete this row ]</span>
							</td>
						</tr>
					</cfloop>
				</tbody>
			</table>
			<span class="likeLink" onclick="addARow();">[ add a row ]</span>
			<p>
				<!--- flag to override atuoguess @displayname - keep it on for the duration os editing a classification one tripped---->
				<div style="border:2px solid red;padding:2em;margin:2em;">
					IMPORTANT!! Classifications should generally have a (one!) non-classification term 
					"display_name" value, which is an HTML-formatted
					namestring including authors, infraspecific rank, etc., according to discipline-specific traditions.
					<p>
						Add to or edit the form above, edit the guess box below and click "use," or click "use" to accept our
						suggestion.
					</p>
					<label for="dng">Our guess at display_name</label>
					<input id="dng" size="80">
				<input type="button" onclick="useDNG();" value="Use this suggestion">
				</div>
				<input type="button" onclick="submitForm();" value="Save Edits">
			</p>
			<div id="originalDisplayName">
				
			</div>
			<p>
				If you haven't yet saved, you can <a href="/editTaxonomy.cfm?action=editClassification&classification_id=#classification_id#">refresh this page</a>
			</p>
		</form>
	</cfoutput>
</cfif>
<!------------------------------------->
<cfif action is "deleteClassification">
	<cfoutput>
		<cfquery name="deleteallclassification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from taxon_term where classification_id='#classification_id#'
		</cfquery>
	</cfoutput>
	<cflocation url="/taxonomy.cfm?TAXON_NAME_ID=#TAXON_NAME_ID#" addtoken="false">
</cfif>
<!------------------------------------->
<cfif action is "saveClassEdits">
	<cfoutput>
		<cftransaction>
			<!---- clear everything out, start over - just easier this way ---->
			<cfquery name="deleteallclassification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from taxon_term where classification_id='#classification_id#'
			</cfquery>
			<!---- these are in no particular order but some may be missing ---->
			<cfloop from="1" to="#listlen(noclassrows)#" index="listpos">
				<cfset x=listgetat(noclassrows,listpos)>
				<cfset i=listlast(x,"_")>
				<cfset thisterm=evaluate("NCTERM_" & i)>
				<cfset thistermtype=evaluate("NCTERM_TYPE_" & i)>
				<!---- just ignore non-paired terms ---->
				<cfif len(thisterm) gt 0 and len(thistermtype) gt 0>
					
				
					<cfquery name="insNCterm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into taxon_term (
							TAXON_NAME_ID,
							CLASSIFICATION_ID,
							TERM,
							TERM_TYPE,
							SOURCE,
							LASTDATE
						) values (
							#TAXON_NAME_ID#,
							'#CLASSIFICATION_ID#',
							'#thisterm#',
							'#thistermtype#',
							'#SOURCE#',
							sysdate
						)
					</cfquery>
				</cfif>
			</cfloop>
			<!--- these MUST be saved in the order they were drug to -------->
			<cfloop from="1" to="#listlen(CLASSIFICATIONROWORDER)#" index="listpos">
				<cfset x=listgetat(CLASSIFICATIONROWORDER,listpos)>
				<cfset i=listlast(x,"_")>
				<cfset thisterm=evaluate("TERM_" & i)>
				<cfset thistermtype=evaluate("TERM_TYPE_" & i)>
				<cfquery name="insCterm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into taxon_term (
						TAXON_NAME_ID,
						CLASSIFICATION_ID,
						TERM,
						TERM_TYPE,
						SOURCE,
						LASTDATE,
						POSITION_IN_CLASSIFICATION
					) values (
						#TAXON_NAME_ID#,
						'#CLASSIFICATION_ID#',
						'#thisterm#',
						'#thistermtype#',
						'#SOURCE#',
						sysdate,
						#listpos#
					)
				</cfquery>
			</cfloop>
		</cftransaction>
		<cflocation url="/editTaxonomy.cfm?action=editClassification&classification_id=#classification_id#" addtoken="false">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveEditScientificName">
<cfoutput>
<cftransaction>
	<cfquery name="edTaxa" datasource="user_login" username='#session.username#' password="#decrypt(session.epw,session.sessionKey)#">
	UPDATE taxon_name SET scientific_name='#scientific_name#' where taxon_name_id=#taxon_name_id#
	</cfquery>
	</cftransaction>
	<cflocation url="editTaxonomy.cfm?Action=editnoclass&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "newTaxonPub">
	<cfquery name="newTaxonPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO taxonomy_publication (taxon_name_id,publication_id)
		VALUES (#taxon_name_id#,#new_publication_id#)
	</cfquery>
	<cflocation url="editTaxonomy.cfm?Action=editnoclass&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "removePub">
	<cfquery name="removePub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from taxonomy_publication where taxonomy_publication_id=#taxonomy_publication_id#
	</cfquery>
	<cflocation url="editTaxonomy.cfm?Action=editnoclass&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "newTaxaRelation">
<cfoutput>
	<cfquery name="newReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO taxon_relations (
			 TAXON_NAME_ID,
			 RELATED_TAXON_NAME_ID,
			 TAXON_RELATIONSHIP,
			 RELATION_AUTHORITY
		  )	VALUES (
			#TAXON_NAME_ID#,
			 #newRelatedId#,
			 '#TAXON_RELATIONSHIP#',
		 	'#RELATION_AUTHORITY#'
		)		 
	</cfquery>
	<cflocation url="editTaxonomy.cfm?Action=editnoclass&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveRelnEdit">
<cfoutput>
<cfquery name="edRel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	UPDATE taxon_relations SET
		taxon_relationship = '#taxon_relationship#',
		related_taxon_name_id = #related_taxon_name_id#,
		relation_authority = '#relation_authority#'
	WHERE
		taxon_relations_id = #taxon_relations_id#
</cfquery>
<cflocation url="editTaxonomy.cfm?Action=editnoclass&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>				
<!---------------------------------------------------------------------------------------------------->
<cfif action is "deleReln">
<cfoutput>
<cfquery name="deleReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	DELETE FROM 
		taxon_relations
	WHERE
		taxon_relations_id = #taxon_relations_id#
		</cfquery>
		<cflocation url="editTaxonomy.cfm?Action=editnoclass&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>			
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveCommon">
<cfoutput>
	<cfquery name="upCommon" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		UPDATE
			common_name
		SET 
			common_name = '#common_name#'
		WHERE 
			common_name_id=#common_name_id#
	</cfquery>
	<cflocation url="editTaxonomy.cfm?Action=editnoclass&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "deleteCommon">
<cfoutput>
	<cfquery name="killCommon" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		DELETE FROM 
			common_name
		WHERE 
			common_name_id=#common_name_id#
	</cfquery>
	<cflocation url="editTaxonomy.cfm?Action=editnoclass&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "newCommon">
<cfoutput>
	<cfquery name="newCommon" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO common_name (common_name, taxon_name_id)
		VALUES ('#common_name#', #taxon_name_id#)
	</cfquery>
	<cflocation url="editTaxonomy.cfm?Action=editnoclass&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveNewName">
<cfoutput>
	<cfquery name="saveNewName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO taxon_name (TAXON_NAME_ID,SCIENTIFIC_NAME) VALUES (sq_TAXON_NAME_ID.nextval,'#scientific_name#')
	</cfquery>
	<br>
	<cflocation url="/name/#SCIENTIFIC_NAME#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "newName">
	<p>Use this form to create "namestrings."</p>
	<p>
		"Namestrings" are (more or less) formal taxa produced by publication. "Sorex cinereus" is a namestring. "Sorex sp." and "Sorex sp. nov. 41" are not.
		Namestrings are rankless - "Animalia" is acceptable. Namestrings are not tied to singular classifications - namestring "Diptera" refers to 
		insects and plants and no duplication is necessary.
	</p>
	<p>
		Make sure you've searched before using this form. Errors make us nervous....
	</p>
	<p>
		When you successfully create a namestring here, you'll be redirected to the main taxonomy page, where you can
		<ul>
			<li>Pull information from GlobalNames, and then clone those into other classifications if necessary.</li>
			<li>"Edit non-classification data" to create relationships, common names, etc.</li>
			<li>Manually create classifications and non-classificatoin metadata</li>
		</ul>
	</p>
	<p>
		If you want to bring an Arctos classification over, use your back button, find a similar name, and then "clone classification into new name."
	</p>
	<form name="name" method="post" action="editTaxonomy.cfm">
		<input type="hidden" name="action" value="saveNewName">
		<label for="scientific_name">Scientific Name</label>
		<input type="text" id="scientific_name" name="scientific_name" size="80">
		<input type="submit" value="Create Name" class="insBtn">
	</form>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "editnoclass">
	<cfoutput>	
		<cfquery name="thisname" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select scientific_name  from taxon_name where taxon_name_id=#taxon_name_id#
		</cfquery>
		<cfset title="Edit non-classification data for #thisname.scientific_name#">
		<p>Editing non-classification data for <strong><em>#thisname.scientific_name#</em></strong></p>
		<br><a href="/name/#thisname.scientific_name#">Return to taxon overview</a> to edit classifications
		
		<form name="name" method="post" action="editTaxonomy.cfm">
			<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
			<input type="hidden" name="action" value="saveEditScientificName">
			<label for="scientific_name">Scientific Name</label>
			<input type="text" id="scientific_name" name="scientific_name" value="#thisname.scientific_name#" size="80">
			<input type="submit" value="Save Change" class="savBtn">
		</form>
		<cfquery name="ctRelation" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select taxon_relationship from cttaxon_relation order by taxon_relationship
		</cfquery>
		<cfquery name="tax_pub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select 
				taxonomy_publication_id,
				short_citation,
				taxonomy_publication.publication_id
			from
				taxonomy_publication,
				publication		
			where
				taxonomy_publication.publication_id=publication.publication_id and
				taxonomy_publication.taxon_name_id=#taxon_name_id#
		</cfquery>
		<cfset i = 1>
		<span class="likeLink" onClick="getDocs('taxonomy','taxonomy_publication');">Related Publications</span>
			<form name="newPub" method="post" action="editTaxonomy.cfm">
				<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
				<input type="hidden" name="Action" value="newTaxonPub">
				<input type="hidden" name="new_publication_id" id="new_publication_id">
				<label for="new_pub">Pick Publication</label>
				<input type="text" id="newPub" onchange="getPublication(this.id,'new_publication_id',this.value,'newPub')" size="80">
				<input type="submit" value="Add Publication" class="insBtn">
			</form>
			<cfif tax_pub.recordcount gt 0>
				<ul>
			</cfif>
			<cfloop query="tax_pub">
				<li>
					#short_citation#
					<ul>
						<li>
							<a href="editTaxonomy.cfm?action=removePub&taxonomy_publication_id=#taxonomy_publication_id#&taxon_name_id=#taxon_name_id#">[ remove ]</a>
						</li>
						<li>
							<a href="/SpecimenUsage.cfm?publication_id=#publication_id#">[ details ]</a>
						</li>
					</ul>
				</li>
			</cfloop>
			<cfif tax_pub.recordcount gt 0>
				</ul>
			</cfif>
		</table>
		<cfquery name="relations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT 
				taxon_relations_id,
				scientific_name, 
				taxon_relationship,
				relation_authority,
				related_taxon_name_id
			FROM 
				taxon_relations,
				taxon_name
			WHERE
				taxon_relations.related_taxon_name_id = taxon_name.taxon_name_id 
				AND taxon_relations.taxon_name_id = #taxon_name_id#
		</cfquery>
		<cfset i = 1>
		<span class="likeLink" onClick="getDocs('taxonomy','taxon_relations');">Related Taxa:</span>
		<table border="1">
			<tr>
				<th>Relationship</th>
				<th>Related Taxa</th>
				<th>Authority</th>
			</tr>
			<form name="newRelation" method="post" action="editTaxonomy.cfm">
				<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
				<input type="hidden" name="action" value="newTaxaRelation">
				<tr class="newRec">
					<td>
						<label for="taxon_relationship">Add Relationship</label>
						<select name="taxon_relationship" size="1" class="reqdClr">
							<cfloop query="ctRelation">
								<option value="#ctRelation.taxon_relationship#">#ctRelation.taxon_relationship#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<input type="text" name="relatedName" class="reqdClr" size="50" 
							onChange="taxaPick('newRelatedId','relatedName','newRelation',this.value); return false;"
							onKeyPress="return noenter(event);">
						<input type="hidden" name="newRelatedId">
					</td>
					<td>
						<input type="text" name="relation_authority">
					</td>
					<td>
						<input type="submit" value="Create" class="insBtn">	
		   			</td>
				</tr>
			</form>
			<cfloop query="relations">
				<form name="relation#i#" method="post" action="editTaxonomy.cfm">
					<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
					<input type="hidden" name="taxon_relations_id" value="#taxon_relations_id#">
					<input type="hidden" name="action">
					<input type="hidden" name="related_taxon_name_id" value="#related_taxon_name_id#">
					<tr>
						<td>
							<select name="taxon_relationship" size="1" class="reqdClr">
								<cfloop query="ctRelation">
									<option <cfif ctRelation.taxon_relationship is relations.taxon_relationship> 
										selected="selected" </cfif>value="#ctRelation.taxon_relationship#">#ctRelation.taxon_relationship#
									</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" name="relatedName" class="reqdClr" size="50" value="#relations.scientific_name#"
								onChange="taxaPick('related_taxon_name_id','relatedName','relation#i#',this.value); return false;"
								onKeyPress="return noenter(event);">
						</td>
						<td>
							<input type="text" name="relation_authority" value="#relations.relation_authority#">
						</td>
						<td>
							<input type="button" value="Save" class="savBtn" onclick="relation#i#.action.value='saveRelnEdit';submit();">	
							<input type="button" value="Delete" class="delBtn" onclick="relation#i#.action.value='deleReln';confirmDelete('relation#i#');">
						</td>
					</tr>
				</form>
				<cfset i = i+1>
			</cfloop>
		</table>
		<cfquery name="common" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select 
				common_name,
				common_name_id
			from common_name where taxon_name_id = #taxon_name_id#
		</cfquery>
		<span class="likeLink" onClick="getDocs('taxonomy','common_names');">Common Names</span>
		<cfset i=1>
		<cfloop query="common">
			<form name="common#i#" method="post" action="editTaxonomy.cfm">
				<input type="hidden" name="common_name_id" value="#common_name_id#">
				<input type="hidden" name="action">
				<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
				<input type="text" name="common_name" value="#common_name#" size="50">
				<input type="button" value="Save" class="savBtn" onClick="common#i#.action.value='saveCommon';submit();">	
		   		<input type="button" value="Delete" class="delBtn" onClick="common#i#.action.value='deleteCommon';confirmDelete('common#i#');">
			</form>
			<cfset i=i+1>
		</cfloop>
		<table class="newRec">
			<tr>
				<td>
					<form name="newCommon" method="post" action="editTaxonomy.cfm">
						<input type="hidden" name="Action" value="newCommon">
						<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
						<label for="common_name">New Common Name</label>
						<input type="text" name="common_name" size="50">
						<input type="submit" value="Create" class="insBtn">	
					</form>
				</td>
			</tr>
		</table>
	</cfoutput>
</cfif>
<cfinclude template="includes/_footer.cfm">