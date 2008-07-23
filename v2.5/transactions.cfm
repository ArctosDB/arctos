<cfinclude template = "/includes/_header.cfm">

<cfset title = "Transactions">
<form name="redir" method="post" action="/includes/redir.cfm">
<input type="hidden" name="startApp">
<table border>
	<tr>
		<td>Accessions</td>
		<td>
			<input type="button" 
				class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'" 
   				onmouseout="this.className='lnkBtn'"
				value="Manage" 
				onClick="redir.startApp.value='/editAccn.cfm';submit();">
			 
		</td>
		<td>
			<input type="button" 
				class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'" 
   				onmouseout="this.className='lnkBtn'"
				value="Create" 
				onClick="redir.startApp.value='/newAccn.cfm';submit();">
		</td>		
	</tr>
	<tr>
		<td>Loans</td>
		<td>
			<input type="button" 
				class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'" 
   				onmouseout="this.className='lnkBtn'"
				value="Manage" 
				onClick="redir.startApp.value='/Loan.cfm?Action=addItems';submit();">
		</td>
		<td>
			<input type="button" 
				class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'" 
   				onmouseout="this.className='lnkBtn'"
				value="Create" 
				onClick="redir.startApp.value='/Loan.cfm?Action=newLoan';submit();">
		</td>
		
	</tr>
	<tr>
		<td>Borrow</td>
		<td>
			<input type="button" 
				class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'" 
   				onmouseout="this.className='lnkBtn'"
				value="Manage" 
				onClick="redir.startApp.value='/borrow.cfm';submit();">
		</td>
		<td>
			<input type="button" 
				class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'" 
   				onmouseout="this.className='lnkBtn'"
				value="Create" 
				onClick="redir.startApp.value='/borrow.cfm?action=new';submit();">
		</td>
	</tr>
	<tr>
		<td>Permits</td>
		<td>
			<input type="button" 
				class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'" 
   				onmouseout="this.className='lnkBtn'"
				value="Manage" 
				onClick="redir.startApp.value='/Permit.cfm';submit();">
		</td>
		<td>
			<input type="button" 
				class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'" 
   				onmouseout="this.className='lnkBtn'"
				value="Create" 
				onClick="redir.startApp.value='/Permit.cfm?action=newPermit';submit();">
		</td>
	</tr>
</table>
</form>
<cfinclude template = "/includes/_footer.cfm">