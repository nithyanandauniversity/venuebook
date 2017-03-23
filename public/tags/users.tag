<users>

	<!-- User Search Component -->
	<user-search
		show = "{opts.state.view == 'LIST_USER' || opts.state.view == 'SEARCH_USER'}">
	</user-search>

	<!-- User List Component -->
	<user-list
		show = "{opts.state.view == 'LIST_USER' || opts.state.view == 'SEARCH_USER'}">
	</user-list>

	<!-- User Form Component for Add / Edit -->
	<user-form
		if    = "{opts.state.view == 'ADD_USER' || opts.state.view == 'EDIT_USER'}"
		state = "{opts.state}">
	</user-form>

	<!-- User View Component -->
	<!-- <user-view
		if    = "{opts.state.view == 'VIEW_USER'}"
		state = "{opts.state}">
	</user-view> -->

	<script>
		let state = this.parent.opts.store.getState().routes;
		this.role = state.data ? state.data.role : 0;

		this.searchQ       = '';
		this.searchFilters = {};

		showNew(e) {
			this.opts.store.dispatch({type: 'ADD_USER'});
			this.update();
			// this.tags['center-form'].trigger('create');
		}

		showList(e) {
			if (this.searchQ != '') {
				this.performSearch(this.tags['user-list'].getPage());
			}
			else {
				this.opts.store.dispatch({type: 'LIST_USER'});
				this.update();
				this.tags['user-list'].trigger('refresh');
			}
		}

		showView(user) {
			console.log('show view!', user);
			// this.opts.store.dispatch({type: 'VIEW_USER', id: user.id});
			// this.update();
			// this.tags['user-view'].trigger('view');
		}

		assignCenter(center) {
			this.selectedCenter = center;
			this.tags['user-search'].update();
		}

		performSearch(pageNo) {
			this.opts.store.dispatch({type: 'SEARCH_USER', query: {
				page       : pageNo || 1,
				limit      : 10,
				keyword    : this.searchQ || '',
				attributes : this.searchFilters || {}
			}});
			this.update();
			this.tags['user-list'].trigger('search');
		}

		// if (this.role > 0) {
		// 	this.userTypes = [
		// 		{
		// 			name : 'Program Coordinator',
		// 			role : 5
		// 		},
		// 		{
		// 			name : 'Data Entry',
		// 			role : 6
		// 		}
		// 	];

		// 	if (this.role < 4) {
		// 		this.userTypes.unshift({
		// 			name : 'Center Manager',
		// 			role : 4
		// 		});
		// 	}

		// 	if (this.role < 3) {
		// 		this.userTypes.unshift({
		// 			name : 'Center Admin',
		// 			role : 3
		// 		});
		// 	}

		// 	if (this.role < 2) {
		// 		this.userTypes.unshift({
		// 			name : 'Lead',
		// 			role : 2
		// 		});

		// 		this.userTypes.unshift({
		// 			name : 'ROOT',
		// 			role : 1
		// 		});
		// 	}
		// }

	</script>
</users>
