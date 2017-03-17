<event-view
	class = "ui container"
	style = "margin: 25px 0 100px;">

	<div class="ui">

		<div class="ui two column centered grid">
			<div class="nine wide column">
				<h3 class="ui dividing header">
					<i class="icon browser"></i> Event Details
				</h3>
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
				<h3 class="ui dividing header">
					<i class="icon map outline"></i> Event Venues and Coordinators
				</h3>
				<div class="ui segment">
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
		<div class="ui secondary pointing menu">
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
			class = "ui segment"
			style = "min-height: 250px; padding-bottom: 75px;">
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

		addToRegistration() {}

		addToAttendance(participant, venue_id, attendance_date) {
			console.log("participant, venue_id, attendance_date");
			console.log(participant, venue_id, attendance_date);

			let params = {
				attendance : {
					event_id        : this.view_id,
					venue_id        : venue_id,
					attendance_date : attendance_date,
					member_id       : participant.member_id,
					attendance      : 3
				},
				send_all : true
			}

			this.parent.opts.attendanceService.create(params, (err, response) => {
				if (!err) {
					let attendances = response.body().data().event_attendances;
					this.reloadAttendanceData(attendances);
					this.tags['event-attendances'].update();
				}
			});
		}

		updateAttendance(id, params) {
			this.parent.opts.attendanceService.update(id, params, (err, response) => {});
		}

		removeAttendance(id) {
			this.parent.opts.attendanceService.remove(id, (err, response) => {
				if (!err) {
					console.log(response.body());
					console.log(response.body().data());
					let attendances = response.body().data().event_attendances;
					this.reloadAttendanceData(attendances);
					this.tags['event-attendances'].update();
				}
			})
		}

		reloadAttendanceData(data) {
			this.registrations = data.filter((a) => { return a.attendance < 3 })
			this.attendances   = data.filter((a) => { return a.attendance > 1 })
		}

		if (this.view_id) {
			this.parent.opts.service.get(this.view_id, (err, response) => {
				if (!err) {
					let data = response.body().data();
					this.event   = data.event;
					this.program = data.program;
					this.venues  = data.event_venues;
					this.reloadAttendanceData(data.attendances);
					this.initTab();
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