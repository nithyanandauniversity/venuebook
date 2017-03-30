<upload>

	<div class="ui container" style="margin-top: 25px;">
		<h2>UPLOAD PARTICIPANTS FILE</h2>

		<div class="ui form">
			<div class="field">
				<div class="ui action input">
					<input type="file" ref="file" placeholder="Upload file" />
					<button onclick="{ doUpload() }" class="ui button basic green">Upload</button>
				</div>
			</div>
		</div>
	</div>

	<script>
		this.currentUser = this.opts.store.getState().routes.data;

		doUpload(e) {
			return(e) => {
				let fd = new FormData();
				fd.append('csv', this.refs.file.files[0]);
				// $.each(this.refs.file.files, (key, value) => {
				// 	fd.append(key, value);
				// });

				// this.opts.participantService.import(this.refs.file.files[0], (err, response) => {
				// 	console.log("err, response");
				// 	console.log(err, response);
				// });
			}
		}
	</script>

</upload>
