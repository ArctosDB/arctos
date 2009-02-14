
	  <cfinclude template="/includes/_pickHeader.cfm">
	<cfoutput>
	<cfset title="Attributes Help">
	
		
	<cfif not isdefined("attNum")>
		<!--- they came in from the Attributes Help or More Info links---->
			<i><b>Definition:</b></i> Attributes include characteristics and measurements.  Weight, age, and sex are some examples.
Attributes always have a value, and sometimes have units. For example:</p>
	<table border="1">
		<tr><td><i>Attribute</i>	</td><td><i>Value</i></td><td><i>Units</i></td></tr>
		<tr><td>weight		</td><td>37.2		</td><td>g</td></tr>
		<tr><td>numeric age	</td><td>14		</td><td>years</td></tr>
	<tr><td>sex		</td><td>female		</td><td>[null]</td></tr>
	</table>

<p align="left"><i><b>Searching:</b></i>  You may search for records which have a particular attribute
	by specifying an attribute but not a value.  For example:</p>
	<table border="1">
		<tr><td><i>Attribute</i></td>	<td><i>Operator</i></td>	</td><td><i>Value</i></td>	<td><i>Units</i></td></tr>
		<tr><td><b>weight</b></td>			<td>[whatever]</td>		</td><td>[blank]</td>		<td>[blank]</td></tr>
	</table>	
This will return records with data for the attribute.
Exercising this option unwisely (e.g., all mammals with attribute "sex")
will likely fail by either timing out or crashing your browser.

<p align="left">Similarly, you could search for a particular attribute which has been described in particular units.  For example:</p>
	<table border="1">
		<tr><td><i>Attribute</i></td>	<td><i>Operator</i></td>	</td><td><i>Value</i></td>	<td><i>Units</i></td></tr>
		<tr><td><b>numeric age</b></td		><td>[whatever]</td>		</td><td>[blank]</td>		<td><b>months</b></td></tr>
	</table>	
<p align="left">This will return all records with a numeric age recorded in months.</p>

<p align="left">You may set the Attribute Operator to <i>equals, contains, greater than,</i> or <i>less than.</i> 
<i>Greater than</i> and <i>less than</i> work only for attributes that are expressed numerically.
For example:</p>
	<table border="1">
		<tr><td><i>Attribute</i></td>	<td><i>Operator</i></td>	</td><td><i>Value</i></td>	<td><i>Units</i></td></tr>
		<tr><td>total length</td	><td><b>greater than</b></td>	<td><b>99</b></td>		<td>mm</td></tr>
	</table>
<p align="left">This will return all records where the total length of the animal is recorded as 100 mm or greater. 
<i>Equals</i> will only find exact matches of either numeric or text strings.
<i>Greater than</i> and <i>less than</i> will produce errors if used with non-numeric values.</p>

<p align="left"><i>Contains</i> matches strings and substrings. 
For example:</p>
	<table border="1">
		<tr><td><i>Attribute</i></td>	<td><i>Operator</i></td>	</td><td><i>Value</i></td>	<td><i>Units</i></td></tr>
		<tr><td>sex</td			><td><b>contains</b></td>	<td><b>male</b></td>		<td>[blank]</td></tr>
	</table>
<p align="left">This will return all reocords for which the attribute sex contains the <b>substring</b> "male."
These include "male ?,"  "fe<b>male</b>," and "fe<b>male</b> ?"</p>

