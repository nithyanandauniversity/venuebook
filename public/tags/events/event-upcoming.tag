<event-upcoming>

	<div
		class = "ui message red"
		show  = "{upcoming.length == 0}">
		<h3>No Upcoming Events !</h3>
	</div>

	<script>

		this.upcoming = [];

		loadUpcoming() {
			this.parent.opts.service.getUpcoming((err, response) => {
				if (!err) {
					this.upcoming = response.body().data();
				}
				else {
					this.upcoming = [];
				}

				this.update();
			});
		}

		this.loadUpcoming();

		this.on('reload', () => {
			this.loadUpcoming();
		});

	</script>
</event-upcoming>