Class {
	#name : 'NTSpNoteIndexPresenterTest',
	#superclass : 'NTSpTestCase',
	#instVars : [
		'indexPresenter'
	],
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpNoteIndexPresenterTest >> setUp [

	super setUp.

	indexPresenter := NTSpNoteIndexPresenter newApplication: app.

	indexPresenter model: noteContainer.
	ressources addingNotesAndTagsTo: noteContainer.
	indexPresenter updatePresenter
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> tearDown [

	indexPresenter ifNotNil: [indexPresenter delete].

	super tearDown
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testAddNote [

	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := indexPresenter items size.
	indexPresenter addNote: (NTNote content: 'Test').

	self
		assert: indexPresenter items size
		equals: sizeNotesBeforeAddNote + 1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testFilterNoteWithTheirContent [

	| note |
	ressources addingNotesAndTagsTo: noteContainer.
	note := NTNote content: 'TITLE' , String crlf , 'note content'.
	noteContainer addNote: note.

	indexPresenter searchBar text: ''.
	self assert: indexPresenter items size equals: 4.

	indexPresenter searchBar text: 'note1'.
	self assert: indexPresenter items size equals: 1.

	indexPresenter searchBar text: 'note'.
	self assert: indexPresenter items size equals: 4.
	
	indexPresenter searchBar text: 'content'.
	self assert: indexPresenter items size equals: 1.

	indexPresenter searchBar text: 'ZZZ'.
	self assert: indexPresenter items size equals: 0
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testFilterWithNoteAndTag [

	indexPresenter filteredTagsSelection add:
		(noteContainer ensureTagNamed: 'test').
	indexPresenter searchBar text: 'th'.
	self assert: indexPresenter items size equals: 0.
	indexPresenter filteredTagsSelection removeAll.

	indexPresenter filteredTagsSelection add: ressources getTag1.
	indexPresenter searchBar text: 'note'.
	self assert: indexPresenter items size equals: 1.
	indexPresenter filteredTagsSelection removeAll.

	indexPresenter filteredTagsSelection add: ressources getTag1.
	indexPresenter searchBar text: 'ZZZ'.
	self assert: indexPresenter items size equals: 0
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testFilterWithNoteAndWithoutTag [

	indexPresenter searchBar text: ''.
	self assert: indexPresenter items size equals: 3.

	indexPresenter searchBar text: 'note1'.
	self assert: indexPresenter items size equals: 1.

	indexPresenter searchBar text: 'note'.
	self assert: indexPresenter items size equals: 3.

	indexPresenter searchBar text: 'ZZZ'.
	self assert: indexPresenter items size equals: 0
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testFilterWithoutNoteAndWithTag [

	self assert: indexPresenter items size equals: 3.

	ressources getNote2 addTag: ressources getTag1.
	ressources getNote3 addTag: ressources getTag1.

	indexPresenter filteredTagsSelection add: ressources getTag1.
	indexPresenter filter.
	self assert: indexPresenter items size equals: 3.
	indexPresenter filteredTagsSelection removeAll.

	indexPresenter filteredTagsSelection add: ressources getTag2.
	indexPresenter filter.
	self assert: indexPresenter items size equals: 1.
	indexPresenter filteredTagsSelection removeAll.

	indexPresenter filteredTagsSelection add:
		(noteContainer ensureTagNamed: 'ZZZ').
	indexPresenter filter.
	self assert: indexPresenter items size equals: 0
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testHasSelectedNotes [

	self deny: indexPresenter hasSelectedNote.
	indexPresenter selectNote: ressources getNote1.
	self assert: indexPresenter hasSelectedNote
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testRemoveNote [
	
	| sizeNotesBeforeAddNote |self skip.
	self flag: 'Doesn t have to test remove note in index. Can test if index update catch the change of NTContainer'.
	sizeNotesBeforeAddNote := indexPresenter items size.
	noteContainer removeNote: ressources getNote2.
	indexPresenter updatePresenter.
	self
		assert: indexPresenter items size
		equals: sizeNotesBeforeAddNote - 1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testSelectNote [

	indexPresenter selectNote: ressources getNote1.

	self assert: indexPresenter selectedNotes size equals: 1.
	self assert: indexPresenter selectedNotes first equals: ressources getNote1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testSelectNotes [

	indexPresenter selectNote: ressources getNote1.
	indexPresenter selectNote: ressources getNote2.

	self assert: indexPresenter selectedNotes size equals: 2
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testTagsSearchButtonOpenModalWindow [

	| nbOpenWindows |
	nbOpenWindows := indexPresenter application windows size.

	SpWindowForceOpenNonModal during: [
		indexPresenter tagsFilterButton click ].
	self currentWorld doOneCycle.

	self assert: indexPresenter application windows size equals: nbOpenWindows + 1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testUpdatingPresenterModifyListWhenModelListChanged [

	| sizeNotesBeforeAddNote note |
	sizeNotesBeforeAddNote := indexPresenter items size.
	note := noteContainer addNoteNamed: 'Test'.
	indexPresenter updatePresenter.

	self
		assert: indexPresenter items size
		equals: sizeNotesBeforeAddNote + 1.

	noteContainer removeNotes: (OrderedCollection new add: note; yourself).
	indexPresenter updatePresenter.

	self assert: indexPresenter items size equals: sizeNotesBeforeAddNote
]
