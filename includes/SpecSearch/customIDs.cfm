	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
					<span class="secLabel">Customize Identifiers</span>
					<span class="secControl" id="c_collevent"
						onclick="showHide('collevent',1)">Close</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<a href="javascript:void(0);"
					onClick="getHelp('year_collected'); return false;"
					onMouseOver="self.status='Click for Year Collected help.';return true;"
					onmouseout="self.status='';return true;">Year Collected:
				</a>
			</td>
			<td class="srch">
				<input name="begYear" type="text" size="6">&nbsp;
				<span class="infoLink" onclick="SpecData.endYear.value=SpecData.begYear.value">-->&nbsp;Copy&nbsp;--></span>
				&nbsp;<input name="endYear" type="text" size="6">
			</td>
		</tr>
	</table>