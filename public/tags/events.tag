<events>

	<div class="ui container" style="margin-top: 25px;">

		<div class="content">
			<button
				class   = "ui basic primary large button right floated"
				style   = "margin: 2px;"
				if      = "{currentUser.role < 5}"
				show    = "{opts.state.view == 'UPCOMING_EVENT' || opts.state.view == 'PAST_EVENT' || opts.state.view == 'SEARCH_EVENT'}"
				onclick = "{ createEvent }">
				<i class="icon add to calendar"></i> Create New
			</button>
			<button
				class   = "ui basic brown large button right floated {showSearch && 'active'}"
				style   = "margin: 2px;"
				show    = "{opts.state.view == 'PAST_EVENT' || opts.state.view == 'SEARCH_EVENT'}"
				onclick = "{ toggleSearch }">
				<i class="icon search" style="margin: 0;"></i> Search
			</button>
			<button
				class   = "ui basic orange large button right floated"
				style   = "margin: 2px;"
				show    = "{opts.state.view == 'VIEW_EVENT'}"
				onclick = "{ goEdit }">
				<i class="write icon"></i> Edit
			</button>
			<button
				class   = "ui basic primary large button right floated"
				style   = "margin: 2px;"
				show    = "{opts.state.view == 'ADD_EVENT' || opts.state.view == 'VIEW_EVENT'}"
				onclick = "{ goPrev }">
				<i class="chevron left icon"></i> Back
			</button>
		</div>

		<div class="ui large compact menu">
			<a
				class   = "green item {opts.state.view == 'UPCOMING_EVENT' && 'active'}"
				onclick = "{ showUpcoming }">
				<i class="icon calendar"></i> Upcoming Events
			</a>
			<a
				class   = "orange item {opts.state.view == 'PAST_EVENT' && 'active'} {opts.state.view == 'SEARCH_EVENT' && 'active'}"
				onclick = "{ showPast }">
				<i class="icon checked calendar"></i> Past Events
			</a>
		</div>

	</div>

	<div class="ui divider"></div>

	<!-- Event - Upcoming Component -->
	<event-upcoming
		show  = "{opts.state.view == 'UPCOMING_EVENT'}"
		state = "{opts.state}">
	</event-upcoming>

	<event-search
		if    = "{(opts.state.view == 'PAST_EVENT' || opts.state.view == 'SEARCH_EVENT') && showSearch}"
		state = "{opts.state}">
	</event-search>

	<!-- Event - Past Component -->
	<event-past
		show  = "{opts.state.view == 'PAST_EVENT' || opts.state.view == 'SEARCH_EVENT'}"
		state = "{opts.state}">
	</event-past>

	<!-- Event Form Component -->
	<event-form
		if    = "{opts.state.view == 'ADD_EVENT' || opts.state.view == 'EDIT_EVENT'}"
		state = "{opts.state}">
	</event-form>

	<!-- Event View Component -->
	<event-view
		if    = "{opts.state.view == 'VIEW_EVENT'}"
		state = "{opts.state}">
	</event-view>


	<script>
		console.log("this.opts");
		console.log(this.opts);

		this.currentUser  = this.opts.store.getState().routes.data;
		this.showSearch = false;

		createEvent(params) {
			this.prevState = this.opts.store.getState().events;
			this.opts.store.dispatch({type: 'ADD_EVENT', params: params});
			this.update();
		}

		toggleSearch() {
			this.showSearch = !this.showSearch;
			this.update();
		}

		viewEvent(event) {
			this.prevState = this.opts.store.getState().events;
			this.opts.store.dispatch({type: 'VIEW_EVENT', id: event.id});
			this.update();
		}

		goEdit(e) {
			this.editEvent({id: this.opts.store.getState().events.id});
		}

		editEvent(event) {
			this.prevState = this.opts.store.getState().events;
			this.opts.store.dispatch({type: 'EDIT_EVENT', id: event.id});
			this.update();
		}

		removeEvent(event) {
			this.prevState = this.opts.store.getState().events;
			this.opts.service.remove(event.id, (err, response) => {
				console.log("err, response");
				console.log(err, response);
				if (!err) {
					this.tags['event-past'].trigger('reload');
				}
			});
		}

		goPrev() {
			if (this.prevState && this.prevState.view) {
				if (this.prevState.view == 'PAST_EVENT') {
					console.log('show past !');
					this.showPast();
				}
				else if (this.prevState.view == 'SEARCH_EVENT') {
					console.log('show search !');
					this.doSearch(this.prevState.query);
				}
				else {
					console.log('show upcoming !');
					this.showUpcoming();
				}
			}
			else {
				console.log('show upcoming !!');
				this.showUpcoming();
			}
		}

		doSearch(params) {
			this.opts.store.dispatch({type: 'SEARCH_EVENT', query : params});
			this.update();
			this.tags['event-past'].trigger('reload');
		}

		showUpcoming() {
			if (this.opts.store.getState().events.view == 'UPCOMING_EVENT') { return; }
			this.opts.store.dispatch({type: 'UPCOMING_EVENT'});
			this.update();
			this.tags['event-upcoming'].trigger('reload');
		}

		showPast() {
			if (this.opts.store.getState().events.view == 'PAST_EVENT') { return; }
			this.opts.store.dispatch({type: 'PAST_EVENT'});
			this.showSearch = false;
			this.update();
			this.tags['event-past'].trigger('reload');
		}

		if (this.opts.settingService) {
			this.opts.settingService.getByName('center_areas', (err, response) => {
				if (!err) {
					this.center_areas = response.body()[0].data();
				}
			});
		}

	</script>

</events>
