"
I represent a NTNoteObject.
"
Class {
	#name : 'NTNotePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'note'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'layout' }
NTNotePresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: self note title;
		  add: self note modificationDate asDate asString;
		  add: self note tagsNameString;
		  yourself
]

{ #category : 'layout' }
NTNotePresenter >> initializePresenter [ 

	self note: NTNote new
]

{ #category : 'layout' }
NTNotePresenter >> note [

	^ note
]

{ #category : 'layout' }
NTNotePresenter >> note: aNTNoteObject [

	note := aNTNoteObject.
	layout := self defaultLayout
]
