<event-upcoming>

	<div
		class = "ui three cards"
		show  = "{upcoming.length > 0}">
		<div
			class = "card"
			each  = "{event in upcoming}">
			<div class="content">
				<div class="header">{event.program.program_name}</div>
				<div class="meta">{event.program.program_type}</div>
				<div
					class = "ui sub header green"
					show  = "{event.name && event.name != ''}">
					{event.name}
				</div>
				<div class="description">
					<h5>
						{format(event.start_date, 'date', 'fullDate')}
						<span show = "{event.end_date}"> - {format(event.end_date, 'date', 'fullDate')}</span>
					</h5>
				</div>
			</div>
			<div class="extra content">
				<span class="left floated view">
					<button
						class   = "ui blue basic button"
						onclick = "{ viewEvent() }">
						<i class="icon info"></i> View
					</button>
				</span>
				<span
					class   = "right floated edit"
					onclick = "{ editEvent() }"
					show    = "{currentUser.role <= 4}">
					<button class = "ui orange basic button">
						<i class = "icon write"></i> Edit
					</button>
				</span>
			</div>
		</div>
	</div>

	<div
		class = "ui message red"
		show  = "{upcoming.length == 0}">
		<h3>No Upcoming Events !</h3>
	</div>

	<script>

		this.upcoming    = [];
		this.currentUser = this.parent.opts.store.getState().routes.data;

		getData(res) {
			return res.data();
		}

		viewEvent(e) {
			return(e) => {
				this.parent.viewEvent(e.item.event);
			}
		}

		editEvent(e) {
			return(e) => {
				this.parent.editEvent(e.item.event);
			}
		}

		loadUpcoming() {
			this.parent.opts.service.getUpcoming((err, response) => {
				if (!err) {
					this.upcoming = this.getData(response.body()[0])['events'];
				}
				else {
					this.upcoming = [];
				}

				this.update();
			});
		}

		this.loadUpcoming();

		this.on('reload', () => {
			this.loadUpcoming();
		});

	</script>
</event-upcoming>