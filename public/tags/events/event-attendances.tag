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
				if   = "{
					( activeVenue == 'ALL' && ( date_index == 'ALL' || ( date_index != 'ALL' && attendance[format(parent.event_dates[date_index], 'date', 'isoDate')] ) ) ) ||
					( activeVenue != 'ALL' && ( (date_index == 'ALL' && attendance.attended_venues.includes(activeVenue)) || (date_index != 'ALL' && attendance[format(parent.event_dates[date_index], 'date', 'isoDate')] == activeVenue) ) )
				}">
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
		class = "ui fluid input huge right action left icon input"
		style = "position: absolute; bottom: 10px; left: 10px; right: 10px;"
		show  = "{parent.allowAttendance && activeVenue != 'ALL' && date_index != 'ALL'}">
		<input
			id          = "search-attendance"
			type        = "text"
			placeholder = "Search for participants and add to attendance..." />
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
						keyword : query
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

		this.currentUser  = this.parent.parent.opts.store.getState().routes.data;

		loadSearchInput() {
			$("#search-attendance").autocomplete({
				minChars : 2,
				lookup   : (query, done) => {

					let params = {
						page    : 1,
						limit   : 10,
						keyword : query
					}

					// if (this.opts.currentUser.role > 2) {
					// 	params.center_id = this.opts.currentUser.center_id;
					// }

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

					// console.log("params");
					// console.log(params);

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

				this.refs['payment_status_' + i].value = att.payment_status;
				this.refs['payment_method_' + i].value = att.payment_method;
				this.refs['amount_' + i].value         = att.amount;
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
