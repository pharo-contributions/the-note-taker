Class {
	#name : 'NTSpLogPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'renderedText'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'instance creation' }
NTSpLogPresenter class >> openLogOfFolder: aFileReference [

	^ self new openLog: aFileReference / 'TheNoteTaker.log'
]

{ #category : 'initialization' }
NTSpLogPresenter >> contents [

	^ renderedText text
]

{ #category : 'initialization' }
NTSpLogPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: renderedText;
		  yourself
]

{ #category : 'initialization' }
NTSpLogPresenter >> initializePresenters [
	"in initialize it is called after so defeat textInputText: logic"

	renderedText := self newText.

	titleHolder := 'LOG'
]

{ #category : 'initialization' }
NTSpLogPresenter >> openLog: aFileReference [

	aFileReference exists ifFalse: [ aFileReference ensureCreateFile ].

	renderedText text: aFileReference contents
]
