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

{ #category : 'helpers' }
NT3ApplicationTest >> tagNamesOf: aNote [

	^ aNote tags collect: [ :each | each tagName ] as: Set
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

{ #category : 'tests - tags' }
NT3ApplicationTest >> testShowsTagsByDefault [

	self assert: application showsTags
]

{ #category : 'tests - tags' }
NT3ApplicationTest >> testShowsTagsCanBeChanged [

	application showsTags: false.
	self deny: application showsTags
]

{ #category : 'tests - tags' }
NT3ApplicationTest >> testTagNamesAreTheTagsOfAllTheNotes [

	application container
		addNote: (NT3Application
				 noteTitled: 'A'
				 body: ''
				 modifiedAt: DateAndTime now
				 tagNames: #( 'spec' 'pharo' ));
		addNote: (NT3Application
				 noteTitled: 'B'
				 body: ''
				 modifiedAt: DateAndTime now
				 tagNames: #( 'pharo' 'books' )).
	self assert: application tagNames asSet equals: #( 'books' 'pharo' 'spec' ) asSet
]

{ #category : 'tests - tags' }
NT3ApplicationTest >> testTagNotesAddsTheTagsToEachNote [

	| first second |
	first := application newNoteTitled: 'First' tagNames: #( 'spec' ).
	second := application newNoteTitled: 'Second' tagNames: #(  ).
	application
		tagNotes: {
				first.
				second }
		adding: #( 'pharo' 'spec' )
		removing: #(  ).
	self assert: (self tagNamesOf: first) equals: #( 'pharo' 'spec' ) asSet.
	self assert: (self tagNamesOf: second) equals: #( 'pharo' 'spec' ) asSet
]

{ #category : 'tests - tags' }
NT3ApplicationTest >> testTagNotesAnnouncesTheSavedNotes [

	| first second saved |
	first := application newNoteTitled: 'First' tagNames: #(  ).
	second := application newNoteTitled: 'Second' tagNames: #(  ).
	saved := OrderedCollection new.
	application whenNoteSavedDo: [ :each | saved add: each ].
	application
		tagNotes: {
				first.
				second }
		adding: #( 'pharo' )
		removing: #(  ).
	self assert: saved asArray equals: {
			first.
			second }
]

{ #category : 'tests - tags' }
NT3ApplicationTest >> testTagNotesKeepsTheModificationDate [

	| note date |
	note := application newNoteTitled: 'First' tagNames: #(  ).
	date := DateAndTime fromString: '2025-01-01T10:00:00'.
	note modificationDate: date.
	application tagNotes: { note } adding: #( 'pharo' ) removing: #(  ).
	self assert: note modificationDate equals: date
]

{ #category : 'tests - tags' }
NT3ApplicationTest >> testTagNotesRemovesAnUnusedTagFromTheContainer [

	| note |
	note := application newNoteTitled: 'First' tagNames: #( 'spec' ).
	application tagNotes: { note } adding: #(  ) removing: #( 'spec' ).
	self deny: (application container tags anySatisfy: [ :each | each tagName = 'spec' ])
]

{ #category : 'tests - tags' }
NT3ApplicationTest >> testTagNotesRemovesTheTagsFromEachNote [

	| first second |
	first := application newNoteTitled: 'First' tagNames: #( 'spec' 'pharo' ).
	second := application newNoteTitled: 'Second' tagNames: #( 'spec' ).
	application
		tagNotes: {
				first.
				second }
		adding: #(  )
		removing: #( 'spec' ).
	self assert: (self tagNamesOf: first) equals: #( 'pharo' ) asSet.
	self assertEmpty: second tags
]

{ #category : 'tests - tags' }
NT3ApplicationTest >> testTagNotesSavesTheNotes [

	| note |
	note := application newNoteTitled: 'First' tagNames: #(  ).
	application tagNotes: { note } adding: #( 'pharo' ) removing: #(  ).
	self assert: (note fileReference contents includesSubstring: 'pharo').
	self deny: (application isUnsaved: note)
]

{ #category : 'tests - tags' }
NT3ApplicationTest >> testTagStyleIsDeclared [
	"Tags are small and coloured like links, with the colour of the theme"

	| style |
	style := application styleSheet flattenClasses detect: [ :each | each fullName = 'label.ntTag' ] ifNone: [ nil ].
	self assert: style isNotNil.
	self assert: (style properties collect: [ :each | each class name ] as: Set) equals: #( #SpFontStyle #SpDrawStyle ) asSet
]
