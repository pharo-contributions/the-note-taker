"
A toolbar with a text entry which has two roles when text is typed 

- A search for notes begins always, if any match then matching notes are returned.
- If none matches, then a new note is created after hitting **enter**

"
Class {
	#name : 'NTSpSearchCreatePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'notesSearchCreateTextPresenter',
		'model',
		'noteSettingsButtonPresenter',
		'tagsSearchCreateTextPresenter',
		'logButtonPresenter'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'layout' }
NTSpSearchCreatePresenter >> defaultLayout [

	^ SpBoxLayout newLeftToRight
		  add: notesSearchCreateTextPresenter;
		  add: tagsSearchCreateTextPresenter;
		  add: noteSettingsButtonPresenter expand: false;
		  add: logButtonPresenter expand: false;
		  yourself
]

{ #category : 'accessing' }
NTSpSearchCreatePresenter >> editorPresenter [
	"Answer the receiver's MicroDown editor"

	^ self owner editorPresenter
]

{ #category : 'callbacks' }
NTSpSearchCreatePresenter >> filteredNotesFor: aString [
	"Answer a <Collection> of <NTNoteObject> whose names match aString"
	
	"| pattern |
	self halt.
	pattern := '*', aString , '*'.
	^ self notes select: [ :note | pattern match: note title ]"
	
	^ self model notesNameMatching: aString 
]

{ #category : 'callbacks' }
NTSpSearchCreatePresenter >> filteredTagsFor: aString withNotes: aNotesCollection [
	"Answer a <Collection> of <NTNoteObject> whose names match aString"

	| pattern |
	pattern := '*' , aString , '*'.
	^ aNotesCollection select: [ :n | (n tags select: [ :t | pattern match: t tagName ]) notEmpty]
]

{ #category : 'initialization' }
NTSpSearchCreatePresenter >> initializePresenters [

	notesSearchCreateTextPresenter := self newTextInput
		                                  help:
			                                  'Create a note by just typing a name';
		                                  placeholder:
			                                  'Type note to search or create';
		                                  whenTextChangedDo: [
			                                  self updateNotesList ];
		                                  whenSubmitDo: [ :newNoteName |
			                                  self requestNewNoteNamed:
					                                  newNoteName ];
		                                  yourself.
	tagsSearchCreateTextPresenter := self newTextInput
		                                 help:
			                                 'search a tag by just typing a name';
		                                 placeholder: 'Type tag to search';
		                                 whenTextChangedDo: [
			                                 self updateNotesList ];
		                                 yourself.
	noteSettingsButtonPresenter := self newButton
		                               icon:
			                               (self iconNamed: #smallConfiguration);
		                               addStyle: 'small';
		                               action: [ self openTNTSettings ];
		                               help: 'Settings';
		                               yourself.
	.
	logButtonPresenter := self newButton
		                      icon: (self iconNamed: #recentMessages);
		                      addStyle: 'small';
		                      action: [ self openLog ];
		                      help: 'Settings';
		                      yourself
]

{ #category : 'accessing' }
NTSpSearchCreatePresenter >> model [

	^ model
]

{ #category : 'callbacks' }
NTSpSearchCreatePresenter >> notes [
	"Answer a <Collection> of <NTNoteObject> representing all the application's notes"

	^ self model notes
]

{ #category : 'callbacks' }
NTSpSearchCreatePresenter >> notesList [
	"Answer the <NTSpNoteIndexPresenter> responsible to display the notes"

	^ self owner notesIndexPresenter
]

{ #category : 'initialization' }
NTSpSearchCreatePresenter >> openLog [

	NTSpLogPresenter new open
]

{ #category : 'initialization' }
NTSpSearchCreatePresenter >> openTNTSettings [
	
	SettingBrowser new
		rootNodes: (SettingBrowser currentTree nodeNamed: #tnt) allChildren;
		open
]

{ #category : 'as yet unclassified' }
NTSpSearchCreatePresenter >> requestNewNoteNamed: aString [

	| newNote |
	"(self confirm: 'Do you want to create a new note named: ' , aString)
		ifFalse: [ ^ self ].
	(self model isValidNoteName: aString) ifFalse: [ ^ self ]."
	newNote := self application addNoteNamed: aString.
	self updateNotesList.
	self notesList selectNote: newNote.

	self editorPresenter takeKeyboardFocus
]

{ #category : 'accessing - model' }
NTSpSearchCreatePresenter >> setModelBeforeInitialization: aNotesObject [

	model := aNotesObject
]

{ #category : 'callbacks' }
NTSpSearchCreatePresenter >> updateNotesList [

	| filteredItems |
	filteredItems := notesSearchCreateTextPresenter text
		                 ifEmpty: [ self notes ]
		                 ifNotEmpty: [ :pattern |
		                 self filteredNotesFor: pattern ].

	filteredItems := tagsSearchCreateTextPresenter text
		                 ifEmpty: [ filteredItems ]
		                 ifNotEmpty: [ :pattern |
		                 self filteredTagsFor: pattern withNotes: filteredItems ].

	self notesList items: filteredItems.
	filteredItems isNotEmpty ifTrue: [
		self notesList selectNote: filteredItems first ]
]
