<!---

	create sequence dev_task_seq;
	create public synonym dev_task_seq for dev_task_seq;
	grant select on dev_task_seq to public;
	create table dev_task (
		task_id number not null,
		submitted_date date not null,
		priority number not null,
		person_responsible varchar2(255),
		submitted_by_person varchar2(255),
		tab_form varchar2(255) not null,
		task_description varchar2(255) not null,
		task_remark varchar2(255),
		date_completed date,
		constraint dev_task_pkey primary key (task_id)
		)
		;
		alter table dev_task add admin_remark varchar2(255);
	create public synonym dev_task for dev_task;
	grant select on dev_task to public;
	grant insert,update,delete on dev_task to uam_update;
	
	CREATE OR REPLACE TRIGGER dev_task_def
	before insert ON dev_task
	for each row
	BEGIN
	if :new.task_id is null then
		select dev_task_seq.nextval into :new.task_id from dual;
	end if;
	end;
---->
<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
<p>
			<input type="butotn" 
			value="Submit New Task" 
			class="insBtn"
			onmouseover="this.className='insBtn btnhov'" 
			onmouseout="this.className='insBtn'" onClick="document.location='dev_task.cfm?action=newTask';">
			</p>
Find Tasks:
<br>
<cfoutput>
<form name="s" method="post" action="dev_task.cfm">
	<input type="hidden" name="action" value="srch">
			<label for="person_responsible">Submitted by</label>
			<input type="text" name="submitted_by_person" id="submitted_by_person">
			<input type="button" value="<--#client.username#" onclick="s.submitted_by_person.value='#client.username#';">
			<label for="task_description">Description</label>
			<input type="text" name="task_description" id="task_description">
			
			<label for="person_responsible">Claimed by</label>
			<input type="text" name="person_responsible" id="person_responsible">
			<label for="admin_remark">Admin Input</label>
			<input type="text" name="admin_remark" id="admin_remark">
			<label for="date_completed">Completed</label>
			<label for="isNotCompleted">Incomplete?</label>
			<input type="checkbox" name="isNotCompleted" id="isNotCompleted" value="1" checked="checked">
			<br>
			<input type="submit" 
			value="Search" 
			class="savBtn"
			onmouseover="this.className='savBtn btnhov'" 
			onmouseout="this.className='savBtn'">
			<input type="reset" 
			value="Clear" 
			class="clrBtn"
			onmouseover="this.className='clrBtn btnhov'" 
			onmouseout="this.className='clrBtn'">
			
