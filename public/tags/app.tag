<app>

	<login
		if      = "{opts.store.getState().routes.path == 'LOGIN'}"
		store   = "{opts.store}"
		service = "{opts.services.sessionService}">
	</login>

	<nav
		if      = "{opts.store.getState().routes.path != 'LOGIN'}"
		store   = "{opts.store}"
		heading = "Global ToF">
	</nav>

	<pages
		if       = {opts.store.getState().routes.path != 'LOGIN'}
		store    = {opts.store}
		state    = {opts.store.getState().participants}
		services = {opts.services}>
	</pages>

	<script>
		this.route       = this.opts.store.getState().routes;
		this.currentUser = this.opts.store.getState().routes.data;

		console.log("sessionStorage");
		console.log(sessionStorage);

		triggerProfile() {
			this.tags['pages'].trigger('showProfile');
		}

		switchCenter() {
			this.tags['pages'].trigger('showCenterSelection');
		}

		authenticate() {

			this.opts.services.sessionService.authenticate((err, result) => {
				if (!err) {
					if (result.data().status && sessionStorage.getItem('CURRENT_USER')) {
						this.navigatePage({
							type: 'DASHBOARD',
							data: JSON.parse(sessionStorage.getItem('CURRENT_USER'))
						});
					}
					else {
						this.navigatePage({
							type : 'LOGIN',
							data : null
						});
					}
				}
				else {
					this.navigatePage({
						type : 'LOGIN',
						data : null
					});
				}
			});
		}

		navigatePage(params) {
			this.opts.store.dispatch(params);
			this.update();
		}

		this.authenticate();
	</script>

</app>
