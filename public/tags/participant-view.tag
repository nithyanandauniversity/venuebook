<participant-view
	class = "ui container"
	style = "margin: 25px 0;">

	<div class="ui">
		<div class="row" style="margin-bottom: 25px;">
			<h2>
				<span>
					View Participant
				</span>
				<div class="ui green basic button right floated" onclick = { edit }>
					<i class="write left icon"></i> Edit
				</div>
				<div class="ui primary basic button right floated" onclick = { parent.showList }>
					<i class="chevron left icon"></i> Back
				</div>
			</h2>
		</div>

		<div class="ui two column centered grid">

			<div class="nine wide column">
				<div class="ui fluid card">
					<div class="content">
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
							style = "font-size: 0.8em;">
							{participant.other_names || 'N/A'}
						</div>
						<div
							class = "description"
							style = "font-size: 0.9em; margin-top: 1em;">
							<div class="fields">
								<div class="field">
									<label>{participant.email}</label>
								</div>
							</div>
						</div>
					</div>
					<div class="extra content">
						<!-- Contact Information here -->
					</div>
				</div>
			</div>
			<div class="seven wide column">
				<participant-comments></participant-comments>
			</div>

		</div>

	</div>


	<script>

		const self = this;

		edit() {
			this.parent.showForm({id: this.opts.state.id});
		}

		participant = {};
		attributes  = {};

		this.on('view', () => {
			this.view_id = this.opts.state.id;
			this.parent.opts.service.get(this.view_id, (err, response) => {
				if (!err) {
					this.participant = response.body().data();
					this.attributes = JSON.parse(this.participant.participant_attributes);
					this.update();
				}
				else {
					this.participant = null;
				}
			});
		});

	</script>

</participant-view>
