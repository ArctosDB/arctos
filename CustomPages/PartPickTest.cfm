<cfinclude template="/includes/_header.cfm">
<cfset title="part demonstration">
	<script src="/includes/sorttable.js"></script>

<script src="/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js" language="javascript" type="text/javascript"></script>
<script>
	function findPart(part_name,collCde,partFld,formName){
		var url="findPart.cfm";
		var popurl=url+"?part_name="+part_name+"&collCde="+collCde+"&partFld="+partFld+"&formName="+formName;
		partpick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
	}
	jQuery(document).ready(function() {
		jQuery("#partname").autocomplete("/CustomPages/part_name.cfm", {
			width: 320,
			max: 20,
			autofill: true,
			highlight: false,
			multiple: false,
			scroll: true,
			scrollHeight: 300
		});
	});
</script>
<style>
	.code{
		font-size:smaller;
		background-color:lightgray;
	}
</style>
This is a test for usability of combined part names. The test data were created as:
<div class="code">
	<p>
	CREATE TABLE pt_specimen_part AS SELECT * FROM specimen_part;
	</p>
	<p>
	ALTER TABLE pt_specimen_part MODIFY part_name VARCHAR2(255);
	</p>
	<p>
	UPDATE pt_specimen_part SET part_name=
	DECODE(PART_MODIFIER,
	      NULL,'',
	      PART_MODIFIER || ' ')
	    || part_name ||
	    DECODE(PRESERVE_METHOD,
	      NULL,'',
	      ' (' || PRESERVE_METHOD || ')')
	      ;
	 </p>
	<p>    
	create table pt_ctspecimen_part_name as select
		part_name,
	    collection.collection_cde
	 FROM
	     pt_specimen_part,
	     cataloged_item,
	     collection
	 WHERE
	     pt_specimen_part.derived_from_cat_item=cataloged_item.collection_object_id AND
	     cataloged_item.collection_id=collection.collection_id
	  GROUP BY
	      part_name,
	    collection.collection_cde;
	</p>	
</div>

<p>
This proposal would merge part name, part modifier, and preservation method. 
It will remove any requirements for users to guess whether an attribute is more properly a modifier or a preservation method,
 will allow Curators to precisely format parts strings, and will disallow data entry personell arbitrarily creating novel part
combinations. It will also create many new part name combinations, necessitating better
methods of picking part names. 
</p>
<p>
	This is a proposal. How and if it proceeds will depend upon operator feedback.
	As always, we're available to field questions, and your suggestions and concerns are welcome.
</p>
<p>
	This does not solve the original issue of adding attributes (such as remaining_volume) to parts. It does allow Curators
	to associate parts and their most common attributes (modifier and preservation method) in a predetermined, formatted
	 string, and makes proceeding
	with part attributes a less-formidable task. I do not believe that our current model will support the addition of part attributes.
</p>
<p>
	The current data are excessively bloated due to our current system allowing data entry personnel to 
	independently select part modifier, part name, and preservation method in any combination. (And Curators haven't been doing a great
	job of entering code table values - something we can only control with privileges.)
	<br>With current code table values, it is 
	possible to create
	{number part names} * {number preservation methods} * {number part modifiers} combinations, 
	currently:
	<blockquote>
		 select count(distinct(part_name)) * count(distinct(part_modifier)) * count(distinct(preserve_method)) NumberPartCombos from specimen_part; 
		 <br>NUMBERPARTCOMBOS
		 <br>----------------
	  	<br>   496822
	</blockquote>
	
	As of 25Jan2009, there are over 900 part combinations in use. Many of these are due to data entry errors and could be
	merged or simplified. Current arbitrary examples of potentially nonsensical or superflous part combinations include:
	<blockquote>
		<br>SEM stub (ethanol)
		<br>antler (dry)
		<br>atlas tooth
		<br>atlas vertebra (dry)
		<br>partial post-cranial postcranial skeleton
		<br>partial post-cranial postcranial skeleton (dry)
		<br>molar dentary
	</blockquote>
	Current data also includes many examples of part combinations which could potentially be shortened. 
	One of the more concise examples is:
	<blockquote>
		<p>
			<br>baculum
			<br>baculum (70% ETOH)
			<br>baculum (95% ETOH)
			<br>baculum (dried)
			<br>baculum (dry)
			<br>baculum (ethanol)
			<br>baculum (frozen)
			<br>baculum (glycerin)
			<br>baculum (slide smear)
		</p>
		<p>
	</blockquote>
	The table at the bottom of this page contains current data. It should illustrate 
	the nature of the problem.
</p>
<cfoutput>

<hr>
	Following are three examples of how this could be implemented. 
	Data in two of the examples are ordered by values in ctspecimen_part_list_order, then alphabetically. 
	Data in ctspecimen_part_list_order 
	may be updated by curatorial agreement at any time. ctspecimen_part_list_order is:
	<cfquery name="ctspecimen_part_list_order" datasource="uam_god">
		select * from ctspecimen_part_list_order order by list_order
	</cfquery>
	<cfdump var="#ctspecimen_part_list_order#">
