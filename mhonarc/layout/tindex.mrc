<!-- the layout for rendering thread index pages -->

<!-- the thread index title -->
<TTITLE>
[$ENV(_LNAME)$] archives by thread for $ENV(_DATE)$
</TTITLE>

<!-- thread index beginning -->
<TIDXPGBEGIN>
<!DOCTYPE html>
<html lang="$ENV(_LANG)$">
<head>
	<meta charset="utf-8">
	<title>$TIDXTITLE$</title>
	<link rel="stylesheet" href="/css/style.css">
</head>

<body>
</TIDXPGBEGIN>

<!-- thread index end -->
<TIDXPGEND>
</body>
</html>
</TIDXPGEND>


<!-- thread index header -->
<THEAD>
	<nav id="top-menu">
		<ul>
			<li><a href="/">home</a></li>
			<li><a href="$IDXFNAME$#$MSGNUM$">date index</a></li>
		</ul>
	</nav>

	<div id="messages">
		<h1>$TIDXTITLE$</h1>

		<div id="tidx">
			<ul>
</THEAD>

<TFOOT>
			</ul>
		</div>
	 </div>
</TFOOT>
