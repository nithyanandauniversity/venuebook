<nav>
	<div class="ui fixed">
		<div class="ui inverted segment">
			<div class="ui container">
				<div class="ui inverted secondary pointing menu">
					<div class="item">
						<!-- <img src="assets/images/logo.png"> -->
						<h2>{ opts.title }</h2>
					</div>
					<a each={ navigations } class={ name == active ? 'active item' : 'item'}>{ name }</a>
				</div>
			</div>
		</div>
	</div>


	<script>
		this.navigations = [
			{ name: 'Participants' },
			{ name: 'Centers' },
			{ name: 'Events' }
		];
		this.active = 'Participants';
	</script>

</nav>
