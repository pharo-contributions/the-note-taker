"
UI class for the note taker application.
This coordinates main events and layout of the main window.

"
Class {
	#name : 'NTTodoSpNoteTakerMainUI',
	#superclass : 'SpPresenter',
	#instVars : [
		'notesIndexPresenter'
	],
	#category : 'TheNoteTaker-Todo-UI-Core',
	#package : 'TheNoteTaker-Todo-UI',
	#tag : 'Core'
}

{ #category : 'layout' }
NTTodoSpNoteTakerMainUI >> defaultLayout [

	^ SpBoxLayout newLeftToRight
			add: notesIndexPresenter;
			yourself
]

{ #category : 'initialization' }
NTTodoSpNoteTakerMainUI >> initializePresenters [

	notesIndexPresenter := self instantiate: NTTodoSpNoteIndexPresenter.
	notesIndexPresenter model: self application taskContainer
]

{ #category : 'accessing' }
NTTodoSpNoteTakerMainUI >> notesIndexPresenter [

	^ notesIndexPresenter
]
