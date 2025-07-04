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
NTSpNoteIndexPresenterTest >> testRemoveNote [

	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := notesIndexPresenter items size.
	noteContainer removeNoteNamed:
		(noteContainer addNoteNamed: 'note2') fileName.
	self
		assert: notesIndexPresenter items size
		equals: sizeNotesBeforeAddNote
]
