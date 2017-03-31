<center-selection class="ui modal">

	<i
		show  = "{opts.currentUser && opts.currentUser.role < 3 && opts.currentUser.center_id}"
		class = "close icon">
	</i>

	<div class="header">
		<h1>Select Active Center</h1>
	</div>

	<div class="content">
		<div class = "ui form">
			<div
				if    = "{ selectedCenter }"
				class = "two fields">
				<div class = "field" style="text-align: right; padding-top: 0.6em;">
					<h2>Selected Center</h2>
				</div>
				<div class = "field">
					<div class = "ui icon large buttons">
						<button class = "ui basic green button">
							{selectedCenter.name}
						</button>
						<button
							class   = "ui basic green icon button"
							onclick = "{ clearCenterSelection() }">
							<i class = "icon remove"></i>
						</button>
					</div>
				</div>
			</div>
			<div
				show  = "{ !selectedCenter || (opts.currentUser && opts.currentUser.center_id) }"
				class = "ui fluid field">
				<label>{(opts.currentUser && opts.currentUser.center_id) ? 'Change' : 'Select'} Center</label>
				<input
					type        = "text"
					id          = "center-selection"
					placeholder = "Search for center..." />
			</div>
		</div>
	</div>

	<div class="actions">
		<div  show="{ selectedCenter }" class="ui checkbox">
			<input type = "checkbox" ref = "make_default" />
			<label for = "make_default">Make default center</label>
		</div>
		<div show="{ selectedCenter }" onclick="{ save() }" class="ui blue button">Apply</div>
	</div>

	<script>

		formatResults(center) {
			let attributes = [center.area, center.country, center.region, center.state, center.city].join(', ');
			let value      = center.name + ' - ' + center.category + ' [' + attributes + ']';

			return {value: value, data: center};
		}

		save(e) {
			return(e) => {
				this.parent.applySelectedCenter(this.selectedCenter.id, this.refs.make_default.checked);
			}
		}

		clearCenterSelection(e) {
			return(e) => {
				this.selectedCenter = null;
				this.update();
			}
		}

		if (!this.selectedCenter) {
			let center = sessionStorage.getItem('CENTER');
			if (center) {
				this.selectedCenter = JSON.parse(center);
			}
		}

		setTimeout(() => {
			console.log("Initialize...")
			$("#center-selection").autocomplete({
				minChars : 2,
				lookup   : (query, done) => {
					let params = {
						page    : 1,
						limit   : 15,
						keyword : query
					};

					this.opts.centerService.search(params, (err, response) => {
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
					$("#center-selection")[0].value = '';
					this.selectedCenter = item.data;
					this.update();
				}
			});
		}, 100)

	</script>
</center-selection>
