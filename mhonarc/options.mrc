<!-- MHonArc configuration. View -->
<!-- http://www.mhonarc.org/release/MHonArc/2.6.7/doc/resources -->
<!-- for more information -->

<!-- use utf-8 -->
<TEXTENCODE>
utf-8; MHonArc::UTF8::to_utf8; MHonArc/UTF8.pm
</TEXTENCODE>

<CHARSETCONVERTERS override>
default; mhonarc::htmlize
</CHARSETCONVERTERS>

<TEXTCLIPFUNC>
MHonArc::UTF8::clip; MHonArc/UTF8.pm
</TEXTCLIPFUNC>

<!-- thread levels -->
<TLEVELS>
8
</TLEVELS>

<!-- show plain text if available, with fallback to html -->
<MIMEALTPREFS>
text/plain
text/html
</MIMEALTPREFS>

<!-- neutralize html in messages that have not text/plain -->
<MIMEFilters>
text/html;   m2h_text_plain::filter; mhtxtplain.pl
text/x-html; m2h_text_plain::filter; mhtxtplain.pl
</MIMEFilters>

<!-- create index.html for date archives -->
<IDXFNAME>
index.html
</IDXFNAME>

<!-- create tindex.html for thread archives -->
<TIDXFNAME>
tindex.html
</TIDXFNAME>

<!-- remove link to mhonarc doc from the footer -->
<NODOC>
</NODOC>

<!-- reverse the date sorting of the messages  -->
<REVERSE>
</REVERSE>

<!-- the fields to show for each message in the correct order -->
<FIELDORDER>
subject
from
date
</FIELDORDER>

<!-- fields beginning/end -->
<FIELDSBEG>
<div id="msg-fields">
	<ul>
</FIELDSBEG>

<FIELDSEND>
	</ul>
</div><!-- #msg-fields -->
</FIELDSEND>

<!-- enable spam mode -->
<SPAMMODE>
</SPAMMODE>

<!-- replace @ and . in addresses to make spambots's life harder -->
<ADDRESSMODIFYCODE>
s/@/ [ at ] /; s/\./ [ dot ] /g;
</ADDRESSMODIFYCODE>

<!-- apply the address filter in body content too -->
<MODIFYBODYADDRESSES>
</MODIFYBODYADDRESSES>
