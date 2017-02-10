<participant-list>
	<table class="ui blue table">
		<thead>
			<tr>
				<th>#</th>
				<th>Full Name</th>
				<th>Email</th>
				<th>Contact</th>
				<th>
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
				<td></td>
			</tr>
		</tbody>
		<tfoot></tfoot>
	</table>

	<script>
		this.participants = [
			{member_id: '1', first_name: 'Saravana', last_name: 'B', email: 'sgsaravana@gmail.com', contact_number: '86286022'},
			{member_id: '2', first_name: 'Senthuraan', last_name: 'P', email: 'psenthu@gmail.com', contact_number: '81012993'}
		]
	</script>
</participant-list>