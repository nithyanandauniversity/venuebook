<participant-view
	class = "ui container"
	style = "margin: 25px 0;">

	<div class="ui">
		<div class="row" style="margin-bottom: 25px;">
			<h2>
				<span>
					View Participant [{participant.member_id}]
				</span>
				<div class="ui green basic button right floated" onclick = "{ edit }">
					<i class="write left icon"></i> Edit
				</div>
				<div class="ui primary basic button right floated" onclick = "{ parent.showList }">
					<i class="chevron left icon"></i> Back
				</div>
			</h2>
		</div>

		<div class="ui two column centered grid">

			<div class="nine wide column">
				<div class="ui fluid card">
					<div class="content">
						<div
							class = "ui violet ribbon label"
							style = "left: -48px; bottom: 5px; font-size: 0.6em;"
							if    = "{attributes.role > 1}">
							{participantRoles[attributes.role]}
						</div>
						<span
							class          = "right floated"
							data-tooltip   = "{!attributes.is_healer && 'Not a'} Healer"
							data-inverted  = ""
							data-variation = "mini">
							<i class="heart {attributes.is_healer && 'red' || 'grey'} icon"></i>
						</span>
						<span
							class          = "right floated"
							data-tooltip   = "{!attributes.ia_graduate && 'Not an'} IA Graduate"
							data-inverted  = ""
							data-variation = "mini">
							<i class="trophy {attributes.ia_graduate && 'green' || 'grey'} icon"></i>
						</span>

						<div
							class = "header"
							style = "font-size: 1em; margin-bottom: .2em;">
							{participant.first_name} {participant.last_name}
						</div>
						<div
							class = "meta"
							if    = "{ participant.other_names }"
							style = "font-size: 0.8em;">
							{participant.other_names || 'N/A'}
						</div>
						<div
							class = "description"
							style = "font-size: 0.9em; margin-top: 1em;">
							<div class="fields">
								<div class="field">
									<span
										class          = "right floated"
										data-tooltip   = "{participant.gender}"
										data-inverted  = ""
										data-variation = "mini"
										if             = "participant.gender">
										<i class = "icon brown {participant.gender && participant.gender.toLowerCase()}"></i>
									</span>
									<label>{participant.email}</label>
								</div>
							</div>
							<div
								if    = "{participant.notes}"
								class = "ui segment orange"
								style = "margin-top: 25px;">
								<label style="font-weight: bolder;">
									<i class="icon write"></i>
									Notes
								</label>
								<p>{participant.notes}</p>
							</div>
						</div>
					</div>
					<div class="extra content" style="font-size: 0.75em;">
						<!-- Contact Information here -->
						<div class="ui two column grid">
							<div class="six wide column">
								<span
									each  = {participant.contacts}
									style = "cursor: default; display: block; margin-bottom: 5px;">
									<i class="icon {contact_type == 'Home' && 'call'} {contact_type == 'Mobile' && 'mobile'} {contact_type == 'Work' && 'building'} {id == participant.default_contact && 'blue'}">
									</i>
									{value}
								</span>
							</div>
							<div class="ten wide column">
								<table class="ui very basic table">
									<tr each = {participant.addresses}>
										<td style="padding: 0;">
											<i class="icon marker {id == participant.default_address && 'blue'}"></i>
										</td>
										<td>
											<span>{street}</span>
											<span>{city} {state} <em>{postal_code}</em></span>
											<div><strong>{country}</strong></div>
										</td>
									</tr>
								</table>
							</div>
						</div>
					</div>
				</div>

				<!-- Participant Center Info -->
				<participant-center
					if     = "{participant.center}"
					center = "{participant.center}">
				</participant-center>

			</div>
			<div class="seven wide column">
				<participant-comments comments = "{participant.comments}"></participant-comments>
			</div>

		</div>

	</div>


	<script>

		const self = this;

		edit() {
			this.parent.showForm({id: this.opts.state.id});
		}

		this.participant = {};
		this.attributes  = {};

		this.participantRoles = ['None', 'Volunteer', 'Thanedar', 'Kotari', 'Mahant', 'Sri Mahant'];
		this.view_id          = this.opts.state.id;

		if (this.view_id) {
			this.parent.opts.service.get(this.view_id, (err, response) => {
				if (!err) {
					this.participant = response.body().data();
					this.attributes  = JSON.parse(this.participant.participant_attributes) || {};
					this.update();
				}
				else {
					this.participant = null;
				}
			});
		}
		// this.on('view', () => {
		// });

	</script>

</participant-view>
