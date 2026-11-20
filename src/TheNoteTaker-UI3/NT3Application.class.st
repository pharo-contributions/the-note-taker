"
I am the application of the new TheNoteTaker UI (UI3): I open the note taker window and save the notes.

## Responsibility:

- I hold the `NTContainer` of the notes and load it from the notes folder (`~/Documents/Notes` by default).
- I know which notes have unsaved edits, save them some seconds after the last edit (`NTSettings>>#autosaveSeconds`, 10 by default), on demand, or all at once, and tell my listeners when a note is saved.
- I follow the notes folder of my settings: when it changes (e.g. in the `NTSettingsPresenter` dialog), I save the unsaved notes, load the notes of the new folder and tell my listeners. I stop following the settings once my last window is closed, since `NTSettings default` outlives me.
- I keep the mode of the note list, whether it shows tags and the autosave delay in my `NTSettings`, and declare the styles of the UI3 presenters (`ntSeparator`, `ntDetail`, `ntTag` coloured with the theme `urlColor`).

## Collaborators:

- `NTContainer` and `NTNote`: the notes; a note writes its own file (`save`).
- `NT3Timer`: runs the autosave after a pause.
- `NTSettings`: my settings (`NTSettings new` by default, `settings:` to share the persisted `NTSettings default`). The mode of the list is stored by its `NT3ListMode>>#settingName`.
- `NT3NoteTakerPresenter`, `NT3NoteListPresenter`, `NT3NoteEditorPresenter`: the presenters I open and serve.

## Public API and Key Messages

- `notesFolder` / `notesFolder:` (before `start`), `loadNotes`, `container`.
- `newNoteTitled:tagNames:` creates, adds and saves a note.
- `tagNames`, `tagNotes:adding:removing:` adds and removes tags of several notes and saves them.
- `noteEdited:`, `isUnsaved:`, `saveNote:`, `saveAll`, `whenNoteSavedDo:`.
- `whenNotesFolderChangedDo:` runs a block once the notes of a new notes folder are loaded.
- `settings` / `settings:`; `listMode` / `listMode:`, `showsTags` / `showsTags:`, `autosaveDelay` read and write them.
- `start` loads the notes and opens the note taker.
- `NT3Application open` opens it on the notes folder of `NTSettings default`, the user's settings saved in the preferences file; `NT3Application onSettings: someSettings` answers an application on other settings, not started.

```
NT3Application scriptStart
```

## Internal Representation

- `container`: an `NTContainer`; `notesFolder`: a `FileReference` or `FileLocator`.
- `unsavedNotes`: an `IdentitySet` of notes; `noteSavedBlocks` and `notesFolderChangedBlocks`: the listeners.
- `autosaveTimer`: an `NT3Timer` (a manual timer in tests); `settings`: an `NTSettings`.

### Implementation Points

