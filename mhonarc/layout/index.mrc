<!-- the layout for rendering main index pages -->

<!-- the index title -->
<TITLE>
[$ENV(_LNAME)$] archives by date for $ENV(_DATE)$
</TITLE>

<!-- index beginning -->
<IDXPGBEGIN>
<!DOCTYPE html>
<html lang="$ENV(_LANG)$">
<head>
	<meta charset="utf-8">
	<title>$IDXTITLE$</title>
	<link rel="stylesheet" href="/css/style.css">
</head>

<body>
	<nav id="top-menu">
		<ul>
			<li><a href="/">home</a></li>
			<li><a href="$TIDXFNAME$#$MSGNUM$">thread index</a></li>
		</ul>
	</nav>

	<h1>$IDXTITLE$</h1>
</IDXPGBEGIN>

<!-- index end -->
<IDXPGEND>
</body>
</html>
</IDXPGEND>

<!-- markup for the main index message list: top -->
<LISTBEGIN>
	<div id="message">
		<ul>
</LISTBEGIN>

<!-- markup for each message in the main index message list -->
<LITEMPLATE>
			<li><span class="msg-date">$MSGLOCALDATE(CUR;%Y-%m-%d)$</span> <span class="msg-subject">$SUBJECT$</span> <span class="msg-from">$FROMNAME$</span></li>
</LITEMPLATE>

<!-- markup for the main index message list end -->
<LISTEND>
		</ul>
	</div>
</LISTEND>
