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
					<input type="text" ref="area" placeholder="Area (Ex: North America)" />
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

			<h4 class="ui dividing header">
				Center Administrator
			</h4>

			<div class="four fields">
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
					<input type="text" ref="password" placeholder="Password" />
				</div>
			</div>
		</div>

		<div class="ui right aligned grid">
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

	<script>

		const self = this;

		// this.validation = {};

		setGender(e) {
			return (e) => {
				self.gender = e.target.dataset.value;
			}
		}

		setGrad(e) {
			return (e) => {
				console.log(e.target.dataset.value);
				self.ia_graduate = e.target.dataset.value;
			}
		}

		setHealer(e) {
			return (e) => {
				self.is_healer = e.target.dataset.value;
			}
		}

		getDefault(c) {
			return c.default;
		}

		markContactDefault(e) {
			return (e) => {
				let def = self.contacts.filter(self.getDefault)[0];
				def.default            = false;
				e.item.contact.default = true;
			}
		}

		markAddressDefault(e) {
			return (e) => {
				let def = self.addresses.filter(self.getDefault)[0];
				def.default            = false;
				e.item.address.default = true;
			}
		}

		removeContact(e) {
			return (e) => {
				let contact = this.contacts[e.item.i];

				if (!contact.id) {
					self.contacts.splice(e.item.i, 1);
				}
				else {
					if (confirm("Are you sure you want to remove this Contact information?")) {
						this.parent.opts.service.removeContact(this.edit_id, contact.id, (err, response) => {
							if (!err) {
								self.contacts.splice(e.item.i, 1);
							}
						});
					}
				}
			}
		}

		removeAddress(e) {
			return (e) => {
				let address = this.addresses[e.item.i];

				if (!address.id) {
					self.addresses.splice(e.item.i, 1);
				}
				else {
					if (confirm("Are you sure you want to remove this Address?")) {
						this.parent.opts.service.removeAddress(this.edit_id, address.id, (err, response) => {
							if (!err) {
								self.addresses.splice(e.item.i, 1);
							}
						});
					}
				}
			}
		}

		insertContact(def = false, id = undefined) {
			this.contacts.push({
				id           : id,
				contact_type : 'Home',
				value        : '',
				default      : def
			});
		}

		insertAddress(def = false, id = undefined) {
			this.addresses.push({
				id          : id,
				street      : '',
				city        : '',
				state       : '',
				postal_code : '',
				country     : '',
				default     : def
			});
		}

		this.on('create', () => {

			$("#participant-dob").calendar({
				type: 'date'
			});

			self.insertContact(true);
			self.insertAddress(true);

			self.update();
		});

		// loadEditForm(participant, attr) {
		// 	console.log("participant, attr");
		// 	console.log(participant, attr);

		// 	this.refs.first_name.value  = participant.first_name;
		// 	this.refs.last_name.value   = participant.last_name;
		// 	this.refs.email.value       = participant.email;
		// 	this.refs.other_names.value = participant.other_names;
		// 	this.refs.dob.value         = participant.dob;
		// 	this.refs.notes.value       = participant.notes;
		// 	this.gender                 = participant.gender;

		// 	this.refs.role.value     = attr.role;
		// 	this.ia_graduate         = attr.ia_graduate;
		// 	this.refs.ia_dates.value = attr.ia_dates;
		// 	this.is_healer           = attr.is_healer;

		// 	participant.contacts.forEach((c) => { this.insertContact(c.id == participant.default_contact, c.id) });
		// 	participant.addresses.forEach((a) => { this.insertAddress(a.id == participant.default_address, a.id) });

		// 	this.update();

		// 	this.assignAddresses(participant.addresses);
		// 	this.assignContacts(participant.contacts);
		// }

		this.on('edit', () => {
			let state = self.parent.opts.state;
			console.log(self.opts.state);

			this.edit_id = this.opts.state.id;
			// this.parent.opts.service.get(this.edit_id, (err, response) => {
			// 	if (!err) {
			// 		this.participant = response.body().data();
			// 		this.attributes  = JSON.parse(this.participant.participant_attributes);
			// 		this.loadEditForm(this.participant, this.attributes);
			// 	}
			// 	else {
			// 		this.participant = null;
			// 		console.log("ERROR LOADING PARTICIPANT !");
			// 	}
			// });

		});

		this.countries        = this.parent.opts.countries();
		this.centerCategories = this.parent.opts.centerCategories;

		validateForm(params) {
			let emailRegex = new RegExp(/^[a-z0-9](\.?[a-z0-9_-]){0,}@[a-z0-9-]+\.([a-z]{1,6}\.)?[a-z]{2,6}$/);
			this.validation = {};

			if (!params.admin.first_name || params.admin.first_name == '') {
				this.validation.emptyName = true;
			}

			if (!params.admin.password || params.admin.password == '') {
				this.validation.emptyPassword = true;
			}

			if (params.admin.email && params.admin.email != '') {
				this.validation.emptyEmail = false;
				this.validation.validEmail = emailRegex.test(params.admin.email);
			}
			else {
				this.validation.emptyEmail = true;
			}

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

			let is_valid = !this.validation.emptyName && !this.validation.emptyPassword
				&& (this.validation.validEmail && !this.validation.emptyEmail)
				&& !this.validation.incompleteCenter;

			return is_valid;
		}

		save() {
			let saveParams = this.generateCenterParams();
			// this.errors = this.validateForm(saveParams);

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
			return {
				center : {
					name     : this.refs.name.value,
					category : this.refs.category.value,
					city     : this.refs.city.value,
					state    : this.refs.state.value,
					region   : this.refs.region.value,
					country  : this.refs.country.value,
					area     : this.refs.area.value
				},
				admin : {
					first_name : this.refs.first_name.value,
					last_name  : this.refs.last_name.value,
					email      : this.refs.email.value,
					password   : this.refs.password.value
				}
			};
		}

		create(data) {
			console.log("data");
			console.log(data);
			this.parent.opts.service.create(data, (err, response) => {
				if (!err) {
					console.log(response.body().data(), response.statusCode());
					this.parent.showList();
				}
				else {
					console.log("err");
					console.log(err);
				}
			});
		}

		edit(data) {
			console.log("data");
			console.log(data);
			// this.parent.opts.service.update(this.edit_id, data, (err, response) => {
			// 	if (!err) {
			// 		console.log(response.body().data(), response.statusCode());
			// 		this.parent.showList();
			// 	}
			// });
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
