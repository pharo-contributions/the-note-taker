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
		'#textInput',
		'#composer',
		'#model',
		'#renderedText',
		'#isRenderedButton',
		'#worker',
		'#isNewNote',
		'#isSaved => ObservableSlot'
	],
	#classVars : [
		'#AutoSave',
		'#IsRenderedEnable'
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
		parent: #tnt_note;
		target: self;
		order: 60;
		label: 'enable automatic save';
		description:
			'When enabled, the application save note after a space or enter character.
When disabled, you need to manually save your note. '
]

{ #category : 'transmission' }
NTSpEditorPresenter >> defaultInputPort [

	^ SpModelPort newPresenter: self
]

{ #category : 'layout' }
NTSpEditorPresenter >> defaultLayout [

	| panedLayout |
	panedLayout := self isRenderedEnable
		               ifTrue: [ self layoutWithRenderedText ]
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

	isRenderedButton := self newButton
		                    iconName: #smallJustified;
		                    action: [ self isRenderedButtonClick ].

	renderedText := self newText
		                beNotEditable;
		                yourself.

	textInput := self newText
		             whenTextChangedDo: [
				             model contents: textInput text asString.
				             self isRenderedEnable ifTrue: [ self renderDocument ].
				             self class AutoSave ifTrue: [ self saveFile ] ];
		             addShortcutWith: [ :action |
				             action
					             shortcutKey: $s meta;
					             action: [ self saveFile ] ];
		             yourself
]

{ #category : 'actions' }
NTSpEditorPresenter >> isRenderedButtonClick [

	IsRenderedEnable := IsRenderedEnable not.
	layout := self defaultLayout
]

{ #category : 'accessing' }
NTSpEditorPresenter >> isRenderedEnable [

	^ IsRenderedEnable ifNil: [ IsRenderedEnable := true ]
]

{ #category : 'layout' }
NTSpEditorPresenter >> layoutWithRenderedText [

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

{ #category : 'accessing - model' }
NTSpEditorPresenter >> model [

	^ model ifNil: [ self newEmptyNote ]
]

{ #category : 'api' }
NTSpEditorPresenter >> newEmptyNote [

	model := NTNote new.
	isNewNote := true.
	self emptyInputText
]

{ #category : 'actions' }
NTSpEditorPresenter >> renderDocument [
	"RENDER button is pressed: render input to output text"

	worker schedule: [
			renderedText text: (composer asRichText: self textInputText) ]
]

{ #category : 'accessing' }
NTSpEditorPresenter >> renderedText [

	^ renderedText text
]

{ #category : 'actions' }
NTSpEditorPresenter >> saveFile [

	isNewNote ifTrue: [
			textInput text ifEmpty: [ ^ self ].
			isNewNote := false ].
	self model isDirty ifFalse: [ ^ self ].
	
	"Dumb assert for activate the whenNoteSavedDo:"
	isSaved := nil.
	self model save
]

{ #category : 'accessing - model' }
NTSpEditorPresenter >> setModel: aNTNoteObject [

	isNewNote := false.
	
	aNTNoteObject
		ifNil: [ self newEmptyNote ]
		ifNotNil: [ model := aNTNoteObject ].

	self textInputText: model contents asString.
	self renderDocument.

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

{ #category : 'api - events' }
NTSpEditorPresenter >> whenNoteChangedDo: aBlock [

	textInput whenTextChangedDo: [ aBlock cull: self model ]
]

{ #category : 'api - events' }
NTSpEditorPresenter >> whenNoteSavedDo: aBlock [

	self property: #isSaved whenChangedDo: [ aBlock cull: self model ]
]
