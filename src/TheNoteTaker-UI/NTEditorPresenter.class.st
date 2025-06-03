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
		bindKeyCombination: (KMKeyCombinationChoice withShortcuts: { Character space asKeyCombination . Character cr asKeyCombination })
		toAction: [ :target :morph :event |
			[ self renderDocument ] schedule.
			event wasHandled: false ].

	textInput eventHandler whenKeyDownDo: [ :anEvent |
		isTextDirty := true.
		anEvent wasHandled: false ].

	renderedText := self newText
		                beNotEditable;
		                yourself.
]

{ #category : 'testing' }
NTEditorPresenter >> mayLoseEdits [

	^ self textInputText isNotEmpty and: [ isTextDirty ]
]

{ #category : 'api' }
NTEditorPresenter >> newNote: aNoteObject [

	"self mdFile: (MDFile new title: aNoteObject title)."
	self note: aNoteObject.
	self window ifNotNil: [ self updateTitle ].
	self note addMetaDataElements.
	textInput text: self note contents.
	self emptyRenderedText.
	self renderDocument.
	note title: self note fileReference basename.
	note contents: textInput text
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

	textInput text: aNoteObject contents.
	self emptyRenderedText.
	self window ifNotNil: [self updateTitle].
	self renderDocument.
	note := aNoteObject.
	note contents: self textInputText.
]

{ #category : 'actions' }
NTEditorPresenter >> renderDocument [
	"RENDER button is pressed: render input to output text"

	| document |
	document := Microdown parse: self textInputText.
	text := composer visit: document.
	renderedText text: text
]

{ #category : 'accessing' }
NTEditorPresenter >> renderedText [

	^ renderedText text
]

{ #category : 'actions' }
NTEditorPresenter >> saveFile [

	self note existsAsFile ifFalse: [ self saveFileByItsContents ]. 
	self note hasTitle ifFalse: [ 
		| answer |
		answer := self application newRequest
		                 title: 'Enter a title.';
		                 onCancel: [ '' ];
		                 openModal.
		self note title: answer ].
	self note save.
	isTextDirty := false.
	self window ifNotNil: [ self updateTitle ]
]

{ #category : 'testing' }
NTEditorPresenter >> saveFileByItsContents [
	"create a new note with its title which corresponds to the first word of the contents.
	If the contents has more than three words, the title correponds to its first three words. "

	| newNoteByItsContents nameOfNewNote collectionOfTextInput |
	collectionOfTextInput := self textInputText substrings.
	nameOfNewNote := String streamContents: [ :stt |
		(collectionOfTextInput size > 3
			ifTrue: [ collectionOfTextInput copyFrom: 1 to: 3 ]
			ifFalse: [ collectionOfTextInput ]) 
				do: [ :each | stt nextPutAll: each ] ].

	newNoteByItsContents := NTSingleton uniqueInstance addNoteNamed: nameOfNewNote.
	newNoteByItsContents contents: self textInputText.
	
	self emptyInputText.
	self newNote: newNoteByItsContents.
	self owner owner notesIndexPresenter refresh
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

	^ String streamContents: [ : stream |
		stream 
			<< self applicationTitle;
			<< self owner selectedNoteTitle ]
]

{ #category : 'api' }
NTEditorPresenter >> updateTitle [

	self window title: self title
]
