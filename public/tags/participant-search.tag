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

		search() {
			this.parent.performSearch({
				page    : 1,
				limit   : 10,
				keyword : this.refs.searchQ.value
			});
		}

		executeSearch(e) {
			return(e) => {
				if (e.which === 13) {
					this.search();
				}
			}
		}

		this.on('doSearch', this.search);

	</script>

</participant-search>
