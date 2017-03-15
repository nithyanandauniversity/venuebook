<event-view
	class = "ui container"
	style = "margin: 25px 0;">

	<div class="ui">

		<div class="ui two column centered grid">

			<div class="nine wide column">
				<h3 class="ui dividing header">
					<i class="icon browser"></i> Event Details
				</h3>
				<div class="ui">
					<div class="ui fluid card">
						<div class="content">
							<div
								class = "header"
								style = "font-size: 1em; margin-bottom: .2em;">
								{program.program_name}
							</div>
							<div
								class = "meta"
								style = "font-size: 0.8em;">
								{program.program_type}
							</div>
							<div
								class = "ui sub header green"
								show  = "{event.name && event.name != ''}">
								{event.name}
							</div>
							<div class="description">
								<h5>
									{format(event.start_date, 'date', 'fullDate')}
									<span show = "{event.end_date}"> - {format(event.end_date, 'date', 'fullDate')}</span>
								</h5>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div class="seven wide column">
				<h3 class="ui dividing header">
					<i class="icon map outline"></i> Event Venues and Coordinators
				</h3>
				<div class="ui segment">
					<div class="ui middle aligned celled list">
						<div
							each = "{venues}"
							class = "item">
							<div
								class = "right floated content"
								style = "position: absolute; top: 40%; right: 10px;">
								<div class="ui violet horizontal label">{user.first_name}</div>
							</div>
							<div class="content">
								<div class="header">
									{venue.name}
								</div>
								<div class="meta">
									<span>{venue.address.street}, {venue.address.city}. {venue.address.postal_code}</span><br />
									<span>{venue.address.country}</span>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>

		</div>

	</div>

	<script>

		this.event   = {};
		this.program = {};
		this.venues  = [];
		this.view_id = this.opts.state.id;

		if (this.view_id) {
			this.parent.opts.service.get(this.view_id, (err, response) => {
				if (!err) {
					let data = response.body().data();
					this.event   = data.event;
					this.program = data.program;
					this.venues  = data.event_venues;
					this.update();
				}
				else {
					this.event   = null;
					this.program = null;
					this.venues  = [];
				}
			});
		}

	</script>

</event-view>