<participant-list>
	<table class="ui blue table">
		<thead>
			<tr>
				<th>#</th>
				<th>Full Name</th>
				<th>Email</th>
				<th>Contact</th>
				<th style="width: 240px; text-align: center;">
					<i class="options icon"></i> Actions
				</th>
			</tr>
		</thead>
		<tbody>
			<tr each={ participants }>
				<td>{member_id}</td>
				<td><strong>{first_name}</strong> {last_name}</td>
				<td>{email}</td>
				<td>{contact_number}</td>
				<td style="color: black !important;">
					<div class="ui action-btn vertical olive animated button" tabindex="0">
						<div class="hidden content">View</div>
						<div class="visible content">
							<i class="action info icon"></i>
						</div>
					</div>
					<div class="ui action-btn vertical yellow animated button" tabindex="0">
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
		this.participants = [
			{member_id: '1', first_name: 'Saravana', last_name: 'Balaraj', email: 'sgsaravana@gmail.com', contact_number: '(+65) 86286022'},
			{member_id: '2', first_name: 'Senthuraan', last_name: 'Ponnampalam', email: 'psenthu@gmail.com', contact_number: '(+65) 81012993'},
			{member_id: '3', first_name: 'Srinath', last_name: 'Loganathan', email: 'srinath_lsn@gmail.com', contact_number: '(+49) 17623162673'}
		]
	</script>

	<style scoped>
		:scope { font-size: 0.7em; }
		i.action, .action-btn { color: black !important;  }
	</style>
</participant-list>