"
I edit the contents and tags of a note. I save automatically after a pause in typing, when the note changes and when the window closes.
"
Class {
	#name : 'NT2EditorPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'note',
		'textInput',
		'preview',
		'tagField',
		'modeButton',
		'saveButton',
		'statusLabel',
		'isDirty',
		'isLoading',
		'saveProcess',
		'changedBlock',
		'savedBlock'
	],
	#category : 'TheNoteTaker-UI2',
	#package : 'TheNoteTaker-UI2'
}

{ #category : 'saving' }
NT2EditorPresenter >> autosaveDelay [
	"Seconds without typing after which the note is saved"

	^ 2
]

{ #category : 'saving' }
NT2EditorPresenter >> autosaveNow [
	"Save the pending changes now instead of waiting for the end of the autosave delay"

	self flush
]

{ #category : 'saving' }
NT2EditorPresenter >> cancelAutosave [

	saveProcess ifNotNil: [ :process |
			saveProcess := nil.
			process terminate ]
]

{ #category : 'initialization' }
NT2EditorPresenter >> connectPresenters [

	textInput whenTextChangedDo: [ self textChanged ].
	modeButton whenChangedDo: [ self updateMode ].
	tagField whenTagsChangedDo: [
			isDirty := true.
			self flush ]
]

{ #category : 'layout' }
NT2EditorPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: tagField expand: false;
		  add: (self isPreview
				   ifTrue: [ preview ]
				   ifFalse: [ textInput ]);
		  add: (SpBoxLayout newLeftToRight
				   spacing: 4;
				   add: statusLabel;
				   add: modeButton expand: false;
				   add: saveButton expand: false;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'saving' }
NT2EditorPresenter >> flush [

	self cancelAutosave.
	self save
]

{ #category : 'testing' }
NT2EditorPresenter >> hasPendingAutosave [

	^ saveProcess notNil
]

{ #category : 'initialization' }
NT2EditorPresenter >> initializePresenters [

	isDirty := false.
	isLoading := false.
	textInput := self newText.
	preview := self newText
		           beNotEditable;
		           yourself.
	tagField := self instantiate: NT2TagFieldPresenter.
	modeButton := self newToggleButton
		              label: 'Preview';
		              yourself.
	saveButton := self newButton
		              label: 'Save';
		              action: [ self flush ];
		              yourself.
	statusLabel := self newLabel.
	self updateEnablement
]

{ #category : 'testing' }
NT2EditorPresenter >> isDirty [

	^ isDirty
]

{ #category : 'testing' }
NT2EditorPresenter >> isPreview [

	^ modeButton state
]

{ #category : 'accessing' }
NT2EditorPresenter >> modeButton [

	^ modeButton
]

{ #category : 'accessing' }
NT2EditorPresenter >> note [

	^ note
]

{ #category : 'accessing' }
NT2EditorPresenter >> note: aNTNote [
	"Show aNTNote, after saving the pending changes of the current note"

	aNTNote == note ifTrue: [ ^ self ].
	self flush.
	note := aNTNote.
	isLoading := true.
	[ textInput text: (note ifNil: [ '' ] ifNotNil: [ note contents ]) ] ensure: [ isLoading := false ].
	tagField note: note.
	isDirty := false.
	self isPreview ifTrue: [ self renderPreview ].
	self updateEnablement.
	self updateStatus
]

{ #category : 'accessing' }
NT2EditorPresenter >> previewText [

	^ preview text
]

{ #category : 'preview' }
NT2EditorPresenter >> renderPreview [

	preview text: (MicRichTextComposer new asRichText: (note ifNil: [ '' ] ifNotNil: [ note contents ]))
]

{ #category : 'saving' }
NT2EditorPresenter >> save [

	note ifNil: [ ^ self ].
	isDirty ifFalse: [ ^ self ].
	((self application isUnsaved: note) and: [ note contents isEmpty and: [ note tags isEmpty ] ]) ifTrue: [ ^ self ].
	self application saveNote: note.
	isDirty := false.
	self updateStatus.
	savedBlock ifNotNil: [ savedBlock value: note ]
]

{ #category : 'saving' }
NT2EditorPresenter >> scheduleAutosave [

	self cancelAutosave.
	saveProcess := [
		               (Delay forSeconds: self autosaveDelay) wait.
		               UIManager default defer: [ self autosaveNow ] ] forkAt: Processor userBackgroundPriority
]

{ #category : 'accessing' }
NT2EditorPresenter >> tagField [

	^ tagField
]

{ #category : 'focus' }
NT2EditorPresenter >> takeKeyboardFocus [

	textInput takeKeyboardFocus
]

{ #category : 'editing' }
NT2EditorPresenter >> textChanged [

	(isLoading or: [ note isNil ]) ifTrue: [ ^ self ].
	note contents: textInput text asString.
	isDirty := true.
	self updateStatus.
	changedBlock ifNotNil: [ changedBlock value: note ].
	self scheduleAutosave
]

{ #category : 'accessing' }
NT2EditorPresenter >> textInput [

	^ textInput
]

{ #category : 'updating' }
NT2EditorPresenter >> updateEnablement [

	textInput enabled: note notNil.
	tagField enabled: note notNil.
	saveButton enabled: note notNil
]

{ #category : 'preview' }
NT2EditorPresenter >> updateMode [

	self isPreview ifTrue: [ self renderPreview ].
	"Rebuilding the layout makes the text widget notify an empty text, then the note text"
	isLoading := true.
	[ self layout: self defaultLayout ] ensure: [ isLoading := false ]
]

{ #category : 'updating' }
NT2EditorPresenter >> updateStatus [

	statusLabel label: (note ifNil: [ '' ] ifNotNil: [
				 isDirty
					 ifTrue: [ 'Unsaved changes' ]
					 ifFalse: [ 'Saved' ] ])
]

{ #category : 'events' }
NT2EditorPresenter >> whenNoteChangedDo: aBlock [

	changedBlock := aBlock
]

{ #category : 'events' }
NT2EditorPresenter >> whenNoteSavedDo: aBlock [

	savedBlock := aBlock
]
