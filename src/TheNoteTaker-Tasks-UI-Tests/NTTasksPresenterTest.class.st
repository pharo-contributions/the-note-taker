"
Tests of the task presenters (TheNoteTaker-Tasks-UI), on an in-memory task repository.
"
Class {
	#name : 'NTTasksPresenterTest',
	#superclass : 'NTTaskUITestCase',
	#category : 'TheNoteTaker-Tasks-UI-Tests',
	#package : 'TheNoteTaker-Tasks-UI-Tests'
}

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

{ #category : 'tests' }
NTTasksPresenterTest >> testSelectTaskShowsItInEditor [

	| presenter ci |
	ci := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	presenter := NTTasksPresenter newApplication: application model: repository.
	presenter selectTask: ci.
	self assert: presenter selectedTask equals: ci.
	self assert: presenter editor model equals: ci
]

{ #category : 'tests' }
NTTasksPresenterTest >> testTasksHaveNoChildren [

	| presenter ci |
	ci := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	presenter := NTTasksPresenter newApplication: application model: repository.
	self assert: (presenter childrenOf: ci) isEmpty
]
