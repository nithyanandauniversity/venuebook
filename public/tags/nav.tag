<nav id="navigation">
	<div class="ui fixed">
		<div class="ui inverted segment">
			<div class="ui container">
				<div class="ui inverted secondary menu">
					<a class="item">
						<h2 onclick = "{ goHome() }">
							<i class="icon home {activeRoute == 'DASHBOARD' && 'orange'}"></i> { opts.heading }
						</h2>
					</a>
					<a
						each    = "{ navigations }"
						show    = "{ role.includes(this.currentUser.role) }"
						class   = "{ route == activeRoute ? 'active item' : 'item'}"
						onclick = "{ navClicked() }">
						{ name }
					</a>

					<div class="right menu">
						<div
							show    = "{currentUser.role < 3 && currentUser.center_id}"
							class   = "ui inverted icon yellow small button"
							onclick = "{ switchCenter() }">
							<i
								style = "font-size: 1.5em; position: relative; top: 30%;"
								class = "icon street view"></i>
						</div>
						<div
							class = "menu-dropdown ui floating labeled icon inverted orange small dropdown button">
							<i class = "icon user"></i>
							<span style = "position: relative; top: 30%;">{ currentUser.first_name }</span>

							<div class="menu">
								<div
									class   = "item"
									show    = "{currentUser.role == 1}"
									onclick = "{ showUserManagement() }">
									<i class="icon green users"></i> Users
								</div>
								<div
									class   = "item"
									show    = "{currentUser.role == 1}"
									onclick = "{ showPrograms() }">
									<i class="icon brown tasks"></i> Programs
								</div>
								<div
									class   = "item"
									show    = "{currentUser.role <= 3}"
									onclick = "{ showVenueManagement() }">
									<i class="icon violet map"></i> Venues
								</div>
								<!-- <div
									class   = "item"
									onclick = "{ showSettings() }">
									<i class="icon blue setting"></i> Settings
								</div> -->
								<div class="divider"></div>
								<!-- <div
									class   = "item"
									onclick = "{ showImport() }">
									<i class="icon teal cloud upload"></i> Upload
								</div> -->
								<div
									class   = "item"
									onclick = "{ showProfile() }">
									<i class="icon blue user"></i> Profile
								</div>
								<div
									class   = "item"
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

		goHome(e) {
			return(e) => {
				this.parent.navigatePage({
					type : 'DASHBOARD',
					data : this.currentUser
				});
				this.update();
			}
		}

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

		switchCenter(e) {
			return(e) => {
				this.parent.switchCenter();
			}
		}

		this.navigations = [
			{
				name  : 'Participants',
				route : 'PARTICIPANTS',
				role  : [1, 2, 3, 4]
			},
			{
				name  : 'Events',
				route : 'EVENTS',
				role  : [1, 2, 3, 4, 5]
			},
			{
				name  : 'Centers',
				route : 'CENTERS',
				role  : [1, 2]
			}
		];

		this.activeRoute = 'DASHBOARD';

		this.on('update', (a, b) => {
			this.activeRoute = this.opts.store.getState().routes.path;
		});

		setTimeout(() => {
			$('.menu-dropdown').dropdown();
		}, 10);

		showUserManagement(e) {
			return(e) => {
				console.log("GO TO USER MANAGEMENT");
				this.parent.navigatePage({
					type : 'USERS',
					data : this.currentUser
				});
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

		showImport(e) {
			return(e) => {
				this.parent.navigatePage({
					type : 'UPLOADS',
					data : this.currentUser
				});
			}
		}

		showProfile(e) {
			return(e) => {
				this.parent.triggerProfile();
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
