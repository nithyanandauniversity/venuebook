<program-form>
	<div class="ui container segment">
		<h3>{!edit_id && 'Create' || 'Edit'} Progam</h3>

		<div class="ui form">
			<div class="field {validation && validation.emptyName && 'error'}">
				<label>Program Name</label>
				<div class="ui fluid input">
					<input type="text" ref="program_name" placeholder="Program Name" />
				</div>
			</div>
			<div class="field {validation && validation.emptyType && 'error'}">
				<label>Program Type</label>
				<div class = "ui search fluid input">
					<select
						show  = "{ program_types.obj && program_types.obj.length > 0 }"
						class = "ui search dropdown fluid"
						ref   = "program_type"
						show  = "{proTypes}">
						<option value = "">Select Program Type...</option>
						<option value = "{ value }" each = "{ value in program_types.obj }">{ value }</option>
					</select>
				</div>
			</div>
			<div class="field">
				<div style="text-align: right;">
					<button
						class   = "ui small green basic button"
						onclick = "{ saveProgram() }">
						Save
					</button>
					<button
						class   = "ui small orange basic button"
						onclick = "{ reset }">
						Reset
					</button>
				</div>
			</div>
		</div>
	</div>

	<script>

		getData(res) {
			return res.data();
		}

		this.program_types = {};

		loadProgramTypes() {
			if (this.parent.opts.settingService) {
				this.parent.opts.settingService.getByName('program_types', (err, response) => {
					if (!err) {
						this.program_types = response.body()[0].data();
						this.update();
					}
				});
			}
		}

		generateProgramParams() {
			return {
				program: {
					program_name: this.refs.program_name.value,
					program_type: this.refs.program_type.value
				}
			};
		}

		loadEditForm(program) {
			this.refs.program_name.value = program.program_name;
			this.refs.program_type.value = program.program_type;
		}

		reset() {
			this.edit_id                 = null;
			this.refs.program_name.value = '';
			this.refs.program_type.value = '';
			this.validation              = {};
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

		edit(data) {
			this.parent.opts.service.update(this.edit_id, data, (err, response) => {
				if (!err) {
					this.reset();
					this.loadProgramTypes();
					this.parent.reloadList();
				}
			})
		}

		validateForm(params) {
			this.validation = {};

			if (!params.program.program_name || params.program.program_name == '') {
				this.validation.emptyName = true;
			}

			if (!params.program.program_type || params.program.program_type == '') {
				this.validation.emptyType = true;
			}

			return !this.validation.emptyName && !this.validation.emptyType;
		}

		saveProgram(e) {
			return(e) => {
				let state  = this.parent.opts.store.getState().programs;
				let params = this.generateProgramParams();

				if (!this.validateForm(params)) {
					return false;
				}

				if (state.view == "ADD_PROGRAM" && !this.edit_id) {
					// CREATE PROGRAM
					this.create(params);
				}

				if (state.view == "EDIT_PROGRAM" && this.edit_id) {
					// EDIT PROGRAM
					this.edit(params);
				}
			}
		}

		this.on('edit', () => {
			let state = this.parent.opts.store.getState().programs;
			if (state && state.view == 'EDIT_PROGRAM') {
				this.edit_id = state.id;
				this.parent.opts.service.get(this.edit_id, (err, response) => {
					if (!err) {
						this.program = response.body().data()['program'];
						this.loadEditForm(this.program);
						this.update();
					}
				});
			}
		});

		this.loadProgramTypes();

	</script>
</program-form>

