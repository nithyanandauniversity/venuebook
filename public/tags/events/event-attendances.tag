<event-attendances>

	<div
		class = "ui message red"
		show  = "{parent.attendances && parent.attendances.length == 0}">
		<h3>No Attendances !</h3>
	</div>

	<div
		class = "ui fluid input huge"
		style = "position: absolute; bottom: 10px; left: 10px; right: 10px;"
		show  = "{parent.allowAttendance}">
		<input type="text" placeholder="Search for participants and add to attendance..." />
	</div>

	<script></script>

</event-attendances>