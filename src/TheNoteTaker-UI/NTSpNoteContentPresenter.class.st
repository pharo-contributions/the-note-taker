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

{ #category : 'initialization' }
NTSpNoteContentPresenter >> contents: aString [
	"Set the receiver's document content to be aString"

	self contentPresenter documentFromString: aString
]

{ #category : 'transmission' }
NTSpNoteContentPresenter >> defaultInputPort [ 

	^ SpModelPort newPresenter: self 
]

{ #category : 'layout' }
NTSpNoteContentPresenter >> defaultLayout [ 
	
	^ SpBoxLayout newTopToBottom 
		add: contentPresenter;
		yourself.
]

{ #category : 'initialization' }
NTSpNoteContentPresenter >> initializePresenters [

	contentPresenter := NTMDEditorPresenter new.
	contentPresenter cleanInput.
]

{ #category : 'accessing - model' }
NTSpNoteContentPresenter >> setModel: aNoteObject [ 
	"Private - Set the receiver's content iterating recursively starting from aNode"
	
	self contentPresenter openNote: aNoteObject
]
