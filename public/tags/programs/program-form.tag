<program-form>
	<div class="ui segment">
		<h3>Create Progam</h3>

		<div class="ui form">
			<div class="inline field">
				<label>Program Name</label>
				<input type="text" ref="program_name" placeholder="Program Name" />
			</div>
			<div class="field">
				<label>Program Type</label>
				<div class="ui search">
					<input type="text" ref="program_type" class="prompt" placeholder="Program Type" />
				</div>
			</div>
			<div class="inline field">
				<div style="text-align: right;">
					<button
						class   = "ui small primary basic button"
						onclick = "{ saveProgram() }">
						Save
					</button>
				</div>
			</div>
		</div>
	</div>



	<script>

		getData(res) {
			return res.data();
		}

		loadProgramTypes() {
			this.parent.opts.service.getProgramTypes((err, response) => {
				if (!err) {
					let data = this.getData(response.body()[0]).programs;

					if (data.length) {
						$('.ui.search').search({
							source: data.map((d) => {
								return {title: d['program_type']};
							})
						})
					}
				}
			});
		}

		generateProgramParams() {
			return {
				program: {
					program_name: this.refs.program_name.value,
					program_type: this.refs.program_type.value
				}
			};
		}

		reset() {
			this.edit_id = null;
			this.refs.program_name.value = '';
			this.refs.program_type.value = '';
		}

		create(data) {
			this.parent.opts.service.create(data, (err, response) => {
				if (!err) {
					this.reset();
					this.loadProgramTypes();
					this.parent.reloadList();
				}
			});
		}

		update() {}

		saveProgram(e) {
			return(e) => {
				let state  = this.parent.opts.store.getState().programs;
				let params = this.generateProgramParams();

				if (state.view == "ADD_PROGRAM") {
					// CREATE PROGRAM
					this.create(params);
				}

				if (state.view == "EDIT_PROGRAM") {
					// EDIT PROGRAM
				}
			}
		}

		this.loadProgramTypes()


		// setTimeout(() => {
		// 	$('.ui.search').search()
		// }, 10);
	</script>
</program-form>

