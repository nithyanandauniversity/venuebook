<user-form
	class = "ui container"
	style = "margin: 25px 0;">

	<div class="ui">
		<div class="row" style="margin-bottom: 35px;">
			<h2>
				<span>
					{opts.state.view == 'ADD_USER' ? 'Create New' : 'Edit'} User {opts.state.view == 'EDIT_USER' && user && ' [' + user.email + ']'}
				</span>
				<div
					class   = "ui primary basic button right floated"
					onclick = { parent.showList }>
					<i class="chevron left icon"></i> Back
				</div>
			</h2>
		</div>

		<div class="ui form">

			<div style="margin-bottom: 1.5em;">
				<h4 class="ui horizontal divider header">
					<i class="icon legal"></i>
					Select User Role
				</h4>

				<div
					if    = "{userRoles && userRoles.length}"
					class = "ui fluid five item large menu">
					<a
						each    = "{ role in userRoles }"
						onclick = "{ setActiveRole() }"
						class   = "item {activeRole == role.value && 'active green'} {role.name == 'CENTER_ADMIN' && 'disabled'}">
						<strong>{role.label}</strong>
					</a>
				</div>
			</div>

			<div show="{activeRole >= 2}" style="margin-bottom: 1.5em;">
				<h4 class="ui horizontal divider header">
					<i class="icon street view"></i>
					Center Information
				</h4>

				<div class="ui two column grid">
					<div class="{activeRole > 3 && 'right aligned middle aligned content'} column">
						<div
							show  = "{ activeRole == 2 }"
							class = "field">
							<label>Select Lead Type</label>
							<div class="ui fluid three item menu">
								<a
									each    = "{leadTypes}"
									onclick = "{ setLeadType() }"
									class   = "item {leadType == value && 'active brown'}">
									{label}
								</a>
							</div>
						</div>
						<div show = "{ activeRole > 3 }">
							<h3>Select Primary Center :</h3>
						</div>
					</div>

					<div class="column">
						<!-- SELECT COUNTRIES IF LEAD TYPE IS COUNTRY -->
						<div
							class = "field"
							show  = "{activeRole == 2 && leadType == 'country'}">
							<label>Select Countries :</label>
						</div>

						<!-- SELECT AREAS IF LEAD TYPE IS AREA -->
						<div
							class = "field"
							show  = "{activeRole == 2 && leadType == 'area'}">
							<label>Select Areas :</label>
						</div>

						<!-- SELECT CENTER IF USER IS PROGRAM_COORDINATOR OR DATA_ENTRY -->
						<div
							class = "field"
							show  = "{ activeRole > 3 || (activeRole == 2 && leadType == 'center')}">
							<label show="{ activeRole == 2 }">Select Centers :</label>
							<div class = "ui large input">
								<input
									type        = "text"
									id          = "form-search-center"
									placeholder = "Search for centers..." />
							</div>
						</div>
					</div>
				</div>
			</div>

			<div style="margin-bottom: 1.5em;">
				<h4 class="ui horizontal divider header">
					<i class="icon privacy"></i>
					Enter Login Credentials
				</h4>

				<div class="four fields">
					<div class="field">
						<label>First Name</label>
						<input type="text" ref="first_name" placeholder="First Name" />
					</div>
					<div class="field">
						<label>Last Name</label>
						<input type="text" ref="last_name" placeholder="Last Name" />
					</div>
					<div class="field">
						<label>Email</label>
						<input type="text" ref="email" placeholder="Email Address" />
					</div>
					<div class="field">
						<label>Password</label>
						<input type="password" ref="password" placeholder="Password" />
					</div>
				</div>
			</div>

		</div>

	</div>


	<script>


		setActiveRole(e) {
			return(e) => {
				console.log("e.item");
				console.log(e.item);
				if (e.item.role.name == 'CENTER_ADMIN') { return; }
				this.activeRole = e.item.role.value;
				this.update();
			}
		}

		this.leadTypes = [
			{label: "Lead by Area", value: "area"},
			{label: "Lead by Country", value: "country"},
			{label: "Lead by Center", value: "center"}
		];

		setLeadType(e) {
			return(e) => {
				this.leadType = e.item.value;
				this.update();
			}
		}

		generateUserRoleList() {
			if (this.parent.opts.userRoles) {
				this.userRoles = [];
				for (let role in this.parent.opts.userRoles) {
					this.userRoles.push({
						name  : role,
						label : role.split('_').join(' '),
						value : this.parent.opts.userRoles[role]
					});
				}

				this.update();
			}
		}

		loadSearchInput() {
			$("#form-search-center").autocomplete({
				minChars : 2,
				lookup   : (query, done) => {

					let params = {
						page    : 1,
						limit   : 10,
						keyword : query
					}

					// if (this.opts.currentUser.role > 2) {
					// 	params.center_id = this.opts.currentUser.center_id;
					// }

					this.parent.opts.centerService.search(params, (err, response) => {
						if (!err && response.body().length) {
							let result = response.body()[0].data();

							done({suggestions: result.centers.map(this.formatResults)});
						}
						else {
							done({suggestions: []});
						}
					});
				},
				onSelect : (item) => {
					$("#form-search-center")[0].value = '';
					this.parent.assignCenter(item.data)
					this.doSearch();
				}
			});
		}

		setTimeout(() => {
			this.loadSearchInput();
			this.generateUserRoleList();
		}, 100)
	</script>

</user-form>
