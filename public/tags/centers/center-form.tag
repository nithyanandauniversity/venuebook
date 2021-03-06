<center-form
	class = "ui container"
	style = "margin: 25px 0;">

	<div class="ui">
		<div class="row" style="margin-bottom: 35px;">
			<h2>
				<span>
					{opts.state.view == 'ADD_CENTER' ? 'Create New' : 'Edit'} Center {opts.state.view == 'EDIT_CENTER' && center && ' [' + center.code + ']'}
				</span>
				<div
					class   = "ui primary basic button right floated"
					onclick = { parent.showList }>
					<i class="chevron left icon"></i> Back
				</div>
			</h2>
		</div>

		<div class="ui form">
			<h4 class="ui dividing header">
				Center Information
			</h4>

			<div class="four fields">
				<div class="field">
					<label for="name">Center Name</label>
					<input type="text" ref="name" placeholder="Center Name" />
				</div>
				<div class="field">
					<label for="area">Area</label>
					<!-- <input type="text" ref="area" placeholder="Area (Ex: North America)" /> -->
					<select
						ref      = "area"
						class    = "ui search dropdown">
						<option value="">Select area to add...</option>
						<option
							each    = "{area in parent.center_areas.obj}"
							value   = "{area}">
							{area}
						</option>
					</select>
				</div>
				<div class="field">
					<label for="country">Country</label>
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
			</div>

			<div class="three fields">
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

			<div style="text-align: center;">
				<div
					class = "ui pointing above red label"
					show  = "{validation && validation.incompleteCenter}">
					All fields are mandatory for creating a center!
				</div>
			</div>

			<h4 class="ui dividing header" show="{!hideAdmin}">
				Center Administrator
			</h4>

			<div class="four fields" show="{!hideAdmin}">
				<div class="field {validation && validation.emptyName && 'error'}">
					<label for="first_name">First Name</label>
					<input type="text" ref="first_name" placeholder="First Name" />
				</div>
				<div class="field">
					<label for="last_name">Last Name</label>
					<input type="text" ref="last_name" placeholder="Last Name" />
				</div>
				<div class="field {validation && (validation.emptyEmail || !validation.validEmail) && 'error'}">
					<label for="email">Email Address</label>
					<input type="text" ref="email" placeholder="Email Address" />
				</div>
				<div class="field {validation && validation.emptyPassword && 'error'}">
					<label for="password">Password</label>
					<input type="password" ref="password" placeholder="Password" />
				</div>
			</div>
		</div>

		<div class="ui two column grid">
			<div class="ui left aligned column">
				<label style="font-size: 0.7em;">
					<input type="checkbox" onclick="{ toggleCenterAdmin() }" ref = "no_center_admin" />
					Create Center without an Administrator?
				</label>
			</div>

			<div class="ui right aligned column">
				<div class="column">
					<button class="ui large green button" onclick="{save}">
						SAVE
					</button>
					<button class="ui large red button" onclick="{cancel}">
						{opts.state.view == 'ADD_CENTER' ? 'RESET' : 'CANCEL'}
					</button>
				</div>
			</div>
		</div>


	</div>

	<script>

		const self = this;

		loadEditForm(center, admin) {
			this.refs.name.value     = center.name;
			this.refs.category.value = center.category;
			this.refs.city.value     = center.city;
			this.refs.state.value    = center.state;
			this.refs.country.value  = center.country;
			this.refs.area.value     = center.area;
			this.refs.region.value   = center.region;

			this.refs.first_name.value = admin.first_name;
			this.refs.last_name.value  = admin.last_name;
			this.refs.email.value      = admin.email;

			(".ui.search.dropdown").dropdown({
				forceSelection  : false,
				selectOnKeydown : false
			});

			this.update();
		}

		this.edit_id = this.opts.state.id;

		if (this.edit_id) {
			let state = self.parent.opts.state;
			console.log(self.opts.state);

			this.parent.opts.service.get(this.edit_id, (err, response) => {
				if (!err) {
					let result  = response.body().data();
					this.center = result.center;
					this.admin  = result.admin;
					this.loadEditForm(this.center, this.admin);
				}
				else {
					this.center = null;
					console.log("ERROR LOADING CENTER !");
				}
			});
		}
		else {
			setTimeout(() => {
				$(".ui.search.dropdown").dropdown({
					forceSelection  : false,
					selectOnKeydown : false
				});
			}, 100)
		}

		this.countries        = this.parent.opts.countries();
		this.centerCategories = this.parent.opts.centerCategories;

		toggleCenterAdmin(e) {
			return(e) => {
				this.hideAdmin = !this.hideAdmin;
				this.update();
			}
		}

		validateForm(params) {
			let emailRegex  = new RegExp(/^[a-z0-9](\.?[a-z0-9_-]){0,}@[a-z0-9-]+\.([a-z]{1,6}\.)?[a-z]{2,6}$/);
			this.validation = {};

			if (
				(!params.center.name || params.center.name == '') ||
				(!params.center.category || params.center.category == '') ||
				(!params.center.city || params.center.city == '') ||
				(!params.center.state || params.center.state == '') ||
				(!params.center.region || params.center.region == '') ||
				(!params.center.country || params.center.country == '') ||
				(!params.center.area || params.center.area == '')
			) {
				this.validation.incompleteCenter = true;
			}

			if (params.admin) {
				if (!params.admin.first_name || params.admin.first_name == '') {
					this.validation.emptyName = true;
				}

				if (!this.edit_id && (!params.admin.password || params.admin.password == '')) {
					this.validation.emptyPassword = true;
				}

				if (params.admin.email && params.admin.email != '') {
					this.validation.emptyEmail = false;
					this.validation.validEmail = emailRegex.test(params.admin.email);
				}
				else {
					this.validation.emptyEmail = true;
				}

				return !this.validation.emptyName && !this.validation.emptyPassword
					&& (this.validation.validEmail && !this.validation.emptyEmail)
					&& !this.validation.incompleteCenter;
			}
			else {
				return !this.validation.incompleteCenter;
			}



			// return is_valid;
		}

		save() {
			let saveParams = this.generateCenterParams();

			if (!this.validateForm(saveParams)) {
				console.log("this.validation");
				console.log(this.validation);
				return false;
			}

			if (!this.edit_id) {
				// CREATE PARTICIPANT
				this.create(saveParams);
			}
			else {
				// EDIT PARTICIPANT
				this.edit(saveParams);
			}
		}

		generateCenterParams() {
			let centerParams = {
				name     : this.refs.name.value,
				category : this.refs.category.value,
				city     : this.refs.city.value,
				state    : this.refs.state.value,
				region   : this.refs.region.value,
				country  : this.refs.country.value,
				area     : this.refs.area.value
			};

			let adminParams = {
				first_name : this.refs.first_name.value,
				last_name  : this.refs.last_name.value,
				email      : this.refs.email.value
			};

			let no_center_admin = this.refs.no_center_admin.checked;

			if (!this.edit_id || (this.refs.password.value && this.refs.password.value != '')) {
				adminParams.password = this.refs.password.value;
			}

			let param = { center : centerParams };

			if (!no_center_admin) {
				param.admin = adminParams;
			}

			return param;
		}

		create(data) {
			this.parent.opts.service.create(data, (err, response) => {
				if (!err) {
					// console.log(response.body().data(), response.statusCode());
					this.parent.showList();
				}
				else {
					console.log("err");
					console.log(err);
				}
			});
		}

		edit(data) {
			this.parent.opts.service.update(this.edit_id, data, (err, response) => {
				if (!err) {
					this.parent.showList();
				}
			});
		}

		reset() {
			this.refs.name.value       = ""
			this.refs.category.value   = ""
			this.refs.city.value       = ""
			this.refs.state.value      = ""
			this.refs.region.value     = ""
			this.refs.country.value    = ""
			this.refs.area.value       = ""
			this.refs.first_name.value = ""
			this.refs.last_name.value  = ""
			this.refs.email.value      = ""
			this.refs.password.value   = ""

			self.update();
		}

		cancel() {
			if (this.opts.state.view == 'ADD_CENTER') {
				this.reset();
			}
			else {
				this.parent.showList();
			}
		}

	</script>

</center-form>
