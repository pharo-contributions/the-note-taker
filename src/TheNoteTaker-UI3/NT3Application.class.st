"
I am the application of the new TheNoteTaker UI (UI3): I open the note taker window and save the notes.

## Responsibility:

- I hold the `NTContainer` of the notes and load it from the notes folder (`~/Documents/Notes` by default).
- I know which notes have unsaved edits, save them 10 seconds after the last edit, on demand, or all at once, and tell my listeners when a note is saved.
- I remember the mode of the note list for the session and declare the styles of the UI3 presenters (`ntSeparator`, `ntDetail`).

## Collaborators:

- `NTContainer` and `NTNote`: the notes; a note writes its own file (`save`).
- `NT3Timer`: runs the autosave after a pause.
- `NT3NoteTakerPresenter`, `NT3NoteListPresenter`, `NT3NoteEditorPresenter`: the presenters I open and serve.

## Public API and Key Messages

- `notesFolder` / `notesFolder:` (before `start`), `loadNotes`, `container`.
- `newNoteTitled:tagNames:` creates, adds and saves a note.
- `noteEdited:`, `isUnsaved:`, `saveNote:`, `saveAll`, `whenNoteSavedDo:`.
- `listMode` / `listMode:`.
- `start` loads the notes and opens the note taker.

```
NT3Application example start
```

## Internal Representation

- `container`: an `NTContainer`; `notesFolder`: a `FileReference` or `FileLocator`.
- `unsavedNotes`: an `IdentitySet` of notes; `noteSavedBlocks`: the listeners.
- `autosaveTimer`: an `NT3Timer` (a manual timer in tests); `listMode`: an `NT3ListMode`.

### Implementation Points

Unsaved notes are tracked here rather than with `NTNote>>isDirty`, which reads the file each time.
"
Class {
	#name : 'NT3Application',
	#superclass : 'SpApplication',
	#instVars : [
		'container',
		'listMode',
		'notesFolder',
		'unsavedNotes',
		'autosaveTimer',
		'noteSavedBlocks'
	],
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'examples' }
NT3Application class >> example [
	"An application on an in-memory notes folder holding the sample notes"

	<sampleInstance>
	| application folder |
	folder := FileSystem memory root / 'Notes'.
	folder ensureCreateDirectory.
	application := self new
		               notesFolder: folder;
		               yourself.
	self sampleNotes do: [ :each |
		each folderReference: folder.
		each save.
		application container addNote: each ].
	^ application
]

