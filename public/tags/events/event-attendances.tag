<event-attendances>

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

	<div
		class = "ui text menu"
		show  = "{event_dates && event_dates.length > 1}">
		<div class="header item">Event Dates : </div>
		<a
			each    = "{event_date, i in event_dates}"
			class   = "item ui horizontal large label {date_index == i ? 'brown' : 'grey'}"
			style   = "margin-right: 8px;"
			onclick = "{ selectEventDate() }">
			{format(event_date, 'date', 'longDate')}
		</a>
	</div>

	<h3
		class = "ui dividing header"
		if    = "{event_dates && event_dates.length > 0 && activeVenueName && date_index >= 0}">
		Attendance details on {format(event_dates[date_index], 'date', 'longDate')} at location: { activeVenueName }
	</h3>

	<table
		class = "ui green table"
		show  = "{parent.attendances && parent.attendances.length > 0}">
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
				each = "{attendance, i in parent.attendances}"
				if   = "{(activeVenue == 'ALL' || attendance.venue_id == activeVenue) && event_dates[date_index].toString() == new Date(attendance.attendance_date).toString()}">
				<td>{i + 1}</td>
				<td show = "{activeVenue == 'ALL'}">
					{attendance.venue.name}
				</td>
				<td>
					<span>
						<strong>
							{attendance.participant.first_name}
						</strong> {attendance.participant.last_name}
					</span>
				</td>
				<td>
					<button
						class   = "ui icon orange circular button"
						style   = "margin: 0;"
						onclick = "{ removeAttendance() }">
						<i class="icon remove"></i>
					</button>
				</td>
			</tr>
		</tbody>
	</table>

	<div
		class = "ui message red"
		show  = "{parent.attendances && parent.attendances.length == 0}">
		<h3>No Attendances !</h3>
	</div>

	<div
		class = "ui fluid input huge"
		style = "position: absolute; bottom: 10px; left: 10px; right: 10px;"
		show  = "{parent.allowAttendance && activeVenue != 'ALL'}">
		<input
			id          = "search-attendance"
			type        = "text"
			placeholder = "Search for participants and add to attendance..." />
	</div>

	<script>

		const self = this;

		this.activeVenueName = '';

		selectVenue(e) {
			return(e) => {
				this.activeVenue = e.item ? e.item.venue_id : 'ALL';
				this.setActiveVenueName();
			}
		}

		selectEventDate(e) {
			return(e) => {
				this.date_index = e.item.i;
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

		removeAttendance(e) {
			return(e) => {
				this.parent.removeAttendance(e.item.attendance.id);
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
			$("#search-attendance").autocomplete({
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

					self.opts.service.search(params, (err, response) => {
						if (!err && response.body().length) {
							let result = response.body()[0].data();

							done({suggestions: result.participants.map(self.formatResults)});
						}
						else {
							done({suggestions: []});
						}
					});
				},
				onSelect : (item) => {
					$("#search-attendance")[0].value = '';
					self.parent.addToAttendance(item.data, this.activeVenue, this.event_dates[this.date_index]);
				}
			});
		}

		loadDates() {
			let start_date = new Date(this.opts.event.start_date);
			let end_date   = new Date(this.opts.event.end_date);
			let diff       = (end_date - start_date) / 1000 / 60 / 60 / 24;

			this.event_dates = [start_date];

			if (diff > 0) {
				for (let i = 0; i < diff; i++) {
					this.event_dates.push( new Date(start_date.getTime() + (1000*60*60*24) * (i+1)) );
				}
			}
			this.date_index = 0;
		}

		this.on('loaded', () => {
			if (this.opts.venues && this.opts.venues.length) {
				this.activeVenue = this.opts.venues[0].venue_id;
				this.loadDates();
				this.setActiveVenueName();
				this.update();
			}
		});

		setTimeout( () => {
			this.loadSearchInput();
		}, 100);

	</script>

</event-attendances>
