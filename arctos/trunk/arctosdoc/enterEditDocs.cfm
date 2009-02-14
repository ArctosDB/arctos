<cfinclude template="/includes/_helpHeader.cfm">
<cfquery name="isAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select privs from cf_auth_arctosdoc where username='#session.username#'
</cfquery>
<cfif #len(isAuth.privs)# is 0>
	not authorized.
	<cfabort>
</cfif>

<style>
	input {font-size:.8em;};
</style>
<!---
create table cf_auth_arctosdoc (
	username varchar2(255) not null,
	authorized_by varchar2(255) not null
	);
create public synonym cf_auth_arctosdoc for cf_auth_arctosdoc;
grant all on cf_auth_arctosdoc to manage_authority;
grant select on cf_auth_arctosdoc to public;

alter table cf_auth_arctosdoc add privs varchar2(30);
alter table cf_auth_arctosdoc modify privs varchar2(30) NOT NULL;
insert into cf_auth_arctosdoc values ('dlm','dlm');
insert into cf_auth_arctosdoc values ('gordon','dlm');
	

uam> desc documentation
 Name                                                  Null?    Type
 ----------------------------------------------------- -------- ------------------------------------
 DOC_ID                                                NOT NULL NUMBER
 DEFINITION                                            NOT NULL VARCHAR2(4000)
 COLNAME                                               NOT NULL VARCHAR2(255)

create sequence documentation_seq;
 CREATE OR REPLACE TRIGGER documentation_pkey                                         
 before insert  ON documentation  
 for each row 
    begin     
    	if :NEW.DOC_ID is null then                                                                                      
    		select documentation_seq.nextval into :new.DOC_ID from dual;
    	end if;                                
    end;                                                                                            
/
sho err
delete from documentation;
<!--- seed the table - we can clean up later --->
insert into documentation (colname,definition) (select lower(table_name) || '.' || lower(column_name),'pending' from all_tab_cols
where OWNER='UAM' AND
		table_name not like '%$%' AND
		NOT REGEXP_LIKE(table_name, '[[:digit:]]') AND
		upper(table_name) not like '%BULK%' AND
		upper(table_name) not like '%TOAD%' AND
		upper(table_name) not like '%TEMP%' AND
		upper(table_name) not like 'CF%' AND
		upper(table_name) not like 'CT%' AND
		upper(table_name) not like 'USER%'	);
		
delete from documentation where colname like 'accepted_lat_long%';
delete from documentation where colname like 'blt.%';
delete from documentation where colname like 'cdata.%';
delete from documentation where colname like 'cglobal.%';
delete from documentation where colname like 'darwin%';
delete from documentation where colname like 'detail%';
delete from documentation where colname like 'digir%';

create unique index udoccolname on documentation (colname);
create unique index udocdispname on documentation (display_name);

alter table documentation add more_info varchar2(255);
alter table documentation add display_name varchar2(255);
alter table documentation modify display_name varchar2(255) not null;
---->
<script>

function saveMoreInfoChange (docid,ele) {
	//alert(defn);
	var d = 'more_info_' + docid;
	var elem = document.getElementById(d);
	//alert(ele);
	ele = ele.replace('#','##');
	//alert(ele);
	elem.className='red';
	DWREngine._execute(_cfdocajax, null, 'saveMoreInfoChange',docid,ele, success_saveMoreInfoChange);
}
function success_saveMoreInfoChange (result) {
	//alert(result);
	var rAry = result.split('|');
	var st = rAry[0];
	var msg = rAry[1];
	if (st=1) {
		var d = 'more_info_' + msg;
		var def=document.getElementById(d);
		def.className='';
	} else {
		alert('Error: ' + msg);
	}
}
function saveSearchHintChange (docid,ele) {
	//alert(defn);
	var d = 'more_info_' + docid;
	var elem = document.getElementById(d);
	//alert(ele);
	ele = ele.replace('#','##');
	//alert(ele);
	elem.className='red';
	DWREngine._execute(_cfdocajax, null, 'saveSearchHintChange',docid,ele, success_saveSearchHintChange);
}
function success_saveSearchHintChange (result) {
	//alert(result);
	var rAry = result.split('|');
	var st = rAry[0];
	var msg = rAry[1];
	if (st=1) {
		var d = 'more_info_' + msg;
		var def=document.getElementById(d);
		def.className='';
	} else {
		alert('Error: ' + msg);
	}
}



					onblur="('#search_hint#',this.value);">#search_hint#</textarea>
					
					
					
