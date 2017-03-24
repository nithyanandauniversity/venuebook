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
	<user-view
		if    = "{opts.state.view == 'VIEW_USER'}"
		state = "{opts.state}">
	</user-view>

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
			this.opts.store.dispatch({type: 'VIEW_USER', id: user.id});
			this.update();
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

		if (this.opts.settingService) {
			this.opts.settingService.getByName('center_areas', (err, response) => {
				if (!err) {
					this.center_areas = response.body()[0].data();
					console.log("this.center_areas");
					console.log(this.center_areas);
				}
			});
		}

		showForm(user) {
			// console.log('show form!', user);
			// this.opts.store.dispatch({type: 'EDIT_USER', id: user.id});
			// this.update();
			// this.tags['user-form'].trigger('edit');
		}

	</script>
</users>
