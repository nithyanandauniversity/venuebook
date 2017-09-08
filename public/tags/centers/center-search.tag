<center-search
	class = "ui container"
	id    = "center-search"
	style = "margin: 25px 0;">

	<div class="ui fluid right action left icon input">
		<i class="search icon"></i>
		<input
			type         = "text"
			ref          = "searchQ"
			placeholder  = "Search for centers..."
			onkeypress   = "{ triggerSearch() }"
			autocomplete = "off" />
		<!-- <div class="ui icon input"> -->
		<!-- </div> -->
		<div
			class   = "ui orange basic button"
			style   = "margin-right: 1px;"
			onclick = "{ toggleFilter() }">
			<i class="icon filter"></i> Filter
		</div>
		<div
			class   = "ui primary basic button"
			onclick = { parent.showNew }>
			<i class = "add user icon"></i> Create New
		</div>
	</div>

	<div class="ui segment form" show = "{ showFilters }">
		<div class="five fields">
			<div class="field">
				<label>Area</label>
				<!-- <input type="text" ref="area" placeholder="Area (Ex: North America)" /> -->
				<select
					if    = "parent.center_areas"
					ref   = "area"
					class = "ui search dropdown">
					<option value = "">Select area to add...</option>
					<option
						each  = "{area in parent.center_areas.obj}"
						value = "{area}">
						{area}
					</option>
				</select>
			</div>
			<div class="field">
				<label>Country</label>
				<select
					ref   = "country"
					class = "ui search dropdown">
					<option value="">Select Country...</option>
					<option
						each  = {country in countries}
						value = "{country.value}">
						{country.value}
					</option>
				</select>
			</div>
			<div class="field">
				<label for="region">Region</label>
				<input type="text" ref="region" placeholder="Region (Ex: Midwest / East Coast)" />
			</div>
			<div class="field">
				<label for="state">State</label>
				<input type="text" ref="state" placeholder="State (Ex: California)" />
			</div>
			<div class="field">
				<label for="city">City</label>
				<input type="text" ref="city" placeholder="City (Ex: San Jose)" />
			</div>
			<div class="field">
				<label for="category">Category</label>
				<select ref="category" class="ui search dropdown">
					<option value="">Select Category...</option>
					<option
						each  = "{cat in centerCategories}"
						value = "{cat.value}">
						{cat.label} ({cat.value})
					</option>
				</select>
			</div>
		</div>

		<div class="ui right aligned grid">
			<div class="column">
				<button
					class   = "ui button basic primary"
					onclick = "{ doSearch }">
					Search
				</button>
			</div>
		</div>
	</div>

	<script>

		this.showFilters      = false;
		this.countries        = this.parent.opts.countries();
		this.centerCategories = this.parent.opts.centerCategories;

		toggleFilter() {
			return(e) => {
				this.showFilters = !this.showFilters;
			}
		}

		generateFilterParams() {
			return {
				category : this.refs.category.value,
				city     : this.refs.city.value,
				state    : this.refs.state.value,
				region   : this.refs.region.value,
				country  : this.refs.country.value,
				area     : this.refs.area.value
			}
		}

		generateFilters() {
			let filters = {};
			let params  = this.generateFilterParams();

			if (params.category && params.category != '') {
				filters['category'] = params.category;
			}

			if (params.city && params.city != '') {
				filters['city'] = params.city;
			}

			if (params.state && params.state != '') {
				filters['state'] = params.state;
			}

			if (params.region && params.region != '') {
				filters['region'] = params.region;
			}

			if (params.country && params.country != '') {
				filters['country'] = params.country;
			}

			if (params.area && params.area != '') {
				filters['area'] = params.area;
			}

			return filters;
		}

		doSearch() {
			this.parent.searchFilters = this.showFilters ? this.generateFilters() : null;
			this.parent.searchQ       = this.refs.searchQ.value;
			this.parent.performSearch(1);
		}

		setTimeout(() => {
			$(".ui.search.dropdown").dropdown({
				forceSelection  : false,
				selectOnKeydown : false
			});
		}, 100)

		triggerSearch(e) {
			return(e) => {
				if (e.which === 13) {
					this.doSearch();
				}
			}
		}

	</script>

</center-search>
