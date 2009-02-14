<cfinclude template="/includes/_header.cfm">
<cfset title="Form Access">
<script>
	function setUserFormAccess (id) {
		var cid = "cell_" + id;
		var theCell = document.getElementById(cid);
		theCell.setAttribute('style','background-color:red;');
		//alert('going');
		var wwg = id.split(':');
		var role = wwg[0];
		var form = wwg[1];
		var onoff = document.getElementById(id).checked;
		//alert('onoff: ' + onoff);
		//alert('role: ' + role);
		//alert('form: ' + form);
		DWREngine._execute(_cfscriptLocation, null, 'setUserFormAccess', role,form,onoff,success_setUserFormAccess);
}
function success_setUserFormAccess (result) {
	//alert(result);
	var rarray = result.split(':');
	var status = rarray[0];
	if (status != 'Success'){
		alert('An error occured. Your changes may not have been saved.')
	} else {
		var f = rarray[1];
		var r = rarray[2];
		var o = rarray[3];
		var ids = r + ':' + f;
		var cid = "cell_" + ids;
		var theCell = document.getElementById(cid);
		theCell.setAttribute('style','background-color:;');
	}
}
	
</script>
<!---
	Set roles needed to access forms in a table, and access that table before letting users load the form

	create table cf_form_permissions (
		key number not null,
		form_path varchar2(255),
		role_name varchar2(255)
	);
	
	CREATE OR REPLACE TRIGGER cf_form_permissions_key                                         
	 before insert  ON cf_form_permissions  
	 for each row 
	    begin     
	    	if :NEW.key is null then                                                                                      
	    		select somerandomsequence.nextval into :new.key from dual;
	    	end if;                                
	    end;                                                                                            
	/
	
	// need pkey to make sure we don't kill used roles, and
	// to make sure used roles are actual roles
	
	ALTER TABLE cf_ctuser_roles ADD constraint user_role_key PRIMARY KEY (ROLE_NAME);
	ALTER TABLE cf_form_permissions
		add CONSTRAINT fk_role
  		FOREIGN KEY (role_name)
  		REFERENCES cf_ctuser_roles(ROLE_NAME);
	create or replace public synonym cf_form_permissions for cf_form_permissions;
	grant update,insert,select,delete on cf_form_permissions to global_admin;
	grant select on cf_form_permissions to public;
	
--->

Find a form using the filter below. Searches are case-sensitive. Only .cfm files are available.
<form name="r" method="post" action="form_roles.cfm">
	<input type="hidden" name="action" value="setRoles">
	Filter for form name contains: <input type="text" name="filter">
	<input type="submit">
</form>

<cfif #action# is "setRoles">
<cfoutput>
	Check or uncheck boxs below to require roles for form access. A form may require any number of roles. 
	No checks means the form is not available to any user and should be PERMANENTLY DELETED.
	
	<cfquery name="roles" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select distinct role_name from cf_ctuser_roles order by role_name
	</cfquery>
	<cfset path="">
	<cfset ff=filter>
	<cfif filter contains "/">
		<cfset sPos=RFind("/",filter)>
		<cfset path=left(filter,sPos)>
		<cfset ff=mid(filter,sPos+1,len(filter)-sPos+1)>
	</cfif>
	<cfdirectory action="LIST"
    	directory="#Application.webDirectory##path#"
        name="root"
		recurse="yes"
		filter="*#ff#*">
	<form name="r">
	<table border>
		<tr>
			<th>Form</th>
			<cfloop query="roles">
				<th style="font-size:small;">#replace(role_name,"_","_<br>")#</th>
			</cfloop>
		</tr>
		<cfset i=1>
	<cfloop query="root">
		<cfset thisName = replace(directory,Application.webdirectory,'','all')>
		<cfset thisName = "#thisName#/#name#">
		<cfif #thisName# does not contain ".svn" and
				#type# is "File" and
				#right(name,4)# is ".cfm" and
				#thisName# does not contain "/CFIDE" and
				#thisName# does not contain "/WEB-INF" and
				#thisName# does not contain "/cfdocs">
				
				 <tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
					<td style="font-size:small;">#thisName#</td>
					<cfloop query="roles">
						<cfquery name="current" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							select * from cf_form_permissions where form_path='#thisName#' and
							upper(role_name) = '#ucase(role_name)#'					
						</cfquery>
						<td id="cell_#role_name#:#thisName#">
							<input type="checkbox" name="#role_name#:#thisName#" 
								id="#role_name#:#thisName#" onchange="setUserFormAccess(this.id)"
									<cfif #current.recordcount# gt 0>checked="checked"</cfif>>
						</td>
					</cfloop>
				</tr>
				<cfset i=i+1>
		</cfif>
	</cfloop>
	</table>
	</form>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">