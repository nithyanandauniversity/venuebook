<venue-form>
	<div class="ui segment">
		<h2>{!edit_id && 'Create' || 'Edit'} Venue</h2>

		<div class="ui form">

			<div class="fields">
				<div class="field {validation && validation.emptyName && 'error'}">
					<label>Venue Name</label>
					<input type="text" ref="name" placeholder="Venue Name" />
				</div>
				<div class="field">
					<label>Capacity</label>
					<input type="text" ref="capacity" placeholder="#" />
				</div>
			</div>

			<h4 class="ui dividing header">
				Address Information
			</h4>
			<div class="fields">
				<div class="ten wide field {validation && validation.emptyStreet && 'error'}">
					<label>Street</label>
					<input type="text" ref="street" placeholder="Street name" />
				</div>
				<div class="six wide field {validation && validation.emptyCity && 'error'}">
					<label>City</label>
					<input type="text" ref="city" placeholder="City" />
				</div>
			</div>
			<div class="fields">
				<div class="field">
					<label>State</label>
					<input type="text" ref="state" placeholder="State" />
				</div>
				<div class="field">
					<label>Postal Code</label>
					<input type="text" ref="postal_code" placeholder="Postal Code" />
				</div>
				<div class="field {validation && validation.emptyCountry && 'error'}">
					<label>Country</label>
					<select
						class = "ui search dropdown"
						ref   = "country">
						<option value="">Select Country...</option>
						<option
							each  = {country in countries}
							value = "{country.value}">
							{country.value}
						</option>
					</select>
				</div>
			</div>

			<div class="field">
				<div style="text-align: right;">
					<button
						class   = "ui small green basic button"
						onclick = "{ saveVenue() }">
						Save
					</button>
					<button
						class   = "ui small orange basic button"
						onclick = "{ reset }">
						Reset
					</button>
				</div>
			</div>
		</div>
	</div>

	<script>

		getData(res) {
			return res.data();
		}

		this.countries = this.parent.opts.countries();

		generateVenueParams() {
			return {
				venue: {
					name      : this.refs.name.value,
					capacity  : this.refs.capacity.value,
					center_id : this.parent.currentUser.center_id
				},
				address: {
					street      : this.refs.street.value,
					city        : this.refs.city.value,
					state       : this.refs.state.value,
					postal_code : this.refs.postal_code.value,
					country     : this.refs.country.value
				}
			};
		}

		loadEditForm(venue, address) {
			this.refs.name.value        = venue.name;
			this.refs.capacity.value    = venue.capacity;

			this.refs.street.value      = address.street;
			this.refs.city.value        = address.city;
			this.refs.state.value       = address.state;
			this.refs.postal_code.value = address.postal_code;
			this.refs.country.value     = address.country;
		}

		reset() {
			this.edit_id                = null;
			this.refs.name.value        = '';
			this.refs.capacity.value    = '';
			this.refs.street.value      = '';
			this.refs.city.value        = '';
			this.refs.state.value       = '';
			this.refs.postal_code.value = '';
			this.refs.country.value     = '';
			this.validation             = {};
		}

		create(data) {
			this.parent.opts.service.create(data, (err, response) => {
				if (!err) {
					this.reset();
					this.parent.reloadList();
				}
			});
		}

		edit(data) {
			this.parent.opts.service.update(this.edit_id, data, (err, response) => {
				if (!err) {
					this.reset();
					this.parent.reloadList();
				}
			});
		}

		validateForm(params) {
			this.validation = {};

			if (!params.venue.name || params.venue.name == '') {
				this.validation.emptyName = true;
			}

			if (!params.address.street || params.address.street == '') {
				this.validation.emptyStreet = true;
			}

			if (!params.address.city || params.address.city == '') {
				this.validation.emptyCity = true;
			}

			if (!params.address.country || params.address.country == '') {
				this.validation.emptyCountry = true;
			}

			return !this.validation.emptyName
				&& !this.validation.emptyStreet
				&& !this.validation.emptyCity
				&& !this.validation.emptyCountry;
		}

		saveVenue(e) {
			return(e) => {
				let state  = this.parent.opts.store.getState().venues;
				let params = this.generateVenueParams();

				if (!this.validateForm(params)) {
					return false;
				}

				if (state.view == "ADD_VENUE" && !this.edit_id) {
					// CREATE PROGRAM
					this.create(params);
				}

				if (state.view == "EDIT_VENUE" && this.edit_id) {
					// EDIT PROGRAM
					this.edit(params);
				}
			}
		}

		this.on('edit', () => {
			let state = this.parent.opts.store.getState().venues;
			if (state && state.view == 'EDIT_VENUE') {
				this.edit_id = state.id;
				this.parent.opts.service.get(this.edit_id, (err, response) => {
					if (!err) {
						let data     = response.body().data();
						this.venue   = data.venue;
						this.address = data.address;
						this.loadEditForm(this.venue, this.address);
						this.update();
					}
				});
			}
		});

	</script>
</venue-form>

