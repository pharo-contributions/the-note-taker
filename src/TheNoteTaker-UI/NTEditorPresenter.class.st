"
I'm a editor of notes. I have 3 presenters:

- A presenter to write note contents and modificate it.
- A presenter to show the render of the note contents in Microdown
- a button at top right, for show or not the render prensenter.

We use a note like a model, we can save a note by use Cmd+s or by activate the autosave, who save the note when we modificate it.
We also render when we modificate the note.

We have two events we handle: 
-when we change a note (`whenNoteChangeDo:`) and when we save a note: `(whenNoteSavedDo:`)

When a new note is created in the Editor, if we save it when it is empty, nothing changes, else we add it to index prensenter.

In renderDocument, we use worker schedule:. We use it for increase performance: when we render, if we render again when the first is not finished, then it should cancel the first render and use only the last one.

"
Class {
	#name : 'NTEditorPresenter',
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
NTEditorPresenter class >> AutoSave [

	^ AutoSave ifNil: [AutoSave := true] 
	
	
]

{ #category : 'as yet unclassified' }
NTEditorPresenter class >> AutoSave: aBoolean [

	AutoSave := aBoolean
]

{ #category : 'settings' }
NTEditorPresenter class >> settingsOn: aBuilder [

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
NTEditorPresenter >> defaultInputPort [

	^ SpModelPort newPresenter: self
]

{ #category : 'layout' }
NTEditorPresenter >> defaultLayout [

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
NTEditorPresenter >> emptyInputText [
	"CLEAN button is pressed: erase both input and output text content"

	self textInputText: ''.
	renderedText text: ''
]

{ #category : 'initialization' }
NTEditorPresenter >> initialize [

	super initialize.
	worker := TKTLocalProcessTaskRunner new.
	self newEmptyNote.
]

{ #category : 'initialization' }
NTEditorPresenter >> initializePresenters [
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
NTEditorPresenter >> isRenderedButtonClick [

	IsRenderedEnable := IsRenderedEnable not.
	layout := self defaultLayout
]

{ #category : 'accessing' }
NTEditorPresenter >> isRenderedEnable [

	^ IsRenderedEnable ifNil: [ IsRenderedEnable := true ]
]

{ #category : 'layout' }
NTEditorPresenter >> layoutWithRenderedText [

	^ SpPanedLayout newLeftToRight
		  add: textInput;
		  add: renderedText;
		  yourself
]

{ #category : 'layout' }
NTEditorPresenter >> layoutWithoutRenderedText [

	^ SpBoxLayout newTopToBottom
		  add: textInput;
		  yourself
]

{ #category : 'testing' }
NTEditorPresenter >> mayLoseEdits [

	^ self textInputText isNotEmpty and: [ model isDirty ]
]

{ #category : 'accessing - model' }
NTEditorPresenter >> model [

	^ model ifNil: [ self newEmptyNote ]
]

{ #category : 'api' }
NTEditorPresenter >> newEmptyNote [

	model := NTNote new.
	isNewNote := true.
	self emptyInputText
]

{ #category : 'actions' }
NTEditorPresenter >> renderDocument [
	"RENDER button is pressed: render input to output text"

	worker schedule: [
			renderedText text: (composer asRichText: self textInputText) ]
]

{ #category : 'accessing' }
NTEditorPresenter >> renderedText [

	^ renderedText text
]

{ #category : 'actions' }
NTEditorPresenter >> saveFile [

	isNewNote ifTrue: [
			textInput text ifEmpty: [ ^ self ].
			isNewNote := false ].
	self model isDirty ifFalse: [ ^ self ].
	
	"Dumb assert for activate the whenNoteSavedDo:"
	isSaved := nil.
	self model save
]

{ #category : 'accessing - model' }
NTEditorPresenter >> setModel: aNTNoteObject [

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
NTEditorPresenter >> textInput [

	^ textInput
]

{ #category : 'accessing' }
NTEditorPresenter >> textInputText [

	^ textInput text
]

{ #category : 'accessing' }
NTEditorPresenter >> textInputText: aString [

	textInput text: aString asString.
]

{ #category : 'api - events' }
NTEditorPresenter >> whenNoteChangedDo: aBlock [

	textInput whenTextChangedDo: [ aBlock cull: self model ]
]

{ #category : 'api - events' }
NTEditorPresenter >> whenNoteSavedDo: aBlock [

	self property: #isSaved whenChangedDo: [ aBlock cull: self model ]
]
