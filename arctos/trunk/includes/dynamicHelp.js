/*
Title: dynamicHelp.js 
Author: Peter DeVore
Email: pdevore@berkeley.edu

Description: 
	Library for help popups.
	A span in the document calls pageHelp2() and requests a popup. If the AJAX
	call is successful, it will create a new div to hold the information.
	On subsequent calls, it will make the div reappear, so that we (1) don't
	have to make more HTTP calls and (2) don't have to remake the div and its
	contents again.  The div is saved under id='page_help_'+fieldName .
	When the mouse is moved outside the div, removePageHelp() is called and
	changes the class of the helpPopup div so that its display='none'.
	Please read the notes below to find out about the delayed functions,
	timers, mutexes and why I had to implement them (hint: Safari makes me cry)
Dependencies:
	As of August 1st, 2007, the only file dependent on this one is
	SpecimenSearch.cfm .
	This file is dependent on the function named getHelpPopupInfo
	in ajax/functions.cfm .
Notes:
Please note that there is an inherent problem in Safari with onmouseover and
onmouseout being called.  This problem is that onmouseout and onmouseover
are repeatedly called just by moving the mouse inside the element that contains
those functions.  However, the CORRECT function is always called LAST in Safari,
which means that an effective way to work around this bug is to use timers.  
If after the timer time the other function has not been called, then you can go 
ahead.  Otherwise, this function needs to be stopped, and so will be stopped by
the other function.
--Peter DeVore
My idea is to use fighting timers, the last one to throw a punch wins.
That is to say, you will cancel the timer from the other function and start
your own timer.  That way, the last called function in a quick flurry of
function calls will have its delayed function ultimately called.  The two
functions that have the timers are pageHelp2() and removePageHelp().
--Peter DeVore
Added mutexes to prevent both functions being called at once.  
(Once one function's delayed helper function is called, the other function's
delayed helper function should NOT be allowed to do anything) However there
is no atomic check-and-set in javascript, so it only avoids the problem in 
most cases, not all cases.
--Peter DeVore
Now pageHelp2() closes all other popups when any popup is opened.
(This works MOST of the time.  If you can think of a better way to make it work
more consistently, feel free to try it out.)
--Peter DeVore
Added a variable into my functions called 'usePopups' that would determine 
whether to use popups or not.  Feel free to remove the line that defines 
usePopups (search for 'var usePopups = true;') and define it elsewhere so that
people can customize whether they want popups to appear to or not as a personal 
option.
--Peter DeVore
*/

var usePopups = true;

var timerIdPageHelp = null;
var timerIdRemovePageHelp = null;
var timerOnPageHelp = false;
var timerOnRemovePageHelp = false;
var pageHelpDelay = 10;
var mutexIsHere = true;

function grabMutex() {
	if (mutexIsHere) {
		mutexIsHere = false;
		return true;
	} else {
		return false;
	}
}

function releaseMutex() {
	mutexIsHere = true;
}

var helpDivArray = document.getElementsByTagName('div');

function closeAllPopups() {
	var i;
	for (i = 0; i < helpDivArray.length; i++) {
		if (helpDivArray[i].id.indexOf('page_help_') >= 0) {
			closePopup(helpDivArray[i]);
		}
	}
}

function closePopup(helpDiv) {
	helpDiv.style.display='none';
	helpDiv.style.className='helpPopupHidden';
}

function openExistingPopup(helpDiv) {
	helpDiv.style.display='block';
	helpDiv.className='helpPopup';
}

function pageHelp2(fieldName) {
	if (!usePopups) {
		return;
	}
	//Always need this at the beginning of main code
	//this prevents the code from going insane if it is called prematurely
	//by the browser not on an event
	if (fieldName === undefined) {
		return;
	}
	//Adapt this to my needs! see morphBankHelp.js
	if (timerOnRemovePageHelp) {
		clearTimeout(timerIdRemovePageHelp);
	}
	timerIdPageHelp = setTimeout( "delayedPageHelp2('"+fieldName+"')" , pageHelpDelay);
	var timerOnPageHelp = true;
	//end timer code
}

