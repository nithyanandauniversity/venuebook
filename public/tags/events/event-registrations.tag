<event-registrations>

	<div class="ui text menu">
		<div class="header item">Venue : </div>
		<a
			class   = "item ui horizontal large label {activeVenue == 'ALL' ? 'green' : 'grey'}"
			show    = "opts.venues && opts.venues.length > 1"
			style   = "margin-right: 8px;"
			onclick = "{ selectVenue() }">
			ALL
		</a>
		<a
			each    = "{opts.venues}"
			class   = "item ui horizontal large label {activeVenue == venue_id ? 'violet' : 'grey'}"
			style   = "margin-right: 8px;"
			onclick = "{ selectVenue() }">
			{venue.name}
		</a>
	</div>

	<table
		class = "ui orange table"
		show  = "{parent.registrations && parent.registrations.length > 0}">
		<thead>
			<tr>
				<th style="width: 100px;">#</th>
				<th show = "{activeVenue == 'ALL'}">Venue</th>
				<th>Full Name</th>
				<th style="width: 58px;"></th>
			</tr>
		</thead>
		<tbody>
			<tr
				each = "{registration, i in parent.registrations}"
				if   = "{activeVenue == 'ALL' || registration.venue_id == activeVenue}">
				<td>{i + 1}</td>
				<td show = "{activeVenue == 'ALL'}">
					{registration.venue.name}
				</td>
				<td>
					<span>
						<strong>
							{registration.participant.first_name}
						</strong> {registration.participant.last_name}
					</span>
				</td>
				<td>
					<button
						class   = "ui icon orange circular button"
						style   = "margin: 0;"
						onclick = "{ removeRegistration() }">
						<i class="icon remove"></i>
					</button>
				</td>
			</tr>
		</tbody>
	</table>

	<div
		class = "ui message red"
		show  = "{parent.registrations && parent.registrations.length == 0}">
		<h3>No Registrations !</h3>
	</div>

	<div
		class = "ui fluid input huge"
		style = "position: absolute; bottom: 10px; left: 10px; right: 10px;"
		show  = "{parent.allowRegistration && activeVenue != 'ALL'}">
		<input
			id          = "search-registration"
			type        = "text"
			placeholder = "Search for participants and add to registrations..." />
	</div>

	<script>

		this.activeVenueName = '';

		selectVenue(e) {
			return(e) => {
				this.activeVenue = e.item ? e.item.venue_id : 'ALL';
				this.setActiveVenueName();
			}
		}

		setActiveVenueName() {
			this.activeVenueName = '';

			if (this.activeVenue) {
				if (this.activeVenue == "ALL") {
					this.activeVenueName = "ALL";
				}
				else {
					let venue = this.opts.venues.filter((v) => {
						return (v.venue_id == this.activeVenue);
					})[0];

					if (venue) {
						this.activeVenueName = venue.venue.name;
					}
				}
			}
		}

		removeRegistration(e) {
			return(e) => {
				this.parent.removeRegistration(e.item.registration.id);
			}
		}

		formatResults(participant) {
			let value = participant.first_name + ' ' + participant.last_name;

			if (participant.other_names && participant.other_names != '') {
				value = value.trim() + ' (' + participant.other_names + ')';
			}

			if (participant.email && participant.email != '') {
				value = value.trim() + ' [' + participant.email + ']';
			}

			return {value: value.trim(), data: participant};
		}


		loadSearchInput() {
			$("#search-registration").autocomplete({
				minChars : 2,
				lookup   : (query, done) => {

					let params = {
						page    : 1,
						limit   : 10,
						keyword : query
					}

					if (this.opts.currentUser.role > 2) {
						params.center_id = this.opts.currentUser.center_id;
					}

					this.opts.service.search(params, (err, response) => {
						if (!err && response.body().length) {
							let result = response.body()[0].data();

							done({suggestions: result.participants.map(this.formatResults)});
						}
						else {
							done({suggestions: []});
						}
					});
				},
				onSelect : (item) => {
					$("#search-registration")[0].value = '';
					this.parent.addToRegistration(item.data, this.activeVenue);
				}
			});
		}


		this.on('loaded', () => {
			if (this.opts.venues && this.opts.venues.length) {
				this.activeVenue = this.opts.venues[0].venue_id;
				this.setActiveVenueName();
				console.log("this.parent.registrations");
				console.log(this.parent.registrations);
				this.update();
			}
		});

		setTimeout( () => {
			this.loadSearchInput();
		}, 100);

	</script>

</event-registrations>

