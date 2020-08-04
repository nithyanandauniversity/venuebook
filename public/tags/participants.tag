<participants>

	<!-- Participant Search Component -->
	<participant-search
		show = "{['LIST_PARTICIPANT','SEARCH_PARTICIPANT','MERGE_PARTICIPANT'].indexOf(opts.state.view) >= 0}">
	</participant-search>

	<!-- Participant List Component -->
	<participant-list
		show = "{['LIST_PARTICIPANT','SEARCH_PARTICIPANT','MERGE_PARTICIPANT'].indexOf(opts.state.view) >= 0}">
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

		this.searchQ   = '';
		this.extSearch = null;

		showNew(e) {
			this.opts.store.dispatch({type: 'ADD_PARTICIPANT'});
			this.update();
			// this.tags['participant-form'].trigger('create');
		}

		showMerge() {
			if (this.opts.state.view != 'MERGE_PARTICIPANT') {
				console.log("merge");
				this.opts.store.dispatch({type: 'MERGE_PARTICIPANT', step: 1});
			}
			else {
				console.log("search")
				this.opts.store.dispatch({type: 'SEARCH_PARTICIPANT'});
			}

			console.log("this.opts.state.view");
			console.log(this.opts.state.view);
			this.update();
			this.tags['participant-list'].trigger('merge');
		}

		goToMergeStepOne(data) {
			this.opts.store.dispatch({type: 'MERGE_PARTICIPANT', step: 1, data: data});
			this.update();
			this.tags['participant-list'].trigger('merge');
		}

		goToMergeStepTwo(data) {
			this.opts.store.dispatch({type: 'MERGE_PARTICIPANT', step: 2, data: data});
			this.update();
			this.tags['participant-list'].trigger('merge');
		}

		resetSearch() {
			this.opts.store.dispatch({type: 'SEARCH_PARTICIPANT'});
			this.update();
			// if (triggerMerge) { this.tags['participant-list'].trigger('merge'); }
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

			let params = {
				page       : pageNo || 1,
				limit      : 10,
				keyword    : this.searchQ || ''
			};

			if (this.extSearch) {
				params.ext_search = this.extSearch;
			}

			this.opts.store.dispatch({type: 'SEARCH_PARTICIPANT', query: params});
			this.update();
			this.tags['participant-list'].trigger('search');
		}

		showView(participant) {
			this.opts.store.dispatch({
				type : 'VIEW_PARTICIPANT',
				id   : participant.member_id
			});
			this.update();
			// this.tags['participant-view'].trigger('view');
		}

		showForm(participant) {
			this.opts.store.dispatch({type: 'EDIT_PARTICIPANT', id: participant.member_id});
			this.update();
			// this.tags['participant-form'].trigger('edit');
		}

		if (this.opts.settingService) {
			this.opts.settingService.getByName('center_areas', (err, response) => {
				if (!err) {
					this.center_areas = response.body()[0].data();
				}
			});
		}

	</script>

</participants>
