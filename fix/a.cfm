

<style>


	#td_search {
		height:100%;
		width:30%;
	}
	
	#td_rslt {
		height:100%;
		width:30%;
	}
	
	#td_edit {
		height:100%;
		width:30%;
	}
	#olTabl {
		display:inline-block;
		border:1px solid red;
		height:100%;
		width:100%;
	}
</style>



<table border id="olTabl">
	<tr>
		<td id="td_search">
		srch
		<!----
			<iframe src="/AgentSearch.cfm" id="_search" name="_search"></iframe>
			<br>
			<iframe src="/AgentGrid.cfm" name="_pick" id="_pick" width="100%" height="200"></iframe>
			---->
		</td>
		<td id="td_rslt" rowspan="2">
			edit 
		</td>
		
	</tr>
		<tr>
		<td id="td_edit" valign="top">
		results
		
		<!----
			<iframe src="/editAllAgent.cfm?agent_id=#agent_id#" name="_person" id="_person" width="100%" height="600"></iframe>
			---->
		</td>
		</tr>
</table>