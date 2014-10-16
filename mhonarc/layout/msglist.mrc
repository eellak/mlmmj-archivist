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
