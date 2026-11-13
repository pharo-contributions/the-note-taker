"
I test `NT3NoteEditorPresenter` without opening it: showing a note, typing, saving, discarding and the matches.

## Responsibility:

- Check that typing goes into the note and makes it unsaved, and that showing a note is not an edit.
- Check Cmd+S and Cmd+L (`save`, `discardEdits`) and moving between the matches.

## Collaborators:

- `NT3NoteEditorPresenter`, `NT3DeferringTestApplication` (in-memory notes folder, manual timer), `NT3TextQuery`.

## Public API and Key Messages

- `testTypingChangesTheNote`, `testDiscardBringsBackTheNoteAsSelected`, `testNextMatchSelectsIt`, …
"
Class {
	#name : 'NT3NoteEditorPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'application',
		'editor',
		'note'
	],
	#category : 'TheNoteTaker-UI3-Tests',
	#package : 'TheNoteTaker-UI3-Tests'
}

{ #category : 'running' }
NT3NoteEditorPresenterTest >> setUp [

	super setUp.
	application := NT3DeferringTestApplication new.
	note := application newNoteTitled: 'Meeting' tagNames: #( 'spec' ).
	note contents: (String cr join: #( 'Meeting' 'The list and the List view' )).
	application
		noteEdited: note;
		saveNote: note.
	editor := NT3NoteEditorPresenter newApplication: application
]

{ #category : 'tests' }
NT3NoteEditorPresenterTest >> testChangingTheQueryUpdatesTheMatches [

	editor note: note.
	editor textQuery: (NT3TextQuery text: 'view').
	self assert: editor matchRanges equals: { 31 to: 34 }
]

{ #category : 'tests' }
NT3NoteEditorPresenterTest >> testDiscardBringsBackTheNoteAsSelected [

	| original date |
	original := note contents.
	date := note modificationDate.
	editor note: note.
	self type: 'Changed'.
	application saveAll.
	editor discardEdits.
	self assert: note contents equals: original.
	self assert: note modificationDate equals: date.
	self assert: editor textEditor text equals: original.
	self assert: note fileReferenceContents equals: original.
	self deny: (application isUnsaved: note)
]

{ #category : 'tests' }
NT3NoteEditorPresenterTest >> testInfoLineOfTheNote [

	editor note: note.
	self assert: editor infoText equals: ((NT3NotePreview note: note today: Date today) infoLineUnsaved: false)
]

{ #category : 'tests' }
NT3NoteEditorPresenterTest >> testMatchesOfTheQuery [

	editor textQuery: (NT3TextQuery text: 'list').
	editor note: note.
	self assert: editor matchRanges equals: { 13 to: 16. 26 to: 29 }
]

{ #category : 'tests' }
NT3NoteEditorPresenterTest >> testNextMatchSelectsIt [

	editor textQuery: (NT3TextQuery text: 'list').
	editor note: note.
	editor selectNextMatch.
	self assert: editor textEditor selectionInterval equals: (26 to: 29).
	editor selectNextMatch.
	self assert: editor textEditor selectionInterval equals: (13 to: 16)
]

{ #category : 'tests' }
NT3NoteEditorPresenterTest >> testPreviousMatchSelectsIt [

	editor textQuery: (NT3TextQuery text: 'list').
	editor note: note.
	editor selectPreviousMatch.
	self assert: editor textEditor selectionInterval equals: (26 to: 29)
]

{ #category : 'tests' }
NT3NoteEditorPresenterTest >> testSaveWritesTheNote [

	editor note: note.
	self type: 'Changed'.
	editor save.
	self deny: (application isUnsaved: note).
	self assert: note fileReferenceContents equals: 'Changed'.
	self deny: (editor infoText beginsWith: '• ')
]

{ #category : 'tests' }
NT3NoteEditorPresenterTest >> testShowingANoteIsNotAnEdit [

	editor note: note.
	self deny: (application isUnsaved: note)
]

{ #category : 'tests' }
NT3NoteEditorPresenterTest >> testShowingANotePutsTheCursorOnTheFirstMatch [

	editor textQuery: (NT3TextQuery text: 'list').
	editor note: note.
	self assert: editor textEditor selectionInterval equals: (13 to: 12)
]

{ #category : 'tests' }
NT3NoteEditorPresenterTest >> testShowsTheContentsOfTheNote [

	editor note: note.
	self assert: editor textEditor text equals: note contents.
	self assert: editor textEditor isEditable
]

{ #category : 'tests' }
NT3NoteEditorPresenterTest >> testTypingChangesTheNote [

	| typed |
	editor note: note.
	typed := String cr join: #( 'Meeting' 'changed' ).
	self type: typed.
	self assert: note contents equals: typed.
	self assert: (application isUnsaved: note).
	self assert: (editor infoText beginsWith: '• ')
]

{ #category : 'tests' }
NT3NoteEditorPresenterTest >> testTypingIsAnnounced [

	| edited |
	edited := nil.
	editor whenNoteEditedDo: [ :each | edited := each ].
	editor note: note.
	self type: 'Other title'.
	self assert: edited identicalTo: note
]

{ #category : 'tests' }
NT3NoteEditorPresenterTest >> testTypingUpdatesTheMatches [

	editor textQuery: (NT3TextQuery text: 'list').
	editor note: note.
	self type: 'A list'.
	self assert: editor matchRanges equals: { 3 to: 6 }
]

{ #category : 'tests' }
NT3NoteEditorPresenterTest >> testWithoutNoteTheEditorIsEmptyAndReadOnly [

	editor note: nil.
	self assert: editor textEditor text isEmpty.
	self deny: editor textEditor isEditable.
	self assert: editor infoText isEmpty
]

{ #category : 'helpers' }
NT3NoteEditorPresenterTest >> type: aString [
	"Change the text as the user would"

	editor textEditor text: aString
]
