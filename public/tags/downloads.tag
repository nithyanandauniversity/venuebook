<downloads class="ui container" style="margin-top: 25px;">

	<div class="ui">
		<div class="row" style="margin-bottom: 35px;">
			<h2>
				<span>
					Downloads
				</span>
			</h2>
		</div>

		<div class="ui form">
			<h4 class="ui dividing header">
				Participant Lists
			</h4>

			<div class="field">
				<label for="mandatory">Mandatory Fields</label>
				<div style="display: inline;">
					<label>[First name / Last name / Email addresss / Contact number]</label>
				</div>
			</div>

			<div class="field">
				<label for="optional">Optional Fields</label>
				<div style="display: inline;">
					<label style="margin-right: 10px;">
						<input type="checkbox" style="margin-top: 4px;" ref="address" />
						Address
					</label>
					<label style="margin-right: 10px;">
						<input type="checkbox" style="margin-top: 4px;" ref="ia_graduate" />
						IA Graduate
					</label>
					<label style="margin-right: 10px;">
						<input type="checkbox" style="margin-top: 4px;" ref="smkt" />
						SMKT Role
					</label>
					<label style="margin-right: 10px;">
						<input type="checkbox" style="margin-top: 4px;" ref="gender" />
						Gender
					</label>
					<label style="margin-right: 10px;">
						<input type="checkbox" style="margin-top: 4px;" ref="enrichers" />
						Enrichers
					</label>
					<label style="margin-right: 10px;">
						<input type="checkbox" style="margin-top: 4px;" ref="created_by" />
						Created by
					</label>
					<label style="margin-right: 10px;">
						<input type="checkbox" style="margin-top: 4px;" ref="created_at" />
						Created Date
					</label>
				</div>
			</div>

			<div class="ui one column grid">
				<div class="ui right aligned column">
					<div class="column">
						<button class="ui large green button {downloadProgress && 'disabled'}" onclick="{ doDownload }">
							<i class="icon white download"></i> Download List
						</button>
					</div>
				</div>
			</div>
		</div>
	</div>

	<script>

		this.currentUser = this.opts.store.getState().routes.data;

		generateParams() {
			let params = {
				with_address : this.refs.address.checked,
				ia_graduate  : this.refs.ia_graduate.checked,
				smkt         : this.refs.smkt.checked,
				gender       : this.refs.gender.checked,
				enrichers    : this.refs.enrichers.checked,
				created_by   : this.refs.created_by.checked,
				created_at   : this.refs.created_at.checked,
				version      : Date.now()
			};

			if (this.currentUser) {
				params.center_code = this.currentUser.center_code;
			}

			return params;
		}

		doDownload() {
			if (this.downloadProgress) {
				return false;
			}

			let params = this.generateParams();

			this.downloadProgress = true;
			this.opts.participantService.getParticipantsReport(params, (err, response) => {
				console.log("err, response");
				console.log(err, response);
				if (!err) {
					let data       = response.body();
					let csvContent = "data:text/csv;charset=utf-8,";

					data.forEach((info, i) => {
						let dataString = info.data().join(",");
						csvContent += i < data.length ? dataString+ "\n" : dataString;
					});

					let encodedUri = encodeURI(csvContent);
					let link       = document.createElement("a");
					link.setAttribute("href", encodedUri);
					link.setAttribute("download", "all_participants_" + Date.now() + ".csv");
					document.body.appendChild(link);

					this.downloadProgress = false;
					this.reset();
					this.update();

					link.click();
				}
			});
		}

		reset() {
			this.refs.address.checked     = false;
			this.refs.ia_graduate.checked = false;
			this.refs.smkt.checked        = false;
			this.refs.gender.checked      = false;
			this.refs.enrichers.checked   = false;
			this.refs.created_by.checked  = false;
			this.refs.created_at.checked  = false;
		}

		// this.reset();
	</script>

</downloads>
