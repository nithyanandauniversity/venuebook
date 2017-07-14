<center-view
	class = "ui container"
	style = "margin: 25px 0;">

	<div class="ui">
		<div class="row" style="margin-bottom: 25px;">
			<h2>
				<span>
					View Center [{center.code}]
				</span>
				<div class="ui green basic button right floated" onclick = { edit }>
					<i class="write left icon"></i> Edit
				</div>
				<div class="ui primary basic button right floated" onclick = { parent.showList }>
					<i class="chevron left icon"></i> Back
				</div>
			</h2>
		</div>


		<div class="ui two column centered grid">

			<div class="eight wide column">
				<div class="ui fluid card">
					<div class="content">
						<div
							class = "header"
							style = "font-size: 1em; margin-bottom: .2em;">
							{center.name}
						</div>
						<div
							class = "meta"
							style = "font-size: 0.8em;">
							{center.category}
						</div>
						<div
							class = "description"
							style = "font-size: 0.9em; margin-top: 1em;">
							<label>
								<strong>Area: </strong> {center.area}
							</label><br /><br />
							<label>
								<strong>Region: </strong> {center.region}
							</label><br /><br />
							<label>
								<strong>City, State: </strong> {center.city}, {center.state}
							</label><br /><br />
							<label>
								<strong>Country: </strong> {center.country}
							</label>
						</div>
					</div>
				</div>

				<div class="ui segment">
					<h3>
						<i class="icon user"></i> Admin
					</h3>

					<label>
						<strong>{admin.first_name}</strong> {admin.last_name}
					</label><br />
					<span>{admin.email}</span>
				</div>
			</div>

			<div class="eight wide column">
				<div class="ui segment">
					<h3>
						<i class="icon map outline"></i> Venues
					</h3>

					<div
						class = "ui list"
						show  = "{venues.length > 0}">
						<div
							class = "item"
							each  = "{venue in venues}">
							<i class = "icon map pin"></i>
							<div class="content" style="width: 100%;">
								<div class="header">{venue.name}</div>
								<div class="description">
									<span>{venue.address.street}, {venue.address.city}</span><br />
									<span show="{venue.address.state != ''}">{venue.address.state},</span>
									<span show="{venue.address.postal_code != ''}">{venue.address.postal_code}.</span>
									<span show="{venue.address.country}"><strong>{venue.address.country}.</strong></span>
								</div>
							</div>
						</div>
					</div>

					<div
						class = "ui message red"
						show  = "{venues.length == 0}">
						No Venues Available
					</div>
				</div>
			</div>

		</div>
	</div>


	<script>

		edit() {
			this.parent.showForm({id: this.opts.state.id});
		}

		this.center = {};
		this.admin  = {};
		this.venues = [];

		this.view_id = this.opts.state.id;
		console.log("this.view_id");
		console.log(this.view_id);
		this.parent.opts.service.get(this.view_id, (err, response) => {
			if (!err) {
				let result  = response.body().data();
				this.center = result.center;
				this.admin  = result.admin;
				this.venues = result.venues;
				console.log("this.center");
				console.log(this.center, this.admin, this.venues);
				this.update();
			}
			else {
				this.participant = null;
			}
		});
		// this.on('view', () => {
		// });

	</script>
</center-view>

