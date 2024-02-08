"
A toolbar with a text entry which has two roles when text is typed 

- A search for notes begins always, if any match then matching notes are returned.
- If none matches, then a new note is created after hitting **enter**

"
Class {
	#name : 'NTSpSearchCreatePresenter',
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
NTSpSearchCreatePresenter >> defaultLayout [ 

	^ SpBoxLayout newLeftToRight 
		add: notesSearchCreateTextPresenter;
		add: notesSearchButtonPresenter expand: false;
		yourself
]

{ #category : 'initialization' }
NTSpSearchCreatePresenter >> initializePresenters [ 

	notesSearchCreateTextPresenter := self newTextInput
		help: 'Create a note by just typing a name';
		placeholder: 'Type note to search or create';
		yourself.
	notesSearchButtonPresenter := self newButton
		icon: (self iconNamed: #smallFind);
		action: [ self searchList: notesSearchCreateTextPresenter text ];		
		help: 'Search note';
		yourself
]

{ #category : 'callbacks' }
NTSpSearchCreatePresenter >> searchList: aString [

	self shouldBeImplemented
]
