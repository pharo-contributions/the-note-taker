"
I test the saving and the notes folder of `NT3Application`, on an in-memory file system with a manual timer.

## Responsibility:

- Check loading the notes folder and creating notes in it.
- Check the unsaved notes, saving one or all of them, the autosave and the saved announcements.

## Collaborators:

- `NT3Application`, `NT3ManualTimer`, `FileSystem memory`.

## Public API and Key Messages

- `testNewNoteIsSavedInTheNotesFolder`, `testAutosaveSavesAllUnsavedNotes`, …
"
Class {
	#name : 'NT3ApplicationTest',
	#superclass : 'TestCase',
	#instVars : [
		'application',
		'folder',
		'timer'
	],
	#category : 'TheNoteTaker-UI3-Tests',
	#package : 'TheNoteTaker-UI3-Tests'
}

{ #category : 'helpers' }
NT3ApplicationTest >> editedNewNote [

	| note |
	note := application newNoteTitled: 'Idea' tagNames: #(  ).
	note contents: (String cr join: #( 'Idea' 'more' )).
	application noteEdited: note.
	^ note
]

{ #category : 'running' }
NT3ApplicationTest >> setUp [

	super setUp.
	folder := FileSystem memory root / 'Notes'.
	timer := NT3ManualTimer new.
	application := NT3Application new
		               notesFolder: folder;
		               autosaveTimer: timer;
		               yourself
]

{ #category : 'tests' }
NT3ApplicationTest >> testAutosaveSavesAllUnsavedNotes [

	| first second |
	first := self editedNewNote.
	second := application newNoteTitled: 'Other' tagNames: #(  ).
	second contents: 'Other changed'.
	application noteEdited: second.
	timer fire.
	self deny: (application isUnsaved: first).
	self deny: (application isUnsaved: second).
	self assert: second fileReferenceContents equals: 'Other changed'
]

{ #category : 'tests' }
NT3ApplicationTest >> testDefaultNotesFolderIsNotesInDocuments [

	self assert: NT3Application new notesFolder equals: FileLocator documents / 'Notes'
]

{ #category : 'tests' }
NT3ApplicationTest >> testEditedNoteIsUnsaved [

	self assert: (application isUnsaved: self editedNewNote)
]

{ #category : 'tests' }
NT3ApplicationTest >> testEditingStartsTheAutosaveTimer [

	self editedNewNote.
	self assert: timer isRunning.
	self assert: timer duration equals: 10 seconds
]

{ #category : 'tests' }
NT3ApplicationTest >> testLoadNotesCreatesTheFolder [

	application loadNotes.
	self assert: folder exists
]

{ #category : 'tests' }
NT3ApplicationTest >> testLoadNotesReadsTheNotesFolder [

	| loaded |
	folder ensureCreateDirectory.
	(NTNote content: 'Saved before')
		folderReference: folder;
		save.
	loaded := NT3Application new notesFolder: folder; yourself.
	loaded loadNotes.
	self assert: (loaded container notes collect: [ :each | each title ] as: Array) equals: #( 'Saved before' )
]

{ #category : 'tests' }
NT3ApplicationTest >> testNewNoteIsSavedInTheNotesFolder [

	| note |
	note := application newNoteTitled: 'Idea' tagNames: #( 'spec' ).
	self assert: note folderReference equals: folder.
	self assert: note exists.
	self assert: note contents equals: 'Idea' , String cr.
	self assert: (note tags collect: [ :each | each tagName ] as: Array) equals: #( 'spec' ).
	self assert: (application container notes includes: note).
	self deny: (application isUnsaved: note)
]

{ #category : 'tests' }
NT3ApplicationTest >> testNewNoteTagsAreTheTagsOfTheContainer [

	| note |
	note := application newNoteTitled: 'Idea' tagNames: #( 'spec' ).
	self assert: (application container tags collect: [ :each | each tagName ] as: Array) equals: #( 'spec' ).
	self assert: note tags anyOne identicalTo: application container tags anyOne
]

{ #category : 'tests' }
NT3ApplicationTest >> testSaveAllStopsTheTimer [

	| note |
	note := self editedNewNote.
	application saveAll.
	self deny: (application isUnsaved: note).
	self deny: timer isRunning
]

{ #category : 'tests' }
NT3ApplicationTest >> testSavingANoteWritesItsFile [

	| note |
	note := self editedNewNote.
	application saveNote: note.
	self deny: (application isUnsaved: note).
	self assert: note fileReferenceContents equals: note contents
]

{ #category : 'tests' }
NT3ApplicationTest >> testSavingASavedNoteDoesNothing [

	| note saved |
	note := application newNoteTitled: 'Idea' tagNames: #(  ).
	saved := false.
	application whenNoteSavedDo: [ :each | saved := true ].
	application saveNote: note.
	self deny: saved
]

{ #category : 'tests' }
NT3ApplicationTest >> testSavingAnnouncesTheNote [

	| note saved |
	note := self editedNewNote.
	saved := nil.
	application whenNoteSavedDo: [ :each | saved := each ].
	application saveNote: note.
	self assert: saved identicalTo: note
]
