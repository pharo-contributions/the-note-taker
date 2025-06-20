Class {
	#name : 'NTSpLogPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'renderedText'
	],
	#category : 'TheNoteTaker-UI-Manifest',
	#package : 'TheNoteTaker-UI',
	#tag : 'Manifest'
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

	renderedText := self newText.

	titleHolder := 'LOG'.

	renderedText text:
		(NTSettings noteLocation asFileReference / 'TheNoteTaker.log')
			contents
]
