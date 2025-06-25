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

{ #category : 'callbacks' }
NTSpSearchCreatePresenter >> emptySearchBar [

	notesSearchCreateTextPresenter clearContent
]

{ #category : 'callbacks' }
NTSpSearchCreatePresenter >> filter [

	| filteredItems |
	filteredItems := notesSearchCreateTextPresenter text
		                 ifEmpty: [
		                 self application noteTakerContainer notes ]
		                 ifNotEmpty: [ :pattern | self filteredNotesFor: pattern ].

	filteredItems := tagsSearchCreateTextPresenter text
		                 ifEmpty: [ filteredItems ]
		                 ifNotEmpty: [ :pattern |
		                 self
			                 filteredTagsFor: pattern
			                 withNotes: filteredItems ].

	^ filteredItems
]

{ #category : 'callbacks' }
NTSpSearchCreatePresenter >> filteredNotesFor: aString [

	^ self application noteTakerContainer notesNameMatching: aString
]

{ #category : 'callbacks' }
NTSpSearchCreatePresenter >> filteredTagsFor: aString withNotes: aNotesCollection [
	"Answer a <Collection> of <NTNoteObject> whose names match aString"

	^ self application noteTakerContainer
		  notesTagsMatching: aString
		  withNotes: aNotesCollection
]

{ #category : 'initialization' }
NTSpSearchCreatePresenter >> initializePresenters [

	notesSearchCreateTextPresenter := self newTextInput
		                                  help:
			                                  'Create a note by just typing a name';
		                                  placeholder:
			                                  'Type note to search or create';
		                                  yourself.

	tagsSearchCreateTextPresenter := self newTextInput
		                                 help:
			                                 'search a tag by just typing a name';
		                                 placeholder: 'Type tag to search';
		                                 yourself.
	noteSettingsButtonPresenter := self newButton
		                               icon:
			                               (self iconNamed: #smallConfiguration);
		                               addStyle: 'small';
		                               action: [ self openTNTSettings ];
		                               help: 'Settings';
		                               yourself.
	logButtonPresenter := self newButton
		                      icon: (self iconNamed: #recentMessages);
		                      addStyle: 'small';
		                      action: [ self openLog ];
		                      help: 'Settings';
		                      yourself
]

{ #category : 'accessing' }
NTSpSearchCreatePresenter >> notesSearchCreateTextPresenter [

	^ notesSearchCreateTextPresenter
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

{ #category : 'accessing' }
NTSpSearchCreatePresenter >> tagsSearchCreateTextPresenter [

	^ tagsSearchCreateTextPresenter
]
