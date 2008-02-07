
<!--- 

BETTERSELECT: 

A Javascript function and ColdFusion custom tag to enhance a select box element with progressive narrowing capabilities for searching long drop-down menus.  Just click on a drop-down select list and start typing to watch the menu start to narrow to the desired option.  Great for long lists of names.

Author: Neal Enssle (enssle@thinksign.com, www.thinksign.com)
Creation Date: June, 2001
Version: 1.0

CUSTOM TAG: This version is a ColdFusion custom tag: <cf_betterselect>

USAGE: To use as a ColdFusion custom tag, simply place this file in either the ColdFusion custom tags directory on the server or in the same directory as the calling template.  Place the <cf_betterselect> start and end tags around the code for the list items -- <option> items generated from the output of a ColdFusion/SQL query are acceptable.  Most standard select attributes are valid in <cf_betterselect>.  The only required attributes are the "name" attribute designating the <select> box and the "formname" attribute specifying the form used.

EXAMPLE:	<cf_betterselect name="employeesList" formname="form_getEmployees">
			<option>...</option>
		</cf_betterselect>

The content of the tag inside the <cf_betterselect> tags can be generated via a ColdFusion/SQL query via standard <cfoutput query="queryName">.

Note: BetterSelect has been tested on IE 5.0+.  It is unlikely that it will work, in its current version, in Netscape.  A Netscape-compatible version is in development! 

LATEST VERSION: Available at http://www.thinksign.com/ideabox

--->

<cfsetting showdebugoutput="no">

<!--- TAG ATTRIBUTES: Only the first two attributes (NAME and FORMNAME) are requried.  These mirror all standard attributes of the regular <select> tag in HTML --->

<cfparam name="attributes.name" default="betterSelectBox"> <!--- Required --->
<cfparam name="attributes.formname" default="document.forms(0)"> <!--- Required --->
<cfparam name="attributes.id" default="">
<cfparam name="attributes.class" default="">
<cfparam name="attributes.style" default="">
<cfparam name="attributes.title" default="">
<cfparam name="attributes.tabindex" default="">
<cfparam name="attributes.size" default="1">
<cfparam name="attributes.multiple" default="no">
<cfparam name="attributes.onmouseover" default="">
<cfparam name="attributes.onmouseout" default="">
<cfparam name="attributes.onfocus" default="">
<cfparam name="attributes.onblur" default="">
<cfparam name="attributes.onselect" default="">

<!--- Note that the "onclick", "onkeydown", and "onkeyup" attributes are used by the custom tag routines and may not be altered or specified via tag attributes. --->


<!--- CUSTOM TAG code begins here --->

<cfswitch expression="#thistag.executionmode#">

<!--- Start tag: Set up attributes and tie into Javascript functionality --->

<!--- onclick="searchString = ''; window.status = '';" --->

<cfcase value="start">

<!--- Javascript begins here --->

<script>

var searchString = "";

function clearSearchString() {
	searchString = "";
}

function betterSelect(selectName, formName) {
	// Get the keypress from the select box
	var keyCode = event.keyCode;
	var keyChar = String.fromCharCode(keyCode).toLowerCase();
	var selectBox = eval("document." + formName + "." + selectName);
	var optionsCount = selectBox.options.length;
	var i;
	
	// Check to see if the keypress is something we should care about...
	
	if ((keyCode == "8") || (keyCode == "46")) { 
		// Delete or backspace decrement the searchString
		searchString = searchString.slice(0,-1);
	} else if ((keyCode == "38") || (keyCode == "37")) {
		// Up or left arrow move to the preceeding item in options list
		if (selectBox.selectedIndex > 0) {
			selectBox.selectedIndex --; }
		return false;
	} else if ((keyCode == "40") || (keyCode == "39")) {
		// Down or right arrow move to the next item in the options list
		if (selectBox.selectedIndex < (optionsCount - 1)) {
			selectBox.selectedIndex ++; }
		return false;
	} else if (keyCode == "27") {
		// Escape clears the searchString variable
		searchString = "";
		window.status = "";
		return false;
	} else if (keyCode == "188") {
		// Comma dealt with manually
		searchString = searchString + ",";
	} else { 
		// Add the new keypress to the searchString variable (default)
		searchString = searchString + keyChar;
	}
	
	// Display keypresses in the status bar at the bottom of the window
	
	var statusDisplay = searchString.toUpperCase();
	window.status = "Narrowing select menu items (press 'Esc' to clear): " + statusDisplay;
	
	// Advance to the selected item
	
	for(i = 0 ; i < optionsCount; i++) {
		var optionItem = selectBox.options[i].text;
		
		// Uncomment this routine to selectively exclude portions of a substring (e.g. commas, etc.)
		/* var findComma = optionItem.indexOf(", ");
		if (findComma != -1) {
			optionItem = optionItem.substr(0, findComma) +  optionItem.substr(findComma + 2, optionItem.length);
		} */
		
		var optionItemSubString = optionItem.substring(0,searchString.length).toLowerCase();
		
		// Check each option item for text like the current searchString
		if (optionItemSubString == searchString) {
			// If there is a match, select that item and exit loop
			selectBox.options[i].selected = true;
			break;
		}
	}
}

</script>


<!--- End Javascript code --->


	<cfoutput>
	<select name="#attributes.name#" id="#attributes.id#" onkeydown="return false;"  onkeyup="betterSelect('#attributes.name#', '#attributes.formname#');" onclick="clearSearchString(); window.status = '';" onselect="#attributes.onselect#" onmouseover="#attributes.onmouseover#" onmouseout="#attributes.onmouseout#" onfocus="#attributes.onfocus#" onblur="#attributes.onblur#" class="#attributes.class#" style="#attributes.style#" title="#attributes.title#" tabindex="#attributes.tabindex#" size="#attributes.size#" <cfif attributes.multiple EQ "yes">multiple</cfif>>
	</cfoutput>
</cfcase>

<!--- onclick="searchString = ''; window.status = '';" --->

<!--- End tag --->

<cfcase value="end">
	</select>
</cfcase>

</cfswitch>

<!--- End custom tag code here --->


