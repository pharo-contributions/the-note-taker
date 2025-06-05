Class {
	#name : 'NTMDEditorPresenter2',
	#superclass : 'MDEditorPresenter',
	#instVars : [
		'actualNote'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'visiting' }
NTMDEditorPresenter2 >> accept [

	mdFile fileReference writeStreamDo: [ :str |
		str nextPutAll: self text asString ].
	self inform: 'Note ' , mdFile fileReference fullName , ' saved'
]

{ #category : 'accessing' }
NTMDEditorPresenter2 >> actualNote [

	^ actualNote
]

{ #category : 'accessing' }
NTMDEditorPresenter2 >> actualNote: aNoteObject [

	actualNote := aNoteObject.
	textInput text: actualNote contents
]

{ #category : 'private' }
NTMDEditorPresenter2 >> applicationTitle [

	^ self application applicationTitle
]

{ #category : 'display' }
NTMDEditorPresenter2 >> displayContents: aNoteObject [

	actualNote := aNoteObject.
	textInput text: aNoteObject contents asString.
	self renderDocument
]

{ #category : 'initialization' }
NTMDEditorPresenter2 >> initialize [ 

	super initialize.
	self noNote
]

{ #category : 'api' }
NTMDEditorPresenter2 >> initializeMenuBar [

	super initializeMenuBar.

	menu
		addGroup: [ :group | 
			group addItem: [ :item | 
				item
					name: 'Toggle Preview';
					description: 'Show/Hide the preview pane';
					icon: (self iconNamed: #smallInspectIt);
					action: [ self togglePreview ] ] ]
]

{ #category : 'initialization' }
NTMDEditorPresenter2 >> initializePresentersWithText: anInputText [

	super initializePresentersWithText: anInputText.
	textInput
		whenTextChangedDo: [
			self renderDocument.
			actualNote ifNotNil: [
					actualNote contents: textInput text asString ] ];
		bindKeyCombination: $s meta toAction: [ self accept ]
]

{ #category : 'actions' }
NTMDEditorPresenter2 >> newNote: aNoteObject [

	self mdFile: (MDFile new title: aNoteObject title).
	self window ifNotNil: [ self updateTitle ].
	textInput text: self mdFile contents.
	self emptyRenderedText.
	self renderDocument.
	actualNote := aNoteObject.
	actualNote title: self mdFile basename.
	actualNote contents: textInput text
]

{ #category : 'initialization' }
NTMDEditorPresenter2 >> noNote [

	mdFile := MDFile new
]

{ #category : 'actions' }
NTMDEditorPresenter2 >> openNote: aNoteObject [

	self mdFile: (MDFile newFromFileReference: aNoteObject title asFileReference).
	textInput text: aNoteObject contents.
	self emptyRenderedText.
	self window ifNotNil: [self updateTitle].
	self renderDocument.
	actualNote := aNoteObject.
	actualNote contents: self textInputText.
]

{ #category : 'actions' }
NTMDEditorPresenter2 >> saveFile [
	 
	self mdFile hasFile ifFalse: [ self saveFileByItsContents ]. 
	super saveFile
]

{ #category : 'actions' }
NTMDEditorPresenter2 >> saveFileByItsContents [
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

{ #category : 'api' }
NTMDEditorPresenter2 >> title [
	"Answer a <String> representing the application name and selected note title"

	^ String streamContents: [ : stream |
		stream 
			<< self applicationTitle;
			<< self owner selectedNoteTitle ]
]

{ #category : 'callbacks' }
NTMDEditorPresenter2 >> togglePreview [

	renderedText isVisible 
		ifTrue: [ 
			| editorsLayoutPane |
			"textOutput hide."

			editorsLayoutPane := self layout children second.
			editorsLayoutPane remove: #textOutput.
			"editorsLayoutPane replaceFirst: textInput.
			self update" ]
		ifFalse: [ renderedText show ]
]
