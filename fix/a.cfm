<cfinclude template="/includes/_header.cfm">

<style>


	#td_search {
		height:50%;
		width:30%;
	}
	
	#td_rslt {
		height:50%;
		width:30%;
	}
	
	#td_edit {
		height:100%;
		width:30%;
	}
	#olTabl {
		height:100%;
		width:100%;
	}
	
	
	


</style>
<script>
jQuery(document).ready(function() {
	
	
	$("#olTabl").height(420);
 
});


</script>
this.innerHeight = self.innerHeight;
		this.innerWidth = self.innerWidth;


<div style="width:100%;height:100%;border:2px solid blue;">
<table border id="olTabl">
	<tr>
		<td id="td_search">
			srch
		</td>
		<td id="td_rslt" rowspan="2">
			edit 
		</td>
	</tr>
	<tr>
		<td id="td_edit" valign="top">
			results
		</td>
	</tr>
</table>

</div>