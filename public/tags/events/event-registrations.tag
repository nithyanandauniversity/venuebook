<event-registrations>

	<div
		class = "ui message red"
		show  = "{parent.registrations && parent.registrations.length == 0}">
		<h3>No Registrations !</h3>
	</div>

	<div
		class = "ui fluid input huge"
		style = "position: absolute; bottom: 10px; left: 10px; right: 10px;"
		show  = "{parent.allowRegistration}">
		<input type="text" placeholder="Search for participants to add registrations..." />
	</div>

	<script></script>

</event-registrations>

