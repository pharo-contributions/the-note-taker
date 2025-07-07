Class {
	#name : 'NTSpNoteIndexPresenterTest',
	#superclass : 'NTSpNoteTakerMainUITest',
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testAddNote [

	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := notesIndexPresenter items size.
	noteContainer addNoteNamed: 'Test'.
	notesIndexPresenter modelChanged.
	self
		assert: notesIndexPresenter items size
		equals: sizeNotesBeforeAddNote + 1
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testDisplayTags [


	| note1 |
	note1 := NTNoteObject new.
	note1 addTag: (NTTag newNamed: 'tag1').
	note1 addTag: (NTTag newNamed: 'tag2').
	note1 addTag: (NTTag newNamed: 'tag3').
	self assert: (notesIndexPresenter displayNoteTags: note1) equals: 'tag1,tag2,tag3'
]

{ #category : 'tests' }
NTSpNoteIndexPresenterTest >> testRemoveNote [

	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := notesIndexPresenter items size.
	noteContainer removeNoteNamed:
		(noteContainer addNoteNamed: 'note2') fileName.
	self
		assert: notesIndexPresenter items size
		equals: sizeNotesBeforeAddNote
]
