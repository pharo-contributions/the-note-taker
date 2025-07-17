Class {
	#name : 'NTSpNoteIndexPresenterTest',
	#superclass : 'NTSpNoteTakerMainUITest',
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testAddNote [

	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := indexPresenter items size.
	noteContainer addNoteNamed: 'Test'.

	self
		assert: indexPresenter items size
		equals: sizeNotesBeforeAddNote + 1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testDisplayTags [

	self
		assert: (indexPresenter displayNoteTags: self getNote1)
		equals: 'tag1,tag3'
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testHasSelectedNotes [

	indexPresenter selectNote: self getNote1.
	self assert: indexPresenter hasSelectedNote
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testRemoveNote [

	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := indexPresenter items size.
	noteContainer removeNoteNamed: self getNote2 fileName.
	self
		assert: indexPresenter items size
		equals: sizeNotesBeforeAddNote -1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testSelectNote [

	indexPresenter selectNote: self getNote1.

	self assert: indexPresenter selectedNote equals: self getNote1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testSelectNotes [

	indexPresenter selectNote: self getNote1.
	indexPresenter selectNote: self getNote2.

	self assert: indexPresenter selectedNote equals: self getNote1.

	self assert: indexPresenter selectedNotes size equals: 2
]
