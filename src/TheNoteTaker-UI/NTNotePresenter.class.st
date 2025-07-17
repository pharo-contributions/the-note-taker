Class {
	#name : 'NTNotePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'model'
	],
	#category : 'TheNoteTaker-UI',
	#package : 'TheNoteTaker-UI'
}

{ #category : 'layout' }
NTNotePresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: model title;
		  add: model creationDate asDate asString;
		  yourself
]

{ #category : 'layout' }
NTNotePresenter >> initializePresenter [ 

	model := NTNoteObject new
]

{ #category : 'layout' }
NTNotePresenter >> model [ 

	^ model
]

{ #category : 'layout' }
NTNotePresenter >> model: newModel [ 

	model := newModel.
	layout := self defaultLayout
]

{ #category : 'layout' }
NTNotePresenter >> modelChanged [ 

	layout := self defaultLayout
]
