<cfhtmlhead text="<title>magic taxonomy thingy</title>">
<FRAMESET rows="5%, 95%">
	<FRAME src="sqlTaxonomy_head.cfm">

  <FRAMESET cols="50%, 50%">
      <FRAME src="sqlTaxonomy_browse.cfm" name="_browse">
      <FRAME src="sqlTaxonomy_update.cfm" name="_update">
  </FRAMESET>
  
  <NOFRAMES>
      You must enable frames.
  </NOFRAMES>
</FRAMESET>