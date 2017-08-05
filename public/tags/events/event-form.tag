<event-form>

	<div class="ui">
		<div class="row" style="margin-bottom: 25px;">
			<h2>
				<span>
					{opts.state.view == 'ADD_EVENT' ? 'Create New' : 'Edit'} Event {opts.state.view == 'EDIT_EVENT' && event && ' [' + event.id + ']'}
				</span>
			</h2>
		</div>

		<div class="ui form">
			<div class="ui grid">
				<div class="eight wide column">

					<h4 class="ui dividing header">
						<i class="icon browser"></i> Event Details
					</h4>

					<div class="two wide fields">
						<div class="field">
							<label>Event Name</label>
							<input type="text" ref="name" placeholder="Event Name (optional)" />
						</div>
						<div class="field {validation && validation.emptyProgram && 'error'}">
							<label>Program Name</label>
							<select
								show  = "{programGroups.length > 0}"
								ref   = "program_id"
								class = "ui search dropdown">
								<option value="">Select Program</option>
								<optgroup each="{group in programGroups}" label="{group.header}">
									<option
										value = "{program.id}"
										each  = "{program in group.programs}">
										{program.program_name}
									</option>
								</optgroup>
							</select>
						</div>
					</div>

					<div class="three wide fields">
						<div class="field {validation && validation.emptyDate && 'error'}">
							<label>Start Date</label>
							<div class="ui calendar" id="event-start-date">
								<div class="ui input left icon">
									<i class="calendar icon"></i>
									<input
										type        = "text"
										ref         = "start_date"
										readonly    = ""
										placeholder ="Start Date" />
								</div>
							</div>
						</div>
						<div class="field">
							<label>End Date</label>
							<div class="ui calendar" id="event-end-date">
								<div class="ui input left icon">
									<i class="calendar icon"></i>
									<input
										type        = "text"
										ref         = "end_date"
										readonly    = ""
										placeholder ="End Date" />
								</div>
							</div>
						</div>
						<div class="field">
							<label>Program Donation</label>
							<input type="text" ref="program_donation" placeholder="Program Donation" />
						</div>
					</div>

					<div class="field">
						<label>Notes</label>
						<textarea ref="notes" cols="30" rows="3"></textarea>
					</div>

				</div>

				<div class="eight wide column">

					<h4 class="ui dividing header">
						<i class="icon map outline"></i> Venue Details
					</h4>

					<table class="ui violet table">
						<thead>
							<tr>
								<th>Venue</th>
								<th>Coordinator / Acharya</th>
								<th></th>
							</tr>
						</thead>
						<tbody>
							<tr each = "{event_venue, i in venues}">
								<td>
									<select
										ref      = "{'venue_id_' + i}"
										class    = "ui search event_venue dropdown"
										onchange = "{ venueChanged() }">
										<option value="">Select Venue...</option>
										<option
											each  = "{venue in allVenues}"
											value = "{venue.id}">
											{venue.name}
										</option>
									</select>
								</td>
								<td>
									<select
										ref      = "{'user_id_' + i}"
										class    = "ui search event_venue dropdown"
										onchange = "{ userChanged() }">
										<option value = "">Select Coordinator / Acharya</option>
										<option
											each  = "{user in allCoordinators}"
											value = "{user.id}">
											{user.first_name} {user.last_name}
										</option>
									</select>
								</td>
								<td>
									<button
										class          = "circular mini ui icon orange button"
										show           = "{i > 0}"
										data-tooltip   = "Remove Event Venue"
										data-inverted  = ""
										data-variation = "mini"
										onclick        = "{ removeEventVenue() }">
										<i class="remove icon"></i>
									</button>
								</td>
							</tr>
						</tbody>
					</table>

					<div class="ui column">
						<div style="text-align: center;">
							<span
								show  = "{validation && validation.emptyVenues}"
								class = "ui pointing red basic label">
								Minimum 1 Venue is mandatory for an Event
							</span>
						</div>
						<div style="text-align: right;">
							<button
								class = "ui basic primary icon button"
								onclick = "{ addEventVenue() }">
								<i class="icon add"></i> Add Venue
							</button>
						</div>
					</div>
				</div>
			</div>

			<div class="ui divider"></div>

			<div class="ui right aligned grid">
				<div class="column">
					<button class="ui large green button {savingEvent && 'disabled'}" onclick = "{ save }">
						SAVE
					</button>
					<button class="ui large red button" onclick = "{ cancel }">
						{opts.state.view == 'ADD_EVENT' ? 'RESET' : 'CANCEL'}
					</button>
				</div>
			</div>

		</div>
	</div>

	<script>

		this.programs      = [];
		this.programGroups = [];

		this.venues        = [];
		this.allVenues     = [];

		this.currentUser = this.parent.opts.store.getState().routes.data;

		getData(res) {
			return res.data();
		}

		venueChanged(e) {
			return(e) => {
				this.updateEventVenue(e.item);
				this.checkDupVenue(this.venues[e.item.i].venue_id);
			}
		}

		userChanged(e) {
			return(e) => {
				this.updateEventVenue(e.item);
				this.checkDupUser(this.venues[e.item.i].user_id);
			}
		}

		updateEventVenue(item) {
			let itm = this.venues[item.i];
			itm.venue_id = this.refs['venue_id_' + item.i].value;
			itm.user_id  = this.refs['user_id_' + item.i].value;
		}

		checkDupVenue(venue_id) {
			let ex = this.venues.reduce((a, e, i) => {
				if (e.venue_id == venue_id) { a.push(i); }
				return a;
			}, []);

			if (ex.length > 1) {
				this.refs['venue_id_' + ex[1]].value = '';
				this.updateEventVenue({i: ex[1]});
				this.venues.splice(ex[1], 1);
				this.update();
			}
		}

		checkDupUser(user_id) {
			let ex = this.venues.reduce((a, e, i) => {
				if (e.user_id == user_id) { a.push(i); }
				return a;
			}, []);

			if (ex.length > 1) {
				this.refs['user_id_' + ex[1]].value = '';
				this.updateEventVenue({i: ex[1]});
				this.venues.splice(ex[1], 1);
				this.update();
			}
		}

		addEventVenue(e) {
			return(e) => {
				this.insertVenue();
				setTimeout(() => {
					$(".ui.search.event_venue.dropdown").dropdown();
				}, 10);
			}
		}

		removeEventVenue(e) {
			return(e) => {
				let venue = this.venues[e.item.i];

				if (!venue.id) {
					this.venues.splice(e.item.i, 1);
				}
				else {
					console.log("REMOVE EVENT VENUE");
				}
			}
		}

		insertVenue(venue_id = null, user_id = null) {
			this.venues.push({
				venue_id : venue_id,
				user_id  : user_id
			});
		}

		generateEventParams() {
			return {
				event  : {
					name             : this.refs.name.value,
					program_id       : this.refs.program_id.value,
					start_date       : this.refs.start_date.value,
					end_date         : this.refs.end_date.value,
					program_donation : this.refs.program_donation.value,
					notes            : this.refs.notes.value,
					center_id        : this.currentUser.center_id
				},
				venues : this.venues.reduce((data, record, i) => {
					let venue = {
						venue_id : this.refs['venue_id_' + i].value,
						user_id  : this.refs['user_id_' + i].value
					};

					if (venue.venue_id != '' && venue.user_id != '') {
						data.push(venue);
					}

					return data;
				}, [])
			}
		}

		validateForm(params) {
			this.validation = {};

			if (!params.event.program_id || params.event.program_id == "") {
				this.validation.emptyProgram = true;
			}

			if (!params.event.start_date || params.event.start_date == "") {
				this.validation.emptyDate = true;
			}

			if (!params.venues || params.venues.length == 0) {
				this.validation.emptyVenues = true;
			}

			return !this.validation.emptyProgram
				&& !this.validation.emptyDate
				&& !this.validation.emptyVenues;
		}

		save() {
			if (this.savingEvent) {
				return false;
			}

			let saveParams = this.generateEventParams();
			this.errors = this.validateForm(saveParams);

			if (!this.validateForm(saveParams)) {
				return false;
			}

			this.savingEvent = true;
			this.update();

			if (!this.edit_id) {
				// CREATE EVENT
				this.create(saveParams);
			}
			else {
				// EDIT EVENT
				this.edit(saveParams);
			}
		}

		create(data) {
			this.parent.opts.service.create(data, (err, response) => {
				this.savingEvent = false;
				if (!err) {
					this.parent.showUpcoming();
				}
				else {
					this.update();
				}
			});
		}

		edit(data) {
			this.parent.opts.service.update(this.edit_id, data, (err, response) => {
				this.savingEvent = false;
				if (!err) {
					this.parent.goPrev();
				}
				else {
					this.update();
				}
			});
		}

		reset() {
			this.venues = [];

			this.refs.name.value             = ''
			this.refs.program_id.value       = ''
			this.refs.start_date.value       = ''
			this.refs.end_date.value         = ''
			this.refs.program_donation.value = ''
			this.refs.notes.value            = ''

			this.insertVenue();
			this.update();

			$(".ui.search.event_venue.dropdown").dropdown();
		}

		cancel() {
			if (this.opts.state.view == 'ADD_EVENT') {
				this.reset();
			}
			else {
				this.parent.goPrev();
			}
		}

		generateProgramListByGroup() {
			let groups = {};
			for (let i = 0; i < this.programs.length; i++) {
				let program = this.programs[i];
				if (!groups[program.program_type]) {
					groups[program.program_type] = [];
				}

				groups[program.program_type].push(program);
			}

			this.programGroups = [];
			for (let itm in groups) {
				this.programGroups.push({header: itm, programs: groups[itm]});
			}
		}

		loadPrograms() {
			this.parent.opts.programService.search({version : Date.now()}, (err, response) => {
				if (!err) {
					this.programs = this.getData(response.body()[0])['programs'];
					this.generateProgramListByGroup();
				}
				else {
					this.programs = [];
				}

				this.update();
			});
		}

		loadVenues() {
			this.parent.opts.venueService.search({
				center_id : this.currentUser.center_id,
				version   : Date.now()
			}, (err, response) => {
				if (!err) {
					this.allVenues = this.getData(response.body()[0])['venues'];
				}
				else {
					this.allVenues = [];
				}

				this.update();
			});
		}

		loadCoordinators() {
			this.parent.opts.userService.find({
				search_coordinators : true,
				center_id           : this.currentUser.center_id,
				version             : Date.now()
			}, (err, response) => {
				if (!err) {
					this.allCoordinators = this.getData(response.body()[0])['users'];
				}
				else {
					this.allCoordinators = [];
				}

				this.update();
			});
		}

		this.loadPrograms();
		this.loadVenues();
		this.loadCoordinators();

		this.edit_id = this.opts.state.id;

		loadEditForm(event, venues) {
			// console.log("event, venues");
			// console.log(event, venues);

			this.refs.name.value             = event.name;
			this.refs.program_id.value       = event.program_id;
			this.refs.start_date.value       = event.start_date;
			this.refs.end_date.value         = event.end_date;
			this.refs.program_donation.value = event.program_donation;
			this.refs.notes.value            = event.notes;

			$("#event-start-date").calendar({
				type        : 'date',
				initialDate : event.start_date
			});

			$("#event-end-date").calendar({
				type        : 'date',
				initialDate : event.end_date
			});

			venues.forEach((v) => { this.insertVenue(v.venue_id, v.user_id) });
			this.update();


			setTimeout(() => {
				this.assignVenues(venues);
				$(".ui.search.event_venue.dropdown").dropdown();
			}, 50)
		}

		assignVenues(venues) {
			venues.forEach((venue, i) => {
				this.refs['venue_id_' + i].value = venue.venue_id;
				this.refs['user_id_' + i].value  = venue.user_id;
			});
		}

		if (this.edit_id) {
			this.parent.opts.service.get(this.edit_id, (err, response) => {
				if (!err) {
					let data = response.body().data();
					this.event        = data['event'];
					this.event_venues = data['event_venues'];
					this.loadEditForm(this.event, this.event_venues);
				}
				else {
					this.event = null;
					console.log("ERROR LOADING EVENT !");
				}
			});
		}
		else {
			setTimeout(() => {
				$("#event-start-date").calendar({type: 'date'});
				$("#event-end-date").calendar({type: 'date'});

				$(".ui.search.event_venue.dropdown").dropdown();
			}, 10)

			this.insertVenue();

			this.update();
		}

	</script>

</event-form>
