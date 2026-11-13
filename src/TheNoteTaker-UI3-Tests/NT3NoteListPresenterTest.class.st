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
NT3NoteListPresenterTest >> click: anIndex [
	"Select only the row at anIndex, as a plain click or an arrow key does"

	presenter noteList selectIndexes: { anIndex }.
	application runDeferred
]

{ #category : 'helpers' }
NT3NoteListPresenterTest >> displayedNotes [

	^ presenter entries select: [ :each | each isNote ]
]

{ #category : 'helpers' }
NT3NoteListPresenterTest >> selectRows: aCollectionOfIndexes [
	"Select these rows, as Cmd-click or Shift-click do"

	presenter noteList selectIndexes: aCollectionOfIndexes.
	application runDeferred
]

{ #category : 'running' }
NT3NoteListPresenterTest >> setUp [

	super setUp.
	application := NT3DeferringTestApplication new.
	presenter := NT3NoteListPresenter newApplication: application.
	presenter notes: self notes
]

{ #category : 'tests - multiple selection' }
NT3NoteListPresenterTest >> testANoteListedTwiceIsSelectedOnce [
	"By tag: #pharo, Middle, Old, #spec, Recent, Middle, No tag, Untagged"

	presenter mode: NT3ByTagListMode new.
	self selectRows: #( 2 5 6 ).
	self assert: presenter selectedNotes asArray equals: {
			middle.
			recent }
]

{ #category : 'tests - multiple selection' }
NT3NoteListPresenterTest >> testAddedNoteIsTheSelectedNote [

	| announced |
	self click: 2.
	announced := nil.
	presenter whenNoteSelectedDo: [ :note | announced := note ].
	self selectRows: #( 2 5 ).
	self assert: presenter selectedNote identicalTo: middle.
	self assert: announced identicalTo: middle
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
	self click: 1.
	self assert: presenter selectedNote equals: middle.
	self assert: announcements isEmpty
]

{ #category : 'tests - tags' }
NT3NoteListPresenterTest >> testClickingTheTagsButtonDoesNotChangeTheMode [

	presenter tagsButton click.
	self assert: presenter mode class equals: NT3ByDateListMode.
	self assert: (presenter modeButtons collect: [ :each | each state ] as: Array) equals: #( true false false )
]

{ #category : 'tests - tags' }
NT3NoteListPresenterTest >> testClickingTheTagsButtonHidesTheTags [

	presenter tagsButton click.
	self deny: presenter showsTags.
	self deny: presenter tagsButton state
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

{ #category : 'tests - multiple selection' }
NT3NoteListPresenterTest >> testFirstNoteOfARangeUpwardsIsTheSelectedNote [
	"Shift-click on Untagged after clicking Middle selects Untagged to Middle: Untagged was clicked last"

	self click: 5.
	self selectRows: #( 2 3 4 5 ).
	self assert: presenter selectedNote identicalTo: untagged
]

{ #category : 'tests' }
NT3NoteListPresenterTest >> testHiddenNoteIsSelectedAgainWhenListedAgain [

	presenter selectNote: untagged.
	presenter tagSearchText: 'spec '.
	presenter clearTagSearch.
	self assert: presenter selectedNote identicalTo: untagged
]

{ #category : 'tests - multiple selection' }
NT3NoteListPresenterTest >> testLastNoteOfARangeIsTheSelectedNote [
	"Shift-click on Old after clicking Recent selects Recent to Old: Old was clicked last"

	self click: 3.
	self selectRows: #( 3 4 5 6 7 ).
	self assert: presenter selectedNote identicalTo: old
]

{ #category : 'tests - multiple selection' }
NT3NoteListPresenterTest >> testListAllowsSeveralNotesToBeSelected [

	self assert: presenter noteList selection isMultipleSelection
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
	self click: 4.
	self assert: presenter selectedNote equals: middle.
	self assert: presenter noteList selectedIndex equals: 5
]

{ #category : 'tests - selection' }
NT3NoteListPresenterTest >> testMovingUpOntoASeparatorSelectsThePreviousNote [
	"By date: November 2026, Untagged, Recent, October 2026, Middle, December 2025, Old"

	presenter selectNote: middle.
	self click: 4.
	self assert: presenter selectedNote equals: recent
]

{ #category : 'tests - multiple selection' }
NT3NoteListPresenterTest >> testNoteAddedAboveIsTheSelectedNote [

	self click: 5.
	self selectRows: #( 2 5 ).
	self assert: presenter selectedNote identicalTo: untagged
]

{ #category : 'tests - multiple selection' }
NT3NoteListPresenterTest >> testRefreshKeepsTheSelectedNotes [

	self click: 2.
	self selectRows: #( 2 5 ).
	presenter refresh.
	self assert: presenter selectedNotes asArray equals: {
			untagged.
			middle }.
	self assert: presenter selectedNote identicalTo: middle
]

{ #category : 'tests' }
NT3NoteListPresenterTest >> testRefreshMovesAnEditedNoteToTheTop [

	presenter mode: NT3CompactListMode new.
	old modificationDate: DateAndTime now.
	presenter refresh.
	self assert: presenter entries first equals: old
]

{ #category : 'tests - tags' }
NT3NoteListPresenterTest >> testRowsShowTagsAsTheListSays [

	| row |
	row := NT3NoteRowPresenter new.
	presenter configureRow: row.
	self assert: row showsTags.
	presenter tagsButton click.
	presenter configureRow: row.
	self deny: row showsTags
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

{ #category : 'tests - multiple selection' }
NT3NoteListPresenterTest >> testSelectNoteSelectsOnlyThatNote [

	self selectRows: #( 2 5 ).
	presenter selectNote: recent.
	self assert: presenter selectedNotes asArray equals: { recent }
]

{ #category : 'tests - multiple selection' }
NT3NoteListPresenterTest >> testSelectedNotesAreTheSelectedRows [
	"By date: November 2026, Untagged, Recent, October 2026, Middle, December 2025, Old"

	self selectRows: #( 2 5 ).
	self assert: presenter selectedNotes asArray equals: {
			untagged.
			middle }
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

{ #category : 'tests - multiple selection' }
NT3NoteListPresenterTest >> testSeparatorsAreNotSelectedNotes [

	self selectRows: #( 1 2 3 4 ).
	self assert: presenter selectedNotes asArray equals: {
			untagged.
			recent }
]

{ #category : 'tests - tags' }
NT3NoteListPresenterTest >> testShowingTagsIsRememberedByTheApplication [

	presenter tagsButton click.
	self deny: application showsTags.
	self deny: (NT3NoteListPresenter newApplication: application) tagsButton state
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

{ #category : 'tests - tags' }
NT3NoteListPresenterTest >> testTagsButtonComesAfterTheModeButtons [

	| buttons |
	buttons := presenter layout children last children.
	self assert: buttons last identicalTo: presenter tagsButton.
	self assert: (buttons first: 3) asArray equals: presenter modeButtons asArray
]

{ #category : 'tests - tags' }
NT3NoteListPresenterTest >> testTagsButtonIsDisabledInTitlesOnlyMode [

	presenter mode: NT3CompactListMode new.
	self deny: presenter tagsButton isEnabled.
	self assert: presenter tagsButton state
]

{ #category : 'tests - tags' }
NT3NoteListPresenterTest >> testTagsButtonIsEnabledAgainInTheOtherModes [

	presenter mode: NT3CompactListMode new.
	presenter mode: NT3ByTagListMode new.
	self assert: presenter tagsButton isEnabled.
	self assert: presenter showsTags
]

{ #category : 'tests - tags' }
NT3NoteListPresenterTest >> testTagsButtonIsOnByDefault [

	self assert: presenter tagsButton state.
	self assert: presenter tagsButton label equals: '#'.
	self assert: presenter tagsButton help equals: 'Show tags'.
	self assert: presenter showsTags
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

{ #category : 'tests - multiple selection' }
NT3NoteListPresenterTest >> testUnselectingAnotherNoteKeepsTheSelectedNote [

	| announcements |
	self click: 2.
	self selectRows: #( 2 5 ).
	announcements := OrderedCollection new.
	presenter whenNoteSelectedDo: [ :note | announcements add: note ].
	self selectRows: #( 5 ).
	self assert: presenter selectedNote identicalTo: middle.
	self assertEmpty: announcements
]

{ #category : 'tests - multiple selection' }
NT3NoteListPresenterTest >> testUnselectingTheSelectedNoteShowsAnotherSelectedOne [

	self click: 2.
	self selectRows: #( 2 5 ).
	self selectRows: #( 2 ).
	self assert: presenter selectedNote identicalTo: untagged
]