</form>
</cfoutput>
</cfif>
<!---------------------------------------------------->
<cfif #action# is "srch">
	<cfset sql = "select * from dev_task where task_id > 0">
	<cfif len(#submitted_by_person#) gt 0>
		<cfset sql = "#sql# AND upper(submitted_by_person) like '%#ucase(submitted_by_person)#%'">
	</cfif>
	<cfif len(#task_description#) gt 0>
		<cfset sql = "#sql# AND upper(task_description) like '%#ucase(task_description)#%'">
	</cfif>
	<cfif len(#person_responsible#) gt 0>
		<cfset sql = "#sql# AND upper(person_responsible) like '%#ucase(person_responsible)#%'">
	</cfif>
	<cfif len(#admin_remark#) gt 0>
		<cfset sql = "#sql# AND upper(admin_remark) like '%#ucase(admin_remark)#%'">
	</cfif>
	<cfif isdefined("isNotCompleted") and len(#isNotCompleted#) gt 0>
		<cfset sql = "#sql# AND date_completed is null">
	</cfif>
	
	<cfoutput>
	#sql#
	<cfquery name="getTasks" datasource="#Application.uam_dbo#">
		#preservesinglequotes(sql)#
	</cfquery>
	
	<table border>
		<tr>
			<td><strong>Application</strong></td>
			<td><strong>Description</strong></td>
			<td><strong>Priority</strong></td>
			<td><strong>Submittor</strong></td>
			<td><strong>Remarks</strong></td>
			<td><strong>Date Submitted</strong></td>
			<td><strong>Date Completed</strong></td>
			<td><strong>Owner</strong></td>
			<td><strong>Admin Comments</strong></td>
			<td>&nbsp;</td>
		</tr>	
	<cfloop query="getTasks">
	<form name="t" method="post" action="dev_task.cfm">
		<input type="hidden" name="action" value="editTask">
		<input type="hidden" name="task_id" value="#task_id#">
		<tr>
			<td>#tab_form#</td>
			<td>#task_description#</td>
			<td>#priority#</td>
			<td>#submitted_by_person#</td>
			<td>#task_remark#</td>
			<td>#dateformat(submitted_date,'dd-mmm-yyyy')#</td>
			<td>#dateformat(date_completed,'dd-mmm-yyyy')#</td>
			<td>#person_responsible#</td>
			<td>#admin_remark#</td>
			<td>
				<input type="submit" 
					value="Edit" 
					class="insBtn"
					onmouseover="this.className='insBtn btnhov'" 
					onmouseout="this.className='insBtn'">
			</td>
		</tr>
		
	</form>
	</cfloop>
	</table>
	</cfoutput>
</cfif>
<!----------------------------------------------------------------->
<cfif #action# is "editTask">
	<cfquery name="t" datasource="#Application.uam_dbo#">
		select * from dev_task where task_id=#task_id#
	</cfquery>
	<cfoutput query="t">
		<br><strong>Submittor:</strong> #submitted_by_person#
		<br><strong>Application:</strong> #tab_form#
		<br><strong>Description:</strong> #task_description#
		<br><strong>Remarks:</strong> #task_remark#
		<br><strong>Priority:</strong> #priority#
		
		<form name="t" method="post" action="dev_task.cfm">
			<input type="hidden" name="action" value="saveEdit">
			<input type="hidden" name="task_id" value="#task_id#">
			<label for="person_responsible">Claimed by</label>
			<input type="text" name="person_responsible" id="person_responsible" value="#person_responsible#">
			<input type="button" value="<--#client.username#" onclick="t.person_responsible.value='#client.username#';">
			<label for="admin_remark">Admin Input</label>
			<textarea name="admin_remark" id="admin_remark" rows="2" cols="50">#admin_remark#</textarea>
			<label for="date_completed">Completed</label>
			<input type="text" name="date_completed" id="date_completed" value="#dateformat(date_completed,'dd-mmm-yyyy')#">
			<input type="button" value="<--now" onClick="t.date_completed.value='#dateformat(now(),'dd-mmm-yyyy')#'">
			<br>
			<input type="submit" 
			value="Save" 
			class="savBtn"
			onmouseover="this.className='savBtn btnhov'" 
			onmouseout="this.className='savBtn'">
			
			
		</form>
	</cfoutput>
</cfif>

<!----------------------------------------------------------------->
<cfif #action# is "saveEdit">
	<cfquery name="upTask" datasource="#Application.uam_dbo#">
		update dev_task set
			task_id=#task_id#
			<cfif len(#person_responsible#) gt 0>
				,person_responsible = '#person_responsible#'
			</cfif>
			<cfif len(#admin_remark#) gt 0>
				,admin_remark = '#admin_remark#'
			</cfif>
			<cfif len(#date_completed#) gt 0>
				,date_completed = '#dateformat(date_completed,"dd-mmm-yyyy")#'
			</cfif>
			where task_id=#task_id#
	</cfquery>
	<cflocation url="dev_task.cfm">
</cfif>
<!----------------------------------------------------------------->
<cfif #action# is "makeNew">
	<cfquery name="newTask" datasource="#Application.uam_dbo#">
		insert into dev_task (
			submitted_date,
			priority,
			submitted_by_person,
			tab_form,
			task_description
			<cfif len(#task_remark#) gt 0>
				,task_remark
			</cfif>
			) values (
			'#dateformat(now(),"dd-mmm-yyyy")#',
			#priority#,
			'#client.username#',
			'#tab_form#',
			'#task_description#'
			<cfif len(#task_remark#) gt 0>
				,'#task_remark#'
			</cfif>
			)
	</cfquery>
	<cflocation url="dev_task.cfm">
</cfif>
<!----------------------------------------------------------------------->
<cfif #action# is "newTask">
	<form name="nt" method="post" action="dev_task.cfm">
		<input type="hidden" name="action" value="makeNew">
		
		<label for="tab_form">Form or Application</label>
		<input type="text" name="tab_form" id="tab_form" size="70" class="reqdClr">
		
		<label for="task_description">Describe the issue</label>
		<textarea name="task_description" id="task_description" rows="2" cols="50" class="reqdClr"></textarea>
		
		<label for="task_remark">Remarks</label>
		<textarea name="task_remark" id="task_remark" rows="2" cols="50"></textarea>
		
		<label for="priority">Priority</label>
		<select name="priority" id="priority" class="reqdClr">
			<option value="0">0 (least important)</option>
			<option value="1">1 (could be better)</option>
			<option value="2">2 (needs attention sometime)</option>
			<option value="3">3 (needs attention soon)</option>
			<option value="4">4 (needs attention as soon as possible)</option>
			<option value="5">5 (data corruption possible)</option>
		</select>
		<br><input type="submit" 
			value="Submit Request" 
			class="insBtn"
			onmouseover="this.className='insBtn btnhov'" 
			onmouseout="this.className='insBtn'">
	</form>
</cfif>
<cfinclude template="/includes/_footer.cfm">


		
		