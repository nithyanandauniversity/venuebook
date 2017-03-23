<user-search
	class = "ui container"
	id    = "participant-search"
	style = "margin: 25px 0;">

	<div class="ui fluid right action left icon input">
		<i class="search icon"></i>
		<input
			type         = "text"
			ref          = "searchQ"
			placeholder  = "Search for users..."
			onkeypress   = "{ triggerSearch() }"
			autocomplete = "off" />
		<div
			class   = "ui primary basic button"
			onclick = { parent.showNew }>
			<i class = "add user icon"></i> Create New
		</div>
	</div>

	<div class="ui segment form">
		<div class="ui two column middle aligned very relaxed stackable grid">
			<div class="column">
				<div class="field">
					<h3>Filter by Center : </h3>
					<div
						if    = "{ parent.selectedCenter }"
						class = "ui icon large buttons">
						<button class = "ui basic orange button">
							{parent.selectedCenter.name}
						</button>
						<button
							class   = "ui basic orange icon button"
							onclick = "{ clearCenterSelection() }">
							<i class = "icon remove"></i>
						</button>
					</div>
					<div
						show  = "{!parent.selectedCenter}"
						class = "ui large input">
						<input
							type        = "text"
							placeholder = "Search for Center..."
							class       = "large"
							id          = "search-center" />
					</div>
				</div>
			</div>

			<div
				class = "ui vertical divider"
				style = "left: 50%;">Or</div>

			<div class="column">
				<h3>Filter by User Role : </h3>
				<div
					if    = "{userRoles && userRoles.length}"
					class = "ui fluid five item mini menu">
					<a
						each    = "{ role in userRoles }"
						onclick = "{ selectRoleFilter() }"
						class   = "item {role.active && 'active green'}">
						<strong>{role.label}</strong>
					</a>
				</div>
				<!-- <div
					if    = "{userRoles && userRoles.length}"
					class = "ui buttons">
					<button
						each  = "{ role in userRoles }"
						class = "ui { role.active && 'olive' || 'basic green'} button">
						<span>{role.label}</span>
					</button>
				</div> -->
			</div>
		</div>
	</div>

	<script>

		this.showFilters = false;

		console.log("this.parent.opts");
		console.log(this.parent.opts);

		toggleFilter() {
			return(e) => {
				this.showFilters = !this.showFilters;
			}
		}

		generateFilters() {
			let filters = {};
			console.log("this.parent.selectedCenter");
			console.log(this.parent.selectedCenter);
			if (this.parent.selectedCenter) {
				filters['center_id'] = this.parent.selectedCenter.id;
			}

			if (this.userRoles && this.userRoles.length) {
				filters['roles'] = this.userRoles.reduce((arr, itm) => {
					if (itm.active) {
						arr.push(itm.value);
					}
					return arr;
				}, []);
			}

			console.log("filters");
			console.log(filters);
			return filters;
		}

		doSearch() {
			this.parent.searchFilters = this.generateFilters();
			this.parent.searchQ       = this.refs.searchQ.value;
			this.parent.performSearch(1);
		}

		triggerSearch(e) {
			return(e) => {
				if (e.which === 13) {
					this.doSearch();
				}
			}
		}

		formatResults(center) {
			let attributes = [center.area, center.country, center.region, center.state, center.city].join(', ');
			let value      = center.name + ' - ' + center.category + ' [' + attributes + ']';

			return {value: value, data: center};
		}

		selectRoleFilter(e) {
			return(e) => {
				e.item.role.active = !e.item.role.active;
				this.doSearch();
			}
		}

		loadSearchInput() {
			$("#search-center").autocomplete({
				minChars : 2,
				lookup   : (query, done) => {

					let params = {
						page    : 1,
						limit   : 10,
						keyword : query
					}

					// if (this.opts.currentUser.role > 2) {
					// 	params.center_id = this.opts.currentUser.center_id;
					// }

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
					$("#search-center")[0].value = '';
					this.parent.assignCenter(item.data)
					this.doSearch();
				}
			});
		}

		generateUserRoleList() {
			if (this.parent.opts.userRoles) {
				this.userRoles = [];
				for (let role in this.parent.opts.userRoles) {
					this.userRoles.push({
						name  : role,
						label : role.split('_').join(' '),
						value : this.parent.opts.userRoles[role]
					});
				}
				console.log("this.userRoles");
				console.log(this.userRoles);
				this.update();
			}
		}

		clearCenterSelection(e) {
			return(e) => {
				this.parent.assignCenter(null);
				this.doSearch();
			}
		}

		setTimeout(() => {
			this.loadSearchInput();
			this.generateUserRoleList();
		}, 100)


	</script>

</user-search>
