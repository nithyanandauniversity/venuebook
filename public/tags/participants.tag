<participants>

	<participant-search if={opts.state.view == 'LIST_PARTICIPANT'}></participant-search>
	<participant-list if={opts.state.view == 'LIST_PARTICIPANT'}></participant-list>

	<participant-form
		if={opts.state.view == 'ADD_PARTICIPANT' || opts.state.view == 'EDIT_PARTICIPANT'}
		state={opts.state}>
	</participant-form>

	<participant-view
		if={opts.state.view == 'VIEW_PARTICIPANT'}
		state={opts.state}>
	</participant-view>

	<script>
		this.showNew = (e) => {
			this.opts.store.dispatch({type: 'ADD_PARTICIPANT'});
			this.update();
			this.tags['participant-form'].trigger('create');
		}

		this.showList = (e) => {
			this.opts.store.dispatch({type: 'LIST_PARTICIPANT'});
			this.update();
		}

		this.showView = (participant) => {
			// console.log('show view!', participant);
			this.opts.store.dispatch({type: 'VIEW_PARTICIPANT', id: participant.member_id});
			this.update();
		}

		this.showForm = (participant) => {
			// console.log('show form!', participant);
			this.opts.store.dispatch({type: 'EDIT_PARTICIPANT', id: participant.member_id});
			this.update();
			this.tags['participant-form'].trigger('edit');
		}
	</script>

</participants>