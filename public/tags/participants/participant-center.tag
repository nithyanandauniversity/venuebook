<participant-center>

	<div class="ui segment" style="margin-bottom: 2em;">
		<h3>
			<i class="violet icon street view"></i> Center
			<span
				if             = "{parent.currentUser && parent.currentUser.role < 3}"
				data-tooltip   = "Change primary center"
				data-inverted  = ""
				data-variation = "mini"
				onclick        = "{ toggleSwitchCenter() }"
				style          = "float: right;">
				<i class="icon configure"></i>
			</span>
		</h3>

		<div
			class = "ui"
			style = "margin-bottom: 10px;"
			show  = "{ showSwitchCenter }">
			<div class="ui message info">
				<p>Switching a participant to a different center will change the participant's primary center and will not be visible under the current center anymore.</p>
			</div>
			<div class="ui icon buttons" show = "{ newCenter.id }">
				<div class="ui button">{newCenter.name}</div>
				<div class="ui icon button" onclick = "{ removeNewCenter() }">
					<i class="icon remove"></i>
				</div>
			</div>
			<div class="ui form" show = "{ !newCenter.id }">
				<div class="fluid field">
					<input
						id          = "switch-center-search"
						type        = "text"
						placeholder = "Search for center name..." />
				</div>
			</div>
			<div style="text-align: right; margin-top: 5px;">
				<button
					class="ui green basic mini button"
					onclick = "{ switchParticipantCenter() }">
					Apply
				</button>
				<button
					class   = "ui orange basic mini button"
					onclick = "{ toggleSwitchCenter() }">
					Cancel
				</button>
			</div>
		</div>

		<h3 style = "margin: 0;">{opts.center.name} ({opts.center.category})</h3>
		<span>{opts.center.area} - {opts.center.region}</span><br />
		<span>{opts.center.state}, {opts.center.city}. <strong>{opts.center.country}</strong></span>

	</div>


	<script>

		this.newCenter = {};

		toggleSwitchCenter(e) {
			return(e) => {
				this.newCenter        = {};
				this.showSwitchCenter = !this.showSwitchCenter;
				this.update();
			}
		}

		centerSelected(center) {
			this.newCenter = center;
			this.update();
		}

		removeNewCenter(e) {
			return(e) => {
				this.newCenter = {};
				this.update();
			}
		}

		switchParticipantCenter(e) {
			return(e) => {
				this.parent.switchParticipantCenter(this.newCenter);
			}
		}

		formatResults(center) {
			let attributes = [center.area, center.country, center.region, center.state, center.city].join(', ');
			let value      = center.name + ' - ' + center.category + ' [' + attributes + ']';

			return {value: value, data: center};
		}

		loadSearchInput() {
			$("#switch-center-search").autocomplete({
				minChars : 2,
				lookup   : (query, done) => {

					let params = {
						page    : 1,
						limit   : 10,
						keyword : query
					}

					this.parent.parent.opts.centerService.search(params, (err, response) => {
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
					$("#switch-center-search")[0].value = '';
					this.centerSelected(item.data);
				}
			});
		}

		setTimeout(() => {
			this.loadSearchInput();
		}, 100);

	</script>

</participant-center>