{ #category : 'private - demo' }
NT3Application class >> noteTitled: aTitle body: aBody modifiedAt: aDateAndTime tagNames: aCollection [
	"Answer a note for demos and tests, with a fixed modification date and the given tags"

	| note |
	note := NTNote content: aTitle , String cr , aBody.
	aCollection do: [ :each | note addTag: (NTTag newNamed: each) ].
	note modificationDate: aDateAndTime.
	^ note
]

{ #category : 'private - demo' }
NT3Application class >> sampleNotes [
	"Answer notes spread over several months and years, with several, one or no tags, and one without title"

	| now |
	now := DateAndTime now.
	^ {
		  (self
			   noteTitled: '# Spec list redesign'
			   body: 'Three modes: **by date**, by tag and titles only. See [the plan](NOTE-LIST-UI3-PLAN.md).'
			   modifiedAt: now - 2 hours
			   tagNames: #( 'spec' 'notetaker' )).
		  (self
			   noteTitled: 'Groceries'
			   body: (String cr join: #( '- bread' '- cheese' ))
			   modifiedAt: now - 1 day
			   tagNames: #(  )).
		  (self
			   noteTitled: '## Reading list'
			   body: 'Pharo by Example, Learning OOP with Pharo'
			   modifiedAt: now - 4 days
			   tagNames: #( 'pharo' 'books' )).
		  (self
			   noteTitled: 'Microdown syntax'
			   body: 'Use `inline code` and _emphasis_.'
			   modifiedAt: now - 12 days
			   tagNames: #( 'pharo' )).
		  (self
			   noteTitled: '#'
			   body: 'A note whose title line is empty'
			   modifiedAt: now - 40 days
			   tagNames: #( 'misc' )).
		  (self
			   noteTitled: 'Conference talk'
			   body: 'Slides about Spec and Toplo'
			   modifiedAt: now - 75 days
			   tagNames: #( 'spec' 'talks' )).
		  (self
			   noteTitled: 'Old ideas'
			   body: 'Things from last year'
			   modifiedAt: now - 400 days
			   tagNames: #(  )) }
]

{ #category : 'examples' }
NT3Application class >> scriptStart [
	"Open the note taker on the sample notes, kept in memory"

	<example>
	self example start
]

{ #category : 'saving' }
NT3Application >> autosaveDelay [
	"Answer how long after the last edit the unsaved notes are saved"

	^ 10 seconds
]

{ #category : 'accessing' }
NT3Application >> autosaveTimer: aTimer [

	autosaveTimer := aTimer
]

{ #category : 'accessing' }
NT3Application >> container [

	^ container
]

{ #category : 'accessing' }
NT3Application >> container: aNTContainer [

	container := aNTContainer
]

{ #category : 'initialization' }
NT3Application >> initialize [

	super initialize.
	container := NTContainer new.
	listMode := NT3ByDateListMode new.
	unsavedNotes := IdentitySet new.
	noteSavedBlocks := OrderedCollection new.
	autosaveTimer := NT3Timer application: self.
	self addStyleSheetFromString: '.application [
		.label [
			.ntSeparator [ Font { #bold: true } ],
			.ntDetail [ Font { #name: EnvironmentFont(#default), #size: 9 } ] ] ]'
]

{ #category : 'testing' }
NT3Application >> isUnsaved: aNote [

	^ unsavedNotes includes: aNote
]

{ #category : 'accessing' }
NT3Application >> listMode [
	"Answer the mode of the note list, kept for the session"

	^ listMode
]

{ #category : 'accessing' }
NT3Application >> listMode: aListMode [

	listMode := aListMode
]

{ #category : 'notes' }
NT3Application >> loadNotes [
	"Add the notes of the notes folder to the container, creating the folder when missing"

	container importFolder: self notesFolder
]

{ #category : 'notes' }
NT3Application >> newNoteTitled: aString tagNames: aCollection [
	"Create, add and save a note whose first line is aString, having the tags named in aCollection"

	| note |
	note := NTNote content: aString , String cr.
	note folderReference: self notesFolder.
	aCollection do: [ :each | note addTag: (container ensureTagNamed: each) ].
	container addNote: note.
	self notesFolder ensureCreateDirectory.
	note save.
	^ note
]

{ #category : 'saving' }
NT3Application >> noteEdited: aNote [
	"aNote was changed in the editor: remember it is unsaved and save it after a pause"

	unsavedNotes add: aNote.
	autosaveTimer restartAfter: self autosaveDelay do: [ self saveAll ]
]

{ #category : 'accessing' }
NT3Application >> notesFolder [
	"Answer the folder holding the note files"

	^ notesFolder ifNil: [ notesFolder := FileLocator documents / 'Notes' ]
]

{ #category : 'accessing' }
NT3Application >> notesFolder: aFolder [

	notesFolder := aFolder
]

{ #category : 'saving' }
NT3Application >> saveAll [

	unsavedNotes copy do: [ :each | self saveNote: each ].
	autosaveTimer stop
]

{ #category : 'saving' }
NT3Application >> saveNote: aNote [
	"Write aNote to its file when it has unsaved edits, and tell the listeners"

	(self isUnsaved: aNote) ifFalse: [ ^ self ].
	aNote save.
	unsavedNotes remove: aNote.
	unsavedNotes ifEmpty: [ autosaveTimer stop ].
	noteSavedBlocks do: [ :each | each value: aNote ]
]

{ #category : 'running' }
NT3Application >> start [
	"Load the notes of the notes folder and open the note taker window"

	self loadNotes.
	(self instantiate: NT3NoteTakerPresenter) open
]

{ #category : 'events' }
NT3Application >> whenNoteSavedDo: aBlock [
	"aBlock receives each note written to its file"

	noteSavedBlocks add: aBlock
]
