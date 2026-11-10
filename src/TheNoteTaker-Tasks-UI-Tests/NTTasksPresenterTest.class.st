"
Tests of the task presenters (TheNoteTaker-Tasks-UI), on an in-memory task repository.
"
Class {
	#name : 'NTTasksPresenterTest',
	#superclass : 'NTTaskUITestCase',
	#category : 'TheNoteTaker-Tasks-UI-Tests',
	#package : 'TheNoteTaker-Tasks-UI-Tests'
}

{ #category : 'tests - views' }
NTTasksPresenterTest >> presenter [

	^ NTTasksPresenter newApplication: application model: repository
]

{ #category : 'tests' }
NTTasksPresenterTest >> testChildrenOfClosedSection [

	| presenter office |
	self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	office := self finishedTask: 'Move office' section: 'Admin'.
	presenter := NTTasksPresenter newApplication: application model: repository.
	self assert: (presenter childrenOf: 'Finished / Abandoned') asArray equals: { office }
]

{ #category : 'tests' }
NTTasksPresenterTest >> testChildrenOfSection [

	| presenter ci |
	ci := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	self newTask: 'Write paper' section: 'Research' items: #(  ).
	presenter := NTTasksPresenter newApplication: application model: repository.
	self assert: (presenter childrenOf: 'Pharo') asArray equals: { ci }
]

{ #category : 'tests' }
NTTasksPresenterTest >> testDeleteSelectedTask [

	| presenter ci |
	ci := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	presenter := NTTasksPresenter newApplication: application model: repository.
	presenter selectTask: ci.
	presenter deleteSelectedTask.
	self deny: ci fileReference exists.
	self assert: presenter roots isEmpty.
	self assert: presenter editor model isNil
]

{ #category : 'tests - views' }
NTTasksPresenterTest >> testDeleteSelectedView [

	| presenter today |
	presenter := self presenter.
	today := repository views viewNamed: 'Today'.
	presenter selectView: today.
	presenter deleteSelectedView.
	self deny: (presenter viewsList items includes: today).
	self assert: (repository views viewNamed: 'Today') isNil.
	self deny: ((repository folder / 'views.md') contents includesSubstring: '"Today"').
	self assert: presenter detailPresenter equals: presenter editor
]

{ #category : 'tests' }
NTTasksPresenterTest >> testDisplayOfClosedTasks [

	| presenter office grant |
	office := self finishedTask: 'Move office' section: 'Admin'.
	grant := self newTask: 'Old grant' section: 'Research' items: #(  ).
	grant abandon.
	presenter := NTTasksPresenter newApplication: application model: repository.
	self assert: (presenter displayStringOf: office) equals: '✓ Move office'.
	self assert: (presenter displayStringOf: grant) equals: '× Old grant'
]

{ #category : 'tests' }
NTTasksPresenterTest >> testDisplayOfSectionAndOpenTask [

	| presenter ci |
	ci := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' 'b' ).
	ci items first markDoneOn: (self nov: 5).
	presenter := NTTasksPresenter newApplication: application model: repository.
	self assert: (presenter displayStringOf: 'Pharo') equals: 'Pharo'.
	self assert: (presenter displayStringOf: ci) equals: 'Fix CI  1/2'
]

{ #category : 'tests - views' }
NTTasksPresenterTest >> testEditViewFromForm [

	| presenter form today |
	presenter := self presenter.
	today := repository views viewNamed: 'Today'.
	presenter selectView: today.
	form := presenter viewFormOn: today.
	form nameInput text: 'Now'.
	self assert: form accept.
	self assert: (presenter displayStringOfView: today) equals: 'Now  0'.
	self assert: presenter viewPresenter titleLabel label equals: 'Now  (0)'.
	self assert: ((repository folder / 'views.md') contents includesSubstring: '"Now"')
]

{ #category : 'tests' }
NTTasksPresenterTest >> testEditorSaveRefreshesTreeAndKeepsSelection [

	| presenter ci |
	ci := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	presenter := NTTasksPresenter newApplication: application model: repository.
	presenter selectTask: ci.
	presenter editor sectionInput text: 'Admin'.
	presenter editor applySection.
	self assert: presenter roots asArray equals: #( 'Admin' ).
	self assert: presenter selectedTask equals: ci
]

{ #category : 'tests' }
NTTasksPresenterTest >> testNewTaskTitled [

	| presenter task |
	presenter := NTTasksPresenter newApplication: application model: repository.
	task := presenter newTaskTitled: 'Buy milk'.
	self assert: (repository tasks includes: task).
	self assert: task fileReference exists.
	self assert: presenter selectedTask equals: task.
	self assert: (presenter roots includes: 'Unsorted')
]

{ #category : 'tests' }
NTTasksPresenterTest >> testNewTaskWithEmptyTitleDoesNothing [

	| presenter |
	presenter := NTTasksPresenter newApplication: application model: repository.
	self assert: (presenter newTaskTitled: '  ') isNil.
	self assert: repository tasks isEmpty
]

{ #category : 'tests - views' }
NTTasksPresenterTest >> testNewViewFromForm [

	| presenter form |
	presenter := self presenter.
	form := presenter viewFormOn: nil.
	form nameInput text: 'Pharo only'.
	form sectionsList selectItems: #( 'Unsorted' ).
	self assert: form accept.
	self assert: presenter viewsList items last name equals: 'Pharo only'.
	self assert: presenter viewsList selectedItem name equals: 'Pharo only'.
	self assert: ((repository folder / 'views.md') contents includesSubstring: '"Pharo only"')
]

{ #category : 'tests' }
NTTasksPresenterTest >> testNoClosedSectionWithoutClosedTasks [

	| presenter |
	self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	presenter := NTTasksPresenter newApplication: application model: repository.
	self assert: presenter roots asArray equals: #( 'Pharo' )
]

{ #category : 'tests' }
NTTasksPresenterTest >> testOpenAndClose [

	| presenter window |
	self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	presenter := NTTasksPresenter newApplication: application model: repository.
	window := presenter open.
	self assert: window isOpen.
	window close.
	self deny: window isOpen
]

{ #category : 'tests' }
NTTasksPresenterTest >> testReloadReadsNewFiles [

	| presenter |
	presenter := NTTasksPresenter newApplication: application model: repository.
	repository folder ensureCreateDirectory.
	repository folder / '2026-11-07_call.md' writeStreamDo: [ :stream | stream nextPutAll: '- [ ] Call Bob' ].
	presenter reload.
	self assert: presenter roots asArray equals: #( 'Unsorted' )
]

{ #category : 'tests - views' }
NTTasksPresenterTest >> testReloadRereadsViews [

	| presenter |
	presenter := self presenter.
	repository folder ensureCreateDirectory.
	repository folder / 'views.md' writeStreamDo: [ :s | s nextPutAll: '{ "views" : [ { "name" : "Mine" } ] }' ].
	presenter reload.
	self assert: (presenter viewsList items collect: [ :each | each name ] as: Array) equals: #( 'Mine' )
]

{ #category : 'tests - views' }
NTTasksPresenterTest >> testRequestTaskFromViewSelectsIt [

	| presenter task |
	task := self task: 'Release' section: 'Pharo' lines: #( '- [ ] notes @due(2026-11-10)' ).
	presenter := self presenter.
	presenter selectView: (repository views viewNamed: 'Today').
	presenter viewPresenter requestTaskOf: presenter viewPresenter entries first.
	self assert: presenter selectedTask equals: task.
	self assert: presenter detailPresenter equals: presenter editor
]

{ #category : 'tests' }
NTTasksPresenterTest >> testRootsAreSectionsThenClosedSection [

	| presenter |
	self newTask: 'Write paper' section: 'Research' items: #(  ).
	self newTask: 'Buy cables' section: nil items: #(  ).
	self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	self finishedTask: 'Move office' section: 'Admin'.
	presenter := NTTasksPresenter newApplication: application model: repository.
	self assert: presenter roots asArray equals: #( 'Pharo' 'Research' 'Unsorted' 'Finished / Abandoned' )
]

{ #category : 'tests' }
NTTasksPresenterTest >> testSelectSectionShowsNoTask [

	| presenter ci |
	ci := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	presenter := NTTasksPresenter newApplication: application model: repository.
	presenter selectTask: ci.
	presenter taskTree selectPath: #( 1 ).
	self assert: presenter selectedTask isNil.
	self assert: presenter editor model isNil
]

{ #category : 'tests - views' }
NTTasksPresenterTest >> testSelectTaskAfterViewShowsEditor [

	| presenter task |
	task := self task: 'Release' section: 'Pharo' lines: #( '- [ ] notes' ).
	presenter := self presenter.
	presenter selectView: (repository views viewNamed: 'Today').
	presenter selectTask: task.
	self assert: presenter detailPresenter equals: presenter editor.
	self assert: presenter editor model equals: task.
	self assert: presenter viewsList selectedItem isNil
]

{ #category : 'tests' }
NTTasksPresenterTest >> testSelectTaskShowsItInEditor [

	| presenter ci |
	ci := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	presenter := NTTasksPresenter newApplication: application model: repository.
	presenter selectTask: ci.
	self assert: presenter selectedTask equals: ci.
	self assert: presenter editor model equals: ci
]

{ #category : 'tests - views' }
NTTasksPresenterTest >> testSelectViewAfterTaskUnselectsTask [

	| presenter task |
	task := self task: 'Release' section: 'Pharo' lines: #( '- [ ] notes' ).
	presenter := self presenter.
	presenter selectTask: task.
	presenter selectView: (repository views viewNamed: 'Today').
	self assert: presenter selectedTask isNil.
	self assert: presenter detailPresenter equals: presenter viewPresenter
]

{ #category : 'tests - views' }
NTTasksPresenterTest >> testSelectViewShowsIt [

	| presenter today |
	presenter := self presenter.
	today := repository views viewNamed: 'Today'.
	presenter selectView: today.
	self assert: presenter detailPresenter equals: presenter viewPresenter.
	self assert: presenter viewPresenter model equals: today
]

{ #category : 'tests - views' }
NTTasksPresenterTest >> testTaskSavedRefreshesCounts [

	| presenter task |
	task := self task: 'Release' section: 'Pharo' lines: #( '- [ ] notes @due(2026-11-10)' ).
	presenter := self presenter.
	presenter selectTask: task.
	presenter editor itemsPresenter toggle: task items first.
	self assert: (presenter displayStringOfView: (repository views viewNamed: 'Today')) equals: 'Today  0'
]

{ #category : 'tests' }
NTTasksPresenterTest >> testTasksHaveNoChildren [

	| presenter ci |
	ci := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	presenter := NTTasksPresenter newApplication: application model: repository.
	self assert: (presenter childrenOf: ci) isEmpty
]

{ #category : 'tests - views' }
NTTasksPresenterTest >> testTickInViewRefreshesTreeAndCounts [

	| presenter task |
	task := self task: 'Release' section: 'Pharo' lines: #( '- [ ] notes @due(2026-11-10)' '- [ ] slides' ).
	presenter := self presenter.
	presenter selectView: (repository views viewNamed: 'Today').
	presenter viewPresenter toggle: presenter viewPresenter entries first.
	self assert: (presenter displayStringOf: task) equals: 'Release  1/2'.
	self assert: (presenter displayStringOfView: (repository views viewNamed: 'Today')) equals: 'Today  0'
]

{ #category : 'tests - errors' }
NTTasksPresenterTest >> testUnreadableViewsFileIsReported [

	| presenter |
	repository folder ensureCreateDirectory.
	repository folder / 'views.md' writeStreamDo: [ :s | s nextPutAll: '{ "views" : [ { "period" : "today" } ] }' ].
	repository reload.
	presenter := self presenter.
	self assert: presenter viewsLabel label equals: 'Views (views.md not read: a view has no name)'
]

{ #category : 'tests - views' }
NTTasksPresenterTest >> testViewsLabel [

	self assert: self presenter viewsLabel label equals: 'Views'
]

{ #category : 'tests - views' }
NTTasksPresenterTest >> testViewsListShowsViewsWithCounts [

	| presenter |
	self task: 'Release' section: 'Pharo' lines: #( '- [ ] notes @due(2026-11-10)' '- [ ] slides @due(2026-11-12)' ).
	presenter := self presenter.
	self
		assert: (presenter viewsList items collect: [ :each | each name ] as: Array)
		equals: #( 'Today' 'This week' 'Monthly review' 'Late' 'Waiting for others' ).
	self assert: (presenter displayStringOfView: (repository views viewNamed: 'Today')) equals: 'Today  1'.
	self assert: (presenter displayStringOfView: (repository views viewNamed: 'This week')) equals: 'This week  2'
]