function delayedPageHelp2(fieldName) {
	//timer code
	var timerOnPageHelp = false;
	//end timer code
	//what if the other function is being called???
	if (!grabMutex()) {
		return;
	}
	closeAllPopups();
	
	//try to establish the helpPopup itself
	var theHelpDiv = document.getElementById("page_help_" + fieldName);
	if ((theHelpDiv == null) || (theHelpDiv == undefined)) {
		//The working portion
		DWREngine._execute(_cfscriptLocation, null, 
				'getHelpPopupInfo', fieldName, success_pageHelp2);

		//in case the AJAX portion does not work, you can use this to debug the
		//rest of the code:
		
		//var result = new Array();
		//result[0] = "Scientific Name";
		//result[1] = "The scientific name is generally the taxon name of an organism. Most specimens are identified to genus, species, and occasionally subspecies.";
		//result[2] = "http://mvzarctos-dev.berkeley.edu/cfusion/arctosdoc/taxonomy.cfm#scientific_name";
		//result[3] = fieldName;
		
		//helpEntryHelper(result);
		//End here
	} else {
		openExistingPopup(theHelpDiv);
	}
	releaseMutex();
}

function success_pageHelp2(result) {
	if (result.length == 2) {
		alert("Error: no entry for " + result[0] + ". Error type: " + result[1]);
		return;
	}
	var title = result[0];
	var content = result[1];
	var link = result[2];
	var fieldName = result[3];
	
	//Check to see that the id matches with what we are given.  Try to be lenient about
	//case issues
	var theCallingDiv = document.getElementById(fieldName);
	if (theCallingDiv === null) {
		theCallingDiv = document.getElementById(fieldName.toLowerCase());
	}
	if (theCallingDiv === null) {
		theCallingDiv = document.getElementById(fieldName.toUpperCase());
	}
	//Make sure this one is last!
	if (theCallingDiv === null) {
		alert('Could not find the anchor that called pageHelp2().');
		return;
	}
	
	//one last time, check for existence of previous popup div.  Safari
	//still has issues if you don't do this.
	if (document.getElementById("page_help_" + fieldName) != null) {
		releaseMutex();
		return;
	}
	//Setup newDiv
	//We call newHelpDiv so that we correctly refresh 
	var newDiv = document.createElement('div');
	newDiv.className = 'helpPopup';
	newDiv.setAttribute("id", "page_help_" + fieldName);
	
	//Add the title
	//var titleEle = document.createElement("h2");
	//titleEle.appendChild(document.createTextNode(title));
	//titleEle.setAttribute("align","center");
	//newDiv.appendChild(titleEle);
	
	//Add the content
	newDiv.innerHTML += content;
	theCallingDiv.title = content;

	//Add the link if it has one
	if (link.length > 0) {
		newDiv.appendChild(document.createElement("br"));
		//newDiv.appendChild(document.createTextNode('Click for more help.'));
		theCallingDiv.onclick = function() {
			windowOpener(link,'HelpWin','width=700,height=400,resizable,scrollbars,location,toolbar');
		};
	
		var anchor = document.createElement("a");
		anchor.setAttribute("align","left");
		anchor.className='likeLink';
		anchor.onclick = function() {
			windowOpener(link,'HelpWin','width=700,height=400,resizable,scrollbars,location,toolbar');
		};
		anchor.appendChild(document.createTextNode('Click for more help.'));
		//Make the link strong or
		//var strong = document.createElement('strong');
		//strong.appendChild(anchor);
		//newDiv.appendChild(strong);
		//don't make the link strong
		newDiv.appendChild(anchor);
		
	}
	
	//Finally add the new node
	//theCallingDiv.appendChild(newDiv);
	releaseMutex();
}


function removePageHelp(fieldName) {
	if (!usePopups) {
		return;
	}
	//Always need this at the beginning
	if (fieldName === undefined) {
		return;
	}
	//Adapt this to my needs! see morphBankHelp.js
	if (timerOnPageHelp) {
		clearTimeout(timerIdPageHelp);
	}
	timerIdRemovePageHelp = setTimeout( "delayedRemovePageHelp('"+fieldName+"')" , pageHelpDelay);
	timerOnRemovePageHelp = true;
	//end timer code
}

function delayedRemovePageHelp(fieldName) {
	//timer code
	var timerOnRemovePageHelp = false;
	//end timer code
	//what if the other function is being called???
	if (!grabMutex()) {
		return;
	}
	
	var theHelpDiv = document.getElementById("page_help_" + fieldName);
	if (theHelpDiv != null) {
		closePopup(theHelpDiv);
	} /*else {
		alert('the code should never get here');
	}*/
	releaseMutex();
}