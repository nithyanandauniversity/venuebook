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
							data-tooltip   = "Not a Healer"
							data-inverted  = ""
							data-variation = "mini">
							<i class="heart grey icon"></i>
						</span>
						<span
							class          = "right floated"
							data-tooltip   = "IA Graduate"
							data-inverted  = ""
							data-variation = "mini">
							<i class="trophy green icon"></i>
						</span>

						<div
							class = "header"
							style = "font-size: 1em; margin-bottom: .2em;">
							First name Last name
						</div>
						<div
							class = "meta"
							style = "font-size: 0.8em;">
							Spiritual name
						</div>
						<div
							class = "description"
							style = "font-size: 0.9em; margin-top: 1em;">
							<div class="fields">
								<div class="field">
									<label>Emailaddress@domain.com</label>
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

		this.on('view', () => {
			console.log(self.opts.state);
		});

	</script>

</participant-view>
