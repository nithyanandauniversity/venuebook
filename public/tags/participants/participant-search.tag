<participant-search
	class = "ui container"
	id    = "participant-search"
	style = "margin: 25px 0;">

	<div class="ui fluid right action left icon input">
		<input
			type         = "text"
			ref          = "searchQ"
			placeholder  = "Search participants..."
			onkeypress   = "{ executeSearch() }"
			autocomplete = "off" />
		<!-- <div class="ui icon input"> -->
		<i class="search icon"></i>
		<!-- </div> -->
		<div
			class   = "ui brown basic button"
			style   = "margin-right: 1px;"
			onclick = "{ toggleExtSearch() }">
			<i class = "sitemap icon" style = "margin: 0;"></i>
		</div>
		<div class = "ui primary basic button" onclick = "{ parent.showNew }">
			<i class = "add user icon"></i> New
		</div>
	</div>

	<div class="ui message info" if = "{ extSearchApply }">
		<h3>
			Extended search applied for
			<span if = "{ extSearchType && extSearchType == 'area' }">Area(s): {extSearchTypeValue.areas.join(', ')}</span>
			<span if = "{ extSearchType && extSearchType == 'country' }">Country(s): {extSearchTypeValue.countries.join(', ')}</span>
			<span if = "{ extSearchType && extSearchType == 'center' }">Center(s): <span each = "{extSearchTypeValue.centers}">{name}</span></span>
			<span if = "{ extSearchType && extSearchType == 'global' }">Global: (All Areas / Countries / Centers)</span>
			<div style="text-align: right;">
				<button class="ui button basic red" onclick = "{ clearExtSearch(); }">Clear</button>
			</div>
		</h3>
	</div>

	<div class="ui segment form" if = "{ showExtSearch && !extSearchApply }">
		<div class="ui two column grid">

			<div class="six wide column">
				<div class="field">
					<h3>Select Search Type</h3>
					<div class="ui fluid vertical pointing menu">
						<a
							each    = "{extSearchTypes}"
							onclick = "{ setExtSearchType() }"
							class   = "item {extSearchType == value && 'active brown'}">
							{label}
						</a>
					</div>
				</div>
			</div>

			<div class="ten wide column">
				<!-- SELECT AREAS IF SEARCH TYPE IS AREA -->
				<div class="field" show="{extSearchType && extSearchType == 'area'}">
					<h3>Select Areas :</h3>
					<div style = "margin-bottom: 1rem;">
						<div
							each  = "{ area in extSearchTypeValue.areas }"
							style = "margin-right: 8px;"
							class = "ui icon buttons">
							<button class = "ui button">
								{area}
							</button>
							<button
								class   = "ui icon button"
								onclick = "{ removeAreaFromList() }">
								<i class = "icon remove"></i>
							</button>
						</div>
					</div>
					<select
						onchange = "{ areaSelected() }"
						ref      = "search_area"
						class    = "ui search dropdown">
						<option value="">Select area to add...</option>
						<option
							each    = "{area in parent.center_areas.obj}"
							value   = "{area}">
							{area}
						</option>
					</select>
				</div>

				<!-- SELECT COUNTRIES IF SEARCH TYPE IS COUNTRY -->
				<div class="field" show="{extSearchType && extSearchType == 'country'}">
					<h3>Select Countries :</h3>
					<div style = "margin-bottom: 1rem;">
						<div
							each  = "{ country in extSearchTypeValue.countries }"
							style = "margin-right: 8px;"
							class = "ui icon buttons">
							<button class = "ui button">
								{country}
							</button>
							<button
								class   = "ui icon button"
								onclick = "{ removeCountryFromList() }">
								<i class = "icon remove"></i>
							</button>
						</div>
					</div>
					<select
						onchange = "{ countrySelected() }"
						ref      = "search_country"
						class    = "ui search dropdown">
						<option value="">Select country to add...</option>
						<option
							each    = "{country in countries}"
							value   = "{country.value}">
							{country.value}
						</option>
					</select>
				</div>

				<!-- SELECT CENTERS IF SEARCH TYPE IS CENTER -->
				<div class="field" show="{extSearchType && extSearchType == 'center'}">
					<h3>Select Centers :</h3>
					<div style = "margin-bottom: 1rem;">
						<div
							each  = "{ center in extSearchTypeValue.centers }"
							style = "margin-right: 8px;"
							class = "ui icon buttons">
							<button class = "ui button">
								{ center.name }
							</button>
							<button
								class   = "ui icon button { activeRole == 3 && 'disabled' }"
								onclick = "{ removeCenterFromList() }">
								<i class = "icon remove"></i>
							</button>
						</div>
					</div>
					<div class="ui large input">
						<input
							type        = "text"
							id          = "form-search-center"
							placeholder = "Search for centers..." />
					</div>
				</div>

				<div class="field" show="{extSearchType && extSearchType == 'global'}">
					<h3>Search for participant globally across all Areas and Countries?</h3>
				</div>

				<div class="right aligned column" style="text-align: right;">
					<div
						show  = "{(extSearchType == 'area' && extSearchTypeValue.areas && extSearchTypeValue.areas.length > 0) || (extSearchType == 'country' && extSearchTypeValue.countries && extSearchTypeValue.countries.length > 0) || (extSearchType == 'center' && extSearchTypeValue.centers && extSearchTypeValue.centers.length > 0) || (extSearchType == 'global')}"
						class = "ui button basic green"
						onclick = "{ applyExtSearchSettings() }">
						Apply
					</div>
				</div>
			</div>

		</div>
	</div>

	<script>

		this.showExtSearch      = false;
		this.extSearchTypeValue = {};
		this.countries          = this.parent.opts.countries();

		this.extSearchTypes = [
			{label: "Search by Area", value: "area"},
			{label: "Search by Country", value: "country"},
			{label: "Search by Center", value: "center"},
			{label: "Search Globally", value: "global"}
		];

		setSearchParams() {
			this.parent.searchQ  = this.refs.searchQ.value;

			if (
				this.extSearchType &&
				(this.extSearchTypeValue && (this.extSearchTypeValue.areas || this.extSearchTypeValue.countries || this.extSearchTypeValue.centers || this.extSearchTypeValue.global))
				)
			{
				if (this.extSearchType == 'center') {
					this.parent.extSearch = this.extSearchTypeValue.centers.map((center) => { return center.code; })
				}
				else {
					this.parent.extSearch = this.extSearchTypeValue;
				}
			}
			else {
				this.parent.extSearch = null;
			}
		}

		executeSearch(e) {
			return(e) => {
				if (e.which === 13) {
					this.setSearchParams();
					this.parent.performSearch(1);
				}
			}
		}

		toggleExtSearch(e) {
			return(e) => {
				this.showExtSearch = !this.showExtSearch;
				if (this.showExtSearch) {
					setTimeout(() => {
						this.loadSearchInput();
						$(".ui.search.dropdown").dropdown({
							forceSelection  : false,
							selectOnKeydown : false
						});
					}, 50)
				}
			}
		}

		setExtSearchType(e) {
			return(e) => {
				this.extSearchType = e.item.value;
				this.update();
			}
		}

		areaSelected(e) {
			return(e) => {
				let selectedArea = this.refs['search_area'].value;
				if (this.extSearchTypeValue && this.extSearchTypeValue.areas && this.extSearchTypeValue.areas.length > 0) {
					if (!this.extSearchTypeValue.areas.includes(selectedArea)) {
						this.extSearchTypeValue.areas.push(selectedArea);
					}
				}
				else {
					this.extSearchTypeValue = {areas: [selectedArea]};
				}
			}
		}

		removeAreaFromList(e) {
			return(e) => {
				let idx = this.extSearchTypeValue.areas.indexOf(e.item.area);
				this.extSearchTypeValue.areas.splice(idx, 1);
			}
		}

		countrySelected(e) {
			return(e) => {
				let selectedCountry = this.refs['search_country'].value;
				if (this.extSearchTypeValue && this.extSearchTypeValue.countries && this.extSearchTypeValue.countries.length > 0) {
					if (!this.extSearchTypeValue.countries.includes(selectedCountry)) {
						this.extSearchTypeValue.countries.push(selectedCountry);
					}
				}
				else {
					this.extSearchTypeValue = {countries: [selectedCountry]};
				}
			}
		}

		removeCountryFromList(e) {
			return(e) => {
				let idx = this.extSearchTypeValue.countries.indexOf(e.item.country);
				this.extSearchTypeValue.countries.splice(idx, 1);
			}
		}

		centerSelected(center) {
			if (this.extSearchTypeValue && this.extSearchTypeValue.centers && this.extSearchTypeValue.centers.length > 0) {
				let ex = this.extSearchTypeValue.centers.filter((c) => {
					return c.id == center.id;
				});

				if (ex.length == 0) { this.extSearchTypeValue.centers.push(center); }
			}
			else {
				this.extSearchTypeValue = {centers: [center]};
			}

			this.update();
		}

		removeCenterFromList(e) {
			return(e) => {
				this.extSearchTypeValue.centers = this.extSearchTypeValue.centers.filter((center) => {
					return e.item.center.id != center.id;
				});
				this.loadSearchInput();
			}
		}

		applyExtSearchSettings(e) {
			return(e) => {
				if (this.extSearchType == 'global') { this.extSearchTypeValue = {global: true}; }

				console.log("Search Applied", this.extSearchTypeValue);
				this.extSearchApply = true;
				this.update();
				this.setSearchParams();
				this.parent.performSearch(1);
			}
		}

		clearExtSearch(e) {
			return(e) => {
				this.showExtSearch      = false;
				this.extSearchApply     = false;
				this.extSearchType      = null;
				this.extSearchTypeValue = {};
				this.update();
				this.setSearchParams();
				this.parent.performSearch(1);
			}
		}

		let state = this.parent.opts.store.getState().participants;

		formatResults(center) {
			let attributes = [center.area, center.country, center.region, center.state, center.city].join(', ');
			let value      = center.name + ' - ' + center.category + ' [' + attributes + ']';

			return {value: value, data: center};
		}

		loadSearchInput() {
			$("#form-search-center").autocomplete({
				minChars : 2,
				lookup   : (query, done) => {

					let params = {
						page    : 1,
						limit   : 10,
						keyword : query
					}

					this.parent.opts.centerService.search(params, (err, response) => {
						if (!err && response.body().length) {
							let result = response.body()[0].data();

							done({suggestions: result.centers.map(this.formatResults)});
						}
						else {
							done({suggestions: []});
						}
					});
				},
				onSelect : (item) => {
					$("#form-search-center")[0].value = '';
					this.centerSelected(item.data);
				}
			});
		}

		if (state.view == "SEARCH_PARTICIPANT" && state.query) {
			setTimeout(()=>{
				this.refs.searchQ.value = state.query.keyword ? state.query.keyword : '';
			}, 10);
		}

	</script>

</participant-search>
