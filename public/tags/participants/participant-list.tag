<participant-list>

	<div class="ui steps fluid" show = "{ showMergeDiv }">
		<div class="step {showMergeStep == 1 && 'active'}">
			<i class="icon list ul"></i>
			<div class="content">
				<div class="title">Select</div>
				<div class="description">Choose participants you want to merge</div>
			</div>
		</div>
		<div class="step {showMergeStep == 2 && 'active'}">
			<i class="icon tasks"></i>
			<div class="content">
				<div class="title">Customize</div>
				<div class="description">Customise the attributes you want to merge</div>
			</div>
		</div>
		<div class="step {showMergeStep == 3 && 'active'}">
			<i class="icon save"></i>
			<div class="content">
				<div class="title">Confirm</div>
				<div class="description">Verify and complete merge process</div>
			</div>
		</div>
	</div>

	<div class="ui" show="{ showParticipantsList }">
		<div class="ui red message" show = "{ noResultsMessage }">
			<h2>No Results!</h2>
			<p>No records found for your search criteria. Please try again with different parameters.</p>
		</div>

		<table
			class = "ui blue table"
			show  = "{participants.length > 0 && !noResultsMessage}"
			style = "margin-bottom: 25px;">
			<thead>
				<tr>
					<th show = "{ showMergeDiv }" style="text-align: center;">
						<i class="icon check square large"></i>
					</th>
					<th>Full Name</th>
					<th>Email Address</th>
					<th>Contact #</th>
					<th style="min-width: 160px; width: 240px; max-width: 240px; text-align: center;">
						<i class="options icon"></i> Actions
					</th>
				</tr>
			</thead>
			<tbody>
				<tr show = "{showMergeDiv}">
					<td colspan="4">
						Select the participants you want to merge and click next...
					</td>
					<td style="text-align: center;">
						<button
							onclick = "{ goToMergeStepTwo }"
							class   = "ui orange large button {mergeUserList.length < 2 ? 'disabled' : 'active'}">
							Next Step
							<i class="icon chevron circle right"></i>
						</button>
					</td>
				</tr>
				<tr each={ participant in participants } scope={ this }>
					<td show = "{ showMergeDiv }" style="width: 75px;">
						<button
							onclick = "{ toggleSelectParticipant }"
							style   = "margin: 0;"
							class   = "ui icon orange mini button {participant.selectedToMerge ? 'active' : 'basic'}">
							<i class = "icon check large {!participant.selectedToMerge && 'outline'}"></i>
						</button>
					</td>
					<td>
						<div
							class = "ui violet label"
							if    = "{itmAttr(participant.participant_attributes).role > 1}">
							{participantRoles[itmAttr(participant.participant_attributes).role]}
						</div>
						<label>
							<strong>{participant.first_name}</strong> {participant.last_name}
							<i class = "icon trophy green"
							if = {itmAttr(participant.participant_attributes).ia_graduate}></i>
							<i class = "icon heart red"
							if = {itmAttr(participant.participant_attributes).is_healer}></i>
						</label>
						<br>
						<label
							if    = {participant.other_names}
							style = "font-size: .9em;">({participant.other_names})</label>
					</td>
					<td>{participant.email}</td>
					<td>
						<span if={participant.contact}>
							<i class="icon {participant.contact.contact_type == 'Home' && 'call'} {participant.contact.contact_type == 'Mobile' && 'mobile'} {participant.contact.contact_type == 'Work' && 'building'}">
							</i>
							{participant.contact.value}
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
						colspan = "{showMergeDiv ? 5 : 4}"
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
								</div>
							</div>
						</div>
					</td>
				</tr>
			</tfoot>
		</table>
	</div>

	<div class="ui" if = "{ !showParticipantsList && showMergeStep == 2 }">
		<div class="ui grid">
			<div class="row">
				<div class="column">
					<button
						onclick = "{ goToMergeStepOne }"
						class   = "ui left floated large blue button">
						<i class="icon chevron circle left"></i> Previous
					</button>
					<button class="ui right floated large green button {!mainParticipant && 'disabled'}">
						<i class="icon check circle right"></i> Save
					</button>
				</div>
			</div>

			<div class="ui divider" style="margin-top: 0;"></div>

			<div class="two column row">
				<div class="five wide column">
					<div class="ui vertical fluid menu">
						<a
							each    = "{item in mergeUserList}"
							onclick = "{ selectMainParticipant }"
							class   = "item {mainParticipant && (mainParticipant.id != item.id ? 'disabled grey' : 'active orange')}">
							<div
								data-tooltip  = "Number of programs attended"
								data-position = "right center"
								data-inverted = ""
								class         = "ui orange label event_count_label">
								{item.events_count}
							</div>
							<div>
								<label><strong>{item.full_name}</strong></label>
							</div>
							<p>
								<span show="{item.email}"><strong>Email: </strong>{item.email}</span>
							</p>
						</a>
					</div>
				</div>
				<div class="eleven wide column">
					<div if={!mainParticipant} class="ui message yellow">
						<h4>Select the Main participant you want to merge the rest into</h4>
					</div>
					<div if={mainParticipant} class="ui fluid card">
						<div class="content">
							<div class="header">{mainParticipant.full_name}</div>
							<div if={mainParticipant.other_names} class="meta">{mainParticipant.other_names || 'N/A'}</div>
							<div class="description">
								<div class="fields">
									<div class="field"><span>{mainParticipant.email}</span></div>
								</div>
								<div class="ui segment orange">
									<label><i class="icon write"></i> Notes</label>
									<p>{mainParticipant.notes}</p>
								</div>
							</div>
						</div>
						<div class="extra content">
							<div class="ui two column grid">
								<div class="six wide column">
									<span
										each  = {mainParticipant.contacts}
										style = "cursor: default; display: block; margin-bottom: 5px;">
										<i class="icon {contact_type == 'Home' && 'call'} {contact_type == 'Mobile' && 'mobile'} {contact_type == 'Work' && 'building'} {id == mainParticipant.default_contact && 'blue'}">
										</i>
										{value}
									</span>
								</div>
								<div class="six wide column">
									<table class="ui very basic table">
										<tr each = {mainParticipant.addresses}>
											<td style="padding: 0;">
												<i class="icon marker {id == mainParticipant.default_address && 'blue'}"></i>
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
					<button
						onclick = "{ resetMainParticipant }"
						if      = "{ mainParticipant }"
						class   = "ui button small teal right floated">
						Choose another record from list
					</button>
				</div>
			</div>

			<div class="ui divider" style="margin-top: 0;"></div>
			<div class="row" if="{mainParticipant}">
				<div class="column">
					<h4>Select attributes to merge from other duplicate records if any...</h4>
					<table
						class = "ui very compact table"
						if    = "{ otherAttributes && otherAttributes.length }"
					>
						<thead>
							<tr>
								<th>Attribute</th>
								<th>Values</th>
							</tr>
						</thead>
						<tbody>
							<tr
								each = "{attribute in otherAttributes}"
								if   = "{attribute.values && attribute.values.length}"
							>
								<td>{attribute.label}</td>
								<td>
									<div if="{attribute.type == 'string'}">
										<button
											class     = "ui small violet button {!itm.active && 'basic'}"
											data-attr = "{attribute.attr}"
											each      = "{itm in attribute.values}"
											onClick   = "{ selectAttribute }"
										>
											{itm.val}
										</button>
									</div>
									<div if="{attribute.attr == 'contacts' && attribute.values.length}">
										<button
											class   = "ui icon button purple basic"
											each    = "{ contact in attribute.values }"
											onClick = "{ selectAttribute }">
											<i class="icon {contact.val.contact_type == 'Mobile' ? 'mobile' : 'phone'}"></i>
											{contact.val.value}
										</button>
									</div>
									<div
										if      = "{attribute.attr == 'addresses' && attribute.values.length}"
										each    = "{ address in attribute.values }"
										onClick = "{ selectAttribute }">
										<button class="ui icon button purple basic">
											<i class="icon map"></i>
											<span>
												{[address.val.street, address.val.state].join(' ').trim()} {address.val.postal_code} <br />
												{address.val.city}. {address.val.country}
											</span>
										</button>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<!-- <div class="ui divider" style="margin-top: 0;"></div> -->

			<div class="row">
				<div class="column">
					<button class="ui right floated large green button {!mainParticipant && 'disabled'}">
						<i class="icon check circle right"></i> Save
					</button>
				</div>
			</div>
		</div>
	</div>

	<div
		class = "ui message red"
		show  = "{participants.length == 0}">
		<h3>No Participants !</h3>
	</div>

	<script>

		this.mergeUserList        = [];
		this.showMergeDiv         = false;
		this.showParticipantsList = true;

		this.currentUser  = this.parent.opts.store.getState().routes.data;

		showView(e) {
			return (e) => {
				this.parent.showView(e.item.participant);
			}
		}

		showForm(e) {
			return (e) => {
				this.parent.showForm(e.item.participant);
			}
		}

		getData(res) {
			return res.data();
		}

		remove(e) {
			return (e) => {
				if (confirm("Are you sure you want to delete the participant?")) {
					this.parent.opts.service.remove(e.item.participant.member_id, (err, response) => {
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

		getView() {
			return this.parent.opts.store.getState().participants.view;
		}

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

		formatSearchResults(result) {
			if (result.participants && result.current_page_record_count > 0) {
				let selectedItemsNotInResults = [];

				if (this.showMergeDiv) {
					if (this.mergeUserList.length > 0) {
						const mergeIds = this.mergeUserList.map((m) => { return m.id; });
						let dataIds    = [];
						result.participants.forEach((p) => {
							if (mergeIds.indexOf(p.id) >= 0) {
								p.selectedToMerge = true;
								dataIds.push(p.id);
							}
						});
						selectedItemsNotInResults = this.mergeUserList.filter((m) => { return dataIds.indexOf(m.id) < 0; });
					}
				}
				// console.log("selectedItemsNotInResults: ", selectedItemsNotInResults);

				this.noResultsMessage = false;
				this.participants     = selectedItemsNotInResults.concat(result.participants);
				this.currentPage      = result.current_page;
				this.pageCount        = result.page_count;
				this.firstPage        = result.first_page;
				this.lastPage         = result.last_page;
				this.recordRange      = result.current_page_record_range.split('..').join(' to ');
				this.recordCount      = result.pagination_record_count;
			}
			else {
				// NO RESULTS
				this.noResultsMessage = true;
			}

			// this.parent.parent.toggleDimmer('HIDE_LOADER');
			this.update();
			this.tags['riot-pagination'].trigger('refresh');
			$("#pageDimmer").removeClass('active');
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
					this.formatSearchResults(this.getData(response.body()[0]));
					// console.log("result");
					// console.log(result);
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

		toggleSelectParticipant(e) {
			e.item.participant.selectedToMerge = !e.item.participant.selectedToMerge;

			if (e.item.participant.selectedToMerge) {
				this.mergeUserList.push(e.item.participant);
			}
			else {
				this.mergeUserList = this.mergeUserList.filter((u) => {
					return u.id != e.item.participant.id;
				});
			}
		}

		selectMainParticipant(e) {
			if (this.mainParticipant) { return; }
			this.mainParticipant = e.item.item;
			this.generateOtherAttributes();
		}

		selectAttribute(e) {
			console.log("e.item");
			console.log(e.target.dataset.attr, e.item);
			const val = e.item.itm.active;
			this.otherAttributes.forEach((attribute) => {
				if (attribute.attr == e.target.dataset.attr) {
					attribute.values.forEach((val) => {
						val.active = false;
					});
				}
			});
			e.item.itm.active = !val;
		}

		mapValidAttributes(rec, attr) {
			return rec.reduce((ar, r) => {
				if (r[attr]) {
					if (typeof r[attr] != 'object') {
						ar.push({active: false, val: r[attr]});
					}
					else {
						r[attr].forEach((a) => { ar.push({active: false, val: a}); });
					}
				}
				return ar;
			}, []);
		}

		generateOtherAttributes() {
			const otherRecords = this.mergeUserList.filter((u) => {
				return u.id != this.mainParticipant.id;
			});

			this.otherAttributes = [
				{ attr: 'first_name',  label: 'First Name',      type: 'string', values: this.mapValidAttributes(otherRecords, 'first_name') },
				{ attr: 'last_name',   label: 'Last Name',       type: 'string', values: this.mapValidAttributes(otherRecords, 'last_name')},
				{ attr: 'other_names', label: 'Spiritual Name',  type: 'string', values: this.mapValidAttributes(otherRecords, 'other_names')},
				{ attr: 'email',       label: 'Email',           type: 'string', values: this.mapValidAttributes(otherRecords, 'email')},
				{ attr: 'contacts',    label: 'Contact Numbers', type: 'object', values: this.mapValidAttributes(otherRecords, 'contacts')},
				{ attr: 'addresses',   label: 'Addresses',       type: 'object', values: this.mapValidAttributes(otherRecords, 'addresses')},
				{ attr: 'others',      label: 'Others',          type: 'string', values: ['a', 'b', 'a', 'c', 'd', 'a']}
			]

			console.log("this.otherAttributes");
			console.log(this.otherAttributes);
		}

		resetMainParticipant() {
			this.mainParticipant = null;
		}

		goToMergeStepOne() {
			this.parent.goToMergeStepOne(this.mergeUserList);
		}

		goToMergeStepTwo() {
			this.parent.goToMergeStepTwo(this.mergeUserList);
		}

		performSearch() {
			let state = this.parent.opts.store.getState();
			this.getParticipants(state.participants.query || this.getDefaultQueryParams());
		}

		refreshMergeDivs() {
			this.showMergeDiv         = this.parent.opts.store.getState().participants.view == 'MERGE_PARTICIPANT';
			this.showMergeStep        = this.parent.opts.store.getState().participants.step || 1;
			this.showParticipantsList = !this.showMergeDiv || (this.showMergeDiv && this.showMergeStep ==1);
			const mergeData           = this.parent.opts.store.getState().participants.data;
			if (mergeData && mergeData.length > 0) {
				if (this.showMergeStep === 1) {
					this.mergeUserList = mergeData;
				}
				else if (this.showMergeStep === 2) {
					// Load Merge Participants
					this.loadMergeParticipants(mergeData);
				}
			}
			this.update();
		}

		loadMergeParticipants(data) {
			$("#pageDimmer").addClass('active');
			this.parent.opts.service.getManyParticipants(data.map((d) => { return d.member_id }), (err, response) => {
				if (!err && response.body().length) {
					const participants = response.body().map(this.getData);
					this.mergeUserList = participants;
					if (this.mergeUserList.length && !this.mainParticipant) {
						this.selectMainParticipant({item: {item: this.mergeUserList[0]}});
					}
				}
				else {
					console.log("Error !", err);
				}
				this.update();
				$('.event_count_label').popup();
				$("#pageDimmer").removeClass('active');
			});
		}

		this.on('search', (data) => {
			this.performSearch();
		});

		this.on('refresh', (data) => {
			this.refreshMergeDivs();
			this.getParticipants(this.getDefaultQueryParams());
		});

		this.on('merge', () => {
			this.refreshMergeDivs();
		});

		this.performSearch();
		// this.getParticipants(this.getDefaultQueryParams());

	</script>

	<style scoped>
		:scope { font-size: 0.65em; }
		i.action, .action-btn { color: black !important;  }
	</style>

</participant-list>