<p align="left">You can see possible attribute values (and fill in search fields with them) by clicking the button
<a href="/info/attributeHelpPick.cfm?attnum=1"><img src="/images/info.gif"></a> either here or to the right of each attribute row.
<!----

			<hr><hr>
			<p align="left"><i><b>Definition:</b></i>
			<i>Attributes</i> are things such as weight, measurements, and sex. Each specimen may have zero, one, or many attributes. 
			<p align="left"><i><b>Searching:</b></i>
				<blockquote>
					Attributes always have a value, and sometimes have units. For example:
						<ul>
							<li>total length</li>
								<ul>
									<li>Value: Non-controlled numeric values (ie, "10")</li>
									<li>Units: Controlled length units values (ie, "mm," "cm")</li>
								</ul>
							<li>age class</li>
								<ul>
									<li>Value: Controlled text values (ie, "adult," "juvenile")</li>
									<li>Units: null</li>
								</ul>
							<li>colors</li>
								<ul>
									<li>Value: Non-controlled text values (ie, "reddish feet," "brown iris")</li>
									<li>Units: null</li>
								</ul>
						</ul> 
						You may search for only attributes (leave Value and Units blank) to return specimens which match your other criteria and have the attribute you specify. Exercising this option unwisely (ie, searching for all specimens with attribute 'sex' and no other qualifies) will likely time-out your request and/or break your browser.
						<p>You may also search for attributes only by value or units. For example:
							<ul>
								<li>Attribute: numeric age</li>
								<li>Units: years</li>
									<ul>
										<li>Returns all specimens with a numeric age recorded in years</li>
									</ul>
								<li>Attribute: numeric age</li>
								<li>Value: 1</li>
									<ul>
										<li>Returns all specimens with a numeric age of 1 (years, days, etc.)</li>
									</ul>
							</ul>
						</p>
						<p>You may set the Attribute Operator to 'equals,' 'contains,' 'greater than,' or 'less than.' <i>Equals</i> will only find exact matches. <i>Contains</i> will find string matches. For example, sex <i><b>equals</b></i> 'male' will find only <i>male</i> specimens; sex <i><b>like</b></i> 'male' will find <i>male</i>, <i>male ?</i>, <i>female</i>, and <i>female ?</i>. <i>Greater than</i> and <i>less than</i> will produce errors if used with non-numeric values.
						
						</p>
				</blockquote>
			</p>
			<p>You may see possible attribute values (and populate search fields with them) by clicking the <img src="/images/info.gif"> button to the right of an attribute field.
			<!--- send them to the picker part --->
			<p>Click  <a href="/info/attributeHelpPick.cfm?attnum=1">here</a> to get started.</p>
			<p align="right"><a href="javascript: void();" onClick="self.close();">Close this window</a></p>
			---->
			<cfinclude template="/includes/_pickFooter.cfm">
			<cfabort>
	</cfif>
	
	
	<!---- cache this query - it defines what code tables to use for a specific attribute and won't change often.--->
<cfquery name="ctCodes" datasource="#Application.web_user#"   cachedwithin="#createtimespan(0,0,120,0)#">
	select 
		attribute_type,
		value_code_table,
		units_code_table
	 from ctattribute_code_tables
		GROUP BY
		attribute_type,
		value_code_table,
		units_code_table
