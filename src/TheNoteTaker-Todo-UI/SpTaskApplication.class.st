"
This is the todo application class which:

- Handles the task container: A class which acts as a repository of notes.
- Handles the application initialization: See the `NtSpApplication>>start` method.


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

	(SpTaskMainPresenter newApplication: self) open
]

{ #category : 'accessing' }
SpTaskApplication >> taskContainer [

	^ taskContainer
]
