<participant-enrichers>

	<div class="ui segment">
		<h3><i class="icon smile"></i> Enricher(s)</h3>

		<div
			show  = {opts.friends.length}
			class = "ui segment comments">
			<div
				class = "comment"
				style = "border-bottom: 1px solid #ccc;"
				each  = {friend in opts.friends}>
				<div class = "content">
					<a class = "author">{friend.first_name} {friend.last_name}</a>
					<div class = "metadata">{friend.email}</div>
				</div>
			</div>
		</div>
	</div>

</participant-enrichers>