</cfquery>
		<cfquery name="atts" datasource="#Application.web_user#"  cachedwithin="#createtimespan(0,0,120,0)#">
			<!---- attributes don't change very often - cache that query for a couple hours. ---->
			SELECT DISTINCT(attribute_type) FROM ctattribute_type
		</cfquery>
		<cfif not isdefined("attribute") OR len(#attribute#) is 0><!--- set it to something random --->
			<cfset attribute = "#atts.attribute_type#">
			
		</cfif>
		
		<p>To use this form:
		<ul>
			<li>Pick an attribute to see possible values for units and value.</li>
			<li>Click a link to populate Specimen Search Attribute and Value/Units fields</li>					
		</ul>
		<br>Click <a href="/info/attributeHelpPick.cfm">here</a> for more information about attributes and how to search for them.
		<cfif not isdefined("clsWin")>
			<cfset clsWin = "yes">
		</cfif>
		<table border>
		<form name="attPick" method="post" action="attributeHelpPick.cfm">
			<input type="hidden" name="attribute" value="#attribute#">
			
			<input type="hidden" name="clsWin" value="#clsWin#">
			<input type="hidden" name="attNum" value="#attNum#">
			Close this window when an attribute is clicked?
			<br>Yes<input type="radio" name="cw" 
				<cfif #clsWin# is "yes"> checked </cfif>
				onchange="attPick.clsWin.value='yes';submit();">
			<br>No<input type="radio" name="cw"
				<cfif #clsWin# is "no"> checked </cfif>
				onchange="attPick.clsWin.value='no';submit();">
		
		
			<tr>
				<td valign="top">Attribute</td>
				<td>Values</td>
				<td>Units</td>
			</tr>
		<tr>
		<td valign="top" width="80">
		
			
			<select name="attribute_type" size="1" onChange="attPick.attribute.value=attPick.attribute_type.value;submit();">
				<cfloop query="atts">
					<option 
						<cfif #attribute# is "#atts.attribute_type#"> selected </cfif>
						value="#atts.attribute_type#">#atts.attribute_type#</option>
				</cfloop>
			</select>
		</form>
			
			
			</td>
			
			
			
			
			
			
			<!---- see if we should have a code table here --->
		<cfquery name="isValCt" dbtype="query">
			select value_code_table from ctCodes where attribute_type='#attribute#'
		</cfquery>
		<cfif isdefined("isValCt.value_code_table") and len(#isValCt.value_code_table#) gt 0>
			<!--- there's a code table --->
			<cfquery name="valCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from #isValCt.value_code_table#
			</cfquery>
			<!----------------------->
			<!---- get column names --->
			<cfquery name="getCols" datasource="uam_god">
				select column_name from sys.user_tab_columns where table_name='#ucase(isValCt.value_code_table)#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
				<cfset collCode = "">
				<cfset columnName = "">
				<cfloop query="getCols">
					<cfif getCols.column_name is "COLLECTION_CDE">
						<cfset collCde = "yes">
					  <cfelse>
					 	<cfset columnName = "#getCols.column_name#">
					</cfif>
				</cfloop>
				<!--- if we got a collection code, rerun the query to filter ---->
				
				
				
				  	<cfquery name="valCodes" dbtype="query">
						SELECT distinct(#getCols.column_name#) as valCodes from valCT
					</cfquery>
					
				<td valign="top" width="120" align="left">
				
					<cfloop query="valCodes">
						<cfset cleanVal = #replace(valCodes.valCodes,"'","\'","all")#>
						<a href="javascript: void(0);" 
							onClick="opener.document.SpecData.attribute_value_#attNum#.value='#cleanVal#'; 
								opener.document.SpecData.attribute_type_#attNum#.value='#attribute#'; 
								opener.document.SpecData.attribute_units_#attNum#.value=''; 
								<cfif #clsWin# is "yes">
									self.close();
								</cfif>">
								#valCodes.valCodes#</a>
						<br>
					</cfloop>
				
			</td>
		  <cfelse><!--- free text --->
		  <td valign="top" width="120" align="left">
		  This attribute's value is not code table controlled.
		  </td>
		</cfif>
		
		
		
		
			<!---- see if we should have a code table here --->
		<cfquery name="isUnitCt" dbtype="query">
			select units_code_table from ctCodes where attribute_type='#attribute#'
		</cfquery>
		<cfif isdefined("isUnitCt.units_code_table") and len(#isUnitCt.units_code_table#) gt 0>
		
			<!---- there's a code table --->
			<!---- get the data --->
			<cfquery name="unitCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from #isUnitCt.units_code_table#
			</cfquery>
			<!---- get column names --->
			<cfquery name="getCols" datasource="uam_god">
				select column_name from sys.user_tab_columns where table_name='#ucase(isUnitCt.units_code_table)#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
				<cfset collCode = "">
				<cfset columnName = "">
				<cfloop query="getCols">
					<cfif getCols.column_name is "COLLECTION_CDE">
						<cfset collCde = "yes">
					  <cfelse>
					 	<cfset columnName = "#getCols.column_name#">
					</cfif>
				</cfloop>
				<!--- if we got a collection code, rerun the query to filter ---->
				
				  	<cfquery name="unitCodes" dbtype="query">
						SELECT distinct(#getCols.column_name#) as unitCodes from unitCT
					</cfquery>
				
				
					
				
		  
		 
		</cfif>
		<td valign="top" width="120" align="left">
		<cfif isdefined("unitCodes.unitCodes") and len(#unitCodes.unitCodes#) gt 0>
			<cfloop query="unitCodes">
						<a href="javascript: void(0);" 
							onClick="opener.document.SpecData.attribute_units_#attNum#.value='#unitCodes.unitCodes#'; 
							opener.document.SpecData.attribute_type_#attNum#.value='#attribute#';
							opener.document.SpecData.attribute_value_#attNum#.value='';  
								<cfif #clsWin# is "yes">
									self.close();
								</cfif>">#unitCodes.unitCodes#</a>
						<br>
		  </cfloop>
				<cfelse>
				This attribute is unitless.
		</cfif>
		
		</td>
		
		
		</tr>
		</table>
		
		
		<p align="right"><a href="javascript: void();" onClick="self.close();">Close this window</a></p>
		
	</cfoutput>
<cfinclude template="/includes/_pickFooter.cfm">