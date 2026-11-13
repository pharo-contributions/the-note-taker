"
I am the application of the new NoteTaker UI. I hold the notes container of a folder and track the notes that were never saved.

NT2Application open
"
Class {
	#name : 'NT2Application',
	#superclass : 'SpApplication',
	#instVars : [
		'container',
		'folder',
		'mainPresenter',
		'unsavedNotes'
	],
	#classInstVars : [
		'current'
	],
	#category : 'TheNoteTaker-UI2',
	#package : 'TheNoteTaker-UI2'
}

{ #category : 'accessing' }
NT2Application class >> displayTitleOf: aNTNote [
	"Answer the title to display for aNTNote: its first line without leading Markdown heading marks"

	| line |
	line := aNTNote title trimBoth.
	[ line beginsWith: '#' ] whileTrue: [ line := line allButFirst ].
	line := line trimBoth.
	^ line ifEmpty: [ 'unnamed' ]
]

{ #category : 'world menu' }
NT2Application class >> menuNoteTaker2On: aBuilder [

	<worldMenu>
	(aBuilder item: #NoteTaker2)
		parent: #Tools;
		label: 'NoteTaker (new)';
		icon: (self iconNamed: #catalog);
		action: [ self open ];
		help: 'The new NoteTaker UI';
		order: 631
]

{ #category : 'opening' }
NT2Application class >> open [
	"Open the new NoteTaker UI on the notes folder of the settings, or bring its window to the front"

	<script>
	(current notNil and: [ current isOpen ]) ifTrue: [ ^ current bringToFront ].
	current := self new.
	current folder: NTSettings default currentFolder.
	current run.
	^ current
]

{ #category : 'tags' }
NT2Application >> addTagNamed: aString to: aNTNote [

	^ (container ensureTagNamed: aString) addNote: aNTNote
]

{ #category : 'opening' }
NT2Application >> bringToFront [

	mainPresenter withWindowDo: [ :window | window activate ]
]

{ #category : 'accessing' }
NT2Application >> container [

	^ container
]

{ #category : 'notes' }
NT2Application >> discardNote: aNTNote [
	"Forget a note which was never saved"

	unsavedNotes remove: aNTNote ifAbsent: [ ].
	aNTNote tags copy do: [ :tag | container removeTag: tag fromNote: aNTNote ].
	container removeNotes: { aNTNote }
]

{ #category : 'accessing' }
NT2Application >> folder [

	^ folder
]

{ #category : 'accessing' }
NT2Application >> folder: aFileReference [

	folder := aFileReference.
	folder ensureCreateDirectory.
	container replaceFolder: folder
]

{ #category : 'initialization' }
NT2Application >> initialize [

	super initialize.
	container := NTContainer new.
	unsavedNotes := IdentitySet new
]

{ #category : 'testing' }
NT2Application >> isOpen [

	^ mainPresenter notNil and: [ mainPresenter isDisplayed ]
]

{ #category : 'testing' }
NT2Application >> isUnsaved: aNTNote [
	"Answer whether aNTNote was created in the receiver and never saved"

	^ unsavedNotes includes: aNTNote
]

{ #category : 'accessing' }
NT2Application >> mainPresenter [

	^ mainPresenter
]

{ #category : 'notes' }
NT2Application >> newNote [
	"Create an empty note in the folder. Its file name is chosen when it is first saved"

	| note |
	note := NTNote new folderReference: folder.
	container addNote: note.
	unsavedNotes add: note.
	^ note
]

{ #category : 'tags' }
NT2Application >> removeTag: aNTTag from: aNTNote [

	container removeTag: aNTTag fromNote: aNTNote
]

{ #category : 'notes' }
NT2Application >> saveNote: aNTNote [

	(unsavedNotes includes: aNTNote) ifTrue: [ "The file name is based on the first line at the time of the first save"
			aNTNote fileName: nil.
			unsavedNotes remove: aNTNote ].
	aNTNote save
]

{ #category : 'running' }
NT2Application >> start [

	mainPresenter := NT2MainPresenter newApplication: self.
	mainPresenter open
]

{ #category : 'notes' }
NT2Application >> trashNote: aNTNote [

	(unsavedNotes includes: aNTNote) ifTrue: [ ^ self discardNote: aNTNote ].
	container trashNote: aNTNote
]
