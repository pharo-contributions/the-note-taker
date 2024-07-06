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
		'noteTakerFacade'
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
NTSpApplication >> applicationTitle [ 

	^ self class applicationTitle 
]

{ #category : 'initialization' }
NTSpApplication >> initialize [

	super initialize.
	noteTakerFacade := NTSingleton uniqueInstance
]

{ #category : 'testing' }
NTSpApplication >> isValidNote: aString [ 
	"Answer <true> if aString is a valid note title"
	
	^ self noteTaker isValidNote: aString
]

{ #category : 'accessig' }
NTSpApplication >> noteInformation: aNtNodeModel [

	self shouldBeImplemented.
	^ aNtNodeModel 
]

{ #category : 'accessing' }
NTSpApplication >> noteTaker [

	^ noteTakerFacade
]

{ #category : 'accessing' }
NTSpApplication >> notes [
	"Answer the application's <Collection> of <NTNoteObject>"

	^ self noteTaker notes
]

{ #category : 'running' }
NTSpApplication >> start [
	" Private - See superimplementor's comment "

	(NTSpNoteTakerMainUI newApplication: self) "asWorldWindow" open.
]

{ #category : 'running' }
NTSpApplication >> startFullScreen [
	" Private - See superimplementor's comment "

	(NTSpNoteTakerMainUI newApplication: self) asWorldWindow open.
]
