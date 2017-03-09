<events>

	<div class="ui container" style="margin-top: 25px;">
		<div class="content">
			<button
				class = "ui basic primary large button right floated"
				style = "margin: 2px;"
				onclick = "{ createEvent() }">
				<i class="icon add to calendar"></i> Create New
			</button>
		</div>
		<div class="ui large compact menu">
			<a
				class   = "green item {opts.state.view == 'UPCOMING_EVENT' && 'active'}"
				onclick = "{ showUpcoming() }">
				<i class="icon calendar"></i> Upcoming Events
			</a>
			<a
				class   = "orange item {opts.state.view == 'PAST_EVENT' && 'active'}"
				onclick = "{ showPast() }">
				<i class="icon checked calendar"></i> Past Events
			</a>
		</div>
	</div>

	<div class="ui divider"></div>

	<!-- Event - Upcoming Component -->
	<event-upcoming
		show = "{opts.state.view == 'UPCOMING_EVENT'}">
	</event-upcoming>

	<!-- Event - Past Component -->
	<event-past
		show="{opts.state.view == 'PAST_EVENT'}">
	</event-past>

	<!-- Event Form Component -->
	<event-form
		show="{opts.state.view == 'ADD_EVENT' || opts.state.view == 'EDIT_EVENT'}">
	</event-form>


	<script>
		console.log("this.opts");
		console.log(this.opts);

		createEvent(e) {
			return(e) => {}
		}

		showUpcoming(e) {
			return(e) => {
				if (this.opts.state.view == 'UPCOMING_EVENT') { return; }
				this.opts.store.dispatch({type: 'UPCOMING_EVENT'});
				this.update();
			}
		}

		showPast(e) {
			return(e) => {
				if (this.opts.state.view == 'PAST_EVENT') { return; }
				this.opts.store.dispatch({type: 'PAST_EVENT'});
				this.update();
			}
		}

	</script>

</events>