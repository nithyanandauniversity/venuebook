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
		if = "{opts.store.getState().routes.path == 'PROGRAMS'}">
	</programs>

	<events
		if = "{opts.store.getState().routes.path == 'EVENTS'}">
	</events>

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