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
	ressources generateNoteAndTagsTo: noteContainer.
	indexPresenter updatePresenter
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> tearDown [

	settings noteLocation: previousNotesLocation.

	indexPresenter delete.

	super tearDown
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testAddNote [

	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := indexPresenter items size.
	noteContainer addNoteNamed: 'Test'.
	indexPresenter updatePresenter.

	self
		assert: indexPresenter items size
		equals: sizeNotesBeforeAddNote + 1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testFilterWithNoteAndTag [

	indexPresenter searchBar text: ''.
	self assert: indexPresenter filter size equals: 3.

	indexPresenter searchBar text: 'th'.
	indexPresenter filteredTagsSelection add:
		(noteContainer tagNamed: 'test').
	self assert: indexPresenter filter size equals: 0.
	indexPresenter filteredTagsSelection removeAll.

	indexPresenter searchBar text: 'note'.
	indexPresenter filteredTagsSelection add: ressources getTag1.
	self assert: indexPresenter filter size equals: 1.
	indexPresenter filteredTagsSelection removeAll.

	indexPresenter searchBar text: 'ZZZ'.
	indexPresenter filteredTagsSelection add: ressources getTag1.
	self assert: indexPresenter filter size equals: 0
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testFilterWithNoteAndWithoutTag [

	indexPresenter searchBar text: ''.
	self assert: indexPresenter filter size equals: 3.

	indexPresenter searchBar text: 'note1'.
	self assert: indexPresenter filter size equals: 1.

	indexPresenter searchBar text: 'note'.
	self assert: indexPresenter filter size equals: 3.

	indexPresenter searchBar text: 'ZZZ'.
	self assert: indexPresenter filter size equals: 0
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testFilterWithoutNoteAndWithTag [

	self assert: indexPresenter filter size equals: 3.

	ressources getNote2 addTag: ressources getTag1.
	ressources getNote3 addTag: ressources getTag1.

	indexPresenter filteredTagsSelection add: ressources getTag1.
	self assert: indexPresenter filter size equals: 3.
	indexPresenter filteredTagsSelection removeAll.

	indexPresenter filteredTagsSelection add: ressources getTag2.
	self assert: indexPresenter filter size equals: 1.
	indexPresenter filteredTagsSelection removeAll.

	indexPresenter filteredTagsSelection add:
		(noteContainer tagNamed: 'ZZZ').
	self assert: indexPresenter filter size equals: 0
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testFilteredNotes [

	| result |
	result := indexPresenter filteredNotesFor: 'newNote'.
	self assert: result size equals: 0.

	result := indexPresenter filteredNotesFor: 'note'.
	self assert: result size equals: 3.

	result := indexPresenter filteredNotesFor: 'note1'.
	self assert: result size equals: 1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testFilteredtags [

	| result |
	result := indexPresenter
		          notes: noteContainer notes
		          withTags: (OrderedCollection new
				           add: ressources getTag1;
				           yourself).
	self assert: result size equals: 1.

	result := indexPresenter
		          notes: noteContainer notes
		          withTags: (OrderedCollection new
				           add: (noteContainer tagNamed: 'TATA');
				           yourself).
	self assert: result size equals: 0
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testHasSelectedNotes [

	indexPresenter selectNote: ressources getNote1.
	self assert: indexPresenter hasSelectedNote
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testNoteWithTagSearch [

	| result |
	result := indexPresenter
		          notes: noteContainer notes
		          withTags: (OrderedCollection new
				           add: (noteContainer tagNamed: 'test');
				           yourself).
	self assert: result size equals: 0.

	result := indexPresenter
		          notes: noteContainer notes
		          withTags: (OrderedCollection new
				           add: ressources getTag1;
				           yourself).
	self assert: result size equals: 1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testRemoveNote [

	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := indexPresenter items size.
	noteContainer removeNoteNamed: ressources getNote2 fileName.
	indexPresenter updatePresenter.
	self
		assert: indexPresenter items size
		equals: sizeNotesBeforeAddNote - 1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testSelectNote [

	indexPresenter selectNote: ressources getNote1.

	self assert: indexPresenter selectedNote equals: ressources getNote1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testSelectNotes [

	indexPresenter selectNote: ressources getNote1.
	indexPresenter selectNote: ressources getNote2.

	self assert: indexPresenter selectedNotes size equals: 2
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testTagsSearchButtonOpenModalWindow [

	SpWindowForceOpenNonModal during: [
		indexPresenter tagsFilterButton click ].
	self currentWorld doOneCycle.

	self assert: indexPresenter application windows size equals: 1
]