<hr>
One option, which I believe to be unworkable with this many parts, is a simple dropdown.
<cfquery name="ctpartnamemamm" datasource="uam_god">
	select 
		part_name 
	from 
		pt_ctspecimen_part_name,
		ctspecimen_part_list_order
	where 
		collection_cde='Mamm' and
		pt_ctspecimen_part_name.part_name =  ctspecimen_part_list_order.partname (+)
	order by partname, part_name
</cfquery>
<form name="test">
<label for="one">Mammal part dropdown</label>
<select name="one">
	<cfloop query="ctpartnamemamm">
		<option value="#part_name#">#part_name#</option>
	</cfloop>
</select>
<p>
<cfquery name="ctpartnamebird" datasource="uam_god">
	select 
		part_name 
	from 
		pt_ctspecimen_part_name,
		ctspecimen_part_list_order
	where 
		collection_cde='Bird' and
		pt_ctspecimen_part_name.part_name =  ctspecimen_part_list_order.partname (+)
	order by partname, part_name
</cfquery>
<label for="two">Bird part dropdown</label>
<select name="two">
	<cfloop query="ctpartnamebird">
		<option value="#part_name#">#part_name#</option>
	</cfloop>
</select>
<hr>
I think an agent-type pick may be more practical for data entry. Type-and-tab in the box below.
<label for="three">Mammal part pick</label>
<input type="text" name="three"	onchange="findPart(this.value,'Mamm',this.name,'test');" onkeypress="return noenter(event);">

<label for="four">Bird part pick</label>
<input type="text" name="four" onchange="findPart(this.value,'Bird',this.name,'test');" onkeypress="return noenter(event);">
										
</form>
<hr>

A suggest box, while being generally disliked for data entry, can be used for searches. 
Begin typing below to see it in action. These data are for all collections, and are sorted alphabetically.
<label for="partname">Suggest-with-type part name search box</label>
<input type="text" name="partname" id="partname" size="60">
<hr>


<cfquery name="currpart" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
	select
		part_name,
		part_modifier,
		preserve_method,
		DECODE(PART_MODIFIER,
	      NULL,'',
	      PART_MODIFIER || ' ')
	    || part_name ||
	    DECODE(PRESERVE_METHOD,
	      NULL,'',
	      ' (' || PRESERVE_METHOD || ')') cpn
	from
		specimen_part
	group by
		part_name,
		part_modifier,
		preserve_method,
		DECODE(PART_MODIFIER,
	      NULL,'',
	      PART_MODIFIER || ' ')
	    || part_name ||
	    DECODE(PRESERVE_METHOD,
	      NULL,'',
	      ' (' || PRESERVE_METHOD || ')')
	order by
		part_name,
		part_modifier,
		preserve_method
</cfquery>
<p>
	Current parts, modifiers, preservation methods, and proposed combined value. Click headers to sort.
</p>

<table border id="t" class="sortable">
	<tr>
		<th>Part</th>
		<th>Modifier</th>
		<th>Presmeth</th>
		<th>Combined</th>
		<th>ImperfectLinkToSpecimens</th>
	</tr>
	<cfset header="part_name,used_by">
	<cfset variables.encoding="UTF-8">
	<cfset fname = "SpecPartCleanup.csv">
	<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		variables.joFileWriter.writeLine(header); 
	</cfscript>
		
			
			
	<cfloop query="currpart">
		<cfquery name="s" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				collection,
				collection.collection_id,
				count(*) c
			from
				collection,
				cataloged_item,
				specimen_part
			where
				collection.collection_id=cataloged_item.collection_id and
				cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
				part_name='#part_name#' and
				<cfif len(part_modifier) is 0>
					part_modifier is null
				<cfelse>
					part_modifier='#part_modifier#'
				</cfif>
				 and
				 <cfif len(preserve_method) is 0>
					preserve_method is null
				<cfelse>
					preserve_method='#preserve_method#'
				</cfif>
			group by collection,
				collection.collection_id
		</cfquery>
		<cfset cList="">
		<cfloop query="s">
			<cfset tel='<a href="/SpecimenResults.cfm?collection_id=#collection_id#&part_name=#currpart.part_name#&preserv_method=#currpart.preserve_method#&part_modifier=#currpart.part_modifier#">#s.c# #s.collection#</a>'>
			<cfset cList=listappend(cList,tel,";")>
		</cfloop>
		<cfscript>
			variables.joFileWriter.writeLine('"' & cpn & '","' &  REReplaceNoCase(cList,"<[^>]*>","","ALL") & '"');
		</cfscript>
		<tr>
			<td>#part_name#</td>
			<td>#part_modifier#</td>
			<td>#preserve_method#</td>
			<td>#cpn#</td>
			<td>#cList#</td>
		</tr>
	</cfloop>
</table>
</cfoutput>
</p>
<cfscript>	
	variables.joFileWriter.close();
</cfscript>
<a href="/download/#fname#">CSV</a>
<cfinclude template="/includes/_footer.cfm">
