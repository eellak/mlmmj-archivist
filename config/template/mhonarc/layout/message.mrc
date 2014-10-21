<!-- the layout for rendering message pages -->

<!-- message beginning -->
<MSGPGBEGIN>
<!DOCTYPE html>
<html lang="el">
<head>
	<meta charset="utf-8">
	<title>$SUBJECTNA$</title>
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
			<a href="$IDXFNAME$">date index</a>
			<span class="sep">|</span>
			<a href="$TIDXFNAME$">thread index</a>
		</div>

		<div id="message">
</MSGPGBEGIN>

<!-- message body beggining -->
<HEADBODYSEP>
			<div id="msg-body">
</HEADBODYSEP>

<!-- message body end -->
<MSGBODYEND>
			</div><!-- #msg-body -->
</MSGBODYEND>

<!-- message end -->
<MSGPGEND>
		</div><!-- #message -->
	</div><!-- #page -->
</body>
</html>
</MSGPGEND>

<!-- top links, before the message body -->
<TOPLINKS>
<!-- NOTOPLINKS -->
</TOPLINKS>


<!-- ! links after the message body -->

<!-- bottom links -->
<BOTLINKS>
			<div id="msg-nav">
				<h3>message navigation</h3>

				<ul>
					$LINK(PREV)$
					$LINK(NEXT)$
					$LINK(TPREV)$
					$LINK(TNEXT)$
				</ul>
			</div><!-- #msg-nav -->
</BOTLINKS>

<!-- next/prev links -->
<NEXTLINK>
<li>next by date: <strong><a href="$MSG(NEXT)$">$SUBJECT(NEXT)$</a></strong></li>
</NEXTLINK>
<PREVLINK>
<li>previous by date: <strong><a href="$MSG(PREV)$">$SUBJECT(PREV)$</a></strong></li>
</PREVLINK>

<TNEXTLINK>
<li>next by thread: <strong><a href="$MSG(TNEXT)$">$SUBJECT(TNEXT)$</a></strong></li>
</TNEXTLINK>
<TPREVLINK>
<li>previous by thread: <strong><a href="$MSG(TPREV)$">$SUBJECT(TPREV)$</a></strong></li>
</TPREVLINK>

<!-- follow up links messages -->
<FOLUPBEGIN>
			<div id="followups">
				<h3>replies</h2>

				<ul>
</FOLUPBEGIN>

<FOLUPLITXT>
					<li><span class="msg-subject"><strong>$SUBJECT$</strong>, <span class="msg-from"><em>$FROMNAME$</em></span></li>
</FOLUPLITXT>

<FOLUPEND>
				</ul>
			</div><!-- #followups -->
</FOLUPEND>

<!-- explicit reference links messages -->
<REFSBEGIN>
			<div id="msg-ref">
				<h3>references</h3>

				<ul>
</REFSBEGIN>

<REFSLITXT>
					<li><span class="msg-subject"><strong>$SUBJECT$</strong>, <span class="msg-from"><em>$FROMNAME$</em></span></li>
</REFSLITXT>

<REFSEND>
				</ul>
			</div><!-- #msg-ref -->
</REFSEND>

<!-- remove separator from subject. use css instead -->
<SUBJECTHEADER>
<h1>$SUBJECTNA$</h1>
</SUBJECTHEADER>
