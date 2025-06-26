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
		'isTextDirty',
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

{ #category : 'api' }
NTSpEditorPresenter >> displayContents: aNoteObject [

	note := aNoteObject.
	textInput text: aNoteObject contents asString.
	self renderDocument
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

{ #category : 'accessing' }
NTSpEditorPresenter >> initialize [

	super initialize.
	self noNote.
	isTextDirty := false.
	worker := TKTLocalProcessTaskRunner new
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
				self owner notesIndexPresenter refresh.
				event wasHandled: false ].

	"		
	textInput addShortcutWith: [ :action | action 
        shortcutKey: Character space asKeyCombination | Character cr asKeyCombination;
        action: [ self renderDocument ] ].
   "
	textInput eventHandler whenKeyDownDo: [ :anEvent |
			isTextDirty := true.
			anEvent wasHandled: false ].

	renderedText := self newText
		                beNotEditable;
		                yourself.
	textInput
		whenTextChangedDo: [
			note ifNotNil: [ note contents: textInput text asString ] ];
		bindKeyCombination: $s meta toAction: [
				self saveFile.
				self application log save: note ]
]

{ #category : 'testing' }
NTSpEditorPresenter >> mayLoseEdits [

	^ self textInputText isNotEmpty and: [ isTextDirty ]
]

{ #category : 'api' }
NTSpEditorPresenter >> newNote: aNoteObject [

	note := aNoteObject.
	self displayContents: aNoteObject.
	self window ifNotNil: [self updateTitle].
]

{ #category : 'api' }
NTSpEditorPresenter >> noNote [

	note := NTNoteObject new
]

{ #category : 'accessing' }
NTSpEditorPresenter >> note [

	^ note ifNil: [ note := NTNoteObject new ]
]

{ #category : 'accessing' }
NTSpEditorPresenter >> note: aNTNoteObject [

	note := aNTNoteObject
]

{ #category : 'api' }
NTSpEditorPresenter >> openNote: aNoteObject [

	note := aNoteObject.
	self displayContents: aNoteObject.
	self window ifNotNil: [self updateTitle].
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
	isTextDirty := false.
	self window ifNotNil: [ self updateTitle ]
]

{ #category : 'accessing' }
NTSpEditorPresenter >> startNewFile [
	"NEW button is pressed: reset tool"

	self mayLoseEdits ifTrue: [ (self application confirm:
			 'You have unsaved edits. Do you want to proceed?')
			ifFalse: [ ^ self ]  ].

	self emptyInputText.
	note := NTNoteObject new.
	self window ifNotNil: [ self updateTitle ]
]

{ #category : 'accessing' }
NTSpEditorPresenter >> textInputText [

	^ textInput text
]

{ #category : 'accessing' }
NTSpEditorPresenter >> textInputText: aString [

	textInput text: aString asString.
	note contents: self textInputText.
	isTextDirty := false
]

{ #category : 'api' }
NTSpEditorPresenter >> title [
	"Answer a <String> representing the application name and selected note title"

	^ String streamContents: [ :stream |
			  stream
				  << self application applicationTitle;
				  << note title ]
]

{ #category : 'api' }
NTSpEditorPresenter >> updateTitle [

	self window title: self note title
]
