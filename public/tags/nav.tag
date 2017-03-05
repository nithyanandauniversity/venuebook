<nav id="navigation">
	<div class="ui fixed">
		<div class="ui inverted segment">
			<div class="ui container">
				<div class="ui inverted secondary pointing menu">
					<div class="item">
						<!-- <img src="assets/images/logo.png"> -->
						<h2>{ opts.heading }</h2>
					</div>
					<a
						each    = "{ navigations }"
						show    = "{ role.includes(this.currentUser.role) }"
						class   = "{ route == activeRoute ? 'active item' : 'item'}"
						onclick = "{ navClicked() }">
						{ name }
					</a>

					<div class="right menu">
						<div class="item">
							<div
								class = "ui inverted gray icon button"
								onclick = "{ showSettings() }">
								<i class = "icon setting"></i>
							</div>
						</div>
						<div class="item">
							<div
								class   = "ui inverted red icon button"
								onclick = "{ signout() }">
								<i class = "icon power"></i>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>


	<script>

		this.currentUser = this.opts.store.getState().routes.data;

		console.log("this.currentUser");
		console.log(this.currentUser);

		navClicked(e) {
			return(e) => {
				let itm = e.item;
				if (itm.role.includes(this.currentUser.role)) {
					console.log('Navigate to ' + itm.route);
					this.parent.navigatePage({
						type : itm.route,
						data : this.currentUser
					});
				}
			};
		}

		this.navigations = [
			{
				name  : 'Participants',
				route : 'PARTICIPANTS',
				role  : [1, 2, 3, 4, 5]
			},
			{
				name  : 'Centers',
				route : 'CENTERS',
				role  : [1, 2]
			},
			{
				name  : 'Programs',
				route : 'PROGRAMS',
				role  : [1, 2, 3, 4]
			},
			{
				name  : 'Events',
				route : 'EVENTS',
				role  : [1, 2, 3, 4, 5, 6]
			}
		];

		this.activeRoute = 'PARTICIPANTS';

		this.on('update', (a,b) => {
			this.activeRoute = this.opts.store.getState().routes.path;
		});

		showSettings(e) {
			return(e) => {
				console.log("GO TO SETTINGS");
			}
		}

		signout(e) {
			return(e) => {
				sessionStorage.clear();
				this.parent.navigatePage({
					type : 'LOGIN',
					data : null
				});
			}
		}

	</script>

	<style scoped>
		#navigation {
			margin-bottom: 25px;
		}
	</style>

</nav>
