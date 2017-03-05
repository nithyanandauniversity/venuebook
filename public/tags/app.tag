<app>

	<login
		if      = "{opts.store.getState().routes.path == 'LOGIN'}"
		store   = "{opts.store}"
		service = "{opts.services.sessionService}">
	</login>

	<nav
		if      = "{opts.store.getState().routes.path != 'LOGIN'}"
		store   = "{opts.store}"
		heading = "TOF Tracker">
	</nav>

	<pages
		if       = {opts.store.getState().routes.path != 'LOGIN'}
		store    = {opts.store}
		state    = {opts.store.getState().participants}
		services = {opts.services}>
	</pages>

	<script>
		this.route = this.opts.store.getState().routes;

		console.log("sessionStorage");
		console.log(sessionStorage);

		authenticate() {

			this.opts.services.sessionService.authenticate((err, result) => {
				if (!err) {
					let data = result.data();
					console.log("data.status");
					console.log(data.status);
					console.log(sessionStorage.getItem('CURRENT_USER'));
					if (data.status) {
						this.navigatePage({
							type: 'PARTICIPANTS',
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
