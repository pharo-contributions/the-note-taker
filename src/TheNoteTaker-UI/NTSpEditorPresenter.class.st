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
		'model',
		'renderedText',
		'isRenderedButton',
		'worker'
	],
	#classVars : [
		'AutoSave',
		'isRenderedEnable'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'as yet unclassified' }
NTSpEditorPresenter class >> AutoSave [

	^ AutoSave ifNil: [AutoSave := true] 
	
	
]

{ #category : 'as yet unclassified' }
NTSpEditorPresenter class >> AutoSave: aBoolean [

	AutoSave := aBoolean
]

{ #category : 'settings' }
NTSpEditorPresenter class >> settingsOn: aBuilder [

	<systemsettings>
	(aBuilder setting: #AutoSave)
		parent: #tnt;
		target: self;
		order: 60;
		label: 'enable automatic save';
		description:
			'When enabled, the application save note after a space or enter character.
When disabled, you need to manually save your note. '
]

{ #category : 'actions' }
NTSpEditorPresenter >> defaultInputPort [

	^ SpModelPort newPresenter: self
]

{ #category : 'layout' }
NTSpEditorPresenter >> defaultLayout [

	| panedLayout |
	panedLayout := self isRenderedEnable
		               ifTrue: [ self layoutWitRenderedText ]
		               ifFalse: [ self layoutWithoutRenderedText ].

	^ SpOverlayLayout new
		  child: panedLayout;
		  addOverlay: isRenderedButton withConstraints: [ :constraints |
				  constraints
					  vAlignStart;
					  hAlignEnd ];
		  yourself
]

{ #category : 'actions' }
NTSpEditorPresenter >> emptyInputText [
	"CLEAN button is pressed: erase both input and output text content"

	self textInputText: ''.
	renderedText text: ''
]

{ #category : 'initialization' }
NTSpEditorPresenter >> initialize [

	super initialize.
	worker := TKTLocalProcessTaskRunner new.
	self newEmptyNote.
]

{ #category : 'initialization' }
NTSpEditorPresenter >> initializePresenters [
	"in initialize it is called after so defeat textInputText: logic"

	composer := MicRichTextComposer new.

	isRenderedButton := self newButton action: [
		                    self isRenderedButtonClick ].

	textInput := self newText.
	textInput
		bindKeyCombination:
		Character space asKeyCombination | Character cr asKeyCombination
		toAction: [ :target :morph :event |
				isRenderedEnable ifTrue: [ self renderDocument ].
				self class AutoSave ifTrue: [ self saveFile ].
				self updateTitle.
				"self owner notesIndexPresenter modelChanged."
				event wasHandled: false ].

	renderedText := self newText
		                beNotEditable;
		                yourself.
	textInput
		whenTextChangedDo: [ model contents: textInput text asString ];
		bindKeyCombination: $s meta toAction: [
				self saveFile. ]
]

{ #category : 'actions' }
NTSpEditorPresenter >> isRenderedButtonClick [

	isRenderedEnable := isRenderedEnable not.
	layout := self defaultLayout
]

{ #category : 'accessing' }
NTSpEditorPresenter >> isRenderedEnable [

	isRenderedEnable ifNil: [ isRenderedEnable := true ].
	^ isRenderedEnable
]

{ #category : 'layout' }
NTSpEditorPresenter >> layoutWitRenderedText [

	^ SpPanedLayout newLeftToRight
		  add: textInput;
		  add: renderedText;
		  yourself
]

{ #category : 'layout' }
NTSpEditorPresenter >> layoutWithoutRenderedText [

	^ SpBoxLayout newTopToBottom
		  add: textInput;
		  yourself
]

{ #category : 'testing' }
NTSpEditorPresenter >> mayLoseEdits [

	^ self textInputText isNotEmpty and: [ model isDirty ]
]

{ #category : 'accessing' }
NTSpEditorPresenter >> model [

	^ model ifNil: [ self newEmptyNote ]
]

{ #category : 'api' }
NTSpEditorPresenter >> newEmptyNote [

	| nt |
	nt := NTNoteObject new.
	self setModel: nt.

	self emptyInputText
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

	self model exists ifFalse: [ self owner addNote: self model ].
	self model save.
	self owner statusBar pushMessage: (self application log save: model)
]

{ #category : 'accessing' }
NTSpEditorPresenter >> setModel: aNTNoteObject [

	aNTNoteObject
		ifNil: [ self newEmptyNote ]
		ifNotNil: [ model := aNTNoteObject ].
		
	self textInputText: model contents asString.
	self renderDocument.
	self updateTitle

	"self mayLoseEdits ifTrue: [ (self application confirm:
			 'You have unsaved edits. Do you want to proceed?')
			ifFalse: [ ^ self ]  ]."
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

	self window ifNotNil: [
			self window title:
				self application applicationTitle , ' - ' , model title ]
]
