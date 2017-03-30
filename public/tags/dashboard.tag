<dashboard>

	<div class="ui container" style="margin-top: 25px;">

		<div class="ui green message">
			<h2>
				Welcome { currentUser.first_name } { currentUser.last_name } !
			</h2>
		</div>
	</div>

	<script>
		this.currentUser = this.opts.store.getState().routes.data;
	</script>

</dashboard>
