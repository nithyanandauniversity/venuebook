<login class="ui middle aligned center aligned grid">
	<div class="column">
		<h2 class="ui orange image header">
			<!-- <img src="assets/images/logo.png" class="image"> -->
			<div class="content">
				Log-in to your Global TOF account
			</div>
		</h2>
		<form class="ui huge form">
			<div class="ui stacked segment">
				<div class="field">
					<div class="ui left icon huge input">
						<i class="user icon"></i>
						<input
							type        = "text"
							ref         = "email"
							onkeypress  = "{keyPressed()}"
							placeholder = "E-mail address">
					</div>
				</div>

				<div class="field">
					<div class="ui left icon huge input">
						<i class="lock icon"></i>
						<input
							type        = "password"
							ref         = "password"
							onkeypress  = "{keyPressed()}"
							placeholder = "Password">
					</div>
				</div>

				<div
					class   = "ui fluid huge orange submit button"
					onclick = "{ submitForm() }">Login</div>
			</div>

			<div class="ui error message"></div>

		</form>
	</div>

	<script>

		const self = this;

		validateForm() {
			let email    = this.refs.email.value;
			let password = this.refs.password.value;

			return email && email.length > 0 && password && password.length > 0
		}

		submitForm(e) {
			return(e) => {
				if (this.validateForm()) {
					this.doLogin();
				}
			}
		}

		keyPressed(e) {
			return(e) => {
				if (e.which === 13 && this.validateForm()) {
					this.doLogin();
				}
			}
		}

		doLogin() {
			console.log("this.opts");
			console.log(this.opts);
			this.opts.service.doLogin({
				auth: {
					email: this.refs.email.value,
					password: this.refs.password.value
				}
			}, (err, response) => {
				if (!err) {
					let result = response.body().data();
					// console.log("result");
					// console.log(result);
					if (result.token) {
						sessionStorage.setItem('HTTP_TOKEN', result.token);
						sessionStorage.setItem('CURRENT_USER', JSON.stringify(result.current_user));
						console.info("Success");
						this.parent.navigatePage({type: 'PARTICIPANTS', data: result.current_user});
						console.log("this.opts.store.getState()");
						console.log(this.opts.store.getState());
					}
					else {
						console.error("Failed!");
					}
				}
			});
		}
	</script>

	<style>
		login {
			height: 100%;
			background-color: #DADADA;
		}
		/*body > .grid {
		}*/
		/*.image {
		margin-top: -100px;
		}*/
		login > .column {
			max-width: 450px;
		}
	</style>
</login>