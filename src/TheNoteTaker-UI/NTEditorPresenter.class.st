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

{ #category : 'world menu' }
NTEditorPresenter class >> menuCommandOn: aBuilder [

	<worldMenu>
	(aBuilder item: #MicroEd)
		parent: #Tools;
		action: [ self open ];
		order: 40;
		help: 'A microdown Editor & Renderer';
		icon: (self iconNamed: #browseIconName).
	aBuilder withSeparatorAfter
]

{ #category : 'examples' }
NTEditorPresenter class >> open [

	<example>
	| pres |
	pres := self new. 
	^ pres openWithLayout: pres defaultLayoutNoMenu 
]

{ #category : 'layout' }
NTEditorPresenter >> defaultLayout [

	 ^ SpBoxLayout newTopToBottom
		add: #menu expand: false;
		add: (SpPanedLayout newLeftToRight
			add: textInput;
			add: renderedText;
		yourself);
	yourself
]

{ #category : 'layout' }
NTEditorPresenter >> defaultLayoutNoMenu [

	^ SpBoxLayout newTopToBottom
		  add: (SpPanedLayout newLeftToRight
				   add: textInput;
				   add: renderedText;
				   yourself);
		  yourself
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

{ #category : 'api' }
NTEditorPresenter >> initializeMenuBar [

	menu := self newMenuBar.

	menu
		addGroup: [ :group |
			group addItem: [ :item |
					item
						name: 'New';
						description: 'Start in a new file';
						icon: (self iconNamed: #pageIconName);
						action: [ self startNewFile ] ].
			group addItem: [ :item |
				item
					name: 'Open';
					description: 'Open file';
					shortcut: $o meta;
					icon: (self iconNamed: #openIconName);
					action: [ self loadFile ] ].
			group addItem: [ :item |
				item
					name: 'Save';
					description: 'Save file';
					shortcut: $s meta;
					icon: (self iconNamed: #smallSaveIconName);
					action: [ self saveFile ] ] ];
		addGroup: [ :group |
			group addItem: [ :item |
				item
					name: 'Render';
					icon: (self iconNamed: #smallDoItIconName);
					description: 'Render your input text';
					action: [ self renderDocument ] ].

			group addItem: [ :item |
				item
					name: 'Get example';
					description: 'Give a text input example in current syntax';
					icon: (self iconNamed: #smallFindIconName) ] ]
]

{ #category : 'initialization' }
NTEditorPresenter >> initializePresenters [

	| initialText |
	"in initialize it is called after so defeat textInputText: logic"
	composer := MicRichTextComposer new.
	initialText := '% Type your marked-up text here. Render it and see right the output generated as rich text'.
	self initializePresentersWithText: initialText.
	self initializeMenuBar
]

{ #category : 'initialization' }
NTEditorPresenter >> initializePresentersWithText: anInputText [

	textInput := self newText.
	self textInputText: anInputText.
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
		                yourself
]

{ #category : 'initialization' }
NTEditorPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: self title;
		initialExtent: 800 @ 600;
		windowIcon: (self application iconNamed: #browseIconName)
]

{ #category : 'actions' }
NTEditorPresenter >> loadFile [
	"OPEN button is pressed: open window"

	| selectedFile |
	self mayLoseEdits 
		ifTrue: [ (self application confirm: 'You have unsaved edits. Do you want to proceed?')
						ifFalse: [ ^ self ] ].
					
	selectedFile := StOpenFilePresenter new
		                extensions: #( 'md' );
		                openModal.
	selectedFile
		ifNotNil: [
			self note:
				(NTNoteObject newFromFileReference: selectedFile asFileReference).
			self textInputText: selectedFile contents.
			self renderDocument.
			self updateTitle ]
		ifNil: [ self note: NTNoteObject new ]
]

{ #category : 'testing' }
NTEditorPresenter >> mayLoseEdits [

	^ self textInputText isNotEmpty and: [ isTextDirty ]
]

{ #category : 'accessing' }
NTEditorPresenter >> note [

	^ note ifNil: [ note := MDFile new ]
]

{ #category : 'accessing' }
NTEditorPresenter >> note: aMDFile [

	note := aMDFile
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

	self note hasTitle ifFalse: [ 
		| answer |
		answer := self application newRequest
		                 title: 'Enter a title.';
		                 onCancel: [ '' ];
		                 openModal.
		self note title: answer ].
	self note save: self textInputText asString.
	isTextDirty := false.
	self window ifNotNil: [ self updateTitle ]
]

{ #category : 'actions' }
NTEditorPresenter >> startNewFile [
	"NEW button is pressed: reset tool"

	self mayLoseEdits ifTrue: [ (self application confirm:
			 'You have unsaved edits. Do you want to proceed?')
			ifFalse: [ ^ self ]  ].

	self emptyInputText.
	note := MDFile new.
	self window ifNotNil: [ self updateTitle ]
]

{ #category : 'accessing' }
NTEditorPresenter >> textInputText [

	^ textInput text
]

{ #category : 'accessing' }
NTEditorPresenter >> textInputText: aString [

	textInput text: aString asString.
	isTextDirty := false
]

{ #category : 'api' }
NTEditorPresenter >> title [

	^ 'MicroDown Editor - ' , self note fileName
]

{ #category : 'api' }
NTEditorPresenter >> updateTitle [

	self window title: self title
]
