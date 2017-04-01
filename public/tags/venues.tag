<venues class="ui equal width grid" style="margin-top: 25px;">

	<!-- Create Venue Component -->
	<venue-form class="column"></venue-form>

	<!-- List Venue Component -->
	<venue-list class="column"></venue-list>

	<script>

		this.currentUser  = this.opts.store.getState().routes.data;

		editVenue(venue) {
			this.opts.store.dispatch({type: 'EDIT_VENUE', id: venue.id});
			this.update();
			this.tags['venue-form'].trigger('edit');
		}

		reloadList() {
			this.opts.store.dispatch({type: 'ADD_VENUE'});
			this.update();
			this.tags['venue-list'].trigger('reload');
		}

	</script>

</venues>
