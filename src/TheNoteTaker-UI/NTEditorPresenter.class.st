"
A little editor for Microdown. 

Todo: 
- menu
- cmd+s should save and render
- when typing at space we can render?
"
Class {
	#name : 'NTEditorPresenter',
	#superclass : 'SpApplicationWithToolbar',
	#instVars : [
		'textInput',
		'composer',
		'note',
		'renderedText',
		'isTextDirty'
	],
	#category : 'TheNoteTaker-UI-Manifest',
	#package : 'TheNoteTaker-UI',
	#tag : 'Manifest'
}

{ #category : 'layout' }
NTEditorPresenter >> applicationTitle [

	^ self application applicationTitle
]

{ #category : 'actions' }
NTEditorPresenter >> defaultInputPort [

	^ SpModelPort newPresenter: self
]

{ #category : 'layout' }
NTEditorPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: (SpPanedLayout newLeftToRight
				   add: textInput;
				   add: renderedText;
				   yourself);
		  yourself
]

{ #category : 'api' }
NTEditorPresenter >> displayContents: aNoteObject [

	note := aNoteObject.
	textInput text: aNoteObject contents asString.
	self renderDocument
]

{ #category : 'actions' }
NTEditorPresenter >> emptyInputText [
	"CLEAN button is pressed: erase both input and output text content"

	self textInputText: ''.
	self emptyRenderedText
]

{ #category : 'actions' }
NTEditorPresenter >> emptyRenderedText [

	renderedText text: ''
]

{ #category : 'accessing' }
NTEditorPresenter >> initialize [ 

	super initialize.
	self noNote
]

{ #category : 'initialization' }
NTEditorPresenter >> initializePresenters [
	"in initialize it is called after so defeat textInputText: logic"

	composer := MicRichTextComposer new.

	textInput := self newText.
	textInput
		bindKeyCombination: Character space asKeyCombination | Character cr asKeyCombination 
		toAction: [ :target :morph :event |
				Transcript show: '#'.
				self renderDocument.
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
		bindKeyCombination: $s meta 
		toAction: [ self saveFile . self inform: 'Note ' , note fileReference fullName , ' saved' ];
		bindKeyCombination: $g meta 
		toAction: [ self push . self inform: 'Folder push' ]
]

{ #category : 'testing' }
NTEditorPresenter >> mayLoseEdits [

	^ self textInputText isNotEmpty and: [ isTextDirty ]
]

{ #category : 'api' }
NTEditorPresenter >> newNote: aNoteObject [

	note := aNoteObject.
	self displayContents: aNoteObject.
	self window ifNotNil: [self updateTitle].
]

{ #category : 'api' }
NTEditorPresenter >> noNote [

	note := NTNoteObject new
]

{ #category : 'accessing' }
NTEditorPresenter >> note [

	^ note ifNil: [ note := NTNoteObject new ]
]

{ #category : 'accessing' }
NTEditorPresenter >> note: aNTNoteObject [

	note := aNTNoteObject
]

{ #category : 'api' }
NTEditorPresenter >> openNote: aNoteObject [

	note := aNoteObject.
	self displayContents: aNoteObject.
	self window ifNotNil: [self updateTitle].
]

{ #category : 'actions' }
NTEditorPresenter >> push [

	NTSpGitCommand new execute.
]

{ #category : 'actions' }
NTEditorPresenter >> renderDocument [
	"RENDER button is pressed: render input to output text"

	| document |
	
	document := Microdown parse: self textInputText copy.
	text := composer visit: document.
	renderedText text: text
]

{ #category : 'accessing' }
NTEditorPresenter >> renderedText [

	^ renderedText text
]

{ #category : 'actions' }
NTEditorPresenter >> saveFile [
	
	self note save.
	isTextDirty := false.
	self window ifNotNil: [ self updateTitle ]
]

{ #category : 'api' }
NTEditorPresenter >> setModel: aNoteObject [ 
	"Private - Set the receiver's content iterating recursively starting from aNode"
	
	"(self editorPresenter canOpenFile: aNoteObject)
		ifTrue: [ aNoteObject openFromPresenter: self ]
		ifFalse: [ aNoteObject newFromPresenter: self ]" 
]

{ #category : 'accessing' }
NTEditorPresenter >> startNewFile [
	"NEW button is pressed: reset tool"

	self mayLoseEdits ifTrue: [ (self application confirm:
			 'You have unsaved edits. Do you want to proceed?')
			ifFalse: [ ^ self ]  ].

	self emptyInputText.
	note := NTNoteObject new.
	self window ifNotNil: [ self updateTitle ]
]

{ #category : 'accessing' }
NTEditorPresenter >> textInputText [

	^ textInput text
]

{ #category : 'accessing' }
NTEditorPresenter >> textInputText: aString [

	textInput text: aString asString.
	note contents: self textInputText.
	isTextDirty := false
]

{ #category : 'api' }
NTEditorPresenter >> title [
	"Answer a <String> representing the application name and selected note title"

	^ String streamContents: [ :stream |
			  stream
				  << self applicationTitle;
				  << self owner selectedNoteTitle ]
]

{ #category : 'api' }
NTEditorPresenter >> updateTitle [

	self window title: self note title
]
