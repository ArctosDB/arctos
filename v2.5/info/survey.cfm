<cfinclude template="/includes/_header.cfm">

Arctos user survey
<form name="userInput" method="post" action="survey.cfm">
	<input type="hidden" name="action" value="saveRecord">
	<table border>
		<tr>
			<td>Why do you use Arctos?</td>
			<td><textarea name="useReason" rows="4" cols="50"></textarea></td>
		</tr>
		<tr>
			<td>How did you find Arctos?</td>
			<td><textarea name="howGotHere" rows="2" cols="50"></textarea></td>
		</tr>
		<tr>
			<td>What is your relationship with UAM?</td>
			<td><textarea name="relationship" rows="2" cols="50"></textarea></td>
		</tr>
		<tr>
			<td>Do you, or do you intend to, borrow specimens from UAM?</td>
			<td><textarea name="borrower" rows="2" cols="50"></textarea></td>
		</tr>
		<tr>
			<td>Do you find Arctos a useful tool? 
				What could be better? What currently works well?</td>
			<td><textarea name="isItGood" rows="4" cols="50"></textarea></td>
		</tr>
		<tr>
			<td>What information do you, or wish to, access through Arctos? 
			</td>
			<td><textarea name="whatTheyWant" rows="2" cols="50"></textarea></td>
		</tr>
		<tr>
			<td>Have you created an account to customize Acrtos? Why or why not?
			</td>
			<td><textarea name="isUser" rows="2" cols="50"></textarea></td>
		</tr>
		<tr>
			<td>Do you download data? For what purpose? 
			</td>
			<td><textarea name="download" rows="2" cols="50"></textarea></td>
		</tr>
		<tr>
			<td>Are the help files accessable and helpful? Why or why not?
			</td>
			<td><textarea name="help" rows="2" cols="50"></textarea></td>
		</tr>
	</table>
</form>
<cfinclude template="/includes/_footer.cfm">