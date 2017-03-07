<programs class="ui equal width grid" style="margin-top: 25px;">

	<!-- Create Program Component -->
	<program-form class="column"></program-form>

	<!-- List Program Component -->
	<program-list class="column"></program-list>

	<script>

		console.log("this.opts");
		console.log(this.opts);

		reloadList() {
			this.tags['program-list'].trigger('reload');
		}

	</script>
</programs>

