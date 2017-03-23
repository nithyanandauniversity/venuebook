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
		if                  = "{opts.store.getState().routes.path == 'EVENTS'}"
		store               = "{opts.store}"
		state               = "{opts.store.getState().events}"
		service             = "{opts.services.eventService}"
		attendance-service  = "{opts.services.attendanceService}"
		program-service     = "{opts.services.programService}"
		venue-service       = "{opts.services.venueService}"
		participant-service = "{opts.services.participantService}"
		user-service        = "{opts.services.userService}">
	</events>

	<users
		if             = "{opts.store.getState().routes.path == 'USERS'}"
		store          = "{opts.store}"
		state          = "{opts.store.getState().users}"
		service        = "{opts.services.userService}"
		center-service = "{opts.services.centerService}"
		user-roles     = "{opts.services.userRoles}">
	</users>

	<profile
		store        = "{opts.store}"
		user-service = "{opts.services.userService}">
	</profile>


	<script>

		this.on('showProfile', () => {
			$("profile").modal({
					transition : 'vertical flip',
					onShow     : () => {
						if ($(".ui.dimmer.modals > profile").length > 1) {
							$(".ui.dimmer.modals > profile")[0].remove();
						}
					},
					onVisible  : () => {
						this.tags['profile'].trigger('loaded');
					}
				})
				.modal('show');

		});

		hideModal() {
			$("profile").modal('hide');
		}

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
