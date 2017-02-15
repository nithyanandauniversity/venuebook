<participant-comments>

	<div class="ui segment">
		<h3>Comments</h3>

		<div class="ui comments">
			<div
				class="comment"
				each={comment, i in comments}>

				<!-- <a href="" class="avatar"></a> -->
				<div class="content">
					<a href="" class="author">{comment.author}</a>
					<div class="metadata">{comment.date}</div>
					<div class="text">
						{comment.content}
					</div>
				</div>

			</div>
		</div>
	</div>


	<script>

		comments = [
			{
				author: 'Saravana',
				date: '24, Jan 2017. 12:00 AM',
				content: 'This is a test comment'
			},
			{
				author: 'Sri Sadhana',
				date: '26 Jan 2017. 05:00 PM',
				content: 'Second test comment'
			}
		]
	</script>
</participant-comments>