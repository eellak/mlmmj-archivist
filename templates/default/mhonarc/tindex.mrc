<!-- the layout for rendering thread index pages -->

<!-- the thread index title -->
<TTITLE>
[$LIST-NAME$] archives by thread for $DATE-FMT$
</TTITLE>

<!-- thread index beginning -->
<TIDXPGBEGIN>
<!DOCTYPE html>
<html lang="$HTML-LANG$">
<head>
	<meta charset="utf-8">
	<title>$TIDXTITLE$</title>
	<link rel="stylesheet" href="$PUBLIC-URL$/css/style.css">
</head>

<body>
	<div id="page">
		<div id="top-menu">
			<a href="$PUBLIC-URL$">home</a>
			<span class="sep">|</span>
			<a href="$ENV(_LIST_URL)$/listinfo.html">list info</a>
			<span class="sep">|</span>
			<a href="$ENV(_LIST_URL)$">list archive</a>
			<span class="sep">|</span>
			<a href="$IDXFNAME$">date index</a>
			<span class="sep">|</span>
			<a href="$TIDXFNAME$" class="current-item">thread index</a>
		</div><!-- #top-menu -->

		<h1>$TIDXTITLE$</h1>
</TIDXPGBEGIN>

<!-- thread index header -->
<THEAD>
		<div id="messages">
			<ul>
</THEAD>

<!-- markup for each message in thread index message list -->
<TLITXT>
				<li><span class="msg-subject"><strong>$SUBJECT$</strong></span>, <span class="msg-from"><em>$FROMNAME$</em></span><br /><span class="msg-date">$MSGLOCALDATE(CUR;%Y-%m-%d)$</span></li>
</TLITXT>

<TTOPBEGIN>
				<li><span class="msg-subject"><strong>$SUBJECT$</strong></span>, <span class="msg-from"><em>$FROMNAME$</em></span><br /><span class="msg-date">$MSGLOCALDATE(CUR;%Y-%m-%d)$</span></li>
</TTOPBEGIN>

<TSINGLETXT>
				<li><span class="msg-subject"><strong>$SUBJECT$</strong></span>, <span class="msg-from"><em>$FROMNAME$</em></span><br /><span class="msg-date">$MSGLOCALDATE(CUR;%Y-%m-%d)$</span></li>
</TSINGLETXT>

<TFOOT>
			</ul>
		</div><!-- #messages -->
</TFOOT>

<!-- thread index end -->
<TIDXPGEND>
	</div><!-- #page -->
</body>
</html>
</TIDXPGEND>
