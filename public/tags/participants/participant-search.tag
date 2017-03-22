<participant-search
	class = "ui container"
	id    = "participant-search"
	style = "margin: 25px 0;">

	<div class="ui fluid right action left icon input">
		<input
			type         = "text"
			ref          = "searchQ"
			placeholder  = "Search participants..."
			onkeypress   = { executeSearch() }
			autocomplete = "off" />
		<!-- <div class="ui icon input"> -->
		<i class="search icon"></i>
		<!-- </div> -->
		<div class="ui primary basic button" onclick={ parent.showNew }>
			<i class="add user icon"></i> New
		</div>
	</div>

	<script>

		executeSearch(e) {
			return(e) => {
				if (e.which === 13) {
					this.parent.searchQ = this.refs.searchQ.value;
					this.parent.performSearch(1);
				}
			}
		}

		let state = this.parent.opts.store.getState().participants;
		// console.log("state");
		// console.log(state);
		if (state.view == "SEARCH_PARTICIPANT" && state.query) {
			setTimeout(()=>{
				this.refs.searchQ.value = state.query.keyword ? state.query.keyword : '';
			}, 10);
		}

	</script>

</participant-search>
