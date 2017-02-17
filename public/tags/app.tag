<app class="ui container">


	<participants
		store={opts.store}
		state={opts.store.getState().participants}
		service={opts.services.participantService}
		countries={opts.services.countries}></participants>

	<script>

		// countries() {
		// 	return this.opts.services.countries();
		// }

		this.subtitle = 'Easy, right?';
		this.list = [
			{ name: 'my' },
			{ name: 'little' },
			{ name: 'list' }
		];
	</script>


	<style scoped>
		:scope { font-size: 2em }
		h3 { color: #444 }
		ul { color: #999 }
	</style>
</app>
