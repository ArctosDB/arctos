<cfinclude template="/includes/_header.cfm">
look at code for usage - use contact link if that doesn't make sense
<script src="/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js" language="javascript" type="text/javascript"></script>
<style>
	.done{background-color:lightgray;}
	.err{border:5px solid red;}
	.d{border:2px solid black;}
	
</style>
<script>
	$(document).ready(function() {
		$.each($("input[id^='geog_']"), function() {
			$("#" + this.id).autocomplete("/ajax/higher_geog.cfm", {
				width: 320,
				max: 50,
				autofill: false,
				multiple: false,
				scroll: true,
				scrollHeight: 300,
				matchContains: true,
				minChars: 1,
				selectFirst:false
			});
	    });
		$("form").submit(function( event ) {
			event.preventDefault();
			var formId = this.id;
			var iid=formId.replace('f','');
			var tSL=$("#sl" + iid).val();
			var tNG=$("#geog_" + iid).val();
			useThisOne(tSL,tNG,'d'+iid);
		});
	});
	function useThisOne(o,n,d){
		$.getJSON("/component/DSFunctions.cfc",
			{
				method : "updatecf_temp_spec_to_geog",
				returnformat : "json",
				queryformat : 'column',
				old: o,
				new: n
			},
			function(r) {
				if (r=='ok'){
					$("#"+d).removeClass().addClass('done');
				} else {
					$("#"+d).removeClass().addClass('err');
				}
			}
		);
	}		

</script>
<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select * from (select * from cf_temp_spec_to_geog where higher_geog is null order by spec_locality) where rownum<21
	</cfquery>
	<cfset rnum=1>
	<cfloop query="d">
		<cfset qp=replace(spec_locality,';',',','all')>
		<cfset qp=replace(qp,'?',' ','all')>
		<cfset qp=replace(qp,'/',' ','all')>
		<cfset qp=replace(qp,'  ',' ','all')>
		<cfset qp=trim(qp)>
		<cfquery name="sp" datasource="uam_god">
			select higher_geog sugn from geog_auth_rec where 
				upper(country) like '#ucase(trim(qp))#' and state_prov is null and quad is null and feature is null and sea is null and island is null and island_group is null and county is null
				OR
				upper(state_prov) like '#ucase(trim(qp))#' and quad is null and feature is null and sea is null and island is null and island_group is null and county is null
				<cfif listlen(spec_locality,",") gt 0>
					<cfloop list="#qp#" index="x">
						or upper(country) like '#ucase(trim(x))#' and state_prov is null and quad is null and feature is null and sea is null and island is null and island_group is null and county is null
						OR
						upper(state_prov) like '#ucase(trim(x))#' and quad is null and feature is null and sea is null and island is null and island_group is null and county is null
					</cfloop>
				</cfif>
		</cfquery>
		<div id="d#rnum#" class="d">
			<a target="_blank" class="external" href="https://www.google.com/search?q=#spec_locality#">#spec_locality#</a>
			<ul>
				<cfloop query="sp">
					<li>
						<span class="likeLink" onclick="useThisOne('#d.spec_locality#','#sp.sugn#','d#rnum#');">#sp.sugn#</span>
					</li>
				</cfloop>
			</ul>
			<!--- static defaults ---->
			<ul>
				<li>
					<span class="likeLink" onclick="useThisOne('#d.spec_locality#','North America, United States, Alaska','d#rnum#');">North America, United States, Alaska</span>
				</li>
				<li>
					<span class="likeLink" onclick="useThisOne('#d.spec_locality#','North America, United States','d#rnum#');">North America, United States</span>
				</li>
				<li>
					<span class="likeLink" onclick="useThisOne('#d.spec_locality#','North America, Canada','d#rnum#');">North America, Canada</span>
				</li>
				<li>
					<span class="likeLink" onclick="useThisOne('#d.spec_locality#','North America','d#rnum#');">North America</span>
				</li>
				<li>
					<span class="likeLink" onclick="useThisOne('#d.spec_locality#','Eurasia, Russia','d#rnum#');">Eurasia, Russia</span>
				</li>
				<li>
					<span class="likeLink" onclick="useThisOne('#d.spec_locality#','no higher geography recorded','d#rnum#');">no higher geography recorded</span>
				</li>
				<!----
				<li>
					<span class="likeLink" onclick="useThisOne('#d.spec_locality#','xxxx','d#rnum#');">xxxxx</span>
				</li>
				---->
			</ul>
			<form id="f#rnum#">
				<input type="text"  class="ac" name="geog_#rnum#" size="40" id="geog_#rnum#" >
				<input type="hidden" id="sl#rnum#" name="sl#rnum#" value="#d.spec_locality#">		
				<input type="submit">
			</form>
		<cfset rnum=rnum+1>
	</div>	
	</cfloop>
	<p>
		<a href="getGeogFromSpecloc.cfm">load more</a>
	</p>
</cfoutput>