<participant-list>
	<table
		class = "ui blue table"
		show  = "{participants.length > 0}"
		style = "margin-bottom: 25px;">
		<thead>
			<tr>
				<th>Full Name</th>
				<th>Email Address</th>
				<th>Contact #</th>
				<th style="min-width: 160px; width: 240px; max-width: 240px; text-align: center;">
					<i class="options icon"></i> Actions
				</th>
			</tr>
		</thead>
		<tbody>
			<tr each={ participants } scope={ this }>
				<td>
					<div
						class = "ui violet label"
						if    = "{itmAttr(participant_attributes).role > 1}">
						{participantRoles[itmAttr(participant_attributes).role]}
					</div>
					<label>
						<strong>{first_name}</strong> {last_name}
						<i class = "icon trophy green"
						if = {itmAttr(participant_attributes).ia_graduate}></i>
						<i class = "icon heart red"
						if = {itmAttr(participant_attributes).is_healer}></i>
					</label>
					<br>
					<label
						if    = {other_names}
						style = "font-size: .9em;">({other_names})</label>
				</td>
				<td>{email}</td>
				<td>
					<span if={contact}>
						<i class="icon {contact.contact_type == 'Home' && 'call'} {contact.contact_type == 'Mobile' && 'mobile'} {contact.contact_type == 'Work' && 'building'}">
						</i>
						{contact.value}
					</span>
				</td>
				<td style="color: black !important;">
					<button
						class    = "ui action-btn vertical olive animated button"
						tabindex = "0"
						onclick  = { showView() }>
						<div class="hidden content">View</div>
						<div class="visible content">
							<i class="action info icon"></i>
						</div>
					</button>
					<div
						class    = "ui action-btn vertical yellow animated button"
						tabindex = "0"
						onclick  = { showForm() }>
						<div class="hidden content">Edit</div>
						<div class="visible content">
							<i class="action write icon"></i>
						</div>
					</div>
					<div
						class    = "ui action-btn vertical red animated button"
						tabindex = "0"
						onclick  = { remove() }>
						<div class="hidden content">Delete</div>
						<div class="visible content">
							<i class="action remove icon"></i>
						</div>
					</div>
				</td>
			</tr>
		</tbody>
		<tfoot>
			<tr>
				<td
					colspan = "4"
					style   = "border-top: 1px solid rgba(34,36,38,.1);">
					<div class="ui centered column grid">
						<div class="row">
							<riot-pagination
								show         = "{ participants.length }"
								current-page = "{ currentPage }"
								per-page     = "{ perPage }"
								page-changed = "{ switchPage }"
								page-count   = "{ pageCount }"
								record-count = "{ recordCount }"
								max-buttons  = "8"
								show-first   = "true"
								show-last    = "true"
								show-next    = "true"
								show-prev    = "true">
							</riot-pagination>
						</div>
						<div class="row">
							<span class="ui label">
								Showing { recordRange } / { recordCount } records in { pageCount } pages
							</span>
						</div>
					</div>
					<div class="ui left aligned column grid">
						<div class="row">
							<div class="ui left aligned eight wide column">
								<span style="margin-right: 10px;">
									<i class="icon trophy green"></i>- IA Graduate
								</span>
								<span>
									<i class="icon heart red"></i>- Healer
								</span>
							</div>
							<div class="ui right aligned eight wide column">
								<button
									class = "ui green button tiny {downloadProgress && 'disabled'}"
									onclick = "{ downloadAllParticipantsList() }">
									<i class = "icon download"></i> Download All
								</button>
							</div>
						</div>
					</div>
				</td>
			</tr>
		</tfoot>
	</table>

	<div
		class = "ui message red"
		show  = "{participants.length == 0}">
		<h3>No Participants !</h3>
	</div>

	<script>

		this.currentUser  = this.parent.opts.store.getState().routes.data;

		showView(e) {
			return (e) => {
				this.parent.showView(e.item);
			}
		}

		showForm(e) {
			return (e) => {
				this.parent.showForm(e.item);
			}
		}

		getData(res) {
			return res.data();
		}

		remove(e) {
			return (e) => {
				if (confirm("Are you sure you want to delete the participant?")) {
					this.parent.opts.service.remove(e.item.member_id, (err, response) => {
						if (!err) {
							console.log(response.body().data(), response.statusCode());
							this.performSearch();
						}
						else {
							console.log('some error occurred');
						}
					});
				}
				else {
					// User Cancelled
					console.log("Do no delete!");
				}
			}
		}

		this.participants = [];
		this.perPage      = 10;

		this.participantRoles = ['None', 'Volunteer', 'Thanedar', 'Kotari', 'Mahant', 'Sri Mahant'];

		itmAttr(p) {
			return JSON.parse(p || {})
		}

		switchPage(pageNo) {
			if (pageNo) {
				this.getParticipants({page: pageNo, limit: this.perPage});
			}
		}

		getPage() {
			return this.currentPage && this.recordCount > 1 ? this.currentPage : 1;
		}

		getDefaultQueryParams() {
			return {
				page  : this.getPage(),
				limit : this.perPage
			}
		}

		getParticipants(params) {
			params.version = Date.now();

			if (this.parent.searchQ) {
				params.keyword = this.parent.searchQ;
			}

			if (this.currentUser) {
				params.center_code = this.currentUser.center_code;
			}

			// this.parent.parent.toggleDimmer('SHOW_LOADER');
			$("#pageDimmer").addClass('active');

			this.parent.opts.service.search(params, (err, response) => {
				if (!err && response.body().length) {
					let result = this.getData(response.body()[0]);
					// console.log("result");
					// console.log(result);
					if (result.participants && result.current_page_record_count > 0) {
						this.participants = result.participants;
						this.currentPage  = result.current_page;
						this.pageCount    = result.page_count;
						this.firstPage    = result.first_page;
						this.lastPage     = result.last_page;
						this.recordRange  = result.current_page_record_range.split('..').join(' to ');
						this.recordCount  = result.pagination_record_count;
					}
					else {
						// NO RESULTS
					}

					// this.parent.parent.toggleDimmer('HIDE_LOADER');
					this.update();
					this.tags['riot-pagination'].trigger('refresh');
					$("#pageDimmer").removeClass('active');
				}
				else {
					console.log("ERROR !");
				}
			});
		}

		downloadAllParticipantsList(e) {
			return(e) => {
				if (this.downloadProgress) {
					return false;
				}
				let params = {
					version: Date.now()
				}

				if (this.currentUser) {
					params.center_code = this.currentUser.center_code;
				}

				this.downloadProgress = true;
				this.parent.opts.service.getParticipantsReport(params, (err, response) => {

					if (!err) {
						let data       = response.body();
						let csvContent = "data:text/csv;charset=utf-8,";

						data.forEach((info, i) => {
							let dataString = info.data().join(",");
							csvContent += i < data.length ? dataString+ "\n" : dataString;
						});


						let encodedUri = encodeURI(csvContent);
						let link = document.createElement("a");
						link.setAttribute("href", encodedUri);
						link.setAttribute("download", "all_participants_" + Date.now() + ".csv");
						document.body.appendChild(link);
						this.downloadProgress = false;
						link.click();
						this.update();
					}
				});
			}
		}

		performSearch() {
			let state = this.parent.opts.store.getState();
			// console.log('PERFORM SEARCH', state.participants.query);
			this.getParticipants(state.participants.query || this.getDefaultQueryParams());
		}

		this.on('search', (data) => {
			this.performSearch();
		});

		this.on('refresh', (data) => {
			this.getParticipants(this.getDefaultQueryParams());
		});

		this.performSearch();
		// this.getParticipants(this.getDefaultQueryParams());

	</script>

	<style scoped>
		:scope { font-size: 0.65em; }
		i.action, .action-btn { color: black !important;  }
	</style>

</participant-list>

