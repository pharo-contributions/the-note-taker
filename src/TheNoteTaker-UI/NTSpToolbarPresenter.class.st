Class {
	#name : 'NTSpToolbarPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'notesSearchCreateTextPresenter',
		'notesSearchButtonPresenter'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'layout' }
NTSpToolbarPresenter >> defaultLayout [ 

	^ SpBoxLayout newLeftToRight 
		add: notesSearchCreateTextPresenter;
		add: notesSearchButtonPresenter;
		yourself
]

{ #category : 'initialization' }
NTSpToolbarPresenter >> initializePresenters [ 

	notesSearchCreateTextPresenter := self newTextInput
		help: 'Type note to search or create';
		yourself.
	notesSearchButtonPresenter := self newButton
		icon: (self iconNamed: #smallFind);
		help: 'Search note';
		yourself
]
