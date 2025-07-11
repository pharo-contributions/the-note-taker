Class {
	#name : 'NTSpToolbarPresenterTest',
	#superclass : 'NTSpNoteTakerMainUITest',
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testFilterWithNoteAndTag [

	toolbarPresenter searchBarPresenter text: ''.
	self assert: toolbarPresenter filter size equals: 3.

	toolbarPresenter searchBarPresenter text: 'th'.
	toolbarPresenter filteredTagsSelection add:
		(noteContainer tagNamed: 'test').
	self assert: toolbarPresenter filter size equals: 0.
	toolbarPresenter filteredTagsSelection removeAll.

	toolbarPresenter searchBarPresenter text: 'note'.
	toolbarPresenter filteredTagsSelection add: self getTag1.
	self assert: toolbarPresenter filter size equals: 1.
	toolbarPresenter filteredTagsSelection removeAll.

	toolbarPresenter searchBarPresenter text: 'ZZZ'.
	toolbarPresenter filteredTagsSelection add: self getTag1.
	self assert: toolbarPresenter filter size equals: 0
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testFilterWithNoteAndWithoutTag [

	toolbarPresenter searchBarPresenter text: ''.
	self assert: toolbarPresenter filter size equals: 3.

	toolbarPresenter searchBarPresenter text: 'note1'.
	self assert: toolbarPresenter filter size equals: 1.

	toolbarPresenter searchBarPresenter text: 'note'.
	self assert: toolbarPresenter filter size equals: 3.

	toolbarPresenter searchBarPresenter text: 'ZZZ'.
	self assert: toolbarPresenter filter size equals: 0
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testFilterWithoutNoteAndWithTag [

	self assert: toolbarPresenter filter size equals: 3.
	
	self getNote2 addTag: self getTag1.
	self getNote3 addTag: self getTag1.

	toolbarPresenter filteredTagsSelection add:self getTag1.
	self assert: toolbarPresenter filter size equals: 3.
	toolbarPresenter filteredTagsSelection removeAll.

	toolbarPresenter filteredTagsSelection add: self getTag2.
	self assert: toolbarPresenter filter size equals: 1.
	toolbarPresenter filteredTagsSelection removeAll.

	toolbarPresenter filteredTagsSelection add:
		(noteContainer tagNamed: 'ZZZ').
	self assert: toolbarPresenter filter size equals: 0
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testFilteredNotes [

	| result |
	result := toolbarPresenter filteredNotesFor: 'newNote'.
	self assert: result size equals: 0.

	result := toolbarPresenter filteredNotesFor: 'note'.
	self assert: result size equals: 3.

	result := toolbarPresenter filteredNotesFor: 'note1'.
	self assert: result size equals: 1
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testFilteredtags [

	| result |
	result := toolbarPresenter
		          notes: noteContainer notes
		          withTags: (OrderedCollection new
				           add: self getTag1;
				           yourself).
	self assert: result size equals: 1.

	result := toolbarPresenter
		          notes: noteContainer notes
		          withTags: (OrderedCollection new
				           add: (noteContainer tagNamed: 'TATA');
				           yourself).
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
	result := toolbarPresenter
		          notes: noteContainer notes
		          withTags: (OrderedCollection new
				           add: (noteContainer tagNamed: 'test');
				           yourself).
	self assert: result size equals: 0.

	result := toolbarPresenter
		          notes: noteContainer notes
		          withTags: (OrderedCollection new
				           add: self getTag1;
				           yourself).
	self assert: result size equals: 1.

	result := toolbarPresenter
		          notes: noteContainer notes
		          withTags: (OrderedCollection new
				           add: (noteContainer tagNamed: 't');
				           yourself).
	self assert: result size equals: 2
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testOpenLogButtonOpenModalWindow [

	SpWindowForceOpenNonModal during: [
		toolbarPresenter logButtonPresenter click ].
	self currentWorld doOneCycle.

	self assert: toolbarPresenter application windows size equals: 2
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testOpenTNTSettingsButtonOpenModalWindow [

	self skip.
	SpWindowForceOpenNonModal during: [
		toolbarPresenter noteSettingsButtonPresenter click ].

	self assert: toolbarPresenter application windows size equals: 2
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testTagsSearchButtonOpenModalWindow [

	SpWindowForceOpenNonModal during: [
		toolbarPresenter tagsSearchButtonPresenter click ].
	self currentWorld doOneCycle.

	self assert: toolbarPresenter application windows size equals: 2
]
