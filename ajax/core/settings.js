// this is used by DGR locator
_cfscriptLocation = "/ajax/functions.cfm";
_user_loan_functions="/ajax/user_loan_func.cfm";
_data_entry_func="/ajax/data_entry_func.cfm";
function errorHandler(message)
{
	$('disabledZone').style.visibility = 'hidden';
    if (typeof message == "object" && message.name == "Error" && message.description)
    {
        alert("Error: " + message.description);
    }
    else
    {
        alert(message);
    }
};
