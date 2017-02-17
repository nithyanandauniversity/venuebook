<participant-form
	class="ui container"
	style="margin: 25px 0;">

	<div class="ui">
		<div class="row" style="margin-bottom: 35px;">
			<h2>
				<span>
					{opts.state.view == 'ADD_PARTICIPANT' ? 'Create New' : 'Edit'} Participant
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
				<div class="five wide field">
					<label for="first_name">First name</label>
					<input type="text" ref="first_name" placeholder="First Name" />
				</div>
				<div class="five wide field">
					<label for="last_name">Last name</label>
					<input type="text" ref="last_name" placeholder="Last Name" />
				</div>
				<div class="six wide field">
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
					<input type="text" ref="ia_dates" placeholder="IA Dates (MMM, YYYYY)" />
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
							<td>
								<span class={contact.default && 'ui ribbon label'}>#{i + 1}</span>
							</td>
							<td>
								<input
									type        = "text"
									ref         = "{'contact_value_' + i}"
									placeholder = "Contact number" />
							</td>
							<td>
								<select ref="{'contact_type_' + i}" class="ui dropdown">
									<option value="Mobile">Mobile</option>
									<option value="Home">Home</option>
								</select>
							</td>
							<td style="width: 105px; text-align: right;">
								<button
									class   = "circular ui icon olive button"
									show    = "{!contact.default}"
									onclick = "{markContactDefault()}">
									<i class="checkmark icon"></i>
								</button>
								<button
									class   = "circular ui icon orange button"
									show    = "{!contact.default}"
									onclick = "{removeContact()}">
									<i class="remove icon"></i>
								</button>
							</td>
						</tr>
					</table>
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
												value = "{country.code}">
												{country.value}
											</option>
										</select>
									</div>
								</div>
							</td>
							<td style="width: 65px;">
								<button
									class="circular ui icon olive button"
									show="{!address.default}"
									style="margin-bottom: 5px;"
									onclick="{markAddressDefault()}">
									<i class="checkmark icon"></i>
								</button>
								<button
									class="circular ui icon orange button"
									show="{!address.default}"
									onclick="{removeAddress()}">
									<i class="remove icon"></i>
								</button>
							</td>
						</tr>
					</table>
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

		const self = this;

		this.contacts  = [];
		this.addresses = [];

		setGender(e) {
			return (e) => {
				self.gender = e.target.dataset.value;
			}
		}

		setGrad(e) {
			return (e) => {
				self.ia_graduate = e.target.dataset.value;
			}
		}

		setHealer(e) {
			return (e) => {
				self.is_healer = e.target.dataset.value
			}
		}

		addContact(e) {
			return (e) => {
				self.insertContact(false);
			}
		}

		addAddress(e) {
			return (e) => {
				self.insertAddress(false);
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
				self.contacts.splice(e.item.i, 1);
			}
		}

		removeAddress(e) {
			return (e) => {
				self.addresses.splice(e.item.i, 1);
			}
		}

		insertContact(def = false) {
			this.contacts.push({
				contact_type: 'Home',
				value: '',
				default: def
			});
		}

		insertAddress(def = false) {
			this.addresses.push({
				street: '',
				city: '',
				state: '',
				postal_code: '',
				country: '',
				default: def
			});
		}

		this.on('create', () => {

			$("#participant-dob").calendar({
				type: 'date'
			});

			self.insertContact(true);
			self.insertAddress(true);

			self.update();
		})

		this.on('edit', () => {
			let state = self.parent.opts.state;
			console.log(self.opts.state);

		});

		reset() {
			console.log("RESET !!!");
		}

		countries = this.parent.opts.countries();

		generateAddresses(address, i) {
			return {
				street      : this.refs['street_' + i].value,
				city        : this.refs['city_' + i].value,
				state       : this.refs['state_' + i].value,
				postal_code : this.refs['postal_code_' + i].value,
				country     : this.refs['country_' + i].value,
				default     : address.default
			};
		}

		generateContacts(contact, i) {
			return {
				contact_type : this.refs['contact_type_' + i].value,
				value        : this.refs['contact_value_' + i].value,
				default      : contact.default
			};
		}

		save() {
			let params = {
				participant : {
					first_name             : this.refs.first_name.value,
					last_name              : this.refs.last_name.value,
					email                  : this.refs.email.value,
					other_names            : this.refs.other_names.value,
					gender                 : this.gender,
					dob                    : this.refs.dob.value,
					notes                  : this.refs.notes.value,
					participant_attributes : JSON.stringify({
						role        : this.refs.role.value,
						ia_graduate : this.ia_graduate,
						ia_dates    : this.refs.ia_dates.value,
						is_healer   : this.is_healer
					})
				},
				addresses : this.addresses.map(this.generateAddresses),
				contacts  : this.contacts.map(this.generateContacts)
			};

			this.parent.opts.service.create(params, (err, response) => {
				console.log("err, response");
				console.log(err, response);

				if (!err) {
					console.log(response.body().data(), response.statusCode());
					this.parent.showList();
				}
			});
		}

		cancel() {
			if (this.opts.state.view == 'ADD_PARTICIPANT') {
				this.reset();
			}
			else {
				this.parent.showList();
			}
		}

	</script>

</participant-form>
