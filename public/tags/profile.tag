<profile class="ui modal">

	<i class="close icon"></i>

	<div class="header">
		Change Password
	</div>

	<div class="content">
		<div class="ui form">
			<div
				show  = "{ showError }"
				class = "ui message red">
				<h3>ERROR !</h3>
				<p>Something went wrong. Please check your current password and try again.</p>
			</div>

			<div class="field {validation && validation.emptyOldPass && 'error'}">
				<label>Current Password</label>
				<input type="password" ref="old_password" placeholder="Current Password" />
			</div>
			<div class="field {validation && validation.emptyPass && 'error'}">
				<label>New Password</label>
				<input type="password" ref="new_password" placeholder="New Password" />
			</div>
			<div class="field {validation && validation.emptyConfirmation && 'error'}">
				<label>Confirm Password</label>
				<input type="password" ref="password_confirmation" placeholder="Re-type the Password" />
			</div>

			<div
				show  = "{validation && !validation.emptyPass && !validation.emptyConfirmation && !validation.passwordMatch}"
				class = "ui pointing red label">
				Passwords do not match!
			</div>
		</div>
	</div>

	<div class="actions">
		<div onclick="{ cancel() }" class="ui orange button">Cancel</div>
		<div onclick="{ save() }" class="ui blue button">Update</div>
	</div>

	<script>

		cancel(e) {
			return(e) => {
				this.parent.hideModal();
			}
		}

		generatePasswordParams() {
			return {
				old_password          : this.refs['old_password'].value,
				password              : this.refs['new_password'].value,
				password_confirmation : this.refs['password_confirmation'].value
			}
		}

		reset() {
			this.refs['old_password'].value          = '';
			this.refs['new_password'].value          = '';
			this.refs['password_confirmation'].value = '';
		}

		validateForm(params) {
			this.validation = {};
			this.showError  = false;

			if (!params.old_password || params.old_password == '') {
				this.validation.emptyOldPass = true;
			}

			if (!params.password || params.password == '') {
				this.validation.emptyPass = true;
			}

			if (!params.password_confirmation || params.password_confirmation == '') {
				this.validation.emptyConfirmation = true;
			}

			if (!this.validation.emptyPass && !this.validation.emptyConfirmation) {
				this.validation.passwordMatch = (params.password == params.password_confirmation);
			}

			return !this.validation.emptyPass
				&& !this.validation.emptyOldPass
				&& !this.validation.emptyConfirmation
				&& this.validation.passwordMatch;
		}

		save(e) {
			return(e) => {
				let params = this.generatePasswordParams();

				if (!this.validateForm(params)) {
					return false;
				}

				// UPDATE PASSWORD
				console.log("UPDATE PASSWORD !");

				let currentUser = this.opts.store.getState().routes.data;

				this.opts.userService.changePassword(currentUser['id'], {
					user : {
						old_password : params.old_password,
						password     : params.password
					}
				}, (err, response) => {
					if (!err) {
						let user = response.body().data();
						this.parent.hideModal();
					}
					else {
						this.showError = true;
						this.update();
					}
				});

			}
		}

		this.on('loaded', () => {
			this.reset();
		});

	</script>

</profile>

