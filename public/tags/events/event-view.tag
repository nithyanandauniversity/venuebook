<event-view
	class = "ui container"
	style = "margin: 25px 0 100px;">

	<div class="ui">

		<div class="ui two column centered grid">
			<div class="nine wide column">
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
									<span
										show = "{event.end_date && event.start_date != event.end_date}">
										 - {format(event.end_date, 'date', 'fullDate')}
									 </span>
								</h5>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div class="seven wide column">
				<div class="ui segment">
					<h4 class="ui dividing header">
						<i class="icon map outline"></i> Event Venues and Coordinators
					</h4>
					<div class="ui middle aligned celled list">
						<div
							each  = "{venues}"
							class = "item"
							style = "position: relative;">
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

		<!-- Attendances / Registrations Menu -->
		<div class="ui top attached huge tabular menu">
			<a
				class   = "item orange {activeTab == 'REGISTRATION' && 'active'}"
				onclick = "{ switchRegTab() }">
				Registrations
			</a>
			<a
				class   = "item green {activeTab == 'ATTENDANCE' && 'active'}"
				onclick = "{ switchAttTab() }">
				Attendances
			</a>
		</div>
		<div
			class = "ui bottom attached segment"
			style = "min-height: 250px; padding-bottom: 100px;">
			<event-registrations
				show         = "{activeTab == 'REGISTRATION'}"
				current-user = "{currentUser}"
				event        = "{event}"
				venues       = "{venues}"
				service      = "{parent.opts.participantService}">
			</event-registrations>
			<event-attendances
				show         = "{activeTab == 'ATTENDANCE'}"
				current-user = "{currentUser}"
				event        = "{event}"
				venues       = "{venues}"
				service      = "{parent.opts.participantService}">
			</event-attendances>
		</div>

	</div>


	<script>

		this.event       = {};
		this.program     = {};
		this.venues      = [];
		this.view_id     = this.opts.state.id;
		this.activeTab   = 'REGISTRATION';

		this.currentUser = this.parent.opts.store.getState().routes.data;

		switchRegTab(e) {
			return(e) => {
				this.activeTab = 'REGISTRATION';
			}
		}

		switchAttTab(e) {
			return(e) => {
				this.activeTab = 'ATTENDANCE';
			}
		}

		initTab() {
			let event_date = new Date(this.event.start_date);
			let today      = new Date();

			this.activeTab         = event_date > today ? 'REGISTRATION' : 'ATTENDANCE';
			this.allowAttendance   = event_date <= today;
			this.allowRegistration = event_date >= today;
		}

		getAllAttendances() {
			this.parent.opts.service.getAttendances(this.view_id, (err, response) => {
				if (!err) {
					let attendances = response.body()[0].data()['event_attendances'];
					this.reloadAttendanceData(attendances);
					this.tags['event-attendances'].trigger('loaded');
					this.tags['event-registrations'].trigger('loaded');
				}
			});
		}

		addToRegistration(participant, venue_id) {

			let params = {
				attendance : {
					event_id            : this.view_id,
					venue_id            : venue_id,
					attendance_date     : this.event.start_date,
					member_id           : participant.member_id,
					confirmation_status : 3,
					payment_status      : 0,
					attendance          : 1
				},
				send_all : true
			};

			this.parent.opts.attendanceService.create(params, (err, response) => {
				if (!err) {
					let registrations = response.body().data().event_attendances;
					this.reloadAttendanceData(registrations);
					this.tags['event-registrations'].trigger('loaded');
				}
			});
		}

		updateRegistration(id, data) {
			let params = {
				attendance : data,
				send_all   : true
			};

			this.parent.opts.attendanceService.update(id, params, (err, response) => {
				if (!err) {
					let registrations = response.body().data().event_attendances;
					this.reloadAttendanceData(registrations);
					this.tags['event-registrations'].trigger('loaded');
				}
			})
		}

		removeRegistration(id) {
			this.parent.opts.attendanceService.remove(id, (err, response) => {
				if (!err) {
					this.getAllAttendances();
				}
			});
		}

		addToAttendance(participant, venue_id, attendance_date) {

			let params = {
				attendance : {
					event_id        : this.view_id,
					venue_id        : venue_id,
					attendance_date : attendance_date,
					member_id       : participant.member_id,
					attendance      : 3
				},
				send_all : true
			};

			this.parent.opts.attendanceService.create(params, (err, response) => {
				if (!err) {
					let attendances = response.body().data().event_attendances;
					this.reloadAttendanceData(attendances);

					this.tags['event-attendances'].trigger('loaded');
					this.tags['event-registrations'].trigger('loaded');
				}
			});
		}

		updateAttendance(id, params) {
			this.parent.opts.attendanceService.update(id, params, (err, response) => {});
		}

		removeAttendance(id) {
			this.parent.opts.attendanceService.remove(id, (err, response) => {
				if (!err) {
					this.getAllAttendances();
				}
			});
		}

		groupRegistrations(registrations) {
			let groups = {};
			for (let i = 0; i < registrations.length; i++) {
				let registration = registrations[i];
				if (!groups[registration.member_id]) {
					groups[registration.member_id] = [];
				}

				groups[registration.member_id].push(registration);
			}

			this.registrations = [];

			for (let id in groups) {
				let registration = groups[id][0];
				let participant  = registration.participant;
				let venue        = registration.venue;

				let attended_dates = groups[id].reduce( (arr = [], reg, idx) => {
					if (reg.attendance > 1) { arr.push(reg.attendance_date); }
					return arr;
				}, []);

				registration.attended_dates = attended_dates;

				this.registrations.push(registration);
			}
		}

		reloadAttendanceData(data) {
			if (this.event_dates.length > 1) {
				let registrations = data.filter((a) => { return a.attendance < 3 });
				this.groupRegistrations(registrations);
			}
			else {
				this.registrations = data.filter((a) => { return a.attendance < 3 });
			}

			this.attendances = data.filter((a) => { return a.attendance > 1 });
		}

		loadDates() {
			let start_date = new Date(this.event.start_date);
			let end_date   = new Date(this.event.end_date);
			let diff       = (end_date - start_date) / 1000 / 60 / 60 / 24;

			this.event_dates = [start_date];

			if (diff > 0) {
				for (let i = 0; i < diff; i++) {
					this.event_dates.push( new Date(start_date.getTime() + (1000*60*60*24) * (i+1)) );
				}
			}
		}

		if (this.view_id) {
			this.parent.opts.service.get(this.view_id, (err, response) => {
				if (!err) {
					let data = response.body().data();
					this.event   = data.event;
					this.program = data.program;
					this.venues  = data.event_venues;
					this.initTab();
					this.loadDates();
					this.reloadAttendanceData(data.attendances);
					this.update();

					this.tags['event-attendances'].trigger('loaded');
					this.tags['event-registrations'].trigger('loaded');
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