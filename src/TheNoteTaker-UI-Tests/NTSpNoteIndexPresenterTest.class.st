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
NTSpNoteIndexPresenterTest >> testCreateNoteSelectIt [

	| nbNote |
	nbNote := indexPresenter notes size.
	indexPresenter createNoteNamed: 'Test'.
	self assert: indexPresenter selectedNote contents equals: 'Test'
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testCreateNoteWithName [

	| nbNote |
	nbNote := indexPresenter notes size.
	indexPresenter createNoteNamed: 'Test'.
	
	self assert: indexPresenter notes size equals: nbNote +1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testCreateNoteWithoutName [

	| nbNote |
	nbNote := indexPresenter notes size.
	indexPresenter createNoteNamed: ''.
	
	self assert: indexPresenter notes size equals: nbNote
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

	indexPresenter filteredTagsSelection add: ressources tag1.
	indexPresenter searchBar text: 'note'.
	self assert: indexPresenter items size equals: 1.
	indexPresenter filteredTagsSelection removeAll.

	indexPresenter filteredTagsSelection add: ressources tag1.
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

	ressources note2 addTag: ressources tag1.
	ressources note3 addTag: ressources tag1.

	indexPresenter filteredTagsSelection add: ressources tag1.
	indexPresenter filter.
	self assert: indexPresenter items size equals: 3.
	indexPresenter filteredTagsSelection removeAll.

	indexPresenter filteredTagsSelection add: ressources tag2.
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
	indexPresenter selectNote: ressources note1.
	self assert: indexPresenter hasSelectedNote
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testNotesAreFilteredByModificationDate [

	| orderedItems |
	ressources note1 modificationDate: Date yesterday.
	ressources note2 modificationDate: Date today.
	ressources note3 modificationDate: Date tomorrow.

	indexPresenter items: noteContainer notes.
	orderedItems := indexPresenter items.
	self assert: orderedItems first equals: ressources note3.
	self assert: orderedItems second equals: ressources note2.
	self assert: orderedItems third equals: ressources note1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testSelectNote [

	indexPresenter selectNote: ressources note1.

	self assert: indexPresenter selectedNotes size equals: 1.
	self assert: indexPresenter selectedNotes first equals: ressources note1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testSelectNotes [

	indexPresenter selectNote: ressources note1.
	indexPresenter selectNote: ressources note2.

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
NTSpNoteIndexPresenterTest >> testUpdatePresenterRemoveDeletedNote [

	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := indexPresenter items size.
	noteContainer removeNotes: (OrderedCollection new
			 add: ressources note2;
			 yourself).
	indexPresenter updatePresenter.
	self
		assert: indexPresenter items size
		equals: sizeNotesBeforeAddNote - 1
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
