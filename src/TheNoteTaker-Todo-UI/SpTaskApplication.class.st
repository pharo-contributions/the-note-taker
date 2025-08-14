"
This is the main Notes Taker Spec2 application class which:

- Handles the notes container: A class which acts as a repository of notes.
- Provides convenience methods to retrieve notes and its metadata.
- Handles the application initialization: See the `NtSpApplication>>start` method.
- Creates a new entry for this application in the World menu.


"
Class {
	#name : 'SpTaskApplication',
	#superclass : 'SpApplication',
	#instVars : [
		'taskContainer'
	],
	#category : 'TheNoteTaker-Todo-UI-Core',
	#package : 'TheNoteTaker-Todo-UI',
	#tag : 'Core'
}

{ #category : 'private' }
SpTaskApplication class >> openIt [

	<script>
	self new run
]

{ #category : 'initialization' }
SpTaskApplication >> initialize [

	super initialize.
	taskContainer := TaskManager new
]

{ #category : 'running' }
SpTaskApplication >> start [

	(SpTaskMain2Presenter newApplication: self) open
]

{ #category : 'accessing' }
SpTaskApplication >> taskContainer [

	^ taskContainer
]
