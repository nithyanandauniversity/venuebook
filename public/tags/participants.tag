<participants>

	<!-- Participant Search Component -->
	<participant-search
		show = "{opts.state.view == 'LIST_PARTICIPANT' || opts.state.view == 'SEARCH_PARTICIPANT'}">
	</participant-search>

	<!-- Participant List Component -->
	<participant-list
		show = "{opts.state.view == 'LIST_PARTICIPANT' || opts.state.view == 'SEARCH_PARTICIPANT'}">
	</participant-list>

	<!-- Participant Form Component for Add / Edit -->
	<participant-form
		if    = "{opts.state.view == 'ADD_PARTICIPANT' || opts.state.view == 'EDIT_PARTICIPANT'}"
		state = "{opts.state}">
	</participant-form>

	<!-- Participant View Component -->
	<participant-view
		if    = "{opts.state.view == 'VIEW_PARTICIPANT'}"
		state = "{opts.state}">
	</participant-view>

	<script>

		this.searchQ = '';

		showNew(e) {
			this.opts.store.dispatch({type: 'ADD_PARTICIPANT'});
			this.update();
			// this.tags['participant-form'].trigger('create');
		}

		showList(e) {

			if (this.searchQ != '') {
				this.performSearch(this.tags['participant-list'].getPage());
			}
			else {
				this.opts.store.dispatch({type: 'LIST_PARTICIPANT'});
				this.update();
				this.tags['participant-list'].trigger('refresh');
			}
		}

		performSearch(pageNo) {
			this.opts.store.dispatch({type: 'SEARCH_PARTICIPANT', query: {
				page    : pageNo || 1,
				limit   : 10,
				keyword : this.searchQ || ''
			}});
			this.update();
			this.tags['participant-list'].trigger('search');
		}

		showView(participant) {
			// console.log('show view!', participant);
			this.opts.store.dispatch({type: 'VIEW_PARTICIPANT', id: participant.id});
			this.update();
			// this.tags['participant-view'].trigger('view');
		}

		showForm(participant) {
			// console.log('show form!', participant);
			this.opts.store.dispatch({type: 'EDIT_PARTICIPANT', id: participant.id});
			this.update();
			// this.tags['participant-form'].trigger('edit');
		}

		// this.opts.store.dispatch({type: 'LIST_PARTICIPANT'});
		// this.update();
	</script>

</participants>