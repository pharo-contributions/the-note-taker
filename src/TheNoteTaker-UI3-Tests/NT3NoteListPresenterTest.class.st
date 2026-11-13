"
I test `NT3NoteListPresenter` without opening windows.
"
Class {
	#name : 'NT3NoteListPresenterTest',
	#superclass : 'NT3NotesTestCase',
	#instVars : [
		'presenter',
		'application'
	],
	#category : 'TheNoteTaker-UI3-Tests',
	#package : 'TheNoteTaker-UI3-Tests'
}

{ #category : 'helpers' }
NT3NoteListPresenterTest >> displayedNotes [

	^ presenter entries select: [ :each | each isNote ]
]

{ #category : 'running' }
NT3NoteListPresenterTest >> setUp [

	super setUp.
	application := NT3DeferringTestApplication new.
	presenter := NT3NoteListPresenter newApplication: application.
	presenter notes: self notes
]

{ #category : 'tests - search' }
NT3NoteListPresenterTest >> testClearTagSearchShowsAllNotes [

	presenter tagSearchText: 'spec '.
	presenter clearTagSearch.
	self assert: presenter tagSearchText isEmpty.
	self assert: self displayedNotes size equals: 4
]

{ #category : 'tests - mode' }
NT3NoteListPresenterTest >> testClickingAModeButtonChangesTheList [

	(presenter modeButtons at: 2) click.
	self assert: presenter mode class equals: NT3ByTagListMode.
	self assert: presenter entries first label equals: '#pharo'
]

{ #category : 'tests - selection' }
NT3NoteListPresenterTest >> testClickingASeparatorKeepsTheSelection [
	"By date: November 2026, Untagged, Recent, October 2026, Middle, December 2025, Old"

	| announcements |
	presenter selectNote: middle.
	announcements := OrderedCollection new.
	presenter whenNoteSelectedDo: [ :note | announcements add: note ].
	presenter noteList selectIndex: 1.
	application runDeferred.
	self assert: presenter selectedNote equals: middle.
	self assert: announcements isEmpty
]

{ #category : 'tests - mode' }
NT3NoteListPresenterTest >> testCompactModeShowsOnlyNotes [

	presenter mode: NT3CompactListMode new.
	self assert: presenter entries asArray equals: {
			untagged.
			recent.
			middle.
			old }
]

{ #category : 'tests - mode' }
NT3NoteListPresenterTest >> testDefaultModeIsByDate [

	self assert: presenter mode class equals: NT3ByDateListMode.
	self assert: presenter entries first label equals: 'November 2026'
]

{ #category : 'tests' }
NT3NoteListPresenterTest >> testHiddenNoteIsSelectedAgainWhenListedAgain [

	presenter selectNote: untagged.
	presenter tagSearchText: 'spec '.
	presenter clearTagSearch.
	self assert: presenter selectedNote identicalTo: untagged
]

{ #category : 'tests - mode' }
NT3NoteListPresenterTest >> testModeButtonsShowTheCurrentMode [

	presenter mode: NT3CompactListMode new.
	self assert: (presenter modeButtons collect: [ :each | each state ] as: Array) equals: #( false false true )
]

{ #category : 'tests - mode' }
NT3NoteListPresenterTest >> testModeIsRememberedByTheApplication [

	presenter mode: NT3CompactListMode new.
	self assert: (NT3NoteListPresenter newApplication: application) mode class equals: NT3CompactListMode
]

{ #category : 'tests - selection' }
NT3NoteListPresenterTest >> testMovingDownOntoASeparatorSelectsTheNextNote [
	"By date: November 2026, Untagged, Recent, October 2026, Middle, December 2025, Old"

	presenter selectNote: recent.
	presenter noteList selectIndex: 4.
	application runDeferred.
	self assert: presenter selectedNote equals: middle.
	self assert: presenter noteList selectedIndex equals: 5
]

{ #category : 'tests - selection' }
NT3NoteListPresenterTest >> testMovingUpOntoASeparatorSelectsThePreviousNote [
	"By date: November 2026, Untagged, Recent, October 2026, Middle, December 2025, Old"

	presenter selectNote: middle.
	presenter noteList selectIndex: 4.
	application runDeferred.
	self assert: presenter selectedNote equals: recent
]

{ #category : 'tests' }
NT3NoteListPresenterTest >> testRefreshMovesAnEditedNoteToTheTop [

	presenter mode: NT3CompactListMode new.
	old modificationDate: DateAndTime now.
	presenter refresh.
	self assert: presenter entries first equals: old
]

{ #category : 'tests' }
NT3NoteListPresenterTest >> testSelectFirstNoteKeepsTheSelection [

	presenter selectNote: old.
	presenter selectFirstNote.
	self assert: presenter selectedNote identicalTo: old
]

{ #category : 'tests' }
NT3NoteListPresenterTest >> testSelectFirstNoteSkipsTheSeparator [

	presenter selectFirstNote.
	self assert: presenter selectedNote identicalTo: untagged
]

{ #category : 'tests - selection' }
NT3NoteListPresenterTest >> testSelectNoteAnnouncesIt [

	| announced |
	announced := nil.
	presenter whenNoteSelectedDo: [ :note | announced := note ].
	presenter selectNote: recent.
	self assert: presenter selectedNote equals: recent.
	self assert: announced equals: recent
]

{ #category : 'tests' }
NT3NoteListPresenterTest >> testSelectingAnotherNoteForgetsTheHiddenNote [

	presenter selectNote: untagged.
	presenter tagSearchText: 'spec '.
	presenter selectNote: recent.
	presenter clearTagSearch.
	self assert: presenter selectedNote identicalTo: recent
]

{ #category : 'tests - selection' }
NT3NoteListPresenterTest >> testSelectionIsClearedWhenTheNoteIsFilteredOut [

	presenter selectNote: untagged.
	presenter tagSearchText: 'spec '.
	self assert: presenter selectedNote isNil
]

{ #category : 'tests - selection' }
NT3NoteListPresenterTest >> testSelectionIsKeptWhenTheModeChanges [

	presenter selectNote: middle.
	presenter mode: NT3ByTagListMode new.
	self assert: presenter selectedNote equals: middle.
	"#pharo, Middle, ...: the first copy of the note is selected"
	self assert: presenter noteList selectedIndex equals: 2
]

{ #category : 'tests - search' }
NT3NoteListPresenterTest >> testSubmittingTagSearchCompletesTheLastWord [

	presenter tagSearchText: 'unknown'.
	presenter submitTagSearch.
	self assert: presenter entries isEmpty
]

{ #category : 'tests - search' }
NT3NoteListPresenterTest >> testTagNamesAreTheTagsOfTheNotes [

	self assert: presenter tagNames asArray equals: #( 'pharo' 'spec' )
]

{ #category : 'tests - search' }
NT3NoteListPresenterTest >> testTagSearchFiltersNotes [

	presenter tagSearchText: 'spec '.
	self assert: self displayedNotes asArray equals: {
			recent.
			middle }
]

{ #category : 'tests - search' }
NT3NoteListPresenterTest >> testUnfinishedTagWordDoesNotFilter [

	presenter tagSearchText: 'spe'.
	self assert: self displayedNotes size equals: 4
]

{ #category : 'tests' }
NT3NoteListPresenterTest >> testUnsavedNotesAreTheApplicationOnes [

	application noteEdited: recent.
	self assert: (presenter isUnsaved: recent).
	self deny: (presenter isUnsaved: old)
]
