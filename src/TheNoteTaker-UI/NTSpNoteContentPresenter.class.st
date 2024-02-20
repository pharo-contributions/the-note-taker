"
Presents the note content when a note is selected in the `NtSpNoteIndexPresenter`.

"
Class {
	#name : 'NTSpNoteContentPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'contentPresenter'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'accessing' }
NTSpNoteContentPresenter >> contentPresenter [

	^ contentPresenter
]

{ #category : 'accessing' }
NTSpNoteContentPresenter >> contentPresenter: anObject [

	contentPresenter := anObject
]

{ #category : 'layout' }
NTSpNoteContentPresenter >> defaultLayout [ 
	
	^ SpBoxLayout newTopToBottom 
		add: contentPresenter;
		yourself.
]

{ #category : 'initialization' }
NTSpNoteContentPresenter >> document: aString [
	"Set the receiver's document content to be aString"

	self contentPresenter document: aString
]

{ #category : 'initialization' }
NTSpNoteContentPresenter >> initializePresenters [

	contentPresenter := self instantiate: MicrodownPresenter.
]
