"
A little editor for Microdown. 

Todo: 
- menu
- cmd+s should save and render
- when typing at space we can render?
"
Class {
	#name : 'NTSpEditorPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'textInput',
		'composer',
		'note',
		'renderedText',
		'worker'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'actions' }
NTSpEditorPresenter >> defaultInputPort [

	^ SpModelPort newPresenter: self
]

{ #category : 'layout' }
NTSpEditorPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: (SpPanedLayout newLeftToRight
				   add: textInput;
				   add: renderedText;
				   yourself);
		  yourself
]

{ #category : 'actions' }
NTSpEditorPresenter >> emptyInputText [
	"CLEAN button is pressed: erase both input and output text content"

	self textInputText: ''.
	self emptyRenderedText
]

{ #category : 'actions' }
NTSpEditorPresenter >> emptyRenderedText [

	renderedText text: ''
]

{ #category : 'initialization' }
NTSpEditorPresenter >> initialize [

	super initialize.
	worker := TKTLocalProcessTaskRunner new.
	self noNote.
]

{ #category : 'initialization' }
NTSpEditorPresenter >> initializePresenters [
	"in initialize it is called after so defeat textInputText: logic"

	composer := MicRichTextComposer new.

	textInput := self newText.
	textInput
		bindKeyCombination:
		Character space asKeyCombination | Character cr asKeyCombination
		toAction: [ :target :morph :event |
				self renderDocument.
				self updateTitle.
				self owner notesIndexPresenter modelChanged.
				event wasHandled: false ].

	renderedText := self newText
		                beNotEditable;
		                yourself.
	textInput
		whenTextChangedDo: [ note contents: textInput text asString ];
		bindKeyCombination: $s meta toAction: [
				self saveFile.
				self owner statusBar pushMessage: (self application log save: note) ]
]

{ #category : 'layout' }
NTSpEditorPresenter >> layoutWithoutRenderedText [

	^ SpBoxLayout newTopToBottom
		  add: (SpPanedLayout newLeftToRight
				   add: textInput;
				   yourself);
		  yourself
]

{ #category : 'testing' }
NTSpEditorPresenter >> mayLoseEdits [

	^ self textInputText isNotEmpty and: [ note isDirty ]
]

{ #category : 'api' }
NTSpEditorPresenter >> noNote [

	| nt |
	nt := NTNoteObject new.
	"nt folderReference: self application settings noteLocation."
	self note: nt.
	
	self emptyInputText
]

{ #category : 'accessing' }
NTSpEditorPresenter >> note [

	^ note ifNil: [ self noNote ]
]

{ #category : 'accessing' }
NTSpEditorPresenter >> note: aNTNoteObject [

	aNTNoteObject ifNil: [ self noNote ] ifNotNil: [ note := aNTNoteObject ].
	"note fileReference extension = '.md'
		ifTrue: [ self layout: self defaultLayout ]
		ifFalse: [ self layout: self layoutWithoutRenderedText ]."
	textInput text: note contents asString.
	self renderDocument.
	self updateTitle

	"self mayLoseEdits ifTrue: [ (self application confirm:
			 'You have unsaved edits. Do you want to proceed?')
			ifFalse: [ ^ self ]  ]."
]

{ #category : 'actions' }
NTSpEditorPresenter >> renderDocument [
	"RENDER button is pressed: render input to output text"

	worker schedule: [ | document text |
		document := Microdown parse: self textInputText.
		text := composer visit: document.
		renderedText text: text]
]

{ #category : 'accessing' }
NTSpEditorPresenter >> renderedText [

	^ renderedText text
]

{ #category : 'actions' }
NTSpEditorPresenter >> saveFile [

	self note save.
]

{ #category : 'accessing' }
NTSpEditorPresenter >> textInputText [

	^ textInput text
]

{ #category : 'accessing' }
NTSpEditorPresenter >> textInputText: aString [

	textInput text: aString asString.
]

{ #category : 'api' }
NTSpEditorPresenter >> updateTitle [

	self window ifNotNil: [ self window title: self application applicationTitle, ' - ', note title ]
]
