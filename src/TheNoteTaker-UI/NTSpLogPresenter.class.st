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

{ #category : 'initialization' }
NTSpLogPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: renderedText;
		  yourself
]

{ #category : 'initialization' }
NTSpLogPresenter >> initializePresenters [
	"in initialize it is called after so defeat textInputText: logic"

	| logFile |
	renderedText := self newText.

	titleHolder := 'LOG'.
	
	logFile := (self application settings noteLocation / 'TheNoteTaker.log').
	logFile exists ifFalse: [ logFile ensureCreateFile ].

	renderedText text:
		logFile contents
]
