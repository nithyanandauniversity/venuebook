<centers>

	<!-- Center Search Component -->
	<center-search
		show = "{opts.state.view == 'LIST_CENTER' || opts.state.view == 'SEARCH_CENTER'}">
	</center-search>

	<!-- Center List Component -->
	<center-list
		show = "{opts.state.view == 'LIST_CENTER' || opts.state.view == 'SEARCH_CENTER'}">
	</center-list>

	<!-- Center Form Component for Add / Edit -->
	<center-form
		if    = "{opts.state.view == 'ADD_CENTER' || opts.state.view == 'EDIT_CENTER'}"
		state = "{opts.state}">
	</center-form>

	<!-- Center View Component -->

	<script>

		this.searchQ = '';

		showNew(e) {
			this.opts.store.dispatch({type: 'ADD_CENTER'});
			this.update();
			console.log(this.opts);
			console.log("this.opts.store.getState()");
			console.log(this.opts.store.getState());
			// this.tags['center-form'].trigger('create');
		}

		showList(e) {
			if (this.searchQ != '') {
				this.performSearch(this.tags['center-list'].getPage());
			}
			else {
				this.opts.store.dispatch({type: 'LIST_CENTER'});
				this.update();
				this.tags['center-list'].trigger('refresh');
			}
		}

		performSearch(pageNo) {
			// this.opts.store.dispatch({type: 'SEARCH_CENTER', query: {
			// 	page    : pageNo || 1,
			// 	limit   : 10,
			// 	keyword : this.searchQ || ''
			// }});
			// this.update();
			// console.log("this.opts.store.getState()");
			// console.log(this.opts.store.getState());
			// this.tags['participant-list'].trigger('search');
		}

		showView(participant) {
			// console.log('show view!', participant);
			// this.opts.store.dispatch({type: 'VIEW_PARTICIPANT', id: participant.id});
			// this.update();
			// console.log("this.opts.store.getState()");
			// console.log(this.opts.store.getState());
			// this.tags['participant-view'].trigger('view');
		}

		showForm(participant) {
			// console.log('show form!', participant);
			// this.opts.store.dispatch({type: 'EDIT_PARTICIPANT', id: participant.id});
			// this.update();
			// console.log("this.opts.store.getState()");
			// console.log(this.opts.store.getState());
			// this.tags['participant-form'].trigger('edit');
		}
	</script>

</centers>