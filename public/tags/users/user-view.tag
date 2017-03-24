<user-view
	class = "ui container"
	style = "margin: 25px 0;">

	<div class="ui">
		<div class="row" style="margin-bottom: 25px;">
			<h2>
				<span>
					View User
				</span>
				<div class="ui green basic button right floated" onclick = "{ edit }">
					<i class="write left icon"></i> Edit
				</div>
				<div class="ui primary basic button right floated" onclick = "{ parent.showList }">
					<i class="chevron left icon"></i> Back
				</div>
			</h2>
		</div>
	</div>

	<script>

		edit() {
			this.parent.showForm({id: this.opts.state.id});
		}

		this.user    = {}
		this.view_id = this.opts.state.id;

		console.log("this.view_id, this.opts.state");
		console.log(this.view_id, this.opts.state);

		if (this.view_id) {
			this.parent.opts.service.get(this.view_id, (err, response) => {
				if (!err) {
					this.user = response.body().data();
					console.log("this.user");
					console.log(this.user);
					this.update();
				}
				else {
					this.user = null;
				}
			});
		}


	</script>

</user-view>
