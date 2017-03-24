<user-form
	class = "ui container"
	style = "margin: 25px 0;">

	<div class="ui">
		<div class="row" style="margin-bottom: 35px;">
			<h2>
				<span>
					{opts.state.view == 'ADD_USER' ? 'Create New' : 'Edit'} User {opts.state.view == 'EDIT_USER' && user && ' [' + user.email + ']'}
				</span>
				<div
					class   = "ui primary basic button right floated"
					onclick = "{ parent.showList }">
					<i class="chevron left icon"></i> Back
				</div>
			</h2>
		</div>

		<div class="ui form">

			<div style="margin-bottom: 1.5em;">
				<h4 class="ui horizontal divider header {validation && validation.emptyRole && 'red'}">
					<i class="icon legal"></i>
					Select User Role
				</h4>

				<div
					if    = "{userRoles && userRoles.length}"
					class = "ui fluid five item large menu">
					<a
						each    = "{ role in userRoles }"
						onclick = "{ setActiveRole() }"
						class   = "item {activeRole == role.value && 'active green'} {role.name == 'CENTER_ADMIN' && 'disabled'}">
						<strong>{role.label}</strong>
					</a>
				</div>
			</div>

			<div show="{activeRole >= 2}" style="margin-bottom: 1.5em;">
				<h4 class="ui horizontal divider header">
					<i class="icon street view"></i>
					Center / Access Information
				</h4>

				<div class="ui two column grid">
					<div class="{activeRole > 3 && 'right aligned middle aligned content'} six wide column">
						<div
							show  = "{ activeRole == 2 }"
							class = "field">
							<h3>Select Lead Type</h3>
							<div class="ui fluid vertical pointing menu">
								<a
									each    = "{leadTypes}"
									onclick = "{ setLeadType() }"
									class   = "item {leadType == value && 'active brown'}">
									{label}
								</a>
							</div>
						</div>
						<div show = "{ activeRole > 3 }">
							<h3>Select Primary Center :</h3>
						</div>

						<div
							show  = "{validation && validation.emptyLeadType}"
							class = "column center aligned">
							<div class = "ui pointing above red label">
								Select Lead Type
							</div>
						</div>
					</div>

					<div class="ten wide column">
						<!-- SELECT AREAS IF LEAD TYPE IS AREA -->
						<div
							class = "field"
							show  = "{activeRole == 2 && leadType == 'area'}">
							<h3>Select Areas :</h3>
							<div style = "margin-bottom: 1rem;">
								<div
									each  = "{ area in leadTypeValue.areas }"
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
								ref      = "lead_area"
								class    = "ui search dropdown">
								<option value="">Select area to add...</option>
								<option
									each    = "{area in parent.center_areas.obj}"
									value   = "{area}">
									{area}
								</option>
							</select>
						</div>

						<!-- SELECT COUNTRIES IF LEAD TYPE IS COUNTRY -->
						<div
							class = "field"
							show  = "{activeRole == 2 && leadType == 'country'}">
							<h3>Select Countries :</h3>
							<div style = "margin-bottom: 1rem;">
								<div
									each  = "{ country in leadTypeValue.countries }"
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
								ref      = "lead_country"
								class    = "ui search dropdown">
								<option value="">Select country to add...</option>
								<option
									each    = "{country in countries}"
									value   = "{country.value}">
									{country.value}
								</option>
							</select>
						</div>

						<!-- SELECT CENTER IF USER IS PROGRAM_COORDINATOR OR DATA_ENTRY -->
						<div
							class = "field"
							show  = "{ activeRole > 3 || (activeRole == 2 && leadType == 'center')}">
							<label show = "{ activeRole == 2 }">Select Centers :</label>
							<div style = "{ activeRole == 2 && 'margin-bottom: 1rem;'}">
								<div
									each  = "{ center in leadTypeValue.centers }"
									style = "margin-right: 8px;"
									class = "ui icon buttons">
									<button class = "ui button">
										{ center.name }
									</button>
									<button
										class   = "ui icon button"
										onclick = "{ removeCenterFromList() }">
										<i class = "icon remove"></i>
									</button>
								</div>
							</div>
							<div
								show = "{ activeRole < 3 || !leadTypeValue.centers || !leadTypeValue.centers.length }"
								class = "ui large input">
								<input
									type        = "text"
									id          = "form-search-center"
									placeholder = "Search for centers..." />
							</div>
						</div>

						<div
							show  = "{leadType && validation && validation.emptyLeadParams}"
							class = "ui pointing above red label">
							Select {leadType}(s) to assign user to...
						</div>
						<div
							show  = "{validation && validation.emptyCenter}"
							class = "ui pointing above red label">
							Select primary center...
						</div>
					</div>
				</div>
			</div>

			<div style="margin-bottom: 1.5em;">
				<h4 class="ui horizontal divider header">
					<i class="icon privacy"></i>
					Enter Login Credentials
				</h4>

				<div class="four fields">
					<div class="field {validation && validation.emptyName && 'error'}">
						<label>First Name</label>
						<input type="text" ref="first_name" placeholder="First Name" />
					</div>
					<div class="field">
						<label>Last Name</label>
						<input type="text" ref="last_name" placeholder="Last Name" />
					</div>
					<div class="field {validation && validation.emptyEmail && 'error'}">
						<label>Email</label>
						<input type="text" ref="email" placeholder="Email Address" />
					</div>
					<div class="field {validation && validation.emptyPassword && 'error'}">
						<label>Password</label>
						<input type="password" ref="password" placeholder="Password" />
					</div>
				</div>
			</div>

			<div class="ui divider"></div>

			<div class="ui grid actions">
				<div class="right aligned column">
					<div onclick="{ parent.showList }" class="ui orange button">Cancel</div>
					<div onclick="{ save }" class="ui green button">Save</div>
				</div>
			</div>

		</div>

	</div>


	<script>

		this.countries     = this.parent.opts.countries();
		this.leadTypeValue = {};

		setActiveRole(e) {
			return(e) => {
				if (e.item.role.name == 'CENTER_ADMIN') { return; }
				this.leadTypeValue = {};
				this.activeRole    = e.item.role.value;
				this.update();
			}
		}

		this.leadTypes = [
			{label: "Lead by Area", value: "area"},
			{label: "Lead by Country", value: "country"},
			{label: "Lead by Center", value: "center"}
		];

		setLeadType(e) {
			return(e) => {
				this.leadType = e.item.value;
				this.update();
			}
		}

		areaSelected(e) {
			return(e) => {
				let selectedArea = this.refs['lead_area'].value;
				if (this.leadTypeValue && this.leadTypeValue.areas && this.leadTypeValue.areas.length > 0) {
					if (!this.leadTypeValue.areas.includes(selectedArea)) {
						this.leadTypeValue.areas.push(selectedArea);
					}
				}
				else {
					this.leadTypeValue = {areas: [selectedArea]};
				}
			}
		}

		removeAreaFromList(e) {
			return(e) => {
				let idx = this.leadTypeValue.areas.indexOf(e.item.area);
				this.leadTypeValue.areas.splice(idx, 1);
			}
		}

		countrySelected(e) {
			return(e) => {
				let selectedCountry = this.refs['lead_country'].value;
				if (this.leadTypeValue && this.leadTypeValue.countries && this.leadTypeValue.countries.length > 0) {
					if (!this.leadTypeValue.countries.includes(selectedCountry)) {
						this.leadTypeValue.countries.push(selectedCountry);
					}
				}
				else {
					this.leadTypeValue = {countries: [selectedCountry]};
				}
			}
		}

		removeCountryFromList(e) {
			return(e) => {
				let idx = this.leadTypeValue.countries.indexOf(e.item.country);
				this.leadTypeValue.countries.splice(idx, 1);
			}
		}

		centerSelected(center) {
			if (this.leadTypeValue && this.leadTypeValue.centers && this.leadTypeValue.centers.length > 0) {
				let ex = this.leadTypeValue.centers.filter((c) => {
					return c.id == center.id;
				});

				if (ex.length == 0) {
					this.leadTypeValue.centers.push(center);
				}
			}
			else {
				this.leadTypeValue = {centers : [center]};
			}

			this.update();
		}

		removeCenterFromList(e) {
			return(e) => {
				this.leadTypeValue.centers = this.leadTypeValue.centers.filter((center) => {
					return e.item.center.id != center.id;
				});
			}
		}

		generateUserParams() {
			let params = {
				role       : this.activeRole,
				first_name : this.refs['first_name'].value,
				last_name  : this.refs['last_name'].value,
				email      : this.refs['email'].value,
				password   : this.refs['password'].value
			};

			if (this.activeRole) {

				if (this.activeRole == 2) {
					params.permissions = {};

					if (this.leadType == 'area') {
						params.permissions.areas = this.leadTypeValue.areas;
					}
					else if (this.leadType == 'country') {
						params.permissions.countries = this.leadTypeValue.countries;
					}
					else if (this.leadType == 'center') {
						params.permissions.centers = this.leadTypeValue.centers && this.leadTypeValue.centers.length ? this.leadTypeValue.centers.map((c) => { return c.id; }) : null;
					}
				}
				else if (this.activeRole > 3) {
					params.center_id = this.leadTypeValue && this.leadTypeValue.centers && this.leadTypeValue.centers.length ? this.leadTypeValue.centers[0].id : null;
				}
			}

			return {user: params};
		}

		validateForm(params) {
			let emailRegex  = new RegExp(/^[a-z0-9](\.?[a-z0-9_-]){0,}@[a-z0-9-]+\.([a-z]{1,6}\.)?[a-z]{2,6}$/);
			this.validation = {};

			if (!params.user.first_name || params.user.first_name == '') {
				this.validation.emptyName = true;
			}

			if (params.user.email && params.user.email != '') {
				this.validation.emptyEmail = false;
				this.validation.validEmail = emailRegex.test(params.user.email);
			}
			else {
				this.validation.emptyEmail = true;
			}

			if (!params.user.password || params.user.password == '') {
				this.validation.emptyPassword = true;
			}

			if (!params.user.role || params.user.role < 1) {
				this.validation.emptyRole = true;
			}

			if (params.user.role > 3 && (!params.user.center_id || params.user.center_id == '')) {
				this.validation.emptyCenter = true;
			}

			if (params.user.role == 2) {
				if (!this.leadType || ['area', 'country', 'center'].indexOf(this.leadType) < 0) {
					this.validation.emptyLeadType = true;
				}

				if (
					(!params.user.permissions.areas || !params.user.permissions.areas.length) &&
					(!params.user.permissions.countries || !params.user.permissions.countries.length) &&
					(!params.user.permissions.centers || !params.user.permissions.centers.length)
				) {
					this.validation.emptyLeadParams = true;
				}
			}

			return !this.validation.emptyName
				&& (this.validation.validEmail && !this.validation.emptyEmail)
				&& !this.validation.emptyRole
				&& !this.validation.emptyCenter
				&& !this.validation.emptyLeadParams;
		}

		save() {
			let saveParams = this.generateUserParams();

			console.log("saveParams");
			console.log(saveParams);

			if (!this.validateForm(saveParams)) {
				return false;
			}

			if (saveParams.user.role == 2 && saveParams.user.permissions) {
				console.log('setting json text');
				saveParams.user.permissions = JSON.stringify(saveParams.user.permissions);
			}

			console.log("SAVE !!!");

			if (!this.edit_id) {
				// CREATE RECORD
				this.create(saveParams);
			}
			else {
				// UPDATE RECORD
			}
		}

		create(data) {
			this.parent.opts.service.create(data, (err, response) => {
				if (!err) {
					this.parent.showList();
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

				this.update();
			}
		}

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
					$("#form-search-center")[0].value = '';
					this.centerSelected(item.data);
					// this.doSearch();
				}
			});
		}

		this.edit_id = this.opts.state.id;

		console.log("this.edit_id");
		console.log(this.edit_id);

		setTimeout(() => {
			this.loadSearchInput();
			this.generateUserRoleList();
			$(".ui.search.dropdown").dropdown({
				forceSelection  : false,
				selectOnKeydown : false
			});
		}, 100)
	</script>

</user-form>
