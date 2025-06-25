Class {
	#name : 'NTSpSearchCreatePresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'window',
		'memoryFS',
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
	memoryFS := FileSystem memory.
	presenter := NTSpSearchCreatePresenter newApplication: app.
	notesTaker := app noteTakerContainer.
	
	(NTTag newNamed: 'test') addNote:
		(notesTaker addNoteNamed: 'newNote').
	(NTTag newNamed: 'tag') addNote:
		(notesTaker addNoteNamed: 'anotherNote').
	(NTTag newNamed: 'tag') addNote:
		(notesTaker addNoteNamed: 'thirdNote').
]

{ #category : 'tests' }
NTSpSearchCreatePresenterTest >> tearDown [

	presenter application closeAllWindows.
	presenter delete
]

{ #category : 'tests' }
NTSpSearchCreatePresenterTest >> testFilterWithNoteAndTag [

	presenter notesSearchCreateTextPresenter text: ''.
	presenter tagsSearchCreateTextPresenter text: ''.
	self assert: presenter filter size equals: 3.

	presenter notesSearchCreateTextPresenter text: 'th'.
	presenter tagsSearchCreateTextPresenter text: 'test'.
	self assert: presenter filter size equals: 0.

	presenter notesSearchCreateTextPresenter text: 'note'.
	presenter tagsSearchCreateTextPresenter text: 'tag'.
	self assert: presenter filter size equals: 2.

	presenter notesSearchCreateTextPresenter text: 'ZZZ'.
	presenter tagsSearchCreateTextPresenter text: 'tag'.
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

	presenter tagsSearchCreateTextPresenter text: ''.
	self assert: presenter filter size equals: 3.

	presenter tagsSearchCreateTextPresenter text: 'tag'.
	self assert: presenter filter size equals: 2.

	presenter tagsSearchCreateTextPresenter text: 't'.
	self assert: presenter filter size equals: 3.

	presenter tagsSearchCreateTextPresenter text: 'ZZZ'.
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
		          filteredTagsFor: 'tag'
		          withNotes: notesTaker notes.
	self assert: result size equals: 2.

	result := presenter filteredTagsFor: 't' withNotes: notesTaker notes.
	self assert: result size equals: 3.

	result := presenter
		          filteredTagsFor: 'TATA'
		          withNotes: notesTaker notes.
	self assert: result size equals: 0
]

{ #category : 'tests' }
NTSpSearchCreatePresenterTest >> testNoteWithTagSearch [

	| result |

	result := presenter
		          filteredTagsFor: 'test'
		          withNotes: notesTaker notes.
	self assert: result size equals: 1.

	result := presenter
		          filteredTagsFor: 'tag'
		          withNotes: notesTaker notes.
	self assert: result size equals: 2.

	result := presenter filteredTagsFor: 't' withNotes: notesTaker notes.
	self assert: result size equals: 3
]
