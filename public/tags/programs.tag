<programs class="ui equal width grid" style="margin-top: 25px;">

	<!-- Create Program Component -->
	<program-form class="column"></program-form>

	<!-- List Program Component -->
	<program-list class="column"></program-list>

	<script>

		this.currentUser = this.opts.store.getState().routes.data;

		editProgram(program) {
			this.opts.store.dispatch({type: 'EDIT_PROGRAM', id: program.id});
			this.update();
			this.tags['program-form'].trigger('edit');
		}

		reloadList() {
			this.opts.store.dispatch({type: 'ADD_PROGRAM'});
			this.update();
			this.tags['program-list'].trigger('reload');
		}

	</script>
</programs>

