"
This is the main Notes Taker Spec2 application class which:

- Handles the notes container: A class which acts as a repository of notes.
- Provides convenience methods to retrieve notes and its metadata.
- Handles the application initialization: See the `NtSpApplication>>start` method.
- Creates a new entry for this application in the World menu.


"
Class {
	#name : 'NTTodoSpApplication',
	#superclass : 'SpApplication',
	#instVars : [
		'taskContainer'
	],
	#category : 'TheNoteTaker-Todo-UI-Core',
	#package : 'TheNoteTaker-Todo-UI',
	#tag : 'Core'
}

{ #category : 'private' }
NTTodoSpApplication class >> openFull [ 
	<script>
	
	^ self new startFullScreen 
]

{ #category : 'private' }
NTTodoSpApplication class >> openIt [

	<script>
	self new run
]

{ #category : 'initialization' }
NTTodoSpApplication >> initialize [

	super initialize.
	taskContainer := NTTodoContainer new
]

{ #category : 'running' }
NTTodoSpApplication >> start [

	(NTTodoSpNoteIndexPresenter newApplication: self) open
]

{ #category : 'running' }
NTTodoSpApplication >> startFullScreen [
	" Private - Open the main application window in full screen, intended for the release version "

	(NTTodoSpNoteIndexPresenter newApplication: self) asWorldWindow open
]

{ #category : 'accessing' }
NTTodoSpApplication >> taskContainer [

	^ taskContainer
]
