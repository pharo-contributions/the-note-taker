"
This is the main Notes Taker Spec2 application class which:

- Handles the notes container: A class which acts as a repository of notes.
- Provides convenience methods to retrieve notes and its metadata.
- Handles the application initialization: See the `NtSpApplication>>start` method.
- Creates a new entry for this application in the World menu.


"
Class {
	#name : 'NTSpApplication',
	#superclass : 'SpApplication',
	#instVars : [
		'noteTakerContainer',
		'log'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'private' }
NTSpApplication class >> applicationTitle [

	^ 'The Note Taker'
]

{ #category : 'private' }
NTSpApplication class >> menuNoteTakersOn: aBuilder [
	<worldMenu>

	(aBuilder item: #NoteTaker)
		parent: #Tools;
		label: self applicationTitle;
		icon: (self iconNamed: #catalog);
		action: [ NTSpApplication new run ];
		help: 'The Note Taker';
		order: 630
]

{ #category : 'private' }
NTSpApplication class >> openIt [

	<script>
	self new run
]

{ #category : 'testing' }
NTSpApplication >> addNoteNamed: aString [ 
	"Add a new empty note with title aString to the receiver's notes. Answer the receiver"
	
	^ self noteTaker addNoteNamed: aString trimBoth
]

{ #category : 'private' }
NTSpApplication >> applicationTitle [ 

	^ self class applicationTitle 
]

{ #category : 'initialization' }
NTSpApplication >> initialize [

	super initialize.
	noteTakerContainer := NTContainer new.
	log := NTLog newWithFolder: NTSettings noteLocation
]

{ #category : 'testing' }
NTSpApplication >> isValidNoteName: aString [ 
	"Answer <true> if aString is a valid note title"
	
	^ self noteTaker isValidNoteName: aString
]

{ #category : 'accessing' }
NTSpApplication >> log [

	^ log
]

{ #category : 'accessing' }
NTSpApplication >> log: aNTLog [

	log := aNTLog
]

{ #category : 'accessig' }
NTSpApplication >> noteInformation: aNtNodeModel [

	self shouldBeImplemented.
	^ aNtNodeModel 
]

{ #category : 'callbacks' }
NTSpApplication >> noteNamed: aString [ 

	^ self noteTaker noteNamed: aString
]

{ #category : 'accessing' }
NTSpApplication >> noteTaker [

	^ noteTakerContainer
]

{ #category : 'accessing' }
NTSpApplication >> notes [
	"Answer the application's <Collection> of <NTNoteObject>"

	^ self noteTaker notes
]

{ #category : 'running' }
NTSpApplication >> start [

	log noteTakerMain: (NTSpNoteTakerMainUI newApplication: self) open
]

{ #category : 'running' }
NTSpApplication >> startFullScreen [
	" Private - Open the main application window in full screen, intended for the release version "

	(NTSpNoteTakerMainUI newApplication: self) asWorldWindow open
]
