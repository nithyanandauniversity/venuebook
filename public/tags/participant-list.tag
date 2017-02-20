<participant-list>
	<table
		class = "ui blue table"
		show  = "{participants.length > 0}"
		style = "margin-bottom: 25px;">
		<thead>
			<tr>
				<th>ID #</th>
				<th>Full Name</th>
				<th>Email</th>
				<th>Contact</th>
				<th style="min-width: 160px; width: 240px; max-width: 240px; text-align: center;">
					<i class="options icon"></i> Actions
				</th>
			</tr>
		</thead>
		<tbody>
			<tr each={ participants } scope={ this }>
				<td style="font-size: 0.8em; width: 120px;">{member_id}</td>
				<td>
					<label>
						<strong>{first_name}</strong> {last_name}
						<i class = "icon trophy green"
						if = {itmAttr(participant_attributes).ia_graduate}></i>
						<i class = "icon heart red"
						if = {itmAttr(participant_attributes).is_healer}></i>
					</label>
					<br>
					<label
						if={other_names}
						style="font-size: .9em;">({other_names})</label>
					<span
						class = "ui violet horizontal label"
						if    = "{itmAttr(participant_attributes).role > 1}">
						{userRoles[itmAttr(participant_attributes).role]}
					</span>
				</td>
				<td>{email}</td>
				<td>
					<span if={contact}>
						<i class="icon {contact.contact_type == 'Home' ? 'call' : 'mobile'}">
						</i>
						{contact.value}
					</span>
				</td>
				<td style="color: black !important;">
					<button
						class    = "ui action-btn vertical olive animated button"
						tabindex = "0"
						onclick  = { showView() }>
						<div class="hidden content">View</div>
						<div class="visible content">
							<i class="action info icon"></i>
						</div>
					</button>
					<div
						class    = "ui action-btn vertical yellow animated button"
						tabindex = "0"
						data     = "{member_id}"
						onclick  = { showForm() }>
						<div class="hidden content">Edit</div>
						<div class="visible content">
							<i class="action write icon"></i>
						</div>
					</div>
					<div
						class    = "ui action-btn vertical red animated button"
						tabindex = "0"
						data     = "{member_id}"
						onclick  = { remove() }>
						<div class="hidden content">Delete</div>
						<div class="visible content">
							<i class="action remove icon"></i>
						</div>
					</div>
				</td>
			</tr>
		</tbody>
		<tfoot>
			<tr>
				<td colspan="5">
					<div class="ui two column grid">
						<div class="ui left aligned column">
							<span style="margin-right: 10px;">
								<i class="icon trophy green"></i>- IA Graduate
							</span>
							<span>
								<i class="icon heart red"></i>- Healer
							</span>
						</div>
						<div class="ui right aligned column">
							<button
								class   = "ui labeled icon button {first_page && 'disabled'}"
								onclick = { goToPrevious() }>
								<i class="chevron left icon"></i>
								Previous
							</button>
							<button class="ui labeled button disabled">
								Page #{current_page} | Showing {record_range} of {record_count}
							</button>
							<button
								class   = "ui right labeled icon button {last_page && 'disabled'}"
								onclick = { goToNext() }>
								<i class="chevron right icon"></i>
								Next
							</button>
						</div>
					</div>
				</td>
			</tr>
		</tfoot>
	</table>

	<script>

		const self = this;

		showView(e) {
			return (e) => {
				self.parent.showView(e.item);
			}
		}

		showForm(e) {
			return (e) => {
				self.parent.showForm(e.item);
			}
		}

		getData(res) {
			return res.data();
		}

		remove(e) {
			return (e) => {
				if (confirm("Are you sure you want to delete the participant?")) {
					this.parent.opts.service.remove(e.item.id, (err, response) => {
						if (!err) {
							console.log(response.body().data(), response.statusCode());
							this.getParticipants(this.getDefaultQueryParams());
						}
						else {
							console.log('some error occurred');
						}
					});
				}
				else {
					console.log("Do no delete!");
				}
			}
		}

		this.participants = [];

		this.userRoles = ['None', 'Volunteer', 'Thanedar', 'Kotari', 'Mahant', 'Sri Mahant'];

		itmAttr(p) {
			return JSON.parse(p || {})
		}

		goToPrevious(e) {
			return(e) => {
				if (!this.first_page) {
					this.getParticipants({page: (this.current_page - 1), limit: 10});
				}
			}
		}

		goToNext(e) {
			return(e) => {
				if (!this.last_page) {
					this.getParticipants({page: (this.current_page + 1), limit: 10});
				}
			}
		}

		getDefaultQueryParams() {
			return {
				page  : this.current_page && this.record_count > 1 ? this.current_page : 1,
				limit : 10
			}
		}

		getParticipants(params) {
			this.parent.opts.service.search(params, (err, response) => {
				if (!err && response.body().length) {
					let result = this.getData(response.body()[0]);
					console.log("result");
					console.log(result);
					if (result.participants && result.current_page_record_count > 0) {
						this.participants = result.participants;
						this.current_page = result.current_page;
						this.page_count   = result.page_count;
						this.first_page   = result.first_page;
						this.last_page    = result.last_page;
						this.record_range = result.current_page_record_range.split('..').join(' to ');
						this.record_count = result.pagination_record_count;
					}
					else {
						// NO RESULTS
					}
					this.update();
				}
				else {
					console.log("ERROR !");
				}
			});
		}

		this.on('search', (data) => {
			console.log("this.parent.opts.store");
			let state = this.parent.opts.store.getState();
			console.log('PERFORM SEARCH', state.participants.query);
			this.getParticipants(state.participants.query);
		});

		this.getParticipants(this.getDefaultQueryParams());

	</script>

	<style scoped>
		:scope { font-size: 0.7em; }
		i.action, .action-btn { color: black !important;  }
	</style>
</participant-list>