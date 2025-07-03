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
		'tagsSearchButtonPresenter',
		'logButtonPresenter',
		'filteredTagsSelection'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'layout' }
NTSpSearchCreatePresenter >> defaultLayout [

	^ SpBoxLayout newLeftToRight
		  add: notesSearchCreateTextPresenter;
		  add: tagsSearchButtonPresenter expand: false;
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
		                 ifNotEmpty: [ :pattern |
		                 self filteredNotesFor: pattern ].

	filteredItems := filteredTagsSelection
		                 ifEmpty: [ filteredItems ]
		                 ifNotEmpty: [ :pattern |
				                 self
					                 notes: filteredItems
					                 withTags: filteredTagsSelection ].

	^ filteredItems
]

{ #category : 'callbacks' }
NTSpSearchCreatePresenter >> filteredNotesFor: aString [

	^ self application noteTakerContainer notesNameMatching: aString
]

{ #category : 'initialization' }
NTSpSearchCreatePresenter >> filteredTagsSelection [

	^ filteredTagsSelection
]

{ #category : 'initialization' }
NTSpSearchCreatePresenter >> initializePresenters [

	notesSearchCreateTextPresenter := self newTextInput
		                                  help:
			                                  'Create a note by just typing a name';
		                                  placeholder:
			                                  'Type note to search or create';
		                                  yourself.

	tagsSearchButtonPresenter := self newButton
		                             icon: (self iconNamed: #recentMessages);
		                             addStyle: 'small';
		                             action: [ self openTagsSearcher ];
		                             help: 'Tags searcher';
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
		                      help: 'Log';
		                      yourself.
	filteredTagsSelection := OrderedCollection new
]

{ #category : 'callbacks' }
NTSpSearchCreatePresenter >> notes: aNotesCollection withTags: aTagsCollection [
	"Answer a <Collection> of <NTNoteObject> whose names match tags"

	| filteredNotes |
	filteredNotes := Set new.

	aTagsCollection do: [ :tag |
				| notesCollection |
				 notesCollection := self application noteTakerContainer
					 notesTagsMatching: tag tagName
					 withNotes: aNotesCollection.
					filteredNotes addAll: notesCollection ].
				
	^ filteredNotes asOrderedCollection
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

{ #category : 'initialization' }
NTSpSearchCreatePresenter >> openTagsSearcher [
	
	|selectedItems|
	
	selectedItems := filteredTagsSelection collect: [ :tag | tag tagName ].

	(NTSpTagSelectionDialog newApplication: self application)
		title: 'tag name';
		items: (self application noteTakerContainer tags collect: [ :each |
					 each tagName ]);
		selectedItems: selectedItems;
		display: #asString;
		onAccept: [ :dialog |
				filteredTagsSelection := dialog presenter selectedItems collect: [
						                         :each |
						                         self owner noteTakerContainer
							                         tagNamed: each ] ];
		openModalWithParent: owner window
]

{ #category : 'accessing' }
NTSpSearchCreatePresenter >> tagsSearchButtonPresenter [

	^ tagsSearchButtonPresenter
]
