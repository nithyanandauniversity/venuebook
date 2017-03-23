<event-registrations>

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

	<table
		class = "ui orange table"
		show  = "{parent.registrations && parent.registrations.length > 0}">
		<thead>
			<tr>
				<th style="width: 100px;">#</th>
				<th show = "{activeVenue == 'ALL'}">Venue</th>
				<th>Full Name</th>
				<th>Confirmation</th>
				<th>Payment</th>
				<th>Method</th>
				<th>Amount</th>
				<th style="width: 58px;"></th>
			</tr>
		</thead>
		<tbody>
			<tr
				each  = "{registration, i in parent.registrations}"
				class = "{registration.attendance > 1 && 'success'}"
				if    = "{activeVenue == 'ALL' || registration.venue_id == activeVenue}">
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
					<select
						class    = "search ui dropdown small {registration.attendance == 2 && 'disabled'}"
						onchange = "{ registryChanged() }"
						ref      = "{'confirmation_status_' + i}">
						<option value="">Confirmation Status</option>
						<option each="{registrationConfirmationOptions}" value="{value}">
							{label}
						</option>
					</select>
				</td>
				<td>
					<select
						class    = "search ui dropdown small {registration.attendance == 2 && 'disabled'}"
						onchange = "{ registryChanged() }"
						ref      = "{'payment_status_' + i}">
						<option value="">Payment Status</option>
						<option each="{paymentStatusOptions}" value="{value}">
							{label}
						</option>
					</select>
				</td>
				<td>
					<select
						class    = "search ui dropdown small { (!registration.payment_status || registration.attendance == 2) && 'disabled' }"
						onchange = "{ registryChanged() }"
						ref      = "{'payment_method_' + i}">
						<option value="">Payment Method</option>
						<option each="{paymentMethodOptions}" value="{value}">
							{label}
						</option>
					</select>
				</td>
				<td>
					<div
						onchange = "{ registryChanged() }"
						class    = "ui input small { (!registration.payment_status || registration.attendance == 2) && 'disabled' }">
						<input ref="{'amount_' + i}" type="text" placeholder="Payment Amount" />
					</div>
				</td>
				<td>
					<div show = "{ parent.allowAttendance }">
						<div
							class = "ui compact menu small olive buttons"
							show  = "{ parent.event_dates && parent.event_dates.length > 1 }">
							<div
								class = "ui simple dropdown item olive button {registration.attended_dates && parent.event_dates.length == registration.attended_dates.length && 'disabled'}"
								style = "color: rgba(0,0,0,.6);">
								<i class="icon checkmark box"></i> Add
								<i class="dropdown icon"></i>
								<div class="menu">
									<div
										each        = "{event_date in parent.event_dates}"
										data-member = "{registration.participant.member_id}"
										if          = "{registration.attended_dates && !registration.attended_dates.includes(format(event_date, 'date', 'isoDate').toString())}"
										data-venue  = "{registration.venue_id}"
										onclick     = "{ addRegToAttendance() }"
										class       = "item">
										{format(event_date, 'date', 'longDate')}
									</div>
								</div>
							</div>
						</div>
						<button
							class   = "ui icon olive button small { registration.attendance == 2 && 'disabled' }"
							style   = "color: rgba(0,0,0,.6);"
							onclick = "{ addRegToAttendance() }"
							show    = "{ parent.event_dates && parent.event_dates.length == 1 }">
							<i class="icon checkmark box"></i> Add
						</button>
					</div>
					<button
						class   = "ui icon orange circular button"
						style   = "margin: 0;"
						show    = "{ !parent.allowAttendance }"
						onclick = "{ removeRegistration() }">
						<i class="icon remove"></i>
					</button>
				</td>
			</tr>
		</tbody>
	</table>

	<div
		class = "ui message red"
		show  = "{ parent.registrations && parent.registrations.length == 0 }">
		<h3>No Registrations !</h3>
	</div>

	<div
		class = "ui fluid input huge warning message"
		style = "position: absolute; bottom: 10px; left: 10px; right: 10px;"
		show  = "{parent.allowRegistration && activeVenue != 'ALL'}">
		<input
			id          = "search-registration"
			type        = "text"
			placeholder = "Search for participants and add to registrations..." />
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

		getRegistryParams(reg, i, param = {}) {

			if (reg.confirmation_status >= 0 && reg.confirmation_status.toString() != this.refs['confirmation_status_' + i].value) {
				param.confirmation_status = this.refs['confirmation_status_' + i].value;
			}

			if (reg.payment_status >= 0 && reg.payment_status.toString() != this.refs['payment_status_' + i].value) {
				param.payment_status = this.refs['payment_status_' + i].value;
			}

			if (this.refs['payment_method_' + i].value && reg.payment_method != parseInt(this.refs['payment_method_' + i].value)) {
				param.payment_method = this.refs['payment_method_' + i].value;
			}

			if (this.refs['amount_' + i].value && reg.amount != this.refs['amount_' + i].value) {
				param.amount = this.refs['amount_' + i].value;
			}

			return param;
		}

		registryChanged(e) {
			return(e) => {
				let unsubscribe;

				if (unsubscribe) {
					clearTimeout(unsubscribe);
				}

				unsubscribe = setTimeout( () => {
					let params = this.getRegistryParams(e.item.registration, e.item.i);

					this.parent.updateRegistration(e.item.registration.id, params);
				}, 500);
			}
		}

		addRegToAttendance(e) {
			return(e) => {
				if (this.parent.event_dates.length > 1) {
					// Multiple dates. Get date clicked
					let dataset = e.target.dataset;

					this.parent.addToAttendance({member_id: dataset.member}, dataset.venue, e.item.event_date);
				}
				else {
					let reg        = e.item.registration;
					let event_date = new Date(this.parent.event.start_date);

					this.parent.addToAttendance({member_id: reg.participant.member_id}, reg.venue_id, event_date);
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

		setRegValues() {
			for (let i = 0; i < this.parent.registrations.length; i++) {
				let reg = this.parent.registrations[i];

				this.refs['confirmation_status_' + i].value = reg.confirmation_status;
				this.refs['payment_status_' + i].value      = reg.payment_status;
				this.refs['payment_method_' + i].value      = reg.payment_method;
				this.refs['amount_' + i].value              = reg.amount;
			}
		}

		this.on('loaded', () => {
			if (this.opts.venues && this.opts.venues.length) {
				this.activeVenue = this.opts.venues[0].venue_id;

				this.allowAttendance   = this.parent.allowAttendance;
				this.allowRegistration = this.parent.allowRegistration;
				this.event_dates       = this.parent.event_dates;

				this.setActiveVenueName();
				this.update();

				setTimeout( () => {
					this.setRegValues();
					$(".search.ui.dropdown").dropdown();
				}, 20);
			}
		});

		// this.on('update', () => {
		// });

		setTimeout( () => {
			this.loadSearchInput();
		}, 100);

	</script>

</event-registrations>

