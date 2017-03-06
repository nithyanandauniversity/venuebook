<users>


	<script>
		let state = this.parent.opts.store.getState().routes;
		this.role = state.data ? state.data.role : 0;

		if (this.role > 0) {
			this.userTypes = [
				{
					name : 'Program Coordinator',
					role : 5
				},
				{
					name : 'Data Entry',
					role : 6
				}
			];

			if (this.role < 4) {
				this.userTypes.unshift({
					name : 'Center Manager',
					role : 4
				});
			}

			if (this.role < 3) {
				this.userTypes.unshift({
					name : 'Center Admin',
					role : 3
				});
			}

			if (this.role < 2) {
				this.userTypes.unshift({
					name : 'Lead',
					role : 2
				});

				this.userTypes.unshift({
					name : 'ROOT',
					role : 1
				});
			}
		}
	</script>
</users>