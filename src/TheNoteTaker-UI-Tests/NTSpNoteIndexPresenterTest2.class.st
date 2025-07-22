Class {
	#name : 'NTSpNoteIndexPresenterTest2',
	#superclass : 'TestCase',
	#instVars : [
		'indexPresenter',
		'noteContainer',
		'ressources',
		'settings',
		'previousNotesLocation',
		'app'
	],
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpNoteIndexPresenterTest2 >> setUp [

	super setUp.

	settings := NTSettings.
	previousNotesLocation := settings noteLocation.

	app := NTSpApplication new.
	noteContainer := app noteTakerContainer.
	indexPresenter := NTSpNoteIndexPresenter newApplication: app.

	ressources := NTUITestResource new generateNoteAndTagsTo:
		              noteContainer.

	indexPresenter model: noteContainer.
	indexPresenter updatePresenter
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest2 >> tearDown [

	settings noteLocation: previousNotesLocation.
	
	app closeAllWindows.
	indexPresenter delete.

	super tearDown
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest2 >> testAddNote [

	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := indexPresenter items size.
	noteContainer addNoteNamed: 'Test'.
	indexPresenter updatePresenter.

	self
		assert: indexPresenter items size
		equals: sizeNotesBeforeAddNote + 1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest2 >> testFilterWithNoteAndTag [

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
NTSpNoteIndexPresenterTest2 >> testFilterWithNoteAndWithoutTag [

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
NTSpNoteIndexPresenterTest2 >> testFilterWithoutNoteAndWithTag [

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
NTSpNoteIndexPresenterTest2 >> testFilteredNotes [

	| result |
	result := indexPresenter filteredNotesFor: 'newNote'.
	self assert: result size equals: 0.

	result := indexPresenter filteredNotesFor: 'note'.
	self assert: result size equals: 3.

	result := indexPresenter filteredNotesFor: 'note1'.
	self assert: result size equals: 1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest2 >> testFilteredtags [

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
NTSpNoteIndexPresenterTest2 >> testHasSelectedNotes [

	indexPresenter selectNote: ressources getNote1.
	self assert: indexPresenter hasSelectedNote
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest2 >> testNoteWithTagSearch [

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
NTSpNoteIndexPresenterTest2 >> testRemoveNote [

	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := indexPresenter items size.
	noteContainer removeNoteNamed: ressources getNote2 fileName.
	indexPresenter updatePresenter.
	self
		assert: indexPresenter items size
		equals: sizeNotesBeforeAddNote - 1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest2 >> testSelectNote [

	indexPresenter selectNote: ressources getNote1.

	self assert: indexPresenter selectedNote equals: ressources getNote1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest2 >> testSelectNotes [

	indexPresenter selectNote: ressources getNote1.
	indexPresenter selectNote: ressources getNote2.

	self assert: indexPresenter selectedNotes size equals: 2
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest2 >> testTagsSearchButtonOpenModalWindow [

	SpWindowForceOpenNonModal during: [
		indexPresenter tagsFilterButton click ].
	self currentWorld doOneCycle.

	self assert: indexPresenter application windows size equals: 1
]