Unsaved notes are tracked here rather than with `NTNote>>isDirty`, which reads the file each time.
"
Class {
	#name : 'NT3Application',
	#superclass : 'SpApplication',
	#instVars : [
		'container',
		'notesFolder',
		'unsavedNotes',
		'autosaveTimer',
		'noteSavedBlocks',
		'settings',
		'notesFolderChangedBlocks'
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

{ #category : 'world menu' }
NT3Application class >> menuNoteTaker3On: aBuilder [
	"Add NoteTaker 3 to the Tools menu of the World, after the other note takers"

	<worldMenu>
	(aBuilder item: #NoteTaker3)
		parent: #Tools;
		label: 'NoteTaker 3';
		icon: (self iconNamed: #catalog);
		action: [ self open ];
		help: 'Open the note taker on your saved settings';
		order: 632
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

{ #category : 'instance creation' }
NT3Application class >> onSettings: aNTSettings [
	"Answer an application using aNTSettings and their notes folder"

	^ self new
		  settings: aNTSettings;
		  notesFolder: aNTSettings currentFolder;
		  yourself
]

{ #category : 'opening' }
NT3Application class >> open [
	"Open the note taker on the notes folder of the user's settings; changed settings are saved in the preferences file"

	<script>
	^ (self onSettings: NTSettings default)
		  run;
		  yourself
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

	^ settings autosaveSeconds seconds
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

{ #category : 'notes' }
NT3Application >> followNotesFolder: aFolder [
	"Show the notes of aFolder, the new notes folder of the settings. The unsaved notes are first saved in their own folder"

	| folder |
	folder := aFolder asFileReference.
	folder = self notesFolder ifTrue: [ ^ self ].
	self saveAll.
	notesFolder := folder.
	container := NTContainer new.
	self loadNotes.
	notesFolderChangedBlocks do: [ :each | each value ]
]

{ #category : 'initialization' }
NT3Application >> initialize [

	super initialize.
	container := NTContainer new.
	unsavedNotes := IdentitySet new.
	noteSavedBlocks := OrderedCollection new.
	notesFolderChangedBlocks := OrderedCollection new.
	autosaveTimer := NT3Timer application: self.
	self settings: NTSettings new.
	self addStyleSheetFromString: '.application [
		.label [
			.ntSeparator [ Font { #bold: true } ],
			.ntDetail [ Font { #name: EnvironmentFont(#default), #size: 9 } ],
			.ntTag [ Font { #name: EnvironmentFont(#default), #size: 9 }, Draw { #color: EnvironmentColor(#url) } ] ] ]'
]

{ #category : 'testing' }
NT3Application >> isUnsaved: aNote [

	^ unsavedNotes includes: aNote
]

{ #category : 'accessing' }
NT3Application >> listMode [
	"Answer the mode of the note list, kept in the settings"

	^ NT3ListMode named: settings listMode
]

{ #category : 'accessing' }
NT3Application >> listMode: aListMode [

	settings listMode: aListMode settingName
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

{ #category : 'notes' }
NT3Application >> notesTagged: aTagName [
	"Answer the notes having the tag named aTagName"

	^ container notes select: [ :note | note tags anySatisfy: [ :tag | tag tagName = aTagName ] ]
]

{ #category : 'notes' }
NT3Application >> removeTagNamed: aTagName [
	"Remove the tag named aTagName from every note having it, and save these notes"

	self tagNotes: (self notesTagged: aTagName) adding: #(  ) removing: { aTagName }
]

{ #category : 'notes' }
NT3Application >> renameTagNamed: oldName to: newName [
	"Put the tag named newName instead of the tag named oldName on each note having it, and save these notes.
	Renaming to an existing tag merges both. newName is cleaned as any tag name (see NTTag class>>#cleanName:); a blank or unchanged name changes nothing"

	| name |
	name := NTTag cleanName: newName.
	(name isEmpty or: [ name = oldName ]) ifTrue: [ ^ self ].
	self tagNotes: (self notesTagged: oldName) adding: { name } removing: { oldName }
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

{ #category : 'accessing' }
NT3Application >> settings [
	"Answer the settings giving the list mode, whether tags are shown and the autosave delay"

	^ settings
]

{ #category : 'accessing' }
NT3Application >> settings: aNTSettings [
	"Use aNTSettings, and follow the changes of their notes folder instead of those of the previous settings"

	settings ifNotNil: [ settings unsubscribe: self ].
	settings := aNTSettings.
	settings whenCurrentFolderChangeDo: [ :folder | self followNotesFolder: folder ]
]

{ #category : 'accessing' }
NT3Application >> showsTags [
	"Answer whether the note list shows the first tags of the notes, kept in the settings"

	^ settings showsTags
]

{ #category : 'accessing' }
NT3Application >> showsTags: aBoolean [

	settings showsTags: aBoolean
]

{ #category : 'running' }
NT3Application >> start [
	"Load the notes of the notes folder and open the note taker window"

	self loadNotes.
	(self instantiate: NT3NoteTakerPresenter) open
]

{ #category : 'notes' }
NT3Application >> tagNames [
	"Answer the names of the tags of all the notes, each once"

	^ (container notes flatCollect: [ :note | note tags collect: [ :tag | tag tagName ] ]) asSet asArray
]

{ #category : 'notes' }
NT3Application >> tagNotes: aCollectionOfNotes adding: addedTagNames removing: removedTagNames [
	"Add the tags named in addedTagNames to each note and remove those named in removedTagNames, then save the notes.
	A tag that no note uses any more is removed from the container"

	aCollectionOfNotes do: [ :note |
			addedTagNames do: [ :each | note addTag: (container ensureTagNamed: each) ].
			removedTagNames do: [ :each |
				note tags detect: [ :tag | tag tagName = each ] ifFound: [ :tag | container removeTag: tag fromNote: note ] ].
			unsavedNotes add: note.
			self saveNote: note ]
]

{ #category : 'events' }
NT3Application >> whenNoteSavedDo: aBlock [
	"aBlock receives each note written to its file"

	noteSavedBlocks add: aBlock
]

{ #category : 'events' }
NT3Application >> whenNotesFolderChangedDo: aBlock [
	"aBlock is evaluated once the notes of a new notes folder are loaded"

	notesFolderChangedBlocks add: aBlock
]

{ #category : 'windows' }
NT3Application >> windowClosed: aWindowPresenter [
	"Once the last window is closed, stop following the settings, which may outlive the receiver"

	super windowClosed: aWindowPresenter.
	self windows ifEmpty: [ settings unsubscribe: self ]
]
