Class {
	#name : 'NTSpSearchCreatePresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'presenter',
		'notesTaker'
	],
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'tests' }
NTSpSearchCreatePresenterTest >> setUp [

	| app |
	super setUp.
	app := NTSpApplication new initialize.
	presenter := NTSpSearchCreatePresenter newApplication: app.
	notesTaker := app noteTakerContainer.

	(NTTag newNamed: 'test') addNote:
		(notesTaker addNoteNamed: 'newNote').
	(NTTag newNamed: 'tag') addNote:
		(notesTaker addNoteNamed: 'anotherNote').
	(NTTag newNamed: 'tag') addNote:
		(notesTaker addNoteNamed: 'thirdNote')
]

{ #category : 'tests' }
NTSpSearchCreatePresenterTest >> tearDown [

	presenter application closeAllWindows.
	presenter delete
]

{ #category : 'tests' }
NTSpSearchCreatePresenterTest >> testFilterWithNoteAndTag [

	presenter notesSearchCreateTextPresenter text: ''.
	self assert: presenter filter size equals: 3.

	presenter notesSearchCreateTextPresenter text: 'th'.
	presenter filteredTagsSelection add: (notesTaker tagNamed: 'test').
	self assert: presenter filter size equals: 0.
	presenter filteredTagsSelection removeAll.

	presenter notesSearchCreateTextPresenter text: 'note'.
	presenter filteredTagsSelection add: (notesTaker tagNamed: 'tag').
	self assert: presenter filter size equals: 2.
	presenter filteredTagsSelection removeAll.

	presenter notesSearchCreateTextPresenter text: 'ZZZ'.
	presenter filteredTagsSelection add: (notesTaker tagNamed: 'tag').
	self assert: presenter filter size equals: 0
]

{ #category : 'tests' }
NTSpSearchCreatePresenterTest >> testFilterWithNoteAndWithoutTag [

	presenter notesSearchCreateTextPresenter text: ''.
	self assert: presenter filter size equals: 3.

	presenter notesSearchCreateTextPresenter text: 'th'.
	self assert: presenter filter size equals: 2.

	presenter notesSearchCreateTextPresenter text: 'note'.
	self assert: presenter filter size equals: 3.

	presenter notesSearchCreateTextPresenter text: 'ZZZ'.
	self assert: presenter filter size equals: 0
]

{ #category : 'tests' }
NTSpSearchCreatePresenterTest >> testFilterWithoutNoteAndWithTag [

	self assert: presenter filter size equals: 3.

	presenter filteredTagsSelection add: (notesTaker tagNamed: 'tag').
	self assert: presenter filter size equals: 2.
	presenter filteredTagsSelection removeAll.

	presenter filteredTagsSelection add: (notesTaker tagNamed: 't').
	self assert: presenter filter size equals: 3.
	presenter filteredTagsSelection removeAll.

	presenter filteredTagsSelection add: (notesTaker tagNamed: 'ZZZ').
	self assert: presenter filter size equals: 0
]

{ #category : 'tests' }
NTSpSearchCreatePresenterTest >> testFilteredNotes [

	| result |

	result := presenter filteredNotesFor: 'newNote'.
	self assert: result size equals: 1.

	result := presenter filteredNotesFor: 'nnn'.
	self assert: result size equals: 0.

	result := presenter filteredNotesFor: 'Note'.
	self assert: result size equals: 3
]

{ #category : 'tests' }
NTSpSearchCreatePresenterTest >> testFilteredtags [

	| result |
	result := presenter
		          notes: notesTaker notes
		          withTags: (OrderedCollection new add: (notesTaker tagNamed: 'tag'); yourself).
	self assert: result size equals: 2.

	result := presenter
		          notes: notesTaker notes
		          withTags: (OrderedCollection new add: (notesTaker tagNamed: 't'); yourself).
	self assert: result size equals: 3.

	result := presenter
		          notes: notesTaker notes
		          withTags:
		          (OrderedCollection new add: (notesTaker tagNamed: 'TATA'); yourself).
	self assert: result size equals: 0
]

{ #category : 'tests' }
NTSpSearchCreatePresenterTest >> testNoteWithTagSearch [

	| result |
	result := presenter
		          notes: notesTaker notes
		          withTags: (OrderedCollection new
				           add: (notesTaker tagNamed: 'test');
				           yourself).
	self assert: result size equals: 1.

	result := presenter
		          notes: notesTaker notes
		          withTags: (OrderedCollection new
				           add: (notesTaker tagNamed: 'tag');
				           yourself).
	self assert: result size equals: 2.

	result := presenter
		          notes: notesTaker notes
		          withTags: (OrderedCollection new
				           add: (notesTaker tagNamed: 't');
				           yourself).
	self assert: result size equals: 3
]
