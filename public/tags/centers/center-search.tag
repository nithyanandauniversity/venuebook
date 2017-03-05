<center-search
	class = "ui container"
	id    = "center-search"
	style = "margin: 25px 0;">

	<div class="ui fluid right action left icon input">
		<input
			type         = "text"
			ref          = "searchQ"
			placeholder  = "Search for centers..."
			onkeypress   = { executeSearch() }
			autocomplete = "off" />
		<!-- <div class="ui icon input"> -->
		<i class="search icon"></i>
		<!-- </div> -->
		<div
			class   = "ui primary basic button"
			onclick = { parent.showNew }>
			<i class = "add user icon"></i> Create New
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

	</script>

</center-search>
