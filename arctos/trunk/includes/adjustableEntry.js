/* 
Title: adjustableEntry.js 
Author: Peter DeVore
Email: pdevore@berkeley.edu 

Description: 
	A tool for adding and removing rows in a table. Will allow for an
	arbitrary number of variable inputs in a form, where each name is
	differentiated by increasing a number at the end of the variable name.
Dependencies:
	None.
Usage: 
	Put a row with the headers you want, then put in another row with
	a unique, descriptive id, and include a table data cell with a button
	that includes the following: 
	onclick="javascript: addNewRow(
		<array of tag strings>, 
		<array of arrays of attribute types>,
		<array of arrays of attribute values>,
		<array of inner HTMLs>,
		<the unique descriptive id you chose earlier as a string>,
		<the name of the variable you want to use>
	);"
Example:
	<tr>
		<td>Find:</td><td>Replace with:</td><td>Catalog number(s) (comma separated, ranges using "-") or blank for all geographies</td>
	</tr>
	<tr id='endOfGeogMod'>
		<td><input type='button' className='picBtn' 
	onclick='
	javascript: addNewRow(
		new Array("input","input","input"),
		new Array(
			new Array("type","name","size"),
			new Array("type","name","size"),
			new Array("type","name","size")
		),
		new Array(
			new Array("text","Find",50),
			new Array("text","Replace",40),
			new Array("text","Scope",60)
		),
		new Array("","",""),
		"endOfGeogMod",
		"geogMod"
	);' value='Add new geography modifier' /></td>
	</tr>
Caution:
	The last character in varName CANNOT be a number.
	(And perhaps also in each string in varSuffixArray, but I haven't tested 
	that. Feel free to test that out and fill in the documentation.)
*/

/* 
function: addNewRow
	Adds a new row with one element in each <td>. The properties of those 
	elements are designated by the arrays.
Usage:
	tagArray (required): An array of tag name strings. 
		Each tag will be used in a new table data cell.
	attributeTypeArray (required): An array where each element is an array
		corresponding to one element in tagArray. These subarrays contain the 
		attribute types. You may make the subarrays empty, but you need one 
		subarray per element in tagArray.
	attributeValueArray (required): An array where each element is an array
		corresponding to one element in tagArray. These subarrays contain the
		attribute names. You may make the subarrays empty, but you need one 
		subarray per element in tagArray.
	innerHTMLArray (required): An array containing the string of HTML you wish
		to put inside each element in tagArray.
	endRowID (required): A string of the id of the row before which the new 
		rows are to be added.
	varName (required): A string specifying the id of the rows to be made 
		(sans the added number).
*/
function addNewRow(tagArray, attributeTypeArray, attributeValueArray, 
		innerHTMLArray, endRowID, varName) {
		
	//Find the row before which to place the new row	
	var endRow = document.getElementById(endRowID);
	
	//Create the new row
	var prevRow = endRow.previousSibling;
	
	//Determine the number of this new row
	var curNum = 1;
	if (prevRow.id && prevRow.id.indexOf(varName) == 0) {
		//The the previous row is an entry, so we increment the
		//previous number
		var previousNum = prevRow.id.substr(varName.length);
		var curNum = 1 + Number(previousNum);
	}
	var newRow = document.createElement("tr");
	newRow.id = varName + curNum;
	
	var td;
	var e;
	
	//Create the tds and inner elements in each td
	for (var i = 0; i < tagArray.length; i++) {
		td = document.createElement("TD");
		e = document.createElement(tagArray[i]);
		for (var j = 0; j < attributeTypeArray.length; j++) {
			var temp;
			if (attributeTypeArray[i][j].toUpperCase() == 'NAME') {
				temp = attributeValueArray[i][j] + curNum;
			} else {
				temp = attributeValueArray[i][j];
			}
			setAttribute(e, attributeTypeArray[i][j], temp);
		}
		e.innerHTML = innerHTMLArray[i];
		td.appendChild(e);
		newRow.appendChild(td);
	}
	
	//Make a delete button the removes the current row on click
	td = document.createElement("TD");
	e = document.createElement("INPUT");
	e.type = 'button';
	e.value = 'Delete';
	e.onclick = function() {
		removeRow(tagArray, attributeTypeArray, attributeValueArray, endRowID, varName);
	}
	e.tagArray = tagArray;
	e.varName = varName;
	e.attributeTypeArray = attributeTypeArray;
	e.attributeValueArray = attributeValueArray;
	e.endRowID = endRowID;
	if (e.captureEvents) {
		e.captureEvents(Event.CLICK);
	}
	td.appendChild(e);
	newRow.appendChild(td);
	
	//Insert the newly created row into the html document
	endRow.parentNode.insertBefore(newRow,endRow);
}

/*Auxiliary function*/
function removeRow(tagArray, attributeTypeArray, attributeValueArray, endRowID, varName) {
	//Determine the row number
	var that = this.parentNode.parentNode;
	var num = that.id.substr(varName.length);
	
	//Save a reference to the next row
	var theNextRow = that.nextSibling;
	
	//Remove the row
	that.parentNode.removeChild(that);
	
	//Since the name of each row is different, we should reindex the name number
	reIndex(theNextRow, num, tagArray, attributeTypeArray, attributeValueArray, endRowID, varName);
}

/*Auxiliary function*/
function reIndex(theRow, num, tagArray, attributeTypeArray, 
		attributeValueArray, endRowID, varName) {
	
	//Loop through the rows	
	while (theRow.id != endRowID) { 
		var tagIndex = 0;
		
		//Loop through the table data
		for (var curCell = 0; curCell < theRow.cells.length; curCell++) {

			//Loop through the table data's children
			for (var e = theRow.cells[curCell].firstChild(); 
					e != null; e = e.nextSibling) {
				
				//Only do stuff if the node is in the tagArray, and not 
				//an added text node
				if (tagArray[tagIndex] == e.nodeName) {
					
					//Change the name attribute to reflect the new value
					for (var curAttr = 0; curAttr < attributeTypeArray.length; curAttr++) {
						if (attributeTypeArray[curCell][curAttr].toUpperCase() == 'NAME') {
							setAttribute(e, attributeTypeArray[curCell][curAttr], 
									attributeValueArray[curCell][curAttr] + num);
						}
					}
				}
			}
		}
		theRow.id = varName + num;
		num++;
		theRow = theRow.nextSibling;
	}
	
}

function setAttribute(node, name, value) {
	for (var i = 0; i < node.attributes[i]; i++) {
		if (node.attributes[i].name.toUpperCase() == name.toUpperCase()) {
			node.attributes[i].value = value;
		}
	}
} 