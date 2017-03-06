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
	<center-view
		if    = "{opts.state.view == 'VIEW_CENTER'}"
		state = "{opts.state}">
	</center-view>

	<script>

		this.searchQ       = '';
		this.searchFilters = {};

		showNew(e) {
			this.opts.store.dispatch({type: 'ADD_CENTER'});
			this.update();
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
			this.opts.store.dispatch({type: 'SEARCH_CENTER', query: {
				page       : pageNo || 1,
				limit      : 10,
				keyword    : this.searchQ || '',
				attributes : this.searchFilters || {}
			}});
			this.update();
			console.log("this.opts.store.getState()");
			console.log(this.opts.store.getState());
			this.tags['center-list'].trigger('search');
		}

		showView(center) {
			console.log('show view!', center);
			this.opts.store.dispatch({type: 'VIEW_CENTER', id: center.id});
			this.update();
			// console.log("this.opts.store.getState()");
			// console.log(this.opts.store.getState());
			this.tags['center-view'].trigger('view');
		}

		showForm(center) {
			console.log('show form!', center);
			this.opts.store.dispatch({type: 'EDIT_CENTER', id: center.id});
			this.update();
			// console.log("this.opts.store.getState()");
			// console.log(this.opts.store.getState());
			this.tags['center-form'].trigger('edit');
		}

		// this.opts.store.dispatch({type: 'LIST_CENTER'});
		// this.update();
	</script>

</centers>