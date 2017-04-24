<participant-comments style = "display: block; margin-bottom: 1em;">

	<div class = "ui segment">

		<h3><i class="icon comments"></i>Comments</h3>

		<div
			show  = {opts.comments.length}
			class = "ui segment comments"
			style = "overflow-y: scroll; max-height: 200px;">
			<div
				class = "comment"
				style = "border-bottom: 1px solid #ccc;"
				each  = {comment, i in opts.comments}>
				<!-- <a href="" class="avatar"></a> -->
				<div class = "content">
					<a href = "" class = "author">{comment.created_by}</a>
					<div class = "metadata">{comment.created_at}</div>
					<div class = "text">{comment.content}</div>
				</div>
			</div>
		</div>

		<div
			show  = "{!opts.comments.length}"
			class = "ui message red">
			<span>No Comments for this user!</span>
		</div>

		<div class="ui fluid icon input">
			<input type="text" ref="comment" placeholder="Enter a comment for the user..." />
			<i class="icon comment"></i>
		</div>

		<div class="ui pointing red label">This doesn't work now</div>

	</div>

</participant-comments>
