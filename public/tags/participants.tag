<participants>
	<participant-search if={opts.state.view == 'LIST_PARTICIPANT'}></participant-search>
	<participant-list if={opts.state.view == 'LIST_PARTICIPANT'}></participant-list>

	<h3>
		{opts.state.view}
	</h3>

	<script>
		this.showNew = () => {
			this.opts.store.dispatch({type: 'ADD_PARTICIPANT'});
			this.update();
		}
	</script>

</participants>