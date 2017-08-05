<pages class="ui container">

	<dashboard
		if    = "{opts.store.getState().routes.path == 'DASHBOARD'}"
		store = "{opts.store}">
	</dashboard>

	<participants
		if              = "{opts.store.getState().routes.path == 'PARTICIPANTS'}"
		store           = "{opts.store}"
		state           = "{opts.store.getState().participants}"
		service         = "{opts.services.participantService}"
		setting-service = "{opts.services.settingService}"
		center-service  = "{opts.services.centerService}"
		countries       = "{opts.services.countries}"
		dialcodes       = "{opts.services.dialcodes}">
	</participants>

	<centers
		if                = "{opts.store.getState().routes.path == 'CENTERS'}"
		store             = "{opts.store}"
		state             = "{opts.store.getState().centers}"
		service           = "{opts.services.centerService}"
		setting-service   = "{opts.services.settingService}"
		countries         = "{opts.services.countries}"
		center-categories = "{opts.services.centerCategories}">
	</centers>

	<programs
		if              = "{opts.store.getState().routes.path == 'PROGRAMS'}"
		store           = "{opts.store}"
		state           = "{opts.store.getState().programs}"
		setting-service = "{opts.services.settingService}"
		service         = "{opts.services.programService}">
	</programs>

	<venues
		if        = "{opts.store.getState().routes.path == 'VENUES'}"
		store     = "{opts.store}"
		countries = "{opts.services.countries}"
		state     = "{opts.store.getState().programs}"
		service   = "{opts.services.venueService}">
	</venues>

	<downloads
		if                  = "{opts.store.getState().routes.path == 'DOWNLOADS'}"
		store               = "{opts.store}"
		state               = "{opts.store.getState().programs}"
		event-service       = "{opts.services.eventService}"
		participant-service = "{opts.services.participantService}">
	</downloads>

	<events
		if                  = "{opts.store.getState().routes.path == 'EVENTS'}"
		store               = "{opts.store}"
		state               = "{opts.store.getState().events}"
		service             = "{opts.services.eventService}"
		attendance-service  = "{opts.services.attendanceService}"
		program-service     = "{opts.services.programService}"
		venue-service       = "{opts.services.venueService}"
		participant-service = "{opts.services.participantService}"
		center-service      = "{opts.services.centerService}"
		setting-service     = "{opts.services.settingService}"
		user-service        = "{opts.services.userService}"
		countries           = "{opts.services.countries}">
	</events>

	<users
		if              = "{opts.store.getState().routes.path == 'USERS'}"
		store           = "{opts.store}"
		state           = "{opts.store.getState().users}"
		countries       = "{opts.services.countries}"
		service         = "{opts.services.userService}"
		center-service  = "{opts.services.centerService}"
		setting-service = "{opts.services.settingService}"
		user-roles      = "{opts.services.userRoles}">
	</users>

	<profile
		store        = "{opts.store}"
		user-service = "{opts.services.userService}">
	</profile>

	<center-selection
		store          = "{opts.store}"
		current-user   = "{currentUser}"
		center-service = "{opts.services.centerService}">
	</center-selection>

	<upload
		if                  = "{opts.store.getState().routes.path == 'UPLOADS'}"
		store               = "{opts.store}"
		participant-service = "{opts.services.participantService}">
	</upload>


	<script>

		this.route       = this.opts.store.getState().routes;
		this.currentUser = this.opts.store.getState().routes.data;

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

		showCenterSelection() {
			this.trigger('showCenterSelection');
		}

		this.on('showCenterSelection', () => {
			console.log('loading...');
			$("center-selection").modal({
				transition : 'vertical flip',
				closable   : false,
				onShow     : () => {
					if ($(".ui.dimmer.modals > center-selection").length > 1) {
						$(".ui.dimmer.modals > center-selection")[0].remove();
					}
				},
				onVisible  : () => {
					this.tags['center-selection'].trigger('loaded');
				}
			})
			.modal('show');
		});

		applySelectedCenter(center, make_default) {
			if (make_default) {
				this.opts.services.userService.setDefaultCenter(this.currentUser.id, {center_id: center.id}, (err, response) => {
					if (!err) {
						this.setActiveCenter(center);
					}
				});
			}
			else {
				this.setActiveCenter(center);
			}
		}

		setActiveCenter(center) {
			this.currentUser.center_id   = center.id;
			this.currentUser.center_code = center.code;

			sessionStorage.setItem('CURRENT_USER', JSON.stringify(this.currentUser));

			let route = this.opts.store.getState().routes;
			this.parent.navigatePage({
				type : route.path,
				data : this.currentUser
			});
			$("center-selection").modal('hide');
		}

		hideModal() {
			$("profile").modal('hide');
		}

	</script>


	<style scoped>
		:scope { font-size: 2em }
		h3 { color: #444 }
		ul { color: #999 }
	</style>
</pages>
