<table border="0" width="100%">
	<tr>
		<td width="70%" align="left"><br><br>
			<a href="products.cfm#p1" style="background-color:'yellow'">Purchase it</a>
			<br><br>
			Due to popular demand. The following options were implemented in DynamicPDF 1.0. All you have to do is place
			each of these options in the "Options" attribute supplied to DynamicPDF tag.<br><br>
			
			<UL>
				<LI><a href="#1">Page Break</a></LI>
				<LI><a href="#2">Adding a custom footer</a></LI>
				<LI><a href="#3">Adding a custom header</a></LI>
				<LI><a href="#4">Adding a pre-defined footer and header (automatic page numbering, date, etc.)</a></LI>
				<LI><a href="#5">Choosing a font type for header and footer</a></LI>
				<LI><a href="#6">Choosing a font size for header and footer</a></LI>
				<LI><a href="#7">Choosing a font typeface for header and footer</a></LI>
				<LI><a href="#8">Choosing how many lines (or pt, in, cm, mm) should be left before breaking to next page</a></LI>
				<LI><a href="#9">Choosing how many pages should be displayed on the output page</a></LI>
				<LI><a href="#10">Choosing the format of the displayed file (PDF 1.2, Level 2 PostScript, etc.)</a></LI>
				<LI><a href="#11">Choosing a default color for all links</a></LI>
				<LI><a href="#12">Choosing whether to allow having links in your generated file or not</a></LI>
				<LI><a href="#13">Choosing a link style (underline or not)</a></LI>
				<LI><a href="#14">Choosing browser width in pixels</a></LI>
				<LI><a href="#15">Choosing the 8-bit character set encoding</a></LI>
				<LI><a href="#16">Choosing top/bottom/right/left margins for your document</a></LI>
				<LI><a href="#17">Choosing a logo image for the HTML navigation bar and page headers and footers for PostScript and 
					PDF files</a></LI>
				<LI><a href="#18">Choosing background image for all pages in the generated document (BMP, GIF, JPEG, and PNG)</a></LI>
				<LI><a href="#19">Choosing a background color for all pages in the generated document</a></LI>
				<LI><a href="#20">Choosing a font typeface for text in all pages</a></LI>
				<LI><a href="#21">Choosing a compression level for generated documents</a></LI>
				<LI><a href="#22">Choosing to encrypt your generated documents</a></LI>
				<LI><a href="#23">Choosing a level of compression of JPEG images (quality)</a></LI>
				<LI><a href="#24">Adding an author</a></LI>
				<LI><a href="#25">Adding copyright</a></LI>
				<LI><a href="#26">Adding the document number</a></LI>
				<LI><a href="#27">Adding the name of the generator application</a></LI>
				<LI><a href="#28">Add search keywords</a></LI>
				<LI><a href="#29">Adding a subject to the document</a></LI>
				<LI><a href="#30">Setting margins for the page</a></LI>
				<LI><a href="#31">Choosing a Landscape or Portrait orientation</a></LI>
				<LI><a href="#32">Choosing a page size ("Letter", "Legal", "Universal", "A4", or custom size)</a></LI>
				<LI><a href="#33">Choosing single-sided or double-sided printing for the page</a></LI>
				<LI><a href="#34">Choosing media type attribute for the page ("Plain", "Glossy", etc.)</a></LI>
				<LI><a href="#35">Disabling compression</a></LI>
				<LI><a href="#36">Disabling duplexing</a></LI>
				<LI><a href="#37">Disabling embedding fonts</a></LI>
				<LI><a href="#38">Disabling encryption</a></LI>
				<LI><a href="#39">Disabling compression on large JPEG images</a></LI>
				<LI><a href="#40">Disabling hyperlinking</a></LI>
				<LI><a href="#41">Disabling Xerox PostScript job comments</a></LI>
				<LI><a href="#42">Setting a password on the generated file</a></LI>
				<LI><a href="#43">Choosing number of seconds that each page will be displayed in the document</a></LI>
				<LI><a href="#44">Choosing paging effects</a></LI>
				<LI><a href="#45">Choosing a page layout (single, one, towleft, tworight, etc.)</a></LI>
				<LI><a href="#46">Choosing a page mode (document, outline, fullscreen)</a></LI>
				<LI><a href="#47">Choosing paths of directories to be loaded when executing the tag</a></LI>
				<LI><a href="#48">Choosing permission level on the generated document (copy, modify, print, etc.)</a></LI>
			</UL>
			
			<table border="1">
				<tr bgcolor="#CCFFFF">
					<td>
						<strong>Syntax</strong>
					</td>
					<td>
						<strong>Description</strong>
					</td>
					<td>
						<strong>Example</strong>
					</td>
				</tr>
				<tr>
					<td><a name="1"></a>
						<strong>&lt;HR Break&gt;</strong>
					</td>
					<td>
						This is for page break! Placing text after this tag will cause the text to be written to the next page.
					</td>
					<td>
						<strong>&lt;HR Break&gt;</strong><br>
						Next Page Text Here
					</td>
				</tr>
				<tr>
					<td><a name="2"></a>
						<strong>&lt;!-- FOOTER LEFT "foo" --&gt;</strong><br>
						<strong>&lt;!-- FOOTER CENTER "foo" --&gt;</strong><br>
						<strong>&lt;!-- FOOTER RIGHT "foo" --&gt;</strong>
					</td>
					<td>
						Sets the left, center, and/or right footer text; the test is applied to the current page if empty, 
						or the next page otherwise.
					</td>
					<td>
						<strong>&lt;!-- HEADER LEFT "PDF Document Footer Text" --&gt;</strong><br>
						<strong>&lt;!-- HEADER RIGHT "Page 1" --&gt;</strong>
					</td>
				</tr>
				<tr>
					<td><a name="3"></a>
						<strong>&lt;!-- HEADER LEFT "foo" --&gt;</strong><br>
						<strong>&lt;!-- HEADER CENTER "foo" --&gt;</strong><br>
						<strong>&lt;!-- HEADER RIGHT "foo" --&gt;</strong>
					</td>
					<td>
						Sets the left, center, and/or right header text; the test is applied to the current page if empty, 
						or the next page otherwise.
					</td>
					<td>
						<strong>&lt;!-- HEADER CENTER "Gilgamesh Solutions" --&gt;</strong><br>
						<strong>&lt;!-- HEADER RIGHT "Page 1" --&gt;</strong>
					</td>
				</tr>
			
				<tr>
					<td valign="top" width="20%"><a name="4"></a>
						<strong>--footer lcr<br>--header lcr</strong>
					</td>
					<td width="50%">
						l: Left Alignment<br>
						c: Center Alignment<br>
						r: Right Alignment<br><br>
						The --footer option specifies the contents of the page footer. --header <br>option is for the header of 
						the page.
						In place of the l, c, and r, you can put one
						of these options:<br>
						<TABLE BORDER="1" CELLPADDING="5" WIDTH="80%">
						<TR><TH>lcr</TH><TH>Description</TH></TR>
						<TR><TD ALIGN="CENTER">.</TD><TD>A period indicates that the field
						 should be blank.</TD></TR>
						<TR><TD ALIGN="CENTER">:</TD><TD>A colon indicates that the field should
						 contain the current and total number of pages in the chapter (n/N).</TD>
						</TR>
						<TR><TD ALIGN="CENTER">/</TD><TD>A slash indicates that the field should
						 contain the current and total number of pages (n/N).</TD></TR>
						<TR><TD ALIGN="CENTER">1</TD><TD>The number 1 indicates that the field
						 should contain the current page number in decimal format (1, 2, 3, ...)</TD>
						</TR>
						<TR><TD ALIGN="CENTER">a</TD><TD>A lowercase &quot;a&quot; indicates that the
						 field should contain the current page number using lowercase letters.</TD>
						</TR>
						<TR><TD ALIGN="CENTER">A</TD><TD>An uppercase &quot;A&quot; indicates that the
						 field should contain the current page number using UPPERCASE letters.</TD>
						</TR>
						<TR><TD ALIGN="CENTER">c</TD><TD>A lowercase &quot;c&quot; indicates that the
						 field should contain the current chapter title.</TD></TR>
						<TR><TD ALIGN="CENTER">C</TD><TD>An uppercase &quot;C&quot; indicates that the
						 field should contain the current chapter page number.</TD></TR>
						<TR><TD ALIGN="CENTER">d</TD><TD>A lowercase &quot;d&quot; indicates that the
						 field should contain the current date.</TD></TR>
						<TR><TD ALIGN="CENTER">D</TD><TD>An uppercase &quot;D&quot; indicates that the
						 field should contain the current date and time.</TD></TR>
						<TR><TD ALIGN="CENTER">h</TD><TD>An &quot;h&quot; indicates that the field should
						 contain the current heading.</TD></TR>
						<TR><TD ALIGN="CENTER">i</TD><TD>A lowercase &quot;i&quot; indicates that the
						 field should contain the current page number in lowercase roman
						 numerals (i, ii, iii, ...)</TD></TR>
						<TR><TD ALIGN="CENTER">I</TD><TD>An uppercase &quot;I&quot; indicates that the
						 field should contain the current page number in uppercase roman
						 numerals (I, II, III, ...)</TD></TR>
						<TR><TD ALIGN="CENTER">l</TD><TD>A lowercase &quot;l&quot; indicates that the
						 field should contain the logo image.</TD></TR>
						<TR><TD ALIGN="CENTER">t</TD><TD>A lowercase &quot;t&quot; indicates that the
						 field should contain the document title.</TD></TR>
						<TR><TD ALIGN="CENTER">T</TD><TD>An uppercase &quot;T&quot; indicates that the
						 field should contain the current time.</TD></TR>
						</TABLE><br>			
						Setting the footer to "..." disables the footer entirely.
					</td>
					<td valign="top" width="30%">
						<strong>--footer DIt</strong><br><br>
						This will produce a footer with current date and time on the left, <br>current page number in uppercase roman
						numerals in the center, and the<br> document's title on the right side.
					</td>
				</tr>
				<tr>
					<td><a name="5"></a>
						<strong>--headfootfont font</strong>
					</td>
					<td>
						The --headfootfont option specifies the font that is used for the header and footer text. The font parameter 
						can be one of the following: <br><br>
						* Courier <br>
						* Courier-Bold<br> 
						* Courier-Oblique <br>
						* Courier-BoldOblique <br>
						* Times <br>
						* Times-Roman<br> 
						* Times-Bold <br>
						* Times-Italic <br>
						* Times-BoldItalic <br>
						* Helvetica <br>
						* Helvetica-Bold<br> 
						* Helvetica-Oblique <br>
						* Helvetica-BoldOblique <br><br>
						This option is only available when generating PostScript or PDF files.
					</td>
					<td>
						<strong>--headfootfont "Courier"</strong>
					</td>
				</tr>
				<tr>
					<td><a name="6"></a>
						<strong>--headfootsize size</strong>
					</td>
					<td>
						The --headfootsize option sets the size of the header and footer text in points (1 point = 1/72nd inch). 
						This option is only available when generating PostScript or PDF files.
					</td>
					<td>
						<strong>--headfootsize 1</strong>
					</td>
				</tr>
				<tr>
					<td><a name="7"></a>
						<strong>--headingfont typeface</strong>
					</td>
					<td>
						The --headingfont options sets the typeface that is used for headings in the document. The typeface 
						parameter can be one of the following:<br><br>
						<strong>typeface&nbsp;&nbsp;&nbsp;&nbsp;Actual Font</strong><br>
						Arial:&nbsp;&nbsp;&nbsp;&nbsp;	Helvetica<br>
						Courier:&nbsp;&nbsp;&nbsp;&nbsp;	Courier<br>
						Helvetica:&nbsp;&nbsp;&nbsp;&nbsp;	Helvetica<br>
						Monospace:&nbsp;&nbsp;&nbsp;&nbsp;	Courier<br>
						Sans-Serif:&nbsp;&nbsp;&nbsp;&nbsp;	Helvetica<br>
						Serif:&nbsp;&nbsp;&nbsp;&nbsp;	Times<br>
						Symbol:&nbsp;&nbsp;&nbsp;&nbsp;	Symbol<br>
						Times:&nbsp;&nbsp;&nbsp;&nbsp;	Times
					</td>
					<td>
						<strong>--headingfont "Symbol"</strong>
					</td>
				</tr>
				<tr>
					<td><a name="8"></a>
						<strong>&lt;!-- NEED length --&gt;</strong>
					</td>
					<td>
						Break if there is less than length units left on the current page. The length value defaults to lines of 
						text but can be suffixed by in, mm, or cm to convert from the corresponding units.
					</td>
					<td>
						<strong>&lt;!-- NEED 3 --&gt;</strong><br>
						If there are 3 lines left on the page, break to the next page.
					</td>
				</tr>
				<tr>
					<td><a name="9"></a>
						<strong>&lt;!-- NUMBER-UP nn --&gt;</strong>
					</td>
					<td>
						Sets the number of pages that are placed on each output page. Valid values are 1, 2, 4, 6, 9, and 16.
					</td>
					<td>
						<strong>&lt;!-- NUMBER-UP 4 --&gt;</strong>
					</td>
				</tr>
				<tr>
					<td><a name="10"></a>
						<strong>-t format</strong>
					</td>
					<td>
						<strong>Format&nbsp;&nbsp;&nbsp;&nbsp;Description</strong><br>
						html:&nbsp;&nbsp;&nbsp;&nbsp;	Generate one or more indexed HTML files.<br>
						pdf:&nbsp;&nbsp;&nbsp;&nbsp;	Generate a PDF file (default version - 1.3).<br>
						pdf11:&nbsp;&nbsp;&nbsp;&nbsp;	Generate a PDF 1.1 file for Acrobat Reader 2.0.<br>
						pdf12:&nbsp;&nbsp;&nbsp;&nbsp;	Generate a PDF 1.2 file for Acrobat Reader 3.0.<br>
						pdf13:&nbsp;&nbsp;&nbsp;&nbsp;	Generate a PDF 1.3 file for Acrobat Reader 4.0.<br>
						pdf14:&nbsp;&nbsp;&nbsp;&nbsp;	Generate a PDF 1.4 file for Acrobat Reader 5.0.<br>
						ps:&nbsp;&nbsp;&nbsp;&nbsp;	Generate one or more PostScript files (default level).<br>
						ps1:&nbsp;&nbsp;&nbsp;&nbsp;	Generate one or more Level 1 PostScript files.<br>
						ps2:&nbsp;&nbsp;&nbsp;&nbsp;	Generate one or more Level 2 PostScript files.<br>
						ps3:&nbsp;&nbsp;&nbsp;&nbsp;	Generate one or more Level 3 PostScript files.
					</td>
					<td>
						<strong>-t pdf14</strong>
					</td>
				</tr>
				<tr>
					<td><a name="11"></a>
						<strong>--linkcolor color</strong>
					</td>
					<td>
						The --linkcolor option specifies the color of links in HTML and PDF output. The color can be specified by 
						name or as a 6-digit hexadecimal number of the form #RRGGBB.
					</td>
					<td>
						<strong>--linkcolor "#ffff00"</strong>
					</td>
				</tr>
				<tr>
					<td><a name="12"></a>
						<strong>--links</strong>
					</td>
					<td>
						The --links option specifies that PDF output should contain hyperlinks.
					</td>
					<td>
						<strong>--links</strong>
					</td>
				</tr>
				<tr>
					<td><a name="13"></a>
						<strong>--linkstyle style</strong>
					</td>
					<td>
						The --linkstyle option specifies the style of links in HTML and PDF output. The style can be "plain" for 
						no decoration or "underline" to underline links.
					</td>
					<td>
						<strong>--linkstyle "plain"</strong>
					</td>
				</tr>
				<tr>
					<td><a name="14"></a>
						<strong>--browserwidth pixels</strong>
					</td>
					<td>
						The --browserwidth option specifies the browser width in pixels. The browser width is used to scale images 
						and pixel measurements when generating PostScript and PDF files. It does not affect the font size of text.
						The default browser width is 680 pixels which corresponds roughly to a 96 DPI display. Please note that 
						your images and table sizes are equal to or smaller than the browser width, or your output will overlap 
						or truncate in places. 
					</td>
					<td>
						<strong>--browserwidth 800</strong>
					</td>
				</tr>
				<tr>
					<td><a name="15"></a>
						<strong>--charset charset</strong>
					</td>
					<td>
						The --charset option specifies the 8-bit character set encoding to use for the entire document. HTMLDOC 
						comes with the following character set files:<br><br>
						<strong>charset&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Character Set</strong><br>
						cp-874&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Windows code page 874<br>
						cp-1250&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Windows code page 1250<br>
						cp-1251&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Windows code page 1251<br>
						cp-1252&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Windows code page 1252<br>
						cp-1253&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Windows code page 1253<br>
						cp-1254&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Windows code page 1254<br>
						cp-1255&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Windows code page 1255<br>
						cp-1256&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Windows code page 1256<br>
						cp-1257&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Windows code page 1257<br>
						cp-1258&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Windows code page 1258<br>
						iso-8859-1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	ISO-8859-1<br>
						iso-8859-2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	ISO-8859-2<br>
						iso-8859-3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	ISO-8859-3<br>
						iso-8859-4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	ISO-8859-4<br>
						iso-8859-5&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	ISO-8859-5<br>
						iso-8859-6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	ISO-8859-6<br>
						iso-8859-7&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	ISO-8859-7<br>
						iso-8859-8&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	ISO-8859-8<br>
						iso-8859-9&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	ISO-8859-9<br>
						iso-8859-14&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	ISO-8859-14<br>
						iso-8859-15&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	ISO-8859-15<br>
						koi8-r&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	KOI8-R
					</td>
					<td>
						<strong>--charset "iso-8859-4"</strong>
					</td>
				</tr>
				<tr>
					<td><a name="16"></a>
						<strong>--bottom margin</strong><br>
						<strong>--top margin</strong><br>
						<strong>--right margin</strong><br>
						<strong>--left margin</strong><br>
					</td>
					<td>
						The --bottom/--top/--right/--left option specifies the bottom/top/right/left margin. The default units 
						are points (1 point = 1/72nd inch); the suffixes "in", "cm", and "mm" specify inches, centimeters, 
						and millimeters, respectively. This option is only available when generating PostScript or PDF files.
					</td>
					<td>
						<strong>--bottom 1</strong>
					</td>
				</tr>
				<tr>
					<td><a name="17"></a>
						<strong>--logoimage filename</strong>
					</td>
					<td>
						The --logoimage option specifies the logo image for the HTML navigation bar and page headers and footers 
						for PostScript and PDF files. The supported formats are BMP, GIF, JPEG, and PNG.
					</td>
					<td>
						<strong>--logoimage "logo.jpg"</strong>
					</td>
				</tr>
				<tr>
					<td><a name="18"></a>
						<strong>--bodyimage filename</strong>
					</td>
					<td>
						The --bodyimage option specifies the background image for all pages in the document. The supported formats 
						are BMP, GIF, JPEG, and PNG.
					</td>
					<td>
						<strong>--bodyimage "bg.gif"</strong>
					</td>
				</tr>
				<tr>
					<td><a name="19"></a>
						<strong>--bodycolor color</strong>
					</td>
					<td>
						The --bodycolor option specifies the background color for all pages in the document. The color can be 
						specified by a standard HTML color name or as a 6-digit hexadecimal number of the form #RRGGBB.
					</td>
					<td>
						<strong>--bodycolor "lightblue"</strong>
					</td>
				</tr>
				<tr>
					<td><a name="20"></a>
						<strong>--bodyfont typeface</strong>
					</td>
					<td>
						The --bodyfont option specifies the default text font used for text in the document body. The typeface 
						parameter can be one of the following:<br><br>
						<strong>typeface&nbsp;&nbsp;&nbsp;&nbsp;Actual Font</strong><br>
						Arial:&nbsp;&nbsp;&nbsp;&nbsp;	Helvetica<br>
						Courier:&nbsp;&nbsp;&nbsp;&nbsp;	Courier<br>
						Helvetica:&nbsp;&nbsp;&nbsp;&nbsp;	Helvetica<br>
						Monospace:&nbsp;&nbsp;&nbsp;&nbsp;	Courier<br>
						Sans-Serif:&nbsp;&nbsp;&nbsp;&nbsp;	Helvetica<br>
						Serif:&nbsp;&nbsp;&nbsp;&nbsp;	Times<br>
						Symbol:&nbsp;&nbsp;&nbsp;&nbsp;	Symbol<br>
						Times:&nbsp;&nbsp;&nbsp;&nbsp;	Times<br>
					</td>
					<td>
						<strong>--bodyfont "Arial"</strong>
					</td>
				</tr>
				<tr>
					<td><a name="21"></a>
						<strong>--compression[=level]</strong>
					</td>
					<td>
						The --compression option specifies that Flate compression should be performed on the output file(s). 
						The optional level parameter is a number from 1 (fastest and least amount of compression) to 9 
						(slowest and most amount of compression). This option is only available when generating Level 3 PostScript 
						or PDF files.
					</td>
					<td>
						<strong>--compression 2</strong>
					</td>
				</tr>
				<tr>
					<td><a name="22"></a>
						<strong>--encryption</strong>
					</td>
					<td>
						The --encryption option enables encryption and security features for PDF output. This option is only 
						available when generating PDF files.
					</td>
					<td>
						<strong>--encryption</strong>
					</td>
				</tr>
				<tr>
					<td><a name="23"></a>
						<strong>--jpeg[=quality]</strong>
					</td>
					<td>
						The --jpeg option enables JPEG compression of continuous-tone images. The optional quality parameter 
						specifies the output quality from 0 (worst) to 100 (best). This option is only available when generating 
						Level 2 and Level 3 PostScript or PDF files.
					</td>
					<td>
						<strong>--jpeg 50</strong>
					</td>
				</tr>
				<tr>
					<td><a name="24"></a>
						<strong>&lt;META NAME="AUTHOR" CONTENT="..." &gt;</strong>
					</td>
					<td>
						Specifies the document author.
					</td>
					<td>
						<strong>&lt;META NAME="AUTHOR" CONTENT="Gilgamesh Solutions" &gt;</strong>
					</td>
				</tr>
				<tr>
					<td><a name="25"></a>
						<strong>&lt;META NAME="COPYRIGHT" CONTENT="..."&gt;</strong>
					</td>
					<td>
						Specifies the document copyright.
					</td>
					<td>
						<strong>&lt;META NAME="COPYRIGHT" CONTENT="2003 &copy; Gilgamesh Solutions"&gt;</strong>
					</td>
				</tr>
				<tr>
					<td><a name="26"></a>
						<strong>&lt;META NAME="DOCNUMBER" CONTENT="..." &gt;</strong>
					</td>
					<td>
						Specifies the document number.
					</td>
					<td>
						<strong>&lt;META NAME="DOCNUMBER" CONTENT="3A" &gt;</strong>
					</td>
				</tr>
				<tr>
					<td><a name="27"></a>
						<strong>&lt;META NAME="GENERATOR" CONTENT="..." &gt;</strong>
					</td>
					<td>
						Specifies the application that generated the HTML file.
					</td>
					<td>
						<strong>&lt;META NAME="GENERATOR" CONTENT="ColdFusion MX" &gt;</strong>
					</td>
				</tr>
				<tr>
					<td><a name="28"></a>
						<strong>&lt;META NAME="KEYWORDS" CONTENT="..." &gt;</strong>
					</td>
					<td>
						Specifies document search keywords.
					</td>
					<td>
						<strong>&lt;META NAME="KEYWORDS" CONTENT="Gilgamesh, Solutions, DynamicPDF 1.0" &gt;</strong>
					</td>
				</tr>
				<tr>
					<td><a name="29"></a>
						<strong>&lt;META NAME="SUBJECT" CONTENT="..." &gt;</strong>
					</td>
					<td>
						Specifies document subject.
					</td>
					<td>
						<strong>&lt;META NAME="SUBJECT" CONTENT="DynamicPDF 1.0" &gt;</strong>
					</td>
				</tr>
				<tr>
					<td><a name="30"></a>
						<strong>&lt;!-- MEDIA BOTTOM nnn --&gt;</strong><br>
						<strong>&lt;!-- MEDIA LEFT nnn --&gt;</strong><br>
						<strong>&lt;!-- MEDIA RIGHT nnn --&gt;</strong><br>
						<strong>&lt;!-- MEDIA TOP nnn --&gt;</strong>
					</td>
					<td>
						Sets the left/right/top/bottom margin of the page. The "nnn" string can be any standard measurement value, 
						e.g. 0.5in, 36, 12mm, etc. Breaks to a new page if the current page is already marked.
					</td>
					<td>
						<strong>&lt;!-- MEDIA TOP 1.5in --&gt;</strong>
					</td>
				</tr>
				<tr>
					<td><a name="31"></a>
						<strong>&lt;!-- MEDIA LANDSCAPE [NO|Yes] --&gt;</strong>
					</td>
					<td>
						If "Yes", choose Landscape orientation for the page; If "No", choose Portrait.
						breaks to a new page if the current page is already marked.
					</td>
					<td>
						<strong>&lt;!-- MEDIA LANDSCAPE Yes --&gt;</strong>
					</td>
				</tr>
				<tr>
					<td><a name="32"></a>
						<strong>&lt;!-- MEDIA SIZE foo --&gt;</strong>
					</td>
					<td>
						Sets the media size to the specified size. The "foo" string can be "Letter", "Legal", "Universal", or "A4" 
						for standard sizes or "WIDTH x HEIGHT units" for custom sizes, e.g. "8.5x11in"; breaks to a new page or sheet 
						if the current page is already marked.
					</td>
					<td>
						<strong>&lt;!-- MEDIA SIZE "8.5x11in" --&gt;</strong>
					</td>
				</tr>
				<tr>
					<td><a name="33"></a>
						<strong>&lt;!-- MEDIA DUPLEX [NO|YES] --&gt;</strong>
						
					</td>
					<td>
						Chooses single-sided or double-sided printing for the page; breaks to a new page or sheet if the current 
						page is already marked.
					</td>
					<td>
						<strong>&lt;!-- MEDIA DUPLEX YES --&gt;</strong>
					</td>
				</tr>
				<tr>
					<td><a name="34"></a>
						<strong>&lt;!-- MEDIA TYPE "foo" --&gt;</strong>
					</td>
					<td>
						Sets the media type attribute for the page. The "foo" string is any type name that is supported by the 
						printer, e.g. "Plain", "Glossy", etc. Breaks to a new page or sheet if the current page is already marked.
					</td>
					<td>
						<strong>&lt;!-- MEDIA TYPE "Plain" --&gt;</strong>
					</td>
				</tr>
				<tr>
					<td><a name="35"></a>
						<strong>--no-compression</strong>
					</td>
					<td>
						The --no-compression option specifies that Flate compression should not be performed on the output files.
					</td>
					<td>
						<strong>--no-compression</strong>
					</td>
				</tr>
				<tr>
					<td><a name="36"></a>
						<strong>--no-duplex</strong>
					</td>
					<td>
						The --no-duplex option specifies that the output should be formatted for one sided printing. This option is 
						only available when generating PostScript or PDF files. Use the --pscommands option to generate 
						PostScript duplex mode commands.
					</td>
					<td>
						<strong>--no-duplex</strong>
					</td>
				</tr>
				<tr>
					<td><a name="37"></a>
						<strong>--no-embedfonts</strong>
					</td>
					<td>
						The --no-embedfonts option specifies that fonts should not be embedded in PostScript and PDF output.
					</td>
					<td>
						<strong>--no-embedfonts</strong>
					</td>
				</tr>
				<tr>
					<td><a name="38"></a>
						<strong>--no-encryption</strong>
					</td>
					<td>
						The --no-encryption option specifies that no encryption/security features should be enabled in PDF 
						output. This option is only available when generating PDF files.
					</td>
					<td>
						<strong>--no-encryption</strong>
					</td>
				</tr>
				<tr>
					<td><a name="39"></a>
						<strong>--no-jpeg</strong>
					</td>
					<td>
						The --no-jpeg option specifies that JPEG compression should not be performed on large images.
					</td>
					<td>
						<strong>--no-jpeg</strong>
					</td>
				</tr>
				<tr>
					<td><a name="40"></a>
						<strong>--no-links</strong>
					</td>
					<td>
						The --no-links option specifies that PDF output should not contain hyperlinks.
					</td>
					<td>
						<strong>--no-links</strong>
					</td>
				</tr>
				<tr>
					<td><a name="41"></a>
						<strong>--no-xrxcomments</strong>
					</td>
					<td>
						The --no-xrxcomments option specifies that Xerox PostScript job comments should not be written to the 
						output files. This option is only available when generating PostScript files.
					</td>
					<td>
						<strong>--no-xrxcomments</strong>
					</td>
				</tr>
				<tr>
					<td><a name="42"></a>
						<strong>--owner-password password</strong>
					</td>
					<td>
						The --owner-password option specifies the owner password for a PDF file. If not specified or the empty 
						string (""), a random password is generated. This option is only available when generating PDF files.
					</td>
					<td>
						<strong>--owner-password "mypassword"</strong>
					</td>
				</tr>
				<tr>
					<td><a name="43"></a>
						<strong>--pageduration seconds</strong>
					</td>
					<td>
						The --pageduration option specifies the number of seconds that each page will be displayed in the 
						document. This option is only available when generating PDF files.
					</td>
					<td>
						<strong>--pageduration 2</strong>
					</td>
				</tr>
				<tr>
					<td><a name="44"></a>
						<strong>--pageeffect effect</strong>
					</td>
					<td>
						The --pageeffect option specifies the page effect to use in PDF files. The effect parameter can be one of 
						the following:<br><br>
						<strong>effect&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Description</strong><br>
						none&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	No effect is generated.<br>
						bi&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Box Inward<br>
						bo&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Box Outward<br>
						d&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Dissolve<br>
						gd&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Glitter Down<br>
						gdr	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Glitter Down and Right<br>
						gr&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Glitter Right<br>
						hb&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Horizontal Blinds<br>
						hsi	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Horizontal Sweet Inward<br>
						hso&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Horizontal Sweep Outward<br>
						vb&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Vertical Blinds<br>
						vsi&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Vertical Sweep Inward<br>
						vso&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Vertical Sweep Outward<br>
						wd&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Wipe Down<br>
						wl&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Wipe Left<br>
						wr&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Wipe Right<br>
						wu&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Wipe Up<br>
						This option is only available when generating PDF files.
					</td>
					<td>
						<strong>--pageeffect "wr"</strong>
					</td>
				</tr>
				<tr>
					<td><a name="45"></a>
						<strong>--pagelayout layout</strong>
					</td>
					<td>
						The --pagelayout option specifies the initial page layout in the PDF viewer.The layout parameter can be one 
						of the following:<br><br>
						<strong>layout&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Description</strong><br>
						single&nbsp;&nbsp;&nbsp;	A single page is displayed.<br>
						one&nbsp;&nbsp;&nbsp;	A single column is displayed.<br>
						twoleft&nbsp;&nbsp;&nbsp;	Two columns are displayed with the first page on the left.<br>
						tworight&nbsp;&nbsp;&nbsp;	Two columns are displayed with the first page on the right.<br>
						This option is only available when generating PDF files.
					</td>
					<td>
						<strong>--pagelayout "tworight"</strong>
					</td>
				</tr>
				<tr>
					<td><a name="46"></a>
						<strong>--pagemode mode</strong>
					</td>
					<td>
						The --pagemode option specifies the initial viewing mode in the PDF viewer. The mode parameter can be one 
						of the following:<br><br>
						<strong>mode&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Description</strong><br>
						document&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	The document pages are displayed in a normal window.<br>
						outline&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	The document outline and pages are displayed.<br>
						fullscreen&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	The document pages are displayed on the entire screen in
						"slideshow" mode.<br>
						This option is only available when generating PDF files.
					</td>
					<td>
						<strong>--pagemode "document"</strong>
					</td>
				</tr>
				<tr>
					<td><a name="47"></a>
						<strong>--path dir1;dir2;dir3;...;dirN</strong>
					</td>
					<td>
						The --path option specifies a search path for files that are loaded by HTMLDOC. It is usually used to get
						images that use absolute server paths to load. Directories are separated by the semicolon (;) so that 
						drive letters and URLs can be specified. Quotes around the directory parameter are optional. They are
						usually used when the directory string contains spaces.
					</td>
					<td>
						<strong>--path "C:/;D:/MyDir"</strong>
					</td>
				</tr>
				<tr>
					<td><a name="48"></a>
						<strong>--permissions permission</strong>
					</td>
					<td>
						The --permissions option specifies the document permissions. The available permission parameters are 
						listed below:<br><br>
						<strong>Permission&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	Description</strong><br>
						all&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	All permissions<br>
						annotate&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	User can annotate document<br>
						copy&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	User can copy text and images from document<br>
						modify&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	User can modify document<br>
						print&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	User can print document<br>
						no-annotate&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	User cannot annotate document<br>
						no-copy&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	User cannot copy text and images from document<br>
						no-modify&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	User cannot modify document<br>
						no-print&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	User cannot print document<br>
						none&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	No permissions<br><br>
						The --encryption option must be used in conjunction with the --permissions parameter. <br>
						--permissions no-print --encryption <br><br>
						Multiple options can be specified with multiple --permissions entries as needed.<br>
						--permissions no-print --permissions no-copy --encryption<br><br>
						This option is only available when generating PDF files.
					</td>
					<td>
						<strong>--permissions no-print --permissions no-copy --encryption</strong>
					</td>
				</tr>
			</table><br>
		</td>
	</tr>
</table>			