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
SpTaskApplication class >> openFull [ 
	<script>
	
	^ self new startFullScreen 
]

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

	(SpTaskMainPresenter newApplication: self) open
]

{ #category : 'running' }
SpTaskApplication >> startFullScreen [
	" Private - Open the main application window in full screen, intended for the release version "

	(SpTaskMainPresenter newApplication: self) asWorldWindow open
]

{ #category : 'accessing' }
SpTaskApplication >> taskContainer [

	^ taskContainer
]
