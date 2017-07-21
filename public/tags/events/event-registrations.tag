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
		class = "ui fluid input huge right action left icon input"
		style = "position: absolute; bottom: 10px; left: 10px; right: 10px;"
		show  = "{parent.allowRegistration && activeVenue != 'ALL'}">
		<input
			id          = "search-registration"
			type        = "text"
			placeholder = "Search for participants and add to registrations..." />
		<i class="search icon"></i>
		<div
			class   = "ui brown basic button huge"
			style   = "margin-right: 1px;"
			onclick = "{ toggleExtSearch() }">
			<i class = "sitemap icon" style = "margin: 0;"></i>
		</div>
	</div>

	<div class="ui message info" if = "{ extSearchApply }">
		<h3>
			Extended search applied for
			<span if = "{ extSearchType && extSearchType == 'area' }">Area(s): {extSearchTypeValue.areas.join(', ')}</span>
			<span if = "{ extSearchType && extSearchType == 'country' }">Country(s): {extSearchTypeValue.countries.join(', ')}</span>
			<span if = "{ extSearchType && extSearchType == 'center' }">Center(s): <span each = "{extSearchTypeValue.centers}">{name}</span></span>
			<span if = "{ extSearchType && extSearchType == 'global' }">Global: (All Areas / Countries / Centers)</span>
			<div style="text-align: right;">
				<button class="ui button basic red" onclick = "{ clearExtSearch(); }">Clear</button>
			</div>
		</h3>
	</div>

	<div class="ui segment form" if = "{ showExtSearch && !extSearchApply }">
		<div class="ui two column grid">

			<div class="six wide column">
				<div class="field">
					<h3>Select Search Type</h3>
					<div class="ui fluid vertical pointing menu">
						<a
							each    = "{extSearchTypes}"
							onclick = "{ setExtSearchType() }"
							class   = "item {extSearchType == value && 'active brown'}">
							{label}
						</a>
					</div>
				</div>
			</div>

			<div class="ten wide column">
				<!-- SELECT AREAS IF SEARCH TYPE IS AREA -->
				<div class="field" show="{extSearchType && extSearchType == 'area'}">
					<h3>Select Areas :</h3>
					<div style = "margin-bottom: 1rem;">
						<div
							each  = "{ area in extSearchTypeValue.areas }"
							style = "margin-right: 8px;"
							class = "ui icon buttons">
							<button class = "ui button">
								{area}
							</button>
							<button
								class   = "ui icon button"
								onclick = "{ removeAreaFromList() }">
								<i class = "icon remove"></i>
							</button>
						</div>
					</div>
					<select
						onchange = "{ areaSelected() }"
						ref      = "search_area"
						class    = "ui search dropdown">
						<option value="">Select area to add...</option>
						<option
							each    = "{area in parent.parent.center_areas.obj}"
							value   = "{area}">
							{area}
						</option>
					</select>
				</div>

				<!-- SELECT COUNTRIES IF SEARCH TYPE IS COUNTRY -->
				<div class="field" show="{extSearchType && extSearchType == 'country'}">
					<h3>Select Countries :</h3>
					<div style = "margin-bottom: 1rem;">
						<div
							each  = "{ country in extSearchTypeValue.countries }"
							style = "margin-right: 8px;"
							class = "ui icon buttons">
							<button class = "ui button">
								{country}
							</button>
							<button
								class   = "ui icon button"
								onclick = "{ removeCountryFromList() }">
								<i class = "icon remove"></i>
							</button>
						</div>
					</div>
					<select
						onchange = "{ countrySelected() }"
						ref      = "search_country"
						class    = "ui search dropdown">
						<option value="">Select country to add...</option>
						<option
							each    = "{country in countries}"
							value   = "{country.value}">
							{country.value}
						</option>
					</select>
				</div>

				<!-- SELECT CENTERS IF SEARCH TYPE IS CENTER -->
				<div class="field" show="{extSearchType && extSearchType == 'center'}">
					<h3>Select Centers :</h3>
					<div style = "margin-bottom: 1rem;">
						<div
							each  = "{ center in extSearchTypeValue.centers }"
							style = "margin-right: 8px;"
							class = "ui icon buttons">
							<button class = "ui button">
								{ center.name }
							</button>
							<button
								class   = "ui icon button { activeRole == 3 && 'disabled' }"
								onclick = "{ removeCenterFromList() }">
								<i class = "icon remove"></i>
							</button>
						</div>
					</div>
					<div class="ui large input">
						<input
							type        = "text"
							id          = "form-search-center"
							placeholder = "Search for centers..." />
					</div>
				</div>

				<div class="field" show="{extSearchType && extSearchType == 'global'}">
					<h3>Search for participant globally across all Areas and Countries?</h3>
				</div>

				<div class="right aligned column" style="text-align: right;">
					<div
						show  = "{(extSearchType == 'area' && extSearchTypeValue.areas && extSearchTypeValue.areas.length > 0) || (extSearchType == 'country' && extSearchTypeValue.countries && extSearchTypeValue.countries.length > 0) || (extSearchType == 'center' && extSearchTypeValue.centers && extSearchTypeValue.centers.length > 0) || (extSearchType == 'global')}"
						class = "ui button basic green"
						onclick = "{ applyExtSearchSettings() }">
						Apply
					</div>
				</div>
			</div>

		</div>
	</div>

	<script>

		this.activeVenueName    = '';
		this.showExtSearch      = false;
		this.extSearchTypeValue = {};
		this.countries          = this.parent.parent.opts.countries();

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

		// Extended Search

		this.extSearchTypes = [
			{label: "Search by Area", value: "area"},
			{label: "Search by Country", value: "country"},
			{label: "Search by Center", value: "center"},
			{label: "Search Globally", value: "global"}
		];

		toggleExtSearch(e) {
			return(e) => {
				this.showExtSearch = !this.showExtSearch;
				if (this.showExtSearch) {
					setTimeout(() => {
						this.loadSearchInput();
						$(".ui.search.dropdown").dropdown({
							forceSelection  : false,
							selectOnKeydown : false
						});
					}, 50)
				}
			}
		}

		setExtSearchType(e) {
			return(e) => {
				this.extSearchType = e.item.value;
				this.update();
			}
		}

		areaSelected(e) {
			return(e) => {
				let selectedArea = this.refs['search_area'].value;
				if (this.extSearchTypeValue && this.extSearchTypeValue.areas && this.extSearchTypeValue.areas.length > 0) {
					if (!this.extSearchTypeValue.areas.includes(selectedArea)) {
						this.extSearchTypeValue.areas.push(selectedArea);
					}
				}
				else {
					this.extSearchTypeValue = {areas: [selectedArea]};
				}
			}
		}

		removeAreaFromList(e) {
			return(e) => {
				let idx = this.extSearchTypeValue.areas.indexOf(e.item.area);
				this.extSearchTypeValue.areas.splice(idx, 1);
			}
		}

		countrySelected(e) {
			return(e) => {
				let selectedCountry = this.refs['search_country'].value;
				if (this.extSearchTypeValue && this.extSearchTypeValue.countries && this.extSearchTypeValue.countries.length > 0) {
					if (!this.extSearchTypeValue.countries.includes(selectedCountry)) {
						this.extSearchTypeValue.countries.push(selectedCountry);
					}
				}
				else {
					this.extSearchTypeValue = {countries: [selectedCountry]};
				}
			}
		}

		removeCountryFromList(e) {
			return(e) => {
				let idx = this.extSearchTypeValue.countries.indexOf(e.item.country);
				this.extSearchTypeValue.countries.splice(idx, 1);
			}
		}

		centerSelected(center) {
			if (this.extSearchTypeValue && this.extSearchTypeValue.centers && this.extSearchTypeValue.centers.length > 0) {
				let ex = this.extSearchTypeValue.centers.filter((c) => {
					return c.id == center.id;
				});

				if (ex.length == 0) { this.extSearchTypeValue.centers.push(center); }
			}
			else {
				this.extSearchTypeValue = {centers: [center]};
			}

			this.update();
		}

		removeCenterFromList(e) {
			return(e) => {
				this.extSearchTypeValue.centers = this.extSearchTypeValue.centers.filter((center) => {
					return e.item.center.id != center.id;
				});
				this.loadSearchInput();
			}
		}

		applyExtSearchSettings(e) {
			return(e) => {
				if (this.extSearchType == 'global') { this.extSearchTypeValue = {global: true}; }

				console.log("Search Applied", this.extSearchTypeValue);
				this.extSearchApply = true;
				this.update();
				// this.setSearchParams();
				// this.parent.performSearch(1);
			}
		}

		clearExtSearch(e) {
			return(e) => {
				this.showExtSearch      = false;
				this.extSearchApply     = false;
				this.extSearchType      = null;
				this.extSearchTypeValue = {};
				this.update();
				// this.setSearchParams();
				// this.parent.performSearch(1);
			}
		}

		formatResults(center) {
			let attributes = [center.area, center.country, center.region, center.state, center.city].join(', ');
			let value      = center.name + ' - ' + center.category + ' [' + attributes + ']';

			return {value: value, data: center};
		}

		loadSearchInput() {
			$("#form-search-center").autocomplete({
				minChars : 2,
				lookup   : (query, done) => {

					let params = {
						page    : 1,
						limit   : 10,
						keyword : query,
						version : Date.now()
					}

					this.parent.parent.opts.centerService.search(params, (err, response) => {
						if (!err && response.body().length) {
							let result = response.body()[0].data();

							done({suggestions: result.centers.map(this.formatResults)});
						}
						else {
							done({suggestions: []});
						}
					});
				},
				onSelect : (item) => {
					$("#form-search-center")[0].value = '';
					this.centerSelected(item.data);
				}
			});
		}

		// End Extended Search

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
						keyword : query,
						version : Date.now()
					}

					if (this.currentUser) {
						params.center_code = this.currentUser.center_code;
					}

					if (
						this.extSearchType &&
						(this.extSearchTypeValue && (this.extSearchTypeValue.areas || this.extSearchTypeValue.countries || this.extSearchTypeValue.centers || this.extSearchTypeValue.global))
						)
					{
						console.log("coming here...");
						console.log(this.extSearchType, this.extSearchTypeValue);
						if (this.extSearchType == 'center') {
							params.ext_search = this.extSearchTypeValue.centers.map((center) => { return center.code; })
						}
						else {
							params.ext_search = this.extSearchTypeValue;
						}
					}
					else {
						params.ext_search = null;
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
					// $(".search.ui.dropdown").dropdown();
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

