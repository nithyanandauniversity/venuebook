<event-search
	class = "ui container"
	id    = "event-search"
	style = "margin: 25px 0;">

	<div class="ui segment form">
		<div class="ui three column grid">

			<div class="four wide column">
				<h3>Search by Event name:</h3>
				<div
					class = "ui input"
					style = "width: 100%;">
					<input type="text" ref="search_keyword" placeholder="Search..." />
				</div>
			</div>
			<div class="six wide column">
				<div class="field">
					<h3>Search by Program</h3>
					<div style="margin-bottom: 1rem;">
						<div
							each  = "{pro in selectedPrograms}"
							style = "margin-right: 8px; margin-bottom: 5px;"
							class = "ui icon buttons">
							<button class = "ui button" style="padding: .5em">
								{pro.program_name}
							</button>
							<button
								class   = "ui icon button"
								style   = "padding: .5em"
								onclick = "{ removeProgramFromList() }">
								<i class = "icon remove"></i>
							</button>
						</div>
					</div>
					<select
						show  = "{programs.length > 0}"
						onchange = "{ programSelected() }"
						ref   = "search_program"
						class = "ui search dropdown">
						<option value="">Search for programs to add...</option>
						<option
							each  = "{program in programs}"
							value = "{program.id}">
							{program.program_name} [{program.program_type}]
						</option>
					</select>
				</div>
			</div>
			<div class="six wide column">
				<h3>Search by Date / Range</h3>
				<div class="ui buttons" style="margin-bottom: 10px;">
					<div
						class      = "ui button {dateSearchKey == 'date' && 'primary active'}"
						data-value = "date"
						onclick    = "{ setDateSearchVal('date') }">
						Start Date
					</div>
					<div
						class      = "ui button {dateSearchKey == 'range' && 'primary active'}"
						data-value = "range"
						onclick    = "{ setDateSearchVal('range') }">
						Date Range
					</div>
				</div>

				<div show = "{dateSearchKey == 'date'}">
					<div class="ui calendar" id="event-date-search">
						<div class="ui input left icon">
							<i class="calendar icon"></i>
							<input
								type        = "text"
								ref         = "event_date"
								readonly    = ""
								placeholder ="Event Date" />
						</div>
					</div>
				</div>
				<div show = "{dateSearchKey == 'range'}">
					<div
						class = "ui calendar"
						id    = "event-from-date"
						style = "margin-bottom: 8px;">
						<label>Date From</label>
						<div class="ui input left icon">
							<i class="calendar icon"></i>
							<input
								type        = "text"
								ref         = "event_from"
								readonly    = ""
								placeholder ="Date From" />
						</div>
					</div>
					<div class="ui calendar" id="event-to-date">
						<label>Date To</label>
						<div class="ui input left icon">
							<i class="calendar icon"></i>
							<input
								type        = "text"
								ref         = "event_to"
								readonly    = ""
								placeholder = "Date To" />
						</div>
					</div>
				</div>
			</div>

		</div>

		<div class="ui column grid" style="margin-bottom: 1px;">
			<div class="ui container">
				<div
					class   = "ui button right floated green"
					onclick = "{ applyEventSearch() }">
					Apply
				</div>
				<div
					show    = "{this.opts.state.view == 'SEARCH_EVENT'}"
					class   = "ui button right floated red"
					onclick = "{ resetEventSearch() }">
					Reset
				</div>
			</div>
		</div>
	</div>



	<script>
		this.perPage            = 10;
		this.dateSearchKey      = 'date';
		this.programs           = [];
		this.selectedProgramIds = [];
		this.selectedPrograms   = [];

		getData(res) {
			return res.data();
		}

		programSelected(e) {
			return(e) => {
				const val = this.refs['search_program'].value;
				const selected_program = this.programs.find(pro => pro.id == val);
				if (!this.selectedProgramIds.includes(val)) {
					this.selectedProgramIds.push(val);
					this.selectedPrograms.push(selected_program);
				}
			}
		}

		removeProgramFromList(e) {
			return(e) => {
				let idx = this.selectedProgramIds.indexOf(e.item.pro.id.toString());

				this.selectedProgramIds.splice(idx, 1);
				this.selectedPrograms.splice(idx, 1);
			}
		}

		setDateSearchVal(val) {
			return (e) => {
				this.dateSearchKey = e.target.dataset.value;
				if (this.dateSearchKey == 'date') {
					$("#event-date-search").calendar({type: 'date'});
				}
				else {
					$("#event-from-date").calendar({type: 'date'});
					$("#event-to-date").calendar({type: 'date'});
				}
			}
		}

		applyEventSearch(e) {
			return(e) => {
				let isParams      = false;
				let keyword       = this.refs['search_keyword'].value;
				let search_date   = this.refs['event_date'].value;
				let from_date     = this.refs['event_from'].value;
				let to_date       = this.refs['event_to'].value;
				let search_params = {};
				let params        = {
					page  : 1,
					limit : this.perPage
				};

				if (keyword && keyword.length > 0) {
					params.keyword = keyword;
				}

				if (this.selectedProgramIds && this.selectedProgramIds.length) {
					isParams = true;
					search_params.program_id = this.selectedProgramIds;
				}

				if (this.dateSearchKey == 'date' && search_date) {
					isParams = true;
					search_params.event_date = [search_date];
				}

				if (this.dateSearchKey == 'range' && from_date && to_date) {
					isParams = true;
					search_params.event_date = [from_date, to_date];
				}

				if (isParams) {
					params.search_params = search_params;
				}

				this.parent.doSearch((params.keyword || isParams) ? params : null);
			}
		}

		resetEventSearch(e) {
			return(e) => {
				this.dateSearchKey                = 'date';
				this.refs['search_keyword'].value = '';
				this.refs['search_program'].value = null;
				this.refs['event_date'].value     = '';
				this.refs['event_from'].value     = '';
				this.refs['event_to'].value       = '';

				this.selectedProgramIds           = [];
				this.selectedPrograms             = [];
				this.update();

				this.parent.doSearch(null);
			}
		}

		loadPrograms() {
			this.parent.opts.programService.search({version : Date.now()}, (err, response) => {
				if (!err) {
					this.programs = this.getData(response.body()[0])['programs'];
				}
				else {
					this.programs = [];
				}
				this.update();

				setTimeout(() => {
					$(".ui.search.dropdown").dropdown({
						forceSelection  : false,
						selectOnKeydown : false
					});
				}, 50);
			});
		}

		this.loadPrograms();

	</script>

</event-search>
