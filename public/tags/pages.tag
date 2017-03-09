<pages class="ui container">

	<participants
		if        = "{opts.store.getState().routes.path == 'PARTICIPANTS'}"
		store     = "{opts.store}"
		state     = "{opts.store.getState().participants}"
		service   = "{opts.services.participantService}"
		countries = "{opts.services.countries}"
		dialcodes = "{opts.services.dialcodes}">
	</participants>

	<centers
		if                = "{opts.store.getState().routes.path == 'CENTERS'}"
		store             = "{opts.store}"
		state             = "{opts.store.getState().centers}"
		service           = "{opts.services.centerService}"
		countries         = "{opts.services.countries}"
		center-categories = "{opts.services.centerCategories}">
	</centers>

	<programs
		if      = "{opts.store.getState().routes.path == 'PROGRAMS'}"
		store   = "{opts.store}"
		state   = "{opts.store.getState().programs}"
		service = "{opts.services.programService}">
	</programs>

	<venues
		if        = "{opts.store.getState().routes.path == 'VENUES'}"
		store     = "{opts.store}"
		countries = "{opts.services.countries}"
		state     = "{opts.store.getState().programs}"
		service   = "{opts.services.venueService}">
	</venues>

	<events
		if      = "{opts.store.getState().routes.path == 'EVENTS'}"
		store   = "{opts.store}"
		state   = "{opts.store.getState().events}"
		service = "{opts.services.eventService}">
	</events>

	<users
		if = "{opts.store.getState().routes.path == 'USERS'}">
	</users>

	<script>
		console.log("this.opts");
		console.log(this.opts);

		this.route = this.opts.store.getState().routes;

		console.log("this.route");
		console.log(this.route);

	</script>


	<style scoped>
		:scope { font-size: 2em }
		h3 { color: #444 }
		ul { color: #999 }
	</style>
</pages>