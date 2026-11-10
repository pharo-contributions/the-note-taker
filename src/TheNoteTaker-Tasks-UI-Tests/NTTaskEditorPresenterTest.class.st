"
Tests of the task presenters (TheNoteTaker-Tasks-UI), on an in-memory task repository.
"
Class {
	#name : 'NTTaskEditorPresenterTest',
	#superclass : 'NTTaskUITestCase',
	#category : 'TheNoteTaker-Tasks-UI-Tests',
	#package : 'TheNoteTaker-Tasks-UI-Tests'
}

{ #category : 'helpers' }
NTTaskEditorPresenterTest >> editorOn: aTask [

	^ (NTTaskEditorPresenter newApplication: application model: aTask)
		  repository: repository;
		  yourself
]

{ #category : 'tests' }
NTTaskEditorPresenterTest >> testApplySectionSaves [

	| task editor |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	editor := self editorOn: task.
	editor sectionInput text: '  Admin '.
	editor applySection.
	self assert: task section equals: 'Admin'.
	self assert: ((self fileOf: task) includesSubstring: '"section" : "Admin"')
]

{ #category : 'tests' }
NTTaskEditorPresenterTest >> testApplyTitleSaves [

	| task editor |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	editor := self editorOn: task.
	editor titleInput text: 'Fix the CI'.
	editor applyTitle.
	self assert: task title equals: 'Fix the CI'.
	self assert: ((self fileOf: task) includesSubstring: '"title" : "Fix the CI"')
]

{ #category : 'tests' }
NTTaskEditorPresenterTest >> testChangingTaskShowsListPage [

	| task other editor |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	other := self newTask: 'Write paper' section: 'Research' items: #( 'b' ).
	editor := self editorOn: task.
	editor showTextPage.
	editor model: other.
	self assert: editor isOnListPage.
	self assert: editor titleInput text equals: 'Write paper'
]

{ #category : 'tests' }
NTTaskEditorPresenterTest >> testCorrectingInvalidTextApplies [

	| task editor |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	editor := self editorOn: task.
	editor showTextPage.
	editor textPresenter text: (self text: '- [ ] a
not an item
').
	editor showListPage.
	editor showTextPage.
	editor textPresenter text: (self text: '- [ ] a
- [ ] an item
').
	editor showListPage.
	self deny: editor isEditingText.
	self assert: task items size equals: 2
]

{ #category : 'tests' }
NTTaskEditorPresenterTest >> testEmptySectionRemovesSection [

	| task editor |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	editor := self editorOn: task.
	editor sectionInput text: ''.
	editor applySection.
	self assert: task section isNil.
	self deny: ((self fileOf: task) includesSubstring: '"section"')
]

{ #category : 'tests' }
NTTaskEditorPresenterTest >> testInvalidTextDoesNotChangeTask [

	| task editor before |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	before := self fileOf: task.
	editor := self editorOn: task.
	editor showTextPage.
	editor textPresenter text: (self text: '- [ ] a
not an item
').
	editor showListPage.
	self assert: task items size equals: 1.
	self assert: (self fileOf: task) equals: before
]

{ #category : 'tests' }
NTTaskEditorPresenterTest >> testInvalidTextStaysOnTextPage [

	| task editor |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	editor := self editorOn: task.
	editor showTextPage.
	editor textPresenter text: (self text: '- [ ] a
not an item
').
	editor showListPage.
	self assert: editor isEditingText.
	self assert: (editor errorLabel label includesSubstring: 'Line 2').
	self assert: editor textPresenter selectionInterval equals: (9 to: 19)
]

{ #category : 'tests' }
NTTaskEditorPresenterTest >> testItemChangeSavesTask [

	| task editor |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	editor := self editorOn: task.
	editor itemsPresenter addItemTitled: 'Update the image'.
	self assert: ((self fileOf: task) includesSubstring: '- [ ] Update the image')
]

{ #category : 'tests' }
NTTaskEditorPresenterTest >> testReopenFinishedTaskIsNotPossible [
	"A finished task reopens by itself when an item is added or unticked."

	| task editor |
	task := self finishedTask: 'Move office' section: 'Admin'.
	editor := self editorOn: task.
	self assert: editor statusLabel label equals: 'finished'.
	self deny: editor abandonButton isEnabled
]

{ #category : 'tests' }
NTTaskEditorPresenterTest >> testSavedBlockIsCalled [

	| task editor saved |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	editor := self editorOn: task.
	saved := nil.
	editor whenTaskSavedDo: [ :each | saved := each ].
	editor titleInput text: 'Fix the CI'.
	editor applyTitle.
	self assert: saved equals: task
]

{ #category : 'tests' }
NTTaskEditorPresenterTest >> testShowsTask [

	| task editor |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	editor := self editorOn: task.
	self assert: editor titleInput text equals: 'Fix CI'.
	self assert: editor sectionInput text equals: 'Pharo'.
	self assert: editor statusLabel label equals: 'open'.
	self assert: editor abandonButton label equals: 'Abandon'.
	self assert: editor itemsPresenter model equals: task
]

{ #category : 'tests' }
NTTaskEditorPresenterTest >> testTextPageShowsFile [

	| task editor |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	editor := self editorOn: task.
	editor showTextPage.
	self assert: editor textPresenter text asString equals: (NTTaskWriter write: task)
]

{ #category : 'tests' }
NTTaskEditorPresenterTest >> testTickingLastItemFinishesTask [

	| task editor |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	editor := self editorOn: task.
	editor itemsPresenter toggle: task items first.
	self assert: task isFinished.
	self assert: editor statusLabel label equals: 'finished'
]

{ #category : 'tests' }
NTTaskEditorPresenterTest >> testToggleAbandonAndReopen [

	| task editor |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	editor := self editorOn: task.
	editor toggleAbandon.
	self assert: task isAbandoned.
	self assert: editor statusLabel label equals: 'abandoned'.
	self assert: editor abandonButton label equals: 'Reopen'.
	self assert: ((self fileOf: task) includesSubstring: '"status" : "abandoned"').
	editor toggleAbandon.
	self assert: task isOpen.
	self assert: editor abandonButton label equals: 'Abandon'
]

{ #category : 'tests' }
NTTaskEditorPresenterTest >> testValidTextIsApplied [

	| task editor file |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	file := task fileReference.
	editor := self editorOn: task.
	editor showTextPage.
	editor textPresenter text: (self text: '{
  "title" : "Fix CI",
  "section" : "Pharo"
}

- [ ] a
- [ ] b @due(2026-11-20)
').
	editor showListPage.
	self deny: editor isEditingText.
	self assert: editor isOnListPage.
	self assert: task items size equals: 2.
	self assert: task items second due equals: (self nov: 20).
	self assert: task fileReference equals: file.
	self assert: ((self fileOf: task) includesSubstring: '- [ ] b @due(2026-11-20)').
	self assert: editor errorLabel label isEmpty
]

{ #category : 'tests' }
NTTaskEditorPresenterTest >> testWithoutTask [

	| editor |
	editor := self editorOn: nil.
	self assert: editor titleInput text isEmpty.
	self assert: editor sectionInput text isEmpty.
	self assert: editor statusLabel label isEmpty.
	self deny: editor abandonButton isEnabled
]
