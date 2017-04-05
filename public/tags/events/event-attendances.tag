<event-attendances>

	<div class="ui text menu">
		<div class="header item">Venue : </div>
		<a
			class   = "item ui horizontal large label {activeVenue == 'ALL' ? 'green' : 'grey'}"
			show    = "{opts.venues && opts.venues.length > 1}"
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
		show  = "{parent.event_dates && parent.event_dates.length > 1}">
		<div class="header item">Event Dates : </div>
		<a
			class   = "item ui horizontal large label {date_index == 'ALL' ? 'brown' : 'grey'}"
			style   = "margin-right: 8px;"
			onclick = "{ selectEventDate() }">
			ALL
		</a>
		<a
			each    = "{event_date, i in parent.event_dates}"
			class   = "item ui horizontal large label {parseInt(date_index) == i ? 'brown' : 'grey'}"
			style   = "margin-right: 8px;"
			onclick = "{ selectEventDate() }">
			{format(event_date, 'date', 'longDate')}
		</a>
	</div>

	<h3
		class = "ui dividing header"
		if    = "{parent.event_dates && parent.event_dates.length > 0 && activeVenueName && (date_index == 'ALL' || date_index >= 0)}">
		Attendance details on {format(parent.event_dates[date_index], 'date', 'longDate')} at location: { activeVenueName }
		<span style = "position: relative; float: right; bottom: 10px;">
			<button class = "ui green button tiny" onclick = "{ downloadAttendanceList() }">
				<i class = "icon download"></i> Download List
			</button>
		</span>
	</h3>

	<table
		class = "ui green table"
		show  = "{parent.attendances && parent.attendances.length > 0}">
		<thead>
			<tr>
				<th style="width: 100px;">#</th>
				<th show = "{activeVenue == 'ALL'}">Venue</th>
				<th>Full Name</th>
				<th>Payment</th>
				<th>Method</th>
				<th>Amount</th>
				<th show = "{date_index == 'ALL'}">Attendance %</th>
				<th style="width: 58px;"></th>
			</tr>
		</thead>
		<tbody>
			<tr
				each = "{attendance, i in parent.attendances}"
				if   = "{ ( activeVenue == 'ALL' || attendance.venue_id == activeVenue ) && ( date_index == 'ALL' || ( date_index != 'ALL' && attendance[format(parent.event_dates[date_index], 'date', 'isoDate')] ) ) }">
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
					<select
						class    = "search ui dropdown small"
						onchange = "{ attendanceChanged() }"
						ref      = "{'payment_status_' + i}">
						<option value="">Payment Status</option>
						<option each="{paymentStatusOptions}" value="{value}">
							{label}
						</option>
					</select>
				</td>
				<td>
					<select
						class    = "search ui dropdown small { !attendance.payment_status && 'disabled' }"
						onchange = "{ attendanceChanged() }"
						ref      = "{'payment_method_' + i}">
						<option value="">Payment Method</option>
						<option each="{paymentMethodOptions}" value="{value}">
							{label}
						</option>
					</select>
				</td>
				<td>
					<div
						onchange = "{ attendanceChanged() }"
						class    = "ui input small { !attendance.payment_status && 'disabled' }">
						<input ref="{'amount_' + i}" type="text" placeholder="Payment Amount" />
					</div>
				</td>
				<td show = "{date_index == 'ALL'}">
					{attendance.entry_percentage} %
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
		class = "ui fluid input huge success message"
		style = "position: absolute; bottom: 10px; left: 10px; right: 10px;"
		show  = "{parent.allowAttendance && activeVenue != 'ALL' && date_index != 'ALL'}">
		<input
			id          = "search-attendance"
			type        = "text"
			placeholder = "Search for participants and add to attendance..." />
	</div>

	<script>

		this.activeVenueName = '';

		this.registrationConfirmationOptions = [
			{ label : "Not Coming", value : 0 },
			{ label : "Tentative", value : 1 },
			{ label : "Confirmed", value : 2 },
			{ label : "To Be Confirmed", value : 3 },
		];

		this.paymentStatusOptions = [
			{ label : "Full Paid", value : 2 },
			{ label : "Partial", value : 1 },
			{ label : "Not Paid", value : 0 }
		];

		this.paymentMethodOptions = [
			{ label : "Cash", value : 0 },
			{ label : "Cheque", value : 1 },
			{ label : "Bank", value : 2 },
			{ label : "Online", value : 3 },
			{ label : "Coupon", value : 4 }
		];

		selectVenue(e) {
			return(e) => {
				this.activeVenue = e.item ? e.item.venue_id : 'ALL';
				this.setActiveVenueName();
				this.update();
				this.setAttValues();
			}
		}

		selectEventDate(e) {
			return(e) => {
				this.date_index = e.item ? e.item.i : 'ALL';
				this.update();
				this.setAttValues();
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

		getAttendanceParams(att, i, param = {}) {

			if (att.payment_status >= 0 && att.payment_status != this.refs['payment_status_' + i].value) {
				param.payment_status = this.refs['payment_status_' + i].value;
			}

			if (this.refs['payment_method_' + i].value && att.payment_method != parseInt(this.refs['payment_method_' + i].value)) {
				param.payment_method = this.refs['payment_method_' + i].value;
			}

			if (this.refs['amount_' + i].value && att.amount != this.refs['amount_' + i].value) {
				param.amount = this.refs['amount_' + i].value;
			}

			return param;
		}

		attendanceChanged(e) {
			return(e) => {
				let unsubscribe;

				if (unsubscribe) {
					clearTimeout(unsubscribe);
				}

				unsubscribe = setTimeout( () => {
					let params = this.getAttendanceParams(e.item.attendance, e.item.i);

					this.parent.updateAttendance(e.item.attendance.id, params);
				}, 500);
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
					$("#search-attendance")[0].value = '';
					this.parent.addToAttendance(item.data, this.activeVenue, this.parent.event_dates[this.date_index]);
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
					this.event_dates.push(new Date(start_date.getTime() + (1000 * 60 * 60 * 24) * (i + 1)));
				}
			}
		}

		setAttValues() {

			let attendances = this.parent.attendances.filter((attendance) => {
				return (attendance.venue_id == this.activeVenue && (this.date_index == 'ALL' || new Date(attendance.attendance_date).toString() == this.parent.event_dates[this.date_index].toString()));
			});

			for (let i = 0; i < attendances.length; i++) {
				let att = attendances[i];

				this.refs['payment_status_' + i].value      = att.payment_status;
				this.refs['payment_method_' + i].value      = att.payment_method;
				this.refs['amount_' + i].value              = att.amount;
			}

			// $(".search.ui.dropdown").dropdown();
		}

		downloadAttendanceList(e) {
			return(e) => {
				let activeVenue = this.activeVenue == 'ALL' ? null : this.activeVenue;
				let date_index  = this.date_index == 'ALL' ? null : this.date_index;

				this.parent.requestReport(activeVenue, date_index);
			}
		}

		this.on('loaded', () => {
			if (this.opts.venues && this.opts.venues.length) {

				if (this.activeVenue == undefined) {
					this.activeVenue = this.opts.venues[0].venue_id;
				}

				if (this.date_index == undefined) {
					this.date_index  = 0;
				}

				this.loadDates();
				this.setActiveVenueName();
				this.update();

				setTimeout( () => {
					this.setAttValues();
				}, 20);
			}
		});

		setTimeout( () => {
			this.loadSearchInput();
		}, 100);

	</script>

</event-attendances>
