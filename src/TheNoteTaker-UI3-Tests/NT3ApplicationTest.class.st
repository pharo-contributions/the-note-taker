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

{ #category : 'helpers' }
NT3ApplicationTest >> otherFolderWithNoteTitled: aString [
	"Answer a second notes folder holding one saved note whose title is aString"

	| other |
	other := folder fileSystem root / 'Other'.
	other ensureCreateDirectory.
	(NTNote content: aString)
		folderReference: other;
		save.
	^ other
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

{ #category : 'tests - settings' }
NT3ApplicationTest >> testAutosaveDelayIsTheDelayOfTheSettings [

	application settings autosaveSeconds: 3.
	self assert: application autosaveDelay equals: 3 seconds
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

{ #category : 'tests - notes folder' }
NT3ApplicationTest >> testChangingTheFolderOfTheSettingsAnnouncesIt [

	| announced |
	announced := false.
	application whenNotesFolderChangedDo: [ announced := true ].
	application settings currentFolder: (self otherFolderWithNoteTitled: 'Elsewhere').
	self assert: announced
]

{ #category : 'tests - notes folder' }
NT3ApplicationTest >> testChangingTheFolderOfTheSettingsChangesTheNotesFolder [

	| other |
	other := self otherFolderWithNoteTitled: 'Elsewhere'.
	application settings currentFolder: other.
	self assert: application notesFolder equals: other
]

{ #category : 'tests - notes folder' }
NT3ApplicationTest >> testChangingTheFolderOfTheSettingsSavesTheUnsavedNotes [

	| note |
	note := self editedNewNote.
	application settings currentFolder: (self otherFolderWithNoteTitled: 'Elsewhere').
	self deny: (application isUnsaved: note).
	self assert: note fileReferenceContents equals: note contents
]

{ #category : 'tests - notes folder' }
NT3ApplicationTest >> testChangingTheFolderOfTheSettingsShowsOnlyItsNotes [

	self editedNewNote.
	application settings currentFolder: (self otherFolderWithNoteTitled: 'Elsewhere').
	self assert: (application container notes collect: [ :each | each title ] as: Array) equals: #( 'Elsewhere' )
]

{ #category : 'tests - notes folder' }
NT3ApplicationTest >> testClosedApplicationNoLongerFollowsTheSettings [

	| window |
	window := (application instantiate: NT3NoteTakerPresenter) open.
	window close.
	application settings currentFolder: (self otherFolderWithNoteTitled: 'Elsewhere').
	self assert: application notesFolder equals: folder
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

{ #category : 'tests - settings' }
NT3ApplicationTest >> testListModeIsTheModeOfTheSettings [

	application settings listMode: #byTag.
	self assert: application listMode class equals: NT3ByTagListMode
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

{ #category : 'tests - managing tags' }
NT3ApplicationTest >> testNotesTaggedAreTheNotesHavingTheTag [

	| both specOnly |
	both := application newNoteTitled: 'Both' tagNames: #( 'pharo' 'spec' ).
	application newNoteTitled: 'Pharo' tagNames: #( 'pharo' ).
	specOnly := application newNoteTitled: 'Spec' tagNames: #( 'spec' ).
	self assert: (application notesTagged: 'spec') asSet equals: {
			both.
			specOnly } asSet
]

{ #category : 'tests - settings' }
NT3ApplicationTest >> testOnSettingsUsesTheNotesFolderOfTheSettings [

	| settings |
	settings := NTSettings new
		            currentFolder: folder;
		            yourself.
	self assert: (NT3Application onSettings: settings) notesFolder identicalTo: folder
]

{ #category : 'tests - settings' }
NT3ApplicationTest >> testOnSettingsUsesTheSettings [

	| settings |
	settings := NTSettings new.
	self assert: (NT3Application onSettings: settings) settings identicalTo: settings
]

{ #category : 'tests - managing tags' }
NT3ApplicationTest >> testRemoveTagRemovesItFromEveryNote [

	| both pharoOnly |
	both := application newNoteTitled: 'Both' tagNames: #( 'pharo' 'spec' ).
	pharoOnly := application newNoteTitled: 'Pharo' tagNames: #( 'pharo' ).
	application removeTagNamed: 'pharo'.
	self assert: (self tagNamesOf: both) equals: #( 'spec' ) asSet.
	self assert: (self tagNamesOf: pharoOnly) isEmpty.
	self assert: application tagNames asSet equals: #( 'spec' ) asSet
]

{ #category : 'tests - managing tags' }
NT3ApplicationTest >> testRemoveTagSavesTheNotes [

	| note |
	note := application newNoteTitled: 'Pharo' tagNames: #( 'pharo' 'spec' ).
	application removeTagNamed: 'pharo'.
	self deny: (note fileReference contents includesSubstring: 'pharo')
]

{ #category : 'tests - managing tags' }
NT3ApplicationTest >> testRenameTagChangingOnlyTheCaseRenamesIt [

	| note |
	note := application newNoteTitled: 'Pharo' tagNames: #( 'pharo' ).
	application renameTagNamed: 'pharo' to: 'Pharo'.
	self assert: (self tagNamesOf: note) equals: #( 'Pharo' ) asSet
]

{ #category : 'tests - managing tags' }
NT3ApplicationTest >> testRenameTagPutsTheNewNameOnItsNotes [

	| both pharoOnly specOnly |
	both := application newNoteTitled: 'Both' tagNames: #( 'pharo' 'spec' ).
	pharoOnly := application newNoteTitled: 'Pharo' tagNames: #( 'pharo' ).
	specOnly := application newNoteTitled: 'Spec' tagNames: #( 'spec' ).
	application renameTagNamed: 'pharo' to: 'smalltalk'.
	self assert: (self tagNamesOf: both) equals: #( 'smalltalk' 'spec' ) asSet.
	self assert: (self tagNamesOf: pharoOnly) equals: #( 'smalltalk' ) asSet.
	self assert: (self tagNamesOf: specOnly) equals: #( 'spec' ) asSet
]

{ #category : 'tests - managing tags' }
NT3ApplicationTest >> testRenameTagRemovesTheOldNameFromTheTags [

	application newNoteTitled: 'Pharo' tagNames: #( 'pharo' ).
	application renameTagNamed: 'pharo' to: 'smalltalk'.
	self assert: application tagNames asSet equals: #( 'smalltalk' ) asSet
]

{ #category : 'tests - managing tags' }
NT3ApplicationTest >> testRenameTagSavesTheNotes [

	| note |
	note := application newNoteTitled: 'Pharo' tagNames: #( 'pharo' ).
	application renameTagNamed: 'pharo' to: 'smalltalk'.
	self assert: (note fileReference contents includesSubstring: 'smalltalk').
	self deny: (note fileReference contents includesSubstring: 'pharo')
]

{ #category : 'tests - managing tags' }
NT3ApplicationTest >> testRenameTagToABlankNameKeepsIt [

	| note |
	note := application newNoteTitled: 'Pharo' tagNames: #( 'pharo' ).
	application renameTagNamed: 'pharo' to: ' , '.
	self assert: (self tagNamesOf: note) equals: #( 'pharo' ) asSet
]

{ #category : 'tests - managing tags' }
NT3ApplicationTest >> testRenameTagToAnExistingTagMergesThem [

	| both pharoOnly |
	both := application newNoteTitled: 'Both' tagNames: #( 'pharo' 'spec' ).
	pharoOnly := application newNoteTitled: 'Pharo' tagNames: #( 'pharo' ).
	application renameTagNamed: 'pharo' to: 'spec'.
	self assert: (self tagNamesOf: both) equals: #( 'spec' ) asSet.
	self assert: (self tagNamesOf: pharoOnly) equals: #( 'spec' ) asSet.
	self assert: (application container tags count: [ :each | each tagName = 'spec' ]) equals: 1
]

{ #category : 'tests - managing tags' }
NT3ApplicationTest >> testRenameTagToItsOwnNameKeepsIt [

	| note |
	note := application newNoteTitled: 'Pharo' tagNames: #( 'pharo' ).
	application renameTagNamed: 'pharo' to: ' pharo '.
	self assert: (self tagNamesOf: note) equals: #( 'pharo' ) asSet
]

{ #category : 'tests - notes folder' }
NT3ApplicationTest >> testReplacedSettingsAreNoLongerFollowed [

	| previous |
	previous := application settings.
	application settings: NTSettings new.
	previous currentFolder: (self otherFolderWithNoteTitled: 'Elsewhere').
	self assert: application notesFolder equals: folder
]

{ #category : 'tests - notes folder' }
NT3ApplicationTest >> testReplacingSettingsFollowsTheNewOnes [

	| other |
	application settings: NTSettings new.
	other := self otherFolderWithNoteTitled: 'Elsewhere'.
	application settings currentFolder: other.
	self assert: application notesFolder equals: other
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

{ #category : 'tests - settings' }
NT3ApplicationTest >> testSettingShowsTagsChangesTheSettings [

	application showsTags: false.
	self deny: application settings showsTags
]

{ #category : 'tests - settings' }
NT3ApplicationTest >> testSettingTheListModeChangesTheSettings [

	application listMode: NT3CompactListMode new.
	self assert: application settings listMode equals: #compact
]

{ #category : 'tests - notes folder' }
NT3ApplicationTest >> testSettingTheSameFolderKeepsTheNotes [

	| note announced |
	note := self editedNewNote.
	announced := false.
	application whenNotesFolderChangedDo: [ announced := true ].
	application settings currentFolder: folder.
	self assert: (application container notes includes: note).
	self deny: announced
]

{ #category : 'tests - settings' }
NT3ApplicationTest >> testSettingsCanBeReplaced [

	| settings |
	settings := NTSettings new
		            listMode: #compact;
		            yourself.
	application settings: settings.
	self assert: application listMode class equals: NT3CompactListMode
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

{ #category : 'tests - settings' }
NT3ApplicationTest >> testShowsTagsIsTheShowsTagsOfTheSettings [

	application settings showsTags: false.
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

{ #category : 'tests - menu' }
NT3ApplicationTest >> testWorldMenuItemIsInToolsAfterTheOtherNoteTakers [

	| builder item |
	builder := PragmaMenuBuilder new.
	NT3Application menuNoteTaker3On: builder.
	item := builder itemList first.
	self assert: item name equals: #NoteTaker3.
	self assert: item label equals: 'NoteTaker 3'.
	self assert: item parentName equals: #Tools.
	self assert: item order equals: 632
]