function saveDisplayNameChange (docid,ele) {
	//alert(defn);
	var d = 'display_name_' + docid;
	var elem = document.getElementById(d);
	elem.className='red';
	DWREngine._execute(_cfdocajax, null, 'saveDisplayNameChange',docid,ele, success_saveDisplayNameChange);
}
function success_saveDisplayNameChange (result) {
	//alert(result);
	var rAry = result.split('|');
	var st = rAry[0];
	var msg = rAry[1];
	if (st=1) {
		var d = 'display_name_' + msg;
		var def=document.getElementById(d);
		def.className='';
	} else {
		alert('Error: ' + msg);
	}
}

function saveColnameChange (docid,ele) {
	//alert(defn);
	var d = 'colname_' + docid;
	var elem = document.getElementById(d);
	elem.className='red';
	DWREngine._execute(_cfdocajax, null, 'saveColnameChange',docid,ele, success_saveColnameChange);
}
function success_saveColnameChange (result) {
	//alert(result);
	var rAry = result.split('|');
	var st = rAry[0];
	var msg = rAry[1];
	if (st=1) {
		var d = 'colname_' + msg;
		var def=document.getElementById(d);
		def.className='';
	} else {
		alert('Error: ' + msg);
	}
}
function saveDefinitionChange (docid,defn) {
	//alert(defn);
	var d = 'definition_' + docid;
	var def = document.getElementById(d);
	def.className='red';
	DWREngine._execute(_cfdocajax, null, 'saveDefnChange',docid,defn, success_saveDefinitionChange);
}
function success_saveDefinitionChange (result) {
	//alert(result);
	var rAry = result.split('|');
	var st = rAry[0];
	var msg = rAry[1];
	if (st=1) {
		var d = 'definition_' + msg;
		var def=document.getElementById(d);
		def.className='';
	} else {
		alert('Error: ' + msg);
	}
}
function deleteOne(docid) {
	var c = 'colname_' + docid;
	//alert(c);
	var col=document.getElementById(c);
	var colname = col.value;
	var d = 'definition_' + docid;
	var def = document.getElementById(d);
	col.className='red';
	def.className='red';
	DWREngine._execute(_cfdocajax, null, 'deleteOne',docid,success_deleteOne);
}

function success_deleteOne (result) {
	//alert(result);
	var rAry = result.split('|');
	var st = rAry[0];
	var msg = rAry[1];
	if (st=1) {
		theTr = 'tr_' + msg;
		var def=document.getElementById(theTr);
		def.style.display='none';
	} else {
		alert('Error: ' + msg);
	}
}
</script>
<cfif #action# is "manageAccess">
	<cfoutput>
	<a href="enterEditDocs.cfm">Manage Data</a>
		<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from cf_auth_arctosdoc order by username
		</cfquery>
		<cfquery name="ctu" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select username from cf_users
			where username not in (select username from cf_auth_arctosdoc)
			order by username
		</cfquery>
		<form name="new" method="post" action="enterEditDocs.cfm">
			<input type="hidden" name="action" value="authNewUser">
			<label for="newUser">New User Name</label>
			<select name="newUser" size="1">
				<cfloop query="ctu">
					<option value="#username#">#username#</option>
				</cfloop>
			</select>
			<label for="newPrivs">Privileges</label>
			<select name="newPrivs" id="newPrivs" size="1">
					<option value="edit">edit</option>
					<option value="all">edit/add users</option>
			</select>
			<br>
			<input type="submit" value="Create New User"
				class="insBtn"
				onmouseover="this.className='insBtn btnhov'" 
				onmouseout="this.className='insBtn'">
		</form>
		<h2>Existing Users</h2>
		<table border>
			<tr>
				<td><strong>Username</strong></td>
				<td><strong>Privileges</strong></td>
				<td>&nbsp;</td>
			</tr>
		<cfset i=1>
		<cfloop query="u">
			<form name="m#i#" method="post" action="enterEditDocs.cfm">
				<input type="hidden" name="action" value="editUser">
				<input type="hidden" name="username" value="#username#">
				<tr>
					<td>
						#username#
					</td>
					<td>
						<select name="privs" size="1">
							<option <cfif #privs# is "edit"> selected </cfif>value="edit">edit</option>
							<option <cfif #privs# is "all"> selected </cfif>value="all">edit/add users</option>
						</select>
					</td>
					<td>
						<input type="button" value="Save Edits"
							class="savBtn"
							onmouseover="this.className='savBtn btnhov'" 
							onmouseout="this.className='savBtn'"
							onclick="m#i#.action.value='editUser';m#i#.submit();">
						<input type="button" value="Delete User"
							class="delBtn"
							onmouseover="this.className='delBtn btnhov'" 
							onmouseout="this.className='delBtn'"
							onclick="m#i#.action.value='delUser';m#i#.submit();">
					</td>
				</tr>
			</form>
			<cfset i=#i#+1>
		</cfloop>
		
		</table>
	</cfoutput>
	
