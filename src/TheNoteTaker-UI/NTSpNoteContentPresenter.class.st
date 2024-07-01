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

{ #category : 'accessing' }
NTSpNoteContentPresenter >> contents: aString [

	contentPresenter textInputText: aString
]

{ #category : 'transmission' }
NTSpNoteContentPresenter >> defaultInputPort [ 

	^ SpModelPort newPresenter: self 
]

{ #category : 'layout' }
NTSpNoteContentPresenter >> defaultLayout [ 
	
	^ SpBoxLayout newTopToBottom 
		add: contentPresenter;
		yourself
]

{ #category : 'initialization' }
NTSpNoteContentPresenter >> initializePresenters [

	contentPresenter := NTMDEditorPresenter new.
	contentPresenter 
		cleanInput;
		cleanOutput
]

{ #category : 'accessing' }
NTSpNoteContentPresenter >> selectedNoteTitle [
	
	^ self owner selectedNoteTitle
]

{ #category : 'accessing - model' }
NTSpNoteContentPresenter >> setModel: aNoteObject [ 
	"Private - Set the receiver's content iterating recursively starting from aNode"
	
	aNoteObject openFromPresenter: self.

]
