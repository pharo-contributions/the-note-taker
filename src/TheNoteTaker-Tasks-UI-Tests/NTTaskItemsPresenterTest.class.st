"
Tests of the task presenters (TheNoteTaker-Tasks-UI), on an in-memory task repository.
"
Class {
	#name : 'NTTaskItemsPresenterTest',
	#superclass : 'NTTaskUITestCase',
	#category : 'TheNoteTaker-Tasks-UI-Tests',
	#package : 'TheNoteTaker-Tasks-UI-Tests'
}

{ #category : 'tests' }
NTTaskItemsPresenterTest >> testActionsWithoutSelectionDoNothing [

	| task items |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	items := NTTaskItemsPresenter newApplication: application model: task.
	items removeSelectedItem.
	items moveSelectedItemDown.
	self assert: task items size equals: 1
]

{ #category : 'tests' }
NTTaskItemsPresenterTest >> testAddEmptyItemDoesNothing [

	| task items changes |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #(  ).
	items := NTTaskItemsPresenter newApplication: application model: task.
	changes := 0.
	items whenItemsChangedDo: [ changes := changes + 1 ].
	self assert: (items addItemTitled: ' ') isNil.
	self assert: task items isEmpty.
	self assert: changes equals: 0
]

{ #category : 'tests' }
NTTaskItemsPresenterTest >> testAddItemFromInputClearsIt [

	| task items |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #(  ).
	items := NTTaskItemsPresenter newApplication: application model: task.
	items newItemInput text: 'Update the image'.
	items addItemFromInput.
	self assert: task items size equals: 1.
	self assert: items newItemInput text isEmpty
]

{ #category : 'tests' }
NTTaskItemsPresenterTest >> testAddItemTitled [

	| task items changes item |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	items := NTTaskItemsPresenter newApplication: application model: task.
	changes := 0.
	items whenItemsChangedDo: [ changes := changes + 1 ].
	item := items addItemTitled: '  Update the image '.
	self assert: task items last equals: item.
	self assert: item title equals: 'Update the image'.
	self assert: item createdDate equals: Date today.
	self assert: items selectedItem equals: item.
	self assert: changes equals: 1
]

{ #category : 'tests' }
NTTaskItemsPresenterTest >> testAnnotationsString [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item due: (self nov: 15).
	item addTag: 'work'.
	self assert: (NTTaskItemsPresenter new annotationsStringOf: item) equals: '@due(2026-11-15) #work'
]

{ #category : 'tests' }
NTTaskItemsPresenterTest >> testAnnotationsStringHidesDoneAndCreated [
	"The checkbox already shows @done, and @created is bookkeeping: the column shows the other annotations."

	| item |
	item := NTTaskItem title: 'Send slides'.
	item createdDate: (self nov: 4).
	item markDoneOn: (self nov: 8).
	item addTag: 'work'.
	self assert: (NTTaskItemsPresenter new annotationsStringOf: item) equals: '#work'
]

{ #category : 'tests' }
NTTaskItemsPresenterTest >> testDetailChangeIsForwarded [

	| task items changes |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	items := NTTaskItemsPresenter newApplication: application model: task.
	changes := 0.
	items whenItemsChangedDo: [ changes := changes + 1 ].
	items selectItem: task items first.
	items itemPresenter dueDate date: (self nov: 20).
	self assert: task items first due equals: (self nov: 20).
	self assert: changes equals: 1
]

{ #category : 'tests' }
NTTaskItemsPresenterTest >> testMoveFirstItemUpDoesNothing [

	| task items changes |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' 'b' ).
	items := NTTaskItemsPresenter newApplication: application model: task.
	changes := 0.
	items whenItemsChangedDo: [ changes := changes + 1 ].
	items selectItem: task items first.
	items moveSelectedItemUp.
	self assert: (task items collect: [ :each | each title ] as: Array) equals: #( 'a' 'b' ).
	self assert: changes equals: 0
]

{ #category : 'tests' }
NTTaskItemsPresenterTest >> testMoveSelectedItemDown [

	| task items b |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' 'b' 'c' ).
	b := task items second.
	items := NTTaskItemsPresenter newApplication: application model: task.
	items selectItem: b.
	items moveSelectedItemDown.
	self assert: (task items collect: [ :each | each title ] as: Array) equals: #( 'a' 'c' 'b' )
]

{ #category : 'tests' }
NTTaskItemsPresenterTest >> testMoveSelectedItemUp [

	| task items b |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' 'b' 'c' ).
	b := task items second.
	items := NTTaskItemsPresenter newApplication: application model: task.
	items selectItem: b.
	items moveSelectedItemUp.
	self assert: (task items collect: [ :each | each title ] as: Array) equals: #( 'b' 'a' 'c' ).
	self assert: items selectedItem equals: b
]

{ #category : 'tests' }
NTTaskItemsPresenterTest >> testRemoveSelectedItem [

	| task items |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' 'b' ).
	items := NTTaskItemsPresenter newApplication: application model: task.
	items selectItem: task items first.
	items removeSelectedItem.
	self assert: (task items collect: [ :each | each title ] as: Array) equals: #( 'b' ).
	self assert: items table items size equals: 1
]

{ #category : 'tests' }
NTTaskItemsPresenterTest >> testRenameItem [

	| task items item |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	item := task items first.
	items := NTTaskItemsPresenter newApplication: application model: task.
	items rename: item to: ' Update the image '.
	self assert: item title equals: 'Update the image'
]

{ #category : 'tests' }
NTTaskItemsPresenterTest >> testRenameToEmptyKeepsTitle [

	| task items item |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	item := task items first.
	items := NTTaskItemsPresenter newApplication: application model: task.
	items rename: item to: ''.
	self assert: item title equals: 'a'
]

{ #category : 'tests' }
NTTaskItemsPresenterTest >> testSelectingItemShowsDetail [

	| task items |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' 'b' ).
	items := NTTaskItemsPresenter newApplication: application model: task.
	items selectItem: task items second.
	self assert: items itemPresenter model equals: task items second
]

{ #category : 'tests' }
NTTaskItemsPresenterTest >> testTableShowsItemsInOrder [

	| task items |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' 'b' ).
	items := NTTaskItemsPresenter newApplication: application model: task.
	self assert: items table items asArray equals: task items asArray
]

{ #category : 'tests' }
NTTaskItemsPresenterTest >> testToggleMarksDoneThenUndone [

	| task items item changes |
	task := self newTask: 'Fix CI' section: 'Pharo' items: #( 'a' ).
	item := task items first.
	items := NTTaskItemsPresenter newApplication: application model: task.
	changes := 0.
	items whenItemsChangedDo: [ changes := changes + 1 ].
	items toggle: item.
	self assert: item isDone.
	self assert: item doneDate equals: Date today.
	items toggle: item.
	self deny: item isDone.
	self assert: changes equals: 2
]
