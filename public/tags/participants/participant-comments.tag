<participant-comments style = "display: block; margin-bottom: 1em;">

	<div class = "ui segment">

		<h3><i class="blue icon comments"></i>Comments</h3>

		<div
			show  = {comments.length}
			class = "ui segment comments"
			style = "overflow-y: scroll; max-height: 200px;">
			<div
				class = "comment"
				style = "border-bottom: 1px solid #ccc;"
				each  = {comment, i in comments}>
				<!-- <a href="" class="avatar"></a> -->
				<div class = "content">
					<a href = "" class = "author">{comment.created_by}</a>
					<div class = "metadata">{comment.created_at}</div>
					<div class = "text">
						<span>{comment.content}</span>
						<span
							class   = "right floated"
							title   = "Edit Comment"
							style   = "cursor: pointer;"
							onclick = "{ editComment() }"
							show    = "{comment.created_by == getCurrentUser()}">
							<i class="teal icon edit"></i>
						</span>
					</div>
				</div>
			</div>
		</div>

		<div
			show  = "{!comments.length}"
			class = "ui message red">
			<span>No Comments for this user!</span>
		</div>

		<div class="ui fluid icon input {emptyVal && 'error'}">
			<input
				type        = "text"
				id          = "commentInput"
				ref         = "comment"
				onkeypress  = "{ saveComment() }"
				onkeyup     = "{ checkThis() }"
				placeholder = "Enter a comment for the user..." />
			<i class="icon comment"></i>
		</div>

		<!-- <div class="ui pointing red label">This doesn't work now</div> -->

	</div>


	<script>

		this.comments = this.opts.comments;
		this.currentUser = this.parent.currentUser;

		getCurrentUser() {
			return this.currentUser.email;
		}

		editComment(e) {
			return(e) => {
				let comment = e.item.comment;
				this.commentId = comment.id;
				this.refs.comment.value = comment.content;
				$("#commentInput").focus();
			}
		}

		saveComment(e) {
			return(e) => {
				if (e.which == 13) {
					let comment = this.refs.comment.value;
					this.refs.comment.value = '';

					if (comment == '' || !comment.length) {
						this.emptyVal = true;
						return false;
					}

					this.emptyVal = false;
					if (!this.commentId) {
						this.createComment(comment);
					}
					else {
						this.updateComment(comment);
					}
				}
			}
		}

		checkThis(e) {
			return(e) => {
				if (e.which == 27 && this.commentId) {
					this.commentId          = null;
					this.emptyVal           = false;
					this.refs.comment.value = '';
					this.update();
				}
			}
		}

		createComment(comment) {
			this.parent.createComment(comment, (err, response) => {
				if (!err) {
					if (response && response.body() && response.body().data()) {
						this.comments = response.body().data().comments;
						this.update();
					}
				}
			});
		}

		updateComment(comment) {
			this.parent.updateComment(this.commentId, comment, (err, response) => {
				if (!err) {
					if (response && response.body() && response.body().data()) {
						this.comments = response.body().data().comments;
						this.update();
					}
				}
			});
		}

		setTimeout(() => {
			this.update();
		}, 100);
	</script>

</participant-comments>
