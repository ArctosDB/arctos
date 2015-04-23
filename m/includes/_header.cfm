<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<head>
	<cfinclude template="/includes/alwaysInclude.cfm">
	<cfif not isdefined("session.header_color")>
		<cfset setDbUser()>
	</cfif>
	<script language="javascript" type="text/javascript">
		jQuery(document).ready(function(){
	        jQuery("ul.sf-menu").supersubs({
	            minWidth:    12,
	            maxWidth:    27,
	            extraWidth:  1
	        }).superfish({
	            delay:       600,
	            animation:   {opacity:'show',height:'show'},
	            speed:       0,
	        });
	        if (top.location!=document.location) {
				$("#header_color").hide();
				$("#_footerTable").hide();
			}
	    });
	</script>
	<style>
		.collectionCell {vertical-align:text-bottom;padding:0px 0px 7px 0px;}
		.headerImageCell {padding:.3em 1em .3em .3em;text-align:right;}
	</style>
	<cfoutput>
		<meta name="keywords" content="#session.meta_keywords#">
    	<LINK REL="SHORTCUT ICON" HREF="/images/favicon.ico?v=5">
    	<meta http-equiv="content-type" content="text/html; charset=utf-8">
	<meta name=viewport content="width=device-width, initial-scale=1">
   		<cfif len(trim(session.stylesheet)) gt 0>
			<cfset ssName = replace(session.stylesheet,".css","","all")>
    		<link rel="alternate stylesheet" type="text/css" href="/includes/css/#trim(session.stylesheet)#" title="#trim(ssName)#">
			<META http-equiv="Default-Style" content="#trim(ssName)#">
		</cfif>
		</head>
		<body>
		<noscript>
			<div class="browserCheck">
				JavaScript is turned off in your web browser. Please turn it on to take full advantage of Arctos, or
				try our <a target="_top" href="/SpecimenSearchHTML.cfm">HTML SpecimenSearch</a> option.
			</div>
		</noscript>
		<cfif cgi.HTTP_USER_AGENT does not contain "Firefox">
			<div class="browserCheck">
				Some features of this site may not work in your browser. <a href="/home.cfm##requirements">Learn more</a>
			</div>
		</cfif>
		<div id="header_color" style='background-color:#session.header_color#;'>
			<table width="95%" cellpadding="0" cellspacing="0" border="0" id="headerContent">
				<tr>
					<td width="95" nowrap="nowrap" class="headerImageCell" id="headerImageCell">
						<a target="_top" href="#session.collection_url#"><img src="#session.header_image#" alt="Arctos" border="0"></a>
					</td>
					<td align="left" valign="bottom" cellpadding="0" cellspacing="0">
						<table cellpadding="0" cellspacing="0">
							<tr>
								<td align="left" valign="bottom" nowrap="nowrap" id="collectionCell" class="collectionCell">
									<cfif len(session.collection_link_text) gt 0>
										<a target="_top" href="#session.collection_url#" class="novisit">
											<span class="headerCollectionText">
													#session.collection_link_text#
											</span>
										</a>
										<br>
									</cfif>
									<a target="_top" href="#session.institution_url#" class="novisit">
										<span class="headerInstitutionText">
											#session.institution_link_text#
										</span>
									</a>
								</td>
							</tr>
							<cfif len(session.header_credit) gt 0>
								<tr>
									<td colspan="2" id="creditCell">
										<span  class="hdrCredit">
											#session.header_credit#
										</span>
									</td>
								</tr>
							</cfif>
						</table>
					</td>
				</tr>
			</table>
			<div id="headerLinks" style="float:right;position:absolute;top:5px;right:5px;clear:both;">
		    	<cfif len(session.username) gt 0>
					<a target="_top" href="/login.cfm?action=signOut">Log out #session.username#</a>
					<cfif isdefined("session.last_login") and len(session.last_login) gt 0>
						<span style="font-size:smaller">(Last login: #dateformat(session.last_login, "yyyy-mm-dd")#)</span>&nbsp;
					</cfif>
					<cfif isdefined("session.needEmailAddr") and session.needEmailAddr is 1>
						<br>
						<span style="color:red;font-size:smaller;">
							You have no email address in your profile. Please correct.
						</span>
					</cfif>
				<cfelse>
					<cfif isdefined("ref")><!--- passed in by Application.cfc before termination --->
						<cfset gtp=ref>
					<cfelse>
						<cfset gtp="/" & request.rdurl>
					</cfif>
					<!--- run this twice to get /// --->
					<cfset gtp=replace(gtp,"//","/","all")>
					<cfset gtp=replace(gtp,"//","/","all")>
					<form name="logIn" method="post" action="/login.cfm">
						<input type="hidden" name="action" value="signIn">
						<input type="hidden" name="gotopage" value="#gtp#">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td>
									<input type="text" name="username" title="Username" value="Username" size="12"
										class="loginTxt" onfocus="if(this.value==this.title){this.value=''};">
								</td>
								<td>
									<input type="password" name="password" title="Password"  size="12" class="loginTxt">
								</td>
							</tr>
							<tr>
								<td colspan="2" align="center">
									<div class="loginTxt" style="padding-top:3px;">
										<input type="submit" value="Log In" class="smallBtn">
										or
										<input type="button" value="Create Account" class="smallBtn"
											onClick="logIn.action.value='newUser';submit();">
									</div>
						    	</td>
							</tr>
						</table>
					</form>
				</cfif>
			</div>
			<div class="sf-mainMenuWrapper">
				<ul class="sf-menu">
					<li>
						<a target="_top" href="SpecimenSearch.cfm">Specimen</a>
					</li>
					<li>
                        <a target="_top" href="taxonomy.cfm">Taxonomy</a>
                    </li>
					<li>
						 <a target="_top" id="desktoplink" href="/m/desktop.cfm">Desktop Site</a>
					</li>
				</ul>
			</div>
		</div><!--- end header div --->
		<cf_rolecheck>
	</cfoutput>
<br><br>