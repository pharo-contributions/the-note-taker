Class {
	#name : 'NTSpToolbarPresenterTest',
	#superclass : 'NTSpNoteTakerMainUITest',
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'tests' }
NTSpToolbarPresenterTest >> setUp [

	super setUp.

	(NTTag newNamed: 'test') addNote:
		(noteContainer addNoteNamed: 'newNote').
	(NTTag newNamed: 'tag') addNote:
		(noteContainer addNoteNamed: 'anotherNote').
	(NTTag newNamed: 'tag') addNote:
		(noteContainer addNoteNamed: 'thirdNote')
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testFilterWithNoteAndTag [

	notesToolbarPresenter searchBarPresenter text: ''.
	self assert: notesToolbarPresenter filter size equals: 3.

	notesToolbarPresenter searchBarPresenter text: 'th'.
	notesToolbarPresenter filteredTagsSelection add: (noteContainer tagNamed: 'test').
	self assert: notesToolbarPresenter filter size equals: 0.
	notesToolbarPresenter filteredTagsSelection removeAll.

	notesToolbarPresenter searchBarPresenter text: 'note'.
	notesToolbarPresenter filteredTagsSelection add: (noteContainer tagNamed: 'tag').
	self assert: notesToolbarPresenter filter size equals: 2.
	notesToolbarPresenter filteredTagsSelection removeAll.

	notesToolbarPresenter searchBarPresenter text: 'ZZZ'.
	notesToolbarPresenter filteredTagsSelection add: (noteContainer tagNamed: 'tag').
	self assert: notesToolbarPresenter filter size equals: 0
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testFilterWithNoteAndWithoutTag [

	notesToolbarPresenter searchBarPresenter text: ''.
	self assert: notesToolbarPresenter filter size equals: 3.

	notesToolbarPresenter searchBarPresenter text: 'th'.
	self assert: notesToolbarPresenter filter size equals: 2.

	notesToolbarPresenter searchBarPresenter text: 'note'.
	self assert: notesToolbarPresenter filter size equals: 3.

	notesToolbarPresenter searchBarPresenter text: 'ZZZ'.
	self assert: notesToolbarPresenter filter size equals: 0
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testFilterWithoutNoteAndWithTag [

	self assert: notesToolbarPresenter filter size equals: 3.

	notesToolbarPresenter filteredTagsSelection add: (noteContainer tagNamed: 'tag').
	self assert: notesToolbarPresenter filter size equals: 2.
	notesToolbarPresenter filteredTagsSelection removeAll.

	notesToolbarPresenter filteredTagsSelection add: (noteContainer tagNamed: 't').
	self assert: notesToolbarPresenter filter size equals: 3.
	notesToolbarPresenter filteredTagsSelection removeAll.

	notesToolbarPresenter filteredTagsSelection add: (noteContainer tagNamed: 'ZZZ').
	self assert: notesToolbarPresenter filter size equals: 0
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testFilteredNotes [

	| result |

	result := notesToolbarPresenter filteredNotesFor: 'newNote'.
	self assert: result size equals: 1.

	result := notesToolbarPresenter filteredNotesFor: 'nnn'.
	self assert: result size equals: 0.

	result := notesToolbarPresenter filteredNotesFor: 'Note'.
	self assert: result size equals: 3
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testFilteredtags [

	| result |
	result := notesToolbarPresenter
		          notes: noteContainer notes
		          withTags: (OrderedCollection new add: (noteContainer tagNamed: 'tag'); yourself).
	self assert: result size equals: 2.

	result := notesToolbarPresenter
		          notes: noteContainer notes
		          withTags: (OrderedCollection new add: (noteContainer tagNamed: 't'); yourself).
	self assert: result size equals: 3.

	result := notesToolbarPresenter
		          notes: noteContainer notes
		          withTags:
		          (OrderedCollection new add: (noteContainer tagNamed: 'TATA'); yourself).
	self assert: result size equals: 0
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testImportFolderButtonOpenModalWindow [

	self skip.
	"SpWindowForceOpenNonModal during: [
		notesToolbarPresenter importFolderButtonPresenter click ].

	self assert: notesToolbarPresenter application windows size equals: 2"
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testNoteWithTagSearch [

	| result |
	result := notesToolbarPresenter
		          notes: noteContainer notes
		          withTags: (OrderedCollection new
				           add: (noteContainer tagNamed: 'test');
				           yourself).
	self assert: result size equals: 1.

	result := notesToolbarPresenter
		          notes: noteContainer notes
		          withTags: (OrderedCollection new
				           add: (noteContainer tagNamed: 'tag');
				           yourself).
	self assert: result size equals: 2.

	result := notesToolbarPresenter
		          notes: noteContainer notes
		          withTags: (OrderedCollection new
				           add: (noteContainer tagNamed: 't');
				           yourself).
	self assert: result size equals: 3
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testOpenLogButtonOpenModalWindow [

	SpWindowForceOpenNonModal during: [
		notesToolbarPresenter logButtonPresenter click ].
	self currentWorld doOneCycle.

	self assert: notesToolbarPresenter application windows size equals: 2
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testOpenTNTSettingsButtonOpenModalWindow [

	SpWindowForceOpenNonModal during: [
		notesToolbarPresenter noteSettingsButtonPresenter click ].

	self assert: notesToolbarPresenter application windows size equals: 2
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testTagsSearchButtonOpenModalWindow [

	SpWindowForceOpenNonModal during: [
		notesToolbarPresenter tagsSearchButtonPresenter click ].
	self currentWorld doOneCycle.

	self assert: notesToolbarPresenter application windows size equals: 2
]
