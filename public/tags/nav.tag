<nav id="navigation">
	<div class="ui fixed">
		<div class="ui inverted segment">
			<div class="ui container">
				<div class="ui inverted secondary menu">
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
						<div
							class = "menu-dropdown ui floating labeled icon inverted orange small dropdown button"
							style = "height: 60%; margin-top: 16%;">
							<i class = "icon user"></i>
							<span>{ currentUser.first_name }</span>

							<div class="menu">
								<div
									class   = "item"
									show    = "{currentUser.role == 1}"
									onclick = "{ showUserManagement() }">
									<i class="icon green users"></i> Users
								</div>
								<div
									class   = "item"
									show    = "{[1,2,3].includes(currentUser.role)}"
									onclick = "{ showPrograms() }">
									<i class="icon brown tasks"></i> Programs
								</div>
								<div
									class   = "item"
									show    = "{currentUser.role == 3}"
									onclick = "{ showVenueManagement() }">
									<i class="icon violet map"></i> Venues
								</div>
								<div
									class   = "item"
									onclick = "{ showSettings() }">
									<i class="icon blue setting"></i> Settings
								</div>
								<div class="divider"></div>
								<div
									class   = "item red"
									onclick = "{ signout() }">
									<i class="icon red power"></i> Signout
								</div>
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
				name  : 'Events',
				route : 'EVENTS',
				role  : [1, 2, 3, 4, 5, 6]
			},
			{
				name  : 'Centers',
				route : 'CENTERS',
				role  : [1, 2]
			}
		];

		this.activeRoute = 'PARTICIPANTS';

		this.on('update', (a,b) => {
			this.activeRoute = this.opts.store.getState().routes.path;
		});

		setTimeout(() => {
			$('.menu-dropdown').dropdown();
		}, 10);

		showUserManagement(e) {
			return(e) => {
				console.log("GO TO USER MANAGEMENT");
			}
		}

		showPrograms(e) {
			return(e) => {
				this.parent.navigatePage({
					type : 'PROGRAMS',
					data : this.currentUser
				});
			}
		}

		showVenueManagement(e) {
			return(e) => {
				this.parent.navigatePage({
					type : 'VENUES',
					data : this.currentUser
				});
			}
		}

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
