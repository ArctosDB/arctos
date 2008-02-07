
//the window.onload wrapper around these object constructors is just for demo purposes
//in practise you would put them in an existing load function, or use a scaleable solution:
//http://www.brothercake.com/site/resources/scripts/domready/
//http://www.brothercake.com/site/resources/scripts/onload/
window.onload = function()
{



	//initialise the docking boxes manager
	var manager = new dbxManager('taskbar'); 	//session ID [/-_a-zA-Z0-9/]



	//create new docking boxes group
	var buttons = new dbxGroup(
		'buttons', 		// container ID [/-_a-zA-Z0-9/]
		'horizontal', 		// orientation ['vertical'|'horizontal']
		'8', 			// drag threshold ['n' pixels]
		'no',			// restrict drag movement to container axis ['yes'|'no']
		'15', 			// animate re-ordering [frames per transition, or '0' for no effect]
		'no', 			// include open/close toggle buttons ['yes'|'no']
		'', 			// default state ['open'|'closed']

		'', 			// vocabulary for "open", as in "open this box"
		'', 			// vocabulary for "close", as in "close this box"
		'click-down and drag to move this icon', // sentence for "move this box" by mouse
		'', 			// pattern-match sentence for "(open|close) this box" by mouse
		'use the arrow keys to move this icon', // sentence for "move this box" by keyboard
		'',  			// pattern-match sentence-fragment for "(open|close) this box" by keyboard
		'%mytitle%  [%dbxtitle%]' // pattern-match syntax for title-attribute conflicts
		);



};
