"
A toolbar with a text entry which has two roles when text is typed 

- A search for notes begins always, if any match then matching notes are returned.
- If none matches, then a new note is created after hitting **enter**

"
Class {
	#name : 'NTSpToolBarPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'searchBarPresenter',
		'noteSettingsButtonPresenter',
		'tagsSearchButtonPresenter',
		'logButtonPresenter',
		'cloneGitButtonPresenter',
		'gitSaveButtonPresenter',
		'importFolderButtonPresenter',
		'filteredTagsSelection'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'accessing' }
NTSpToolBarPresenter >> cloneGitButtonPresenter [

	^ cloneGitButtonPresenter
]

{ #category : 'layout' }
NTSpToolBarPresenter >> defaultLayout [

	^ SpBoxLayout newLeftToRight
		  add: searchBarPresenter;
		  add: tagsSearchButtonPresenter expand: false;
		  add: gitSaveButtonPresenter expand: false;
		  add: cloneGitButtonPresenter expand: false;
		  add: importFolderButtonPresenter expand: false;
		  add: noteSettingsButtonPresenter expand: false;
		  add: logButtonPresenter expand: false;
		  yourself
]

{ #category : 'callbacks' }
NTSpToolBarPresenter >> emptySearchBar [

	searchBarPresenter clearContent
]

{ #category : 'callbacks' }
NTSpToolBarPresenter >> filter [

	| filteredItems |
	filteredItems := searchBarPresenter text
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
NTSpToolBarPresenter >> filteredNotesFor: aString [

	^ self application noteTakerContainer notesNameMatching: aString
]

{ #category : 'accessing' }
NTSpToolBarPresenter >> filteredTagsSelection [

	^ filteredTagsSelection
]

{ #category : 'accessing' }
NTSpToolBarPresenter >> gitSaveButtonPresenter [

	^ gitSaveButtonPresenter
]

{ #category : 'accessing' }
NTSpToolBarPresenter >> importFolderButtonPresenter [

	^ importFolderButtonPresenter
]

{ #category : 'initialization' }
NTSpToolBarPresenter >> initializeCloneGitFolder [

	cloneGitButtonPresenter := self newButton
		                           icon: (self iconNamed: #into);
		                           addStyle: 'small';
		                           action: [
				                           NTSpGitCommand new
					                           context: self owner;
					                           clone ];
		                           help: 'Import a new git repository';
		                           yourself
]

{ #category : 'initialization' }
NTSpToolBarPresenter >> initializeGitSave [

	gitSaveButtonPresenter := self newButton
		                          icon: (self iconNamed: #delete);
		                          addStyle: 'small';
		                          action: [ NTSpGitCommand new context: self owner; execute ];
		                          help: 'Push current note folder to github';
		                          yourself
]

{ #category : 'initialization' }
NTSpToolBarPresenter >> initializeImportFolder [

	importFolderButtonPresenter := self newButton
		                               icon: (self iconNamed: #into);
		                               addStyle: 'small';
		                               action: [
				                               NTSpImportFolderCommand new
					                               context: self owner;
					                               execute ];
		                               help: 'Import a new folder';
		                               yourself
]

{ #category : 'initialization' }
NTSpToolBarPresenter >> initializeLogButton [

	logButtonPresenter := self newButton
		                      icon: (self iconNamed: #recentMessages);
		                      addStyle: 'small';
		                      action: [ self openLog ];
		                      help: 'Log';
		                      yourself
]

{ #category : 'initialization' }
NTSpToolBarPresenter >> initializeNoteSettingsButton [

	noteSettingsButtonPresenter := self newButton
		                               icon:
			                               (self iconNamed: #smallConfiguration);
		                               addStyle: 'small';
		                               action: [ self openTNTSettings ];
		                               help: 'Settings';
		                               yourself.
]

{ #category : 'initialization' }
NTSpToolBarPresenter >> initializePresenters [

	searchBarPresenter := self newTextInput
		                                  help:
			                                  'Create a note by just typing a name';
		                                  placeholder:
			                                  'Type note to search or create';
		                                  yourself.
	self initializeTagSearchButton.
	self initializeImportFolder.
	self initializeCloneGitFolder.
	self initializeGitSave.
	self initializeNoteSettingsButton.
	self initializeLogButton.

	filteredTagsSelection := OrderedCollection new
]

{ #category : 'initialization' }
NTSpToolBarPresenter >> initializeTagSearchButton [

	tagsSearchButtonPresenter := self newButton
		                             icon: (self iconNamed: #recentMessages);
		                             addStyle: 'small';
		                             action: [ self openTagsSearcher ];
		                             help: 'Tags searcher';
		                             yourself.
]

{ #category : 'accessing' }
NTSpToolBarPresenter >> logButtonPresenter [

	^ logButtonPresenter
]

{ #category : 'accessing' }
NTSpToolBarPresenter >> noteSettingsButtonPresenter [

	^ noteSettingsButtonPresenter
]

{ #category : 'callbacks' }
NTSpToolBarPresenter >> notes: aNotesCollection withTags: aTagsCollection [
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

{ #category : 'opening' }
NTSpToolBarPresenter >> openLog [

	self application registerWindow: (NTSpLogPresenter openLogOfFolder:
		 self application settings noteLocation) openModal
]

{ #category : 'opening' }
NTSpToolBarPresenter >> openTNTSettings [
	
	SettingBrowser new
		rootNodes: (SettingBrowser currentTree nodeNamed: #tnt) allChildren;
		open
]

{ #category : 'opening' }
NTSpToolBarPresenter >> openTagsSearcher [
	
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
NTSpToolBarPresenter >> searchBarPresenter [

	^ searchBarPresenter
]

{ #category : 'accessing' }
NTSpToolBarPresenter >> tagsSearchButtonPresenter [

	^ tagsSearchButtonPresenter
]
