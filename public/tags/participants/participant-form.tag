<participant-form
	class = "ui container"
	style = "margin: 25px 0;">

	<div class="ui">
		<div class="row" style="margin-bottom: 35px;">
			<h2>
				<span>
					{opts.state.view == 'ADD_PARTICIPANT' ? 'Create New' : 'Edit'} Participant {opts.state.view == 'EDIT_PARTICIPANT' && participant && ' [' + participant.member_id + ']'}
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
				Personal Information
			</h4>

			<div class="fields">
				<div class="five wide field {validation && validation.emptyName && 'error'}">
					<label for = "first_name">First name</label>
					<input type="text" ref="first_name" placeholder="First Name" />
				</div>
				<div class="five wide field">
					<label for="last_name">Last name</label>
					<input type="text" ref="last_name" placeholder="Last Name" />
				</div>
				<div class="six wide field {validation && ((validation.emptyEmail && validation.emptyContact) || (!validation.emptyEmail && !validation.validEmail)) && 'error'}">
					<label for="email">Email</label>
					<input type="text" ref="email" placeholder="Email Address" />
				</div>
			</div>

			<div class="fields">
				<div class="six wide field">
					<label for="other_names">Spiritual name</label>
					<input type="text" ref="other_names" placeholder="Spiritual Name" />
				</div>

				<div class="three wide field">
					<label for="role">SMKT Role</label>
					<select ref="role" class="ui search dropdown">
						<option value="0">None</option>
						<option value="1">Volunteer</option>
						<option value="2">Thanedar</option>
						<option value="3">Kotari</option>
						<option value="4">Mahant</option>
						<option value="5">SriMahant</option>
					</select>
				</div>

				<div class="three wide field">
					<label for="gender">Gender</label>
					<div class="ui buttons">
						<button
							class      = "ui button {gender == 'Male' && 'primary active'}"
							data-value = "Male"
							onclick    = {setGender('Male')}>Male</button>
						<button
							class      = "ui button {gender == 'Female' && 'primary active'}"
							data-value = "Female"
							onclick    = {setGender('Female')}>Female</button>
					</div>
				</div>

				<div class="four wide field">
					<label for="dob">Date of Birth</label>
					<div class="ui calendar" id="participant-dob">
						<div class="ui input left icon">
							<i class="calendar icon"></i>
							<input type="text" ref="dob" readonly="" placeholder="Date of Birth" />
						</div>
					</div>
				</div>
			</div>

			<!-- <h4 class="ui dividing header">
				Inner Awakening
			</h4> -->

			<div class="fields">
				<div class="right floated eight wide column field">
					<label for="notes">Notes</label>
					<textarea ref="notes" rows="5"></textarea>
				</div>

				<div class="field">
					<label for="ia_grad">IA Graduate?</label>
					<div class="ui buttons">
						<button
							class      = "ui button {ia_graduate == 1 && 'primary active'}"
							data-value = 1
							onclick    = {setGrad()}>Yes</button>
						<button
							class      = "ui button {ia_graduate == 0 && 'secondary active'}"
							data-value = 0
							onclick    = {setGrad()}>No</button>
					</div>
				</div>

				<div class="four wide field" show={ia_graduate == 1}>
					<label for="ia_dates">IA Dates</label>
					<input type="text" ref="ia_dates" placeholder="IA Dates (MMM, YYYY)" />
				</div>

				<div class="field" show={ia_graduate == 1}>
					<label for="ia_grad">Healer?</label>
					<div class="ui buttons">
						<button
							class      = "ui button {is_healer == 1 && 'primary active'}"
							data-value = 1
							onclick    = {setHealer()}>Yes</button>
						<button
							class      = "ui button {is_healer == 0 && 'secondary active'}"
							data-value = 0
							onclick    = {setHealer()}>No</button>
					</div>
				</div>
			</div>

			<div class="fields">
				<div class="right floated eight wide column field">
					<label>Enrichers</label>
					<div
						each  = "{ enricher in enrichers }"
						style = "margin-right: 8px; margin-bottom: 6px;"
						class = "ui icon teal { !default_friend || enricher.member_id != default_friend.member_id && 'basic'} buttons">
						<button class = "ui button">
							{enricher.first_name} {enricher.last_name}
						</button>
						<button
							class          = "ui icon button"
							data-tooltip   = "Make Default Enricher"
							data-inverted  = ""
							data-variation = "mini"
							show           = "{ !default_friend || enricher.member_id != default_friend.member_id }"
							onclick        = "{ makeEnricherDefault() }">
							<i class="icon checkmark"></i>
						</button>
						<button
							class          = "ui icon button"
							data-tooltip   = "Remove Enricher"
							data-inverted  = ""
							data-variation = "mini"
							onclick        = "{ removeEnricherFromList() }">
							<i class = "icon remove"></i>
						</button>
					</div>
					<input id = "search-enrichers" type = "text" placeholder = "Search Enrichers from list..." />
				</div>
			</div>


			<div class="fields" style="margin-top: 25px;">
				<div class="eight wide field">
					<h4 class="ui dividing header">
						Contact Information
						<span
							class="ui primary basic tiny button right floated"
							style="position: relative; bottom: 10px;"
							onclick="{addContact()}">
							<i class="plus icon"></i> Add
						</span>
					</h4>

					<table class="ui basic table">
						<tr
							each="{contact, i in contacts}"
							class="{contact.default && 'positive'}">
							<td style="padding-right: 0;">
								<span class={contact.default && 'ui ribbon label'}>#{i + 1}</span>
							</td>
							<td>
								<input
									type        = "text"
									ref         = "{'contact_value_' + i}"
									placeholder = "Contact number" />
							</td>
							<td>
								<select
									ref   = "{'contact_type_' + i}"
									class = "ui dropdown">
									<option value="Mobile">Mobile</option>
									<option value="Home">Home</option>
									<option value="Work">Work</option>
								</select>
							</td>
							<td style="width: 90px; text-align: right;">
								<button
									class          = "circular mini ui icon olive button"
									show           = "{!contact.default}"
									data-tooltip   = "Make Default"
									data-inverted  = ""
									data-variation = "mini"
									onclick        = "{markContactDefault()}">
									<i class="checkmark icon"></i>
								</button>
								<button
									class          = "circular mini ui icon orange button"
									show           = "{!contact.default}"
									data-tooltip   = "Remove Contact"
									data-inverted  = ""
									data-variation = "mini"
									onclick        = "{removeContact()}">
									<i class="remove icon"></i>
								</button>
							</td>
						</tr>
					</table>
					<div style="text-align: center;">
						<span
							show  = "{validation && validation.emptyEmail && validation.emptyContact}"
							class = "ui pointing red basic label">
							Email or Contact number is mandatory
						</span>
					</div>
				</div>
				<div class="eight wide field">
					<h4 class="ui dividing header">
						Address Information
						<span
							class="ui primary basic tiny button right floated"
							style="position: relative; bottom: 10px;"
							onclick="{addAddress()}">
							<i class="plus icon"></i> Add
						</span>
					</h4>

					<table class="ui basic table">
						<tr
							each="{address, i in addresses}"
							class="{address.default && 'positive'}">
							<td style="vertical-align: top;">
								<span class={address.default && 'ui ribbon label'}>#{i + 1}</span>
							</td>
							<td>
								<div class="fields">
									<div class="sixteen wide field">
										<label>Street name</label>
										<input
											type        = "text"
											ref         = "{'street_' + i}"
											placeholder = "Street name" />
									</div>
								</div>
								<div class="fields">
									<div class="six wide field">
										<label>City</label>
										<input
											type        = "text"
											ref         = "{'city_' + i}"
											placeholder = "City">
									</div>
									<div class="six wide field">
										<label>State</label>
										<input
											type        = "text"
											ref         = "{'state_' + i}"
											placeholder = "State">
									</div>
									<div class="six wide field">
										<label>Postal Code</label>
										<input
											type        = "text"
											ref         = "{'postal_code_' + i}"
											placeholder = "Postal Code">
									</div>
								</div>
								<div class="fields">
									<div class="sixteen wide field">
										<label>Country</label>
										<select
											ref   = "{'country_' + i}"
											class = "ui search dropdown">
											<option value="">Select Country...</option>
											<option
												each  = {country in countries}
												value = "{country.value}">
												{country.value}
											</option>
										</select>
									</div>
								</div>
							</td>
							<td style="width: 65px;">
								<button
									class          = "circular mini ui icon olive button"
									show           = "{!address.default}"
									style          = "margin-bottom: 5px;"
									data-tooltip   = "Make Default"
									data-inverted  = ""
									data-variation = "mini"
									onclick        = "{markAddressDefault()}">
									<i class="checkmark icon"></i>
								</button>
								<button
									class          = "circular mini ui icon orange button"
									show           = "{!address.default}"
									data-tooltip   = "Remove Address"
									data-inverted  = ""
									data-variation = "mini"
									onclick        = "{removeAddress()}">
									<i class="remove icon"></i>
								</button>
							</td>
						</tr>
					</table>
					<div style="text-align: center;">
						<span
							show  = "{validation && validation.emptyAddress}"
							class = "ui pointing red basic label">
							Address: City and Country is Mandatory
						</span>
					</div>
				</div>
			</div>

		</div>

		<div class="ui right aligned grid">
			<div class="column">
				<button class="ui large green button" onclick="{save}">
					SAVE
				</button>
				<button class="ui large red button" onclick="{cancel}">
					{opts.state.view == 'ADD_PARTICIPANT' ? 'RESET' : 'CANCEL'}
				</button>
			</div>
		</div>

	</div>

	<script>

		this.currentUser  = this.parent.opts.store.getState().routes.data;

		this.contacts   = [];
		this.addresses  = [];
		this.enrichers  = [];

		setGender(e) {
			return (e) => {
				this.gender = e.target.dataset.value;
			}
		}

		setGrad(e) {
			return (e) => {
				console.log(e.target.dataset.value);
				this.ia_graduate = e.target.dataset.value;
			}
		}

		setHealer(e) {
			return (e) => {
				this.is_healer = e.target.dataset.value;
			}
		}

		addContact(e) {
			return (e) => {
				this.insertContact(false);
			}
		}

		addAddress(e) {
			return (e) => {
				this.insertAddress(false);
			}
		}

		getDefault(c) {
			return c.default;
		}

		markContactDefault(e) {
			return (e) => {
				let def = this.contacts.filter(this.getDefault)[0];
				def.default            = false;
				e.item.contact.default = true;
			}
		}

		markAddressDefault(e) {
			return (e) => {
				let def = this.addresses.filter(this.getDefault)[0];
				def.default            = false;
				e.item.address.default = true;
			}
		}

		removeContact(e) {
			return (e) => {
				let contact = this.contacts[e.item.i];

				if (!contact.id) {
					this.contacts.splice(e.item.i, 1);
				}
				else {
					if (confirm("Are you sure you want to remove this Contact information?")) {
						this.parent.opts.service.removeContact(this.edit_id, contact.id, (err, response) => {
							if (!err) {
								this.contacts.splice(e.item.i, 1);
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
					this.addresses.splice(e.item.i, 1);
				}
				else {
					if (confirm("Are you sure you want to remove this Address?")) {
						this.parent.opts.service.removeAddress(this.edit_id, address.id, (err, response) => {
							if (!err) {
								this.addresses.splice(e.item.i, 1);
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

		loadEditForm(participant, attr) {
			console.log("participant, attr");
			console.log(participant, attr);

			this.refs.first_name.value  = participant.first_name;
			this.refs.last_name.value   = participant.last_name;
			this.refs.email.value       = participant.email;
			this.refs.other_names.value = participant.other_names;
			this.refs.dob.value         = participant.dob;
			this.refs.notes.value       = participant.notes;
			this.gender                 = participant.gender;
			this.default_friend         = {member_id: participant.default_friend};

			this.refs.role.value        = attr.role;
			this.ia_graduate            = attr.ia_graduate;
			this.refs.ia_dates.value    = attr.ia_dates;
			this.is_healer              = attr.is_healer;

			this.enrichers              = participant.friends || [];

			$("#participant-dob").calendar({
				type        : 'date',
				initialDate : participant.dob
			});

			participant.contacts.forEach((c) => { this.insertContact(c.id == participant.default_contact, c.id) });
			participant.addresses.forEach((a) => { this.insertAddress(a.id == participant.default_address, a.id) });

			setTimeout(() => {
				this.loadEnricherSearchInput();
			}, 100);

			this.update();

			this.assignAddresses(participant.addresses);
			this.assignContacts(participant.contacts);
		}

		this.countries = this.parent.opts.countries();
		this.dialcodes = this.parent.opts.dialcodes;

		generateAddresses(addresses) {
			return addresses.reduce((data, record, i) => {
				let address = {
					street      : this.refs['street_' + i].value,
					city        : this.refs['city_' + i].value,
					state       : this.refs['state_' + i].value,
					postal_code : this.refs['postal_code_' + i].value,
					country     : this.refs['country_' + i].value,
					default     : record.default
				};

				if ((address.city && address.city.length > 0) && (address.country != '' && address.country.length > 0)) {
					data.push(address);
				}

				return data;
			}, []);
		}

		assignAddresses(addresses) {
			addresses.forEach((address, i) => {
				this.refs['street_' + i].value      = address.street
				this.refs['city_' + i].value        = address.city
				this.refs['state_' + i].value       = address.state
				this.refs['postal_code_' + i].value = address.postal_code
				this.refs['country_' + i].value     = address.country
			});
		}

		generateContacts(contacts) {
			return contacts.reduce((data, record, i) => {
				let contact = {
					contact_type : this.refs['contact_type_' + i].value,
					value        : this.refs['contact_value_' + i].value,
					default      : record.default
				}

				if (contact.value && contact.value.length > 0) {
					data.push(contact);
				}

				return data;
			}, []);
		}

		assignContacts(contacts) {
			contacts.forEach((contact, i) => {
				this.refs['contact_type_' + i].value  = contact.contact_type;
				this.refs['contact_value_' + i].value = contact.value;
			});
		}

		generateEnrichers(enrichers) {
			return enrichers.map((en) => {
				return en.member_id;
			});
		}

		validateForm(params) {
			let emailRegex  = new RegExp(/^[a-z0-9](\.?[a-z0-9_-]){0,}@[a-z0-9-]+\.([a-z]{1,6}\.)?[a-z]{2,6}$/);
			this.validation = {};

			if (!params.participant.first_name || params.participant.first_name == '') {
				this.validation.emptyName = true;
			}

			if (params.participant.email && params.participant.email != '') {
				this.validation.emptyEmail = false;
				this.validation.validEmail = emailRegex.test(params.participant.email);
			}
			else {
				this.validation.emptyEmail = true;
			}

			this.validation.emptyContact = params.contacts.length == 0;
 			this.validation.emptyAddress = params.addresses.length == 0;

			let is_valid = !this.validation.emptyName
				&& (this.validation.validEmail || (this.validation.emptyEmail && !this.validation.emptyContact))
				&& !this.validation.emptyAddress;

			return is_valid;
		}

		save() {
			let saveParams = this.generateParticipantParams();
			this.errors = this.validateForm(saveParams);

			if (!this.validateForm(saveParams)) {
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

		generateParticipantParams() {
			return {
				participant : {
					first_name             : this.refs.first_name.value,
					last_name              : this.refs.last_name.value,
					email                  : this.refs.email.value,
					other_names            : this.refs.other_names.value,
					gender                 : this.gender,
					dob                    : this.refs.dob.value,
					notes                  : this.refs.notes.value,
					center_code            : this.currentUser.center_code,
					default_friend         : this.default_friend ? this.default_friend.member_id : null,
					participant_attributes : JSON.stringify({
						role        : parseInt(this.refs.role.value),
						ia_graduate : parseInt(this.ia_graduate),
						ia_dates    : this.refs.ia_dates.value,
						is_healer   : parseInt(this.is_healer)
					})
				},
				addresses : this.generateAddresses(this.addresses),
				contacts  : this.generateContacts(this.contacts),
				friends   : this.generateEnrichers(this.enrichers)
			};
		}

		create(data) {
			this.parent.opts.service.create(data, (err, response) => {
				if (!err) {
					this.parent.showList();
				}
			});
		}

		edit(data) {
			this.parent.opts.service.update(this.edit_id, data, (err, response) => {
				if (!err) {
					console.log(response.body().data(), response.statusCode());
					this.parent.showList();
				}
			});
		}

		reset() {
			this.contacts  = [];
			this.addresses = [];
			this.enrichers = [];

			this.refs.first_name.value  = ''
			this.refs.last_name.value   = ''
			this.refs.email.value       = ''
			this.refs.other_names.value = ''
			this.refs.dob.value         = ''
			this.refs.notes.value       = ''
			this.refs.role.value        = "0"

			this.gender      = undefined;
			this.ia_graduate = undefined;
			this.is_healer   = undefined;

			this.insertContact(true);
			this.insertAddress(true);

			this.update();
		}

		cancel() {
			if (this.opts.state.view == 'ADD_PARTICIPANT') {
				this.reset();
			}
			else {
				this.parent.showList();
			}
		}

		formatResults(participant) {
			let value = participant.first_name + ' ' + participant.last_name;

			if (participant.other_names && participant.other_names != '') {
				value = value.trim() + ' (' + participant.other_names + ')';
			}

			if (participant.email && participant.email != '') {
				value = value.trim() + ' [' + participant.email + ']';
			}

			return {value: value.trim(), data: participant};
		}

		loadEnricherSearchInput() {
			$("#search-enrichers").autocomplete({
				minChars : 2,
				lookup   : (query, done) => {
					let params = {
						page    : 1,
						limit   : 15,
						keyword : query
					};

					if (this.currentUser.role > 2) {
						params.center_id = this.currentUser.center_code;
					}

					this.parent.opts.service.search(params, (err, response) => {
						if (!err && response.body().length) {
							let result = response.body()[0].data();

							done({suggestions: result.participants.map(this.formatResults)});
						}
						else {
							done({suggestions: []});
						}
					});
				},
				onSelect : (item) => {
					$("#search-enrichers")[0].value = '';

					let ex = this.enrichers.filter((en) => {
						return en.member_id == item.data.member_id;
					});

					if (ex.length == 0) {
						this.enrichers.push(item.data);
						if (this.enrichers.length == 1) { this.default_friend = this.enrichers[0]; }
						this.update();
					}
				}
			});
		}

		makeEnricherDefault(e) {
			return(e) => {
				console.log("e.item");
				console.log(e.item);
				this.default_friend = e.item.enricher;
				console.log("this.default_friend");
				console.log(this.default_friend);
				this.update();
			}
		}

		removeEnricherFromList(e) {
			return(e) => {
				let is_default = this.default_friend && this.default_friend.member_id == e.item.enricher.member_id;
				this.enrichers = this.enrichers.filter((en) => {
					return en.member_id != e.item.enricher.member_id;
				});

				if (is_default && this.enrichers.length > 0) {
					this.default_friend = this.enrichers[0];
				}
			}
		}

		let state = this.parent.opts.state;
		console.log(this.opts.state);

		this.edit_id = this.opts.state.id;
		if (this.edit_id) {

			this.parent.opts.service.get(this.edit_id, (err, response) => {
				if (!err) {
					this.participant = response.body().data();
					this.attributes  = JSON.parse(this.participant.participant_attributes);
					this.loadEditForm(this.participant, this.attributes);
				}
				else {
					this.participant = null;
					console.log("ERROR LOADING PARTICIPANT !");
				}
			});

		}
		else {

			$("#participant-dob").calendar({
				type: 'date'
			});

			setTimeout(() => {
				this.loadEnricherSearchInput();
			}, 100);

			this.insertContact(true);
			this.insertAddress(true);

			this.update();
		}

	</script>

</participant-form>
