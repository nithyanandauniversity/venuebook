<app class="ui container">

	<participants></participants>

	<!-- <h3>{ opts.title }</h3>
	<p>{ subtitle }</p>
	<ul>
		<li each={ list }>{ name }</li>
	</ul> -->

	<script>
		this.subtitle = 'Easy, right?';
		this.list = [
			{ name: 'my' },
			{ name: 'little' },
			{ name: 'list' }
		];
	</script>

	<style scoped>
		:scope { font-size: 2rem }
		h3 { color: #444 }
		ul { color: #999 }
	</style>
</app>