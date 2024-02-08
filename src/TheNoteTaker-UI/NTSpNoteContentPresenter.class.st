Class {
	#name : 'NTSpNoteContentPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'notesContentPresenter'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'layout' }
NTSpNoteContentPresenter >> defaultLayout [ 
	
	^ SpBoxLayout newTopToBottom 
		add: notesContentPresenter;
		yourself.
]

{ #category : 'initialization' }
NTSpNoteContentPresenter >> initializePresenters [

	notesContentPresenter := self newText.
]