</cfif>
<cfif #action# is "editUser">
	<cfoutput>
		<cfquery name="nu" datasource="#Application.uam_dbo#">
			update cf_auth_arctosdoc set 
			privs='#privs#' where
				username=
				'#username#'
		</cfquery>
		<cflocation url="enterEditDocs.cfm?action=manageAccess">
	</cfoutput>
</cfif>
<!----------------------------------------->
<cfif #action# is "delUser">
	<cfoutput>
		<cfquery name="nu" datasource="#Application.uam_dbo#">
			delete from cf_auth_arctosdoc where
				username=
				'#username#'
		</cfquery>
		<cflocation url="enterEditDocs.cfm?action=manageAccess">
	</cfoutput>
</cfif>
<!----------------------------------------->
<cfif #action# is "authNewUser">
	<cfoutput>
		<cfquery name="nu" datasource="#Application.uam_dbo#">
			insert into cf_auth_arctosdoc (
				username,
				authorized_by,
				privs
			) values (
				'#newUser#',
				'#session.username#',
				'#newPrivs#')
		</cfquery>
		<cflocation url="enterEditDocs.cfm?action=manageAccess">
	</cfoutput>
</cfif>
<cfif #action# is "newDoc">
<cfoutput>
<cfquery name="theRest" datasource="#Application.uam_dbo#">
	select lower(table_name) || '.' || lower(column_name) colname
	from all_tab_cols
	where 
		lower(table_name) || '.' || lower(column_name) not in (select colname from documentation) and
		owner='UAM'
</cfquery>

<h3>
Create Documentation:
</h3>
<form name="new" method="post" action="enterEditDocs.cfm">
	<input type="hidden" name="action" value="createNew">
	<label for="newCN">New Column Name (pick OR type - not both)</label>
	<select name="newCN" id="newCN" size="1">
		<option value=""></option>
		<cfloop query="theRest">
			<option value="#colname#">#colname#</option>
		</cfloop>
	</select>
	<label for="newCN">New Column Name (pick OR type - not both)</label>
	<input type="text" name="tnewCN" id="tnewCN" size="80">
	<label for="newDef">New Display Name</label>
	<input type="text" name="newDispname" id="newDispname" size="80">
	<label for="newDef">New Definition</label>
	<textarea name="newDef" 
					id="newDef" 
					rows="2" cols="80"></textarea>
	<label for="newsearch_hint">New Search Hint</label>
	<textarea name="newsearch_hint" 
					id="newsearch_hint" 
					rows="2" cols="80"></textarea>
					<!---
	<input type="text" name="newDef" id="newDef" size="80">
	--->
	<label for="newDef">New More Info (URL)</label>
	<input type="text" name="newMoreInfo" id="newMoreInfo" size="80">
	<br>
	<input type="submit" value="Create New Entry"
		class="insBtn"
		onmouseover="this.className='insBtn btnhov'" 
		onmouseout="this.className='insBtn'">
</form>
</cfoutput>
</cfif>
<!----------------------------------------->
<cfif #action# is "nothing">
<cfoutput>
<script type='text/javascript' src='/ajax/core/engine.js'></script>
	<script type='text/javascript' src='/ajax/core/util.js'></script>
	<script type='text/javascript' src='/ajax/core/settings.js'></script>
