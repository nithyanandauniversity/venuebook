<venue-list>
	<div class="ui segment">
		<h2>Center Venue</h2>

		<div
			class = "ui list"
			show  = "{venues.length > 0}">
			<div
				class = "item"
				each  = "{venue in venues}">
				<div
					class = "right floated content"
					style = "cursor: pointer;">
					<i class="icon blue write" onclick="{editVenue()}"></i>
				</div>
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
			class = "ui red message"
			show  = "{venues.length == 0}">
			<h3>No Venues available!</h3>
		</div>
	</div>


	<script>

		this.venues = [];

		getData(res) {
			return res.data();
		}

		editVenue(e) {
			return(e) => {
				this.parent.editVenue(e.item.venue);
			}
		}

		loadVenuesList() {
			this.parent.opts.service.search({
				center_id : this.parent.currentUser.center_id,
				version   : Date.now()
			}, (err, response) => {
				if (!err) {
					this.venues = this.getData(response.body()[0])['venues'];
				}
				else {
					this.venues = [];
				}

				this.update();
			});
		}

		this.on('reload', () => {
			this.loadVenuesList();
		});

		this.loadVenuesList();

	</script>

</venue-list>

