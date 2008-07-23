_cfscriptLocation = "/ajax/functions.cfm";
_user_loan_functions="/ajax/user_loan_func.cfm";
_data_entry_func="/ajax/data_entry_func.cfm";
_catalog_func="/ajax/catalog_func.cfm";
_containerTree_func="/ajax/containerTree_func.cfm";
_annotateFunction="/ajax/annotateFunction.cfm";
_cfdocajax="/ajax/docFunction.cfm";
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
