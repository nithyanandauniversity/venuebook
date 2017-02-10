<nav>
	<div class="ui fixed">
		<div class="ui container menu">
			<div class="item">
				<!-- <img src="assets/images/logo.png"> -->
				<h2>{ opts.title }</h2>
			</div>
			<a each={ navigations } class="item">{ name }</a>
		</div>
	</div>


	<script>

		this.navigations = [
			{ name: 'Participants' },
			{ name: 'Centers' },
			{ name: 'Events' }
		];
	</script>

</nav>
