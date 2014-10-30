<!-- the layout for rendering main index pages -->

<!-- the index title -->
<TITLE>
[$LIST-NAME$] archives by date for $DATE-FMT$
</TITLE>

<!-- index beginning -->
<IDXPGBEGIN>
<!DOCTYPE html>
<html lang="$HTML-LANG$">
<head>
	<meta charset="utf-8">
	<title>$IDXTITLE$</title>
	<link rel="stylesheet" href="$ENV(_PUBLIC_URL)$/css/style.css">
</head>

<body>
	<div id="page">
		<div id="top-menu">
			<a href="$ENV(_PUBLIC_URL)$">home</a>
			<span class="sep">|</span>
			<a href="$ENV(_LIST_URL)$/listinfo.html">list info</a>
			<span class="sep">|</span>
			<a href="$ENV(_LIST_URL)$">list archive</a>
			<span class="sep">|</span>
			<a href="$IDXFNAME$" class="current-item">date index</a>
			<span class="sep">|</span>
			<a href="$TIDXFNAME$">thread index</a>
		</div>

		<h1>$IDXTITLE$</h1>
</IDXPGBEGIN>

<!-- markup for the main index message list: top -->
<LISTBEGIN>
		<div id="messages">
			<ul>
</LISTBEGIN>

<!-- markup for each message in the main index message list -->
<LITEMPLATE>
			<li><span class="msg-subject"><strong>$SUBJECT$</strong></span>, <span class="msg-from"><em>$FROMNAME$</em></span><br /><span class="msg-date">$MSGLOCALDATE(CUR;%Y-%m-%d)$</span></li>
</LITEMPLATE>

<!-- markup for the main index message list end -->
<LISTEND>
			</ul>
		</div><!-- #messages -->
</LISTEND>

<!-- index end -->
<IDXPGEND>
	</div><!-- #page -->
</body>
</html>
</IDXPGEND>