<cfset title = "Enter and Edit Documentation">
<cfquery name="allCols" datasource="#Application.uam_dbo#">
	select * from documentation 
		where 1=1
		<cfif isdefined("dispNameLike") and len(#dispNameLike#) gt 0>
			AND lower(display_name) like '%#lcase(dispNameLike)#%'
		</cfif>
		<cfif isdefined("columnName") and len(#columnName#) gt 0>
			AND lower(colName) like '%#lcase(columnName)#%'
		</cfif>
	order by colname
</cfquery>
<cfif #isAuth.privs# is "all">
	<a href="enterEditDocs.cfm?action=manageAccess">Manage Access</a>
</cfif>
<br><a href="enterEditDocs.cfm?action=newDoc">New Field Definition</a>

<h4>Filter By...</h4>
<form name="filter" method="post" action="enterEditDocs.cfm">
	<label for="dispNameLike">Display Name</label>
	<input type="text" name="dispNameLike" 
		<cfif isdefined("dispNameLike") and len(#dispNameLike#) gt 0>
			value='#dispNameLike#'
		</cfif>
		id="dispNameLike" size="40" >
	<label for="columnName">Column Name</label>
	<input type="text" name="columnName" 
		<cfif isdefined("columnName") and len(#columnName#) gt 0>
			value='#columnName#'
		</cfif>
		id="columnName" size="40" >
	
	<br>
	<input type="submit" value="Filter"
		class="lnkBtn"
		onmouseover="this.className='lnkBtn btnhov'" 
		onmouseout="this.className='lnkBtn'">
	<input type="button" value="Show All"
		class="lnkBtn"
		onmouseover="this.className='lnkBtn btnhov'" 
		onmouseout="this.className='lnkBtn'"
		onclick="document.location='enterEditDocs.cfm';">
	<input type="button" value="Clear Form"
		class="qutBtn"
		onmouseover="this.className='qutBtn btnhov'" 
		onmouseout="this.className='qutBtn'"
		onclick="filter.dispNameLike.value='';filter.columnName.value='';">
</form>


<h4>Found #allCols.recordcount# columns.</h4>

<h3>
Edit Documentation:
</h3>
<form name="data" method="post" action="enterEditDocs.cfm">
	
	<table border>
	<cfset i=1>
	<cfloop query="allCols">
		<input type="hidden" name="doc_id_#doc_id#" value='#doc_id#' id="docid_#doc_id#">
		<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))# id="tr_#doc_id#">
			<td>
				<label for="colname_#doc_id#">Column Name</label>
				<input type="text" value="#colname#" name="colname_#doc_id#" id="colname_#doc_id#" size="40"
					onchange="saveColnameChange('#doc_id#',this.value);" >
				<label for="display_name_#doc_id#">Display Name</label>
				<input type="text" value="#display_name#" name="display_name_#doc_id#" id="display_name_#doc_id#"
					onchange="saveDisplayNameChange('#doc_id#',this.value);" size="80">
				<label for="definition_#doc_id#">Definition</label>
				<textarea name="definition_#doc_id#" 
					id="definition_#doc_id#" 
					rows="2" cols="80"
					onblur="saveDefinitionChange('#doc_id#',this.value);">#definition#</textarea>
				<label for="search_hint_#doc_id#">Definition</label>
				<textarea name="search_hint_#doc_id#" 
					id="search_hint_#doc_id#" 
					rows="2" cols="80"
					onblur="saveSearchHintChange('#search_hint#',this.value);">#search_hint#</textarea>
				<!---
				<input type="text" value="#definition#" name="definition_#doc_id#" id="definition_#doc_id#"
					onchange="saveDefinitionChange('#doc_id#',this.value);" size="80">
					--->
				<label for="more_info_#doc_id#">More Info At...</label>
				<input type="text" value="#more_info#" name="more_info_#doc_id#" id="more_info_#doc_id#"
					onchange="saveMoreInfoChange('#doc_id#',this.value);" size="80">
			</td>
			<td><img src="/images/del.gif" class="likeLink" onclick="deleteOne('#doc_id#')"></td>
		</tr>
		<cfset i=#i#+1>
	</cfloop>
	</table>
</form>

</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif #action# is "createNew">
<cfoutput>
	<cfif #len(tnewCN)# gt 0 AND #len(newCN)# gt 0>
		You must EITHER pick OR type a column name; not both.
		<cfabort>
	<cfelseif #len(tnewCN)# is 0 AND #len(newCN)# is 0>
		You must pick or type a column name.
		<cfabort>
	</cfif>
	<cfquery name="new" datasource="#Application.uam_dbo#">
		insert into documentation (
			colname, 
			definition,
			display_name
			<cfif len(#newMoreInfo#) gt 0>
				,more_info
			</cfif>
			<cfif len(#newsearch_hint#) gt 0>
				,search_hint
			</cfif>
		) values (
			<cfif len(#newCN#) gt 0>
				'#newCN#',
			<cfelse>
				'#tnewCN#',
			</cfif>
			'#newDef#',
			'#newDispname#'
			<cfif len(#newMoreInfo#) gt 0>
				,'#newMoreInfo#'
			</cfif>
			<cfif len(#newsearch_hint#) gt 0>
				,'#search_hint#'
			</cfif>
			)
	</cfquery>
	<cflocation addtoken="false" url="enterEditDocs.cfm">
	</cfoutput>
</cfif>
<cfinclude template="/includes/_helpFooter.cfm">