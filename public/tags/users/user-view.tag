<user-view
	class = "ui container"
	style = "margin: 25px 0;">

	<div class="ui">
		<div class="row" style="margin-bottom: 25px;">
			<h2>
				<span>
					View User
				</span>
				<div class="ui green basic button right floated" onclick = "{ edit }">
					<i class="write left icon"></i> Edit
				</div>
				<div class="ui primary basic button right floated" onclick = "{ parent.showList }">
					<i class="chevron left icon"></i> Back
				</div>
			</h2>
		</div>
	</div>

	<div class="ui two column centered grid">

		<div class="column">
			<div class="ui fluid card">
				<div class="content">
					<div
						class = "ui green ribbon label"
						style = "left: -48px; bottom: 5px; font-size: 0.6em;"
						if    = "{user.role > 0}">
						{userRoles[user.role]}
					</div>
					<div
						class = "header"
						style = "font-size: 1em; margin-bottom: .2em;">
						<strong>{user.first_name}</strong> {user.last_name}
					</div>
					<div
						class = "meta"
						style = "font-size: 0.8em;">
						{user.email}
					</div>
				</div>
			</div>
		</div>

		<div
			if    ="{user.role > 1}"
			class ="column">
			<div class="ui segment">
				<h3><i class="icon street view"></i> Center / Access Information</h3>

				<div if = "{user.role > 2}">
					<h3 style = "margin: 0;">{user.center.name} ({user.center.category})</h3>
					<span>{user.center.area} - {user.center.region}</span><br />
					<span>{user.center.state}, {user.center.city}. <strong>{user.center.country}</strong></span>
				</div>

				<div if = "{user.role == 2 && user.allowed_centers && user.allowed_centers.length}">
					<h3 if = "{user.user_permissions.areas}">Area(s) : {user.user_permissions.areas.join(', ')}</h3>
					<h3 if = "{user.user_permissions.countries}">Country(ies) : {user.user_permissions.counries.join(', ')}</h3>
					<h3 if = "{user.user_permissions.centers}">Centers: </h3>
					<div
						class = "ui segment comments"
						style = "margin-top: 0;">
						<div
							class = "comment"
							style = "border-bottom: 1px solid #ccc;"
							each  = "{center in user.allowed_centers}">
							<div class = "content">
								<h3 style = "margin: 0;">{center.name} ({center.category})</h3>
								<span>{center.area} - {center.region}</span><br />
								<span>{center.state}, {center.city}. <strong>{center.country}</strong></span>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>

	</div>

	<script>

		edit() {
			this.parent.showForm({id: this.opts.state.id});
		}

		this.user    = {}
		this.view_id = this.opts.state.id;

		console.log("this.view_id, this.opts.state");
		console.log(this.view_id, this.opts.state);

		if (this.view_id) {
			this.parent.opts.service.get(this.view_id, (err, response) => {
				if (!err) {
					this.user = response.body().data();
					console.log("this.user");
					console.log(this.user);
					this.update();
				}
				else {
					this.user = null;
				}
			});
		}

		if (this.parent.opts.userRoles) {
			this.userRoles = {};
			for (let role in this.parent.opts.userRoles) {
				this.userRoles[this.parent.opts.userRoles[role]] = role.toString().split('_').join(' ');
			}
		}


	</script>

</user-view>
