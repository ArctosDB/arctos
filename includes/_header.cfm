<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> 
<head>
	<cfinclude template="/includes/alwaysInclude.cfm">
	<cfif not isdefined("session.header_color")>
		<cfset setDbUser()>
	</cfif>
	<script language="javascript" type="text/javascript">
		jQuery(document).ready(function(){ 
	        $("ul.sf-menu").supersubs({ 
	            minWidth:    12,
	            maxWidth:    27,
	            extraWidth:  1
	        }).superfish({ 
	            delay:       600,
	            animation:   {opacity:'show',height:'show'},
	            speed:       'fast',
	        });
	    });
	</script>
	<cfoutput>
		<meta name="keywords" content="#session.meta_keywords#">
    	<LINK REL="SHORTCUT ICON" HREF="/images/favicon.ico">
    	<meta http-equiv="content-type" content="text/html; charset=utf-8">
   		<cfif len(trim(session.stylesheet)) gt 0>
			<cfset ssName = replace(session.stylesheet,".css","","all")>
    		<link rel="alternate stylesheet" type="text/css" href="/includes/css/#trim(session.stylesheet)#" title="#trim(ssName)#">
			<META http-equiv="Default-Style" content="#trim(ssName)#">
		</cfif>
		</head>
		<body>
		<noscript>
			<div class="browserCheck">
				JavaScript is turned off in your web browser. Please turn it on to take full advantage of Arctos.
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
					<td align="left">
						<table>
							<tr>
								<td align="left" nowrap="nowrap" id="collectionCell" class="collectionCell">
									<a target="_top" href="#session.collection_url#" class="novisit">
										<span class="headerCollectionText">
												#session.collection_link_text#
										</span>
									</a>
									<br>
									<a target="_top" href="#session.institution_url#" class="novisit">
										<span class="headerInstitutionText">
											#session.institution_link_text#
										</span>
									</a>
								</td>
							</tr>	
							<tr>
								<td colspan="2" id="creditCell">
									<span  class="hdrCredit">
										#session.header_credit#
									</span>
								</td>
							</tr>		 
						</table>
					</td>
				</tr>
			</table>	
			<div style="float:right;position:absolute;top:5px;right:5px;clear:both;">
		    	<cfif len(#session.username#) gt 0>
					<a target="_top" href="##" onClick="getDocs('index')">Help</a> ~ 
					<a target="_top" href="/login.cfm?action=signOut">Log out #session.username#</a>
					<cfif isdefined("session.last_login") and len(#session.last_login#) gt 0>
						<span style="font-size:smaller">(Last login: #dateformat(session.last_login, "mmm d yyyy")#)</span>&nbsp;
					</cfif>
					<cfif isdefined("session.needEmailAddr") and session.needEmailAddr is 1>
						<br>
						<span style="color:red;font-size:smaller;">
							You have no email address in your profile. Please correct.
						</span>
					</cfif>
				<cfelse>
					<cfif isdefined("cgi.REDIRECT_URL") and len(cgi.REDIRECT_URL) gt 0>
						<cfset gtp=cgi.REDIRECT_URL>
					<cfelse>
						<cfset gtp=cgi.SCRIPT_NAME>
					</cfif>
					<form name="logIn" method="post" action="/login.cfm">
						<input type="hidden" name="action" value="signIn">
						<input type="hidden" name="gotopage" value="#gtp#">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td rowspan="2" valign="top">
									<a target="_top" href="##" onClick="getDocs('index')">Help</a> ~&nbsp;
								</td>
								<td>
									<input type="text" name="username" title="Username" value="Username" size="12" 
										class="loginTxt" onfocus="if(this.value==this.title){this.value=''};">
								</td>
								<td>
									<input type="password" name="password"title="Password"  size="12" class="loginTxt">
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
			<!---
			<div style="border:2px solid red; text-align:center;margin:2px;padding:2px;background-color:white;font-weight:bold;">
				We're upgrading! Things may be a little goofy until Monday, February 16.
			</div>
			--->
			<cfinclude template="/includes/mainMenu.cfm">
		</div>
		<cf_rolecheck>
	</cfoutput>
<br><br>