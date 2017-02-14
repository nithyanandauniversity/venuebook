<participant-list>
	<table class="ui blue table">
		<thead>
			<tr>
				<th>#</th>
				<th>Full Name</th>
				<th>Email</th>
				<th>Contact</th>
				<th style="min-width: 160px; width: 240px; max-width: 240px; text-align: center;">
					<i class="options icon"></i> Actions
				</th>
			</tr>
		</thead>
		<tbody>
			<tr each={ participant in participants } scope={ this }>
				<td>{participant.member_id}</td>
				<td>
					<label>
						<strong>{participant.first_name}</strong> {participant.last_name}
					</label>
					<br>
					<label
						if={spiritual_name}
						style="font-size: .9em;">({participant.spiritual_name})</label>
				</td>
				<td>{participant.email}</td>
				<td>{participant.contact_number}</td>
				<td style="color: black !important;">
					<button
						class="ui action-btn vertical olive animated button"
						tabindex="0"
						onclick={ showView() }>
						<div class="hidden content">View</div>
						<div class="visible content">
							<i class="action info icon"></i>
						</div>
					</button>
					<div
						class="ui action-btn vertical yellow animated button"
						tabindex="0"
						data="{participant.member_id}"
						onclick={ showForm() }>
						<div class="hidden content">Edit</div>
						<div class="visible content">
							<i class="action write icon"></i>
						</div>
					</div>
					<div class="ui action-btn vertical red animated button" tabindex="0">
						<div class="hidden content">Delete</div>
						<div class="visible content">
							<i class="action remove icon"></i>
						</div>
					</div>
				</td>
			</tr>
		</tbody>
		<tfoot></tfoot>
	</table>

	<script>

		const self = this;

		showView = (e) => {
			return (e) => {
				self.parent.showView(e.item.participant);
			}
		}

		showForm = (e) => {
			return (e) => {
				self.parent.showForm(e.item.participant);
			}
		}

		this.participants = [
			{member_id: '1', first_name: 'Saravana', last_name: 'Balaraj', email: 'sgsaravana@gmail.com', contact_number: '(+65) 86286022'},
			{member_id: '2', first_name: 'Dinesh', last_name: 'Gupta', email: 'sri.sadhana@innerawakening.org', spiritual_name: 'Sri Nithya  Sadhanananda', contact_number: '(+65) 91399486'},
			{member_id: '3', first_name: 'Srinath', last_name: 'Loganathan', email: 'srinath_lsn@gmail.com', contact_number: '(+49) 17623162673'}
		]
	</script>

	<style scoped>
		:scope { font-size: 0.7em; }
		i.action, .action-btn { color: black !important;  }
	</style>
</participant-list>