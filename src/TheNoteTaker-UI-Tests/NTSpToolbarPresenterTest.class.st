Class {
	#name : 'NTSpToolbarPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'presenter',
		'notesTakerContainer'
	],
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'tests' }
NTSpToolbarPresenterTest >> setUp [

	| app |
	super setUp.
	app := NTSpApplication new initialize.
	presenter := NTSpToolBarPresenter newApplication: app.
	notesTakerContainer := app noteTakerContainer.

	(NTTag newNamed: 'test') addNote:
		(notesTakerContainer addNoteNamed: 'newNote').
	(NTTag newNamed: 'tag') addNote:
		(notesTakerContainer addNoteNamed: 'anotherNote').
	(NTTag newNamed: 'tag') addNote:
		(notesTakerContainer addNoteNamed: 'thirdNote')
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> tearDown [

	presenter application closeAllWindows.
	presenter delete
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testFilterWithNoteAndTag [

	presenter searchBarPresenter text: ''.
	self assert: presenter filter size equals: 3.

	presenter searchBarPresenter text: 'th'.
	presenter filteredTagsSelection add: (notesTakerContainer tagNamed: 'test').
	self assert: presenter filter size equals: 0.
	presenter filteredTagsSelection removeAll.

	presenter searchBarPresenter text: 'note'.
	presenter filteredTagsSelection add: (notesTakerContainer tagNamed: 'tag').
	self assert: presenter filter size equals: 2.
	presenter filteredTagsSelection removeAll.

	presenter searchBarPresenter text: 'ZZZ'.
	presenter filteredTagsSelection add: (notesTakerContainer tagNamed: 'tag').
	self assert: presenter filter size equals: 0
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testFilterWithNoteAndWithoutTag [

	presenter searchBarPresenter text: ''.
	self assert: presenter filter size equals: 3.

	presenter searchBarPresenter text: 'th'.
	self assert: presenter filter size equals: 2.

	presenter searchBarPresenter text: 'note'.
	self assert: presenter filter size equals: 3.

	presenter searchBarPresenter text: 'ZZZ'.
	self assert: presenter filter size equals: 0
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testFilterWithoutNoteAndWithTag [

	self assert: presenter filter size equals: 3.

	presenter filteredTagsSelection add: (notesTakerContainer tagNamed: 'tag').
	self assert: presenter filter size equals: 2.
	presenter filteredTagsSelection removeAll.

	presenter filteredTagsSelection add: (notesTakerContainer tagNamed: 't').
	self assert: presenter filter size equals: 3.
	presenter filteredTagsSelection removeAll.

	presenter filteredTagsSelection add: (notesTakerContainer tagNamed: 'ZZZ').
	self assert: presenter filter size equals: 0
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testFilteredNotes [

	| result |

	result := presenter filteredNotesFor: 'newNote'.
	self assert: result size equals: 1.

	result := presenter filteredNotesFor: 'nnn'.
	self assert: result size equals: 0.

	result := presenter filteredNotesFor: 'Note'.
	self assert: result size equals: 3
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testFilteredtags [

	| result |
	result := presenter
		          notes: notesTakerContainer notes
		          withTags: (OrderedCollection new add: (notesTakerContainer tagNamed: 'tag'); yourself).
	self assert: result size equals: 2.

	result := presenter
		          notes: notesTakerContainer notes
		          withTags: (OrderedCollection new add: (notesTakerContainer tagNamed: 't'); yourself).
	self assert: result size equals: 3.

	result := presenter
		          notes: notesTakerContainer notes
		          withTags:
		          (OrderedCollection new add: (notesTakerContainer tagNamed: 'TATA'); yourself).
	self assert: result size equals: 0
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testNoteWithTagSearch [

	| result |
	result := presenter
		          notes: notesTakerContainer notes
		          withTags: (OrderedCollection new
				           add: (notesTakerContainer tagNamed: 'test');
				           yourself).
	self assert: result size equals: 1.

	result := presenter
		          notes: notesTakerContainer notes
		          withTags: (OrderedCollection new
				           add: (notesTakerContainer tagNamed: 'tag');
				           yourself).
	self assert: result size equals: 2.

	result := presenter
		          notes: notesTakerContainer notes
		          withTags: (OrderedCollection new
				           add: (notesTakerContainer tagNamed: 't');
				           yourself).
	self assert: result size equals: 3
]
