"
Presents a table with basic metadata information about saved notes in the system.

"
Class {
	#name : 'NTSpNoteIndexPresenter',
	#superclass : 'SpPresenterWithModel',
	#instVars : [
		'componentList',
		'searchBar',
		'tagsFilterButton',
		'filteredTagsSelection'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'accessing' }
NTSpNoteIndexPresenter class >> buildCommandsGroupWith: presenterInstance forRoot: rootCommandGroup [

	rootCommandGroup
		register: (self buildNTContextualGroupWith: presenterInstance)
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter class >> buildNTContextualGroupWith: presenterInstance [

	^ (CmCommandGroup named: 'NTSelContextualMenu') asSpecGroup
		register: (self buildNoteTakerOperationsGroupWith: presenterInstance);		
		yourself
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter class >> buildNoteTakerOperationsGroupWith: presenterInstance [

	^ (CmCommandGroup named: 'NoteTakerMenu') asSpecGroup
		  register:
			  (NTSpImportNoteCommand forSpec context: presenterInstance);
		  register:
			  (NTSpRemoveNoteCommand forSpec context: presenterInstance);
		  register: (NTSpAddTagCommand forSpec context: presenterInstance);
		  register:
			  (NTSpRemoveTagCommand forSpec context: presenterInstance);
		  beDisplayedAsGroup;
		  yourself
]

{ #category : 'layout' }
NTSpNoteIndexPresenter >> addNote: aNTNoteObject [

	self model addNote: aNTNoteObject.
	self updatePresenter
]

{ #category : 'initialization' }
NTSpNoteIndexPresenter >> connectPresenters [

	searchBar
		whenTextChangedDo: [ self items: self filter ];
		whenSubmitDo: [ :newNoteName |
				| newNote |
				newNote := self model addNoteNamed: newNoteName.
				newNote folderReference: self application currentFolder.
				self updatePresenter.
				self emptySearchBar.
				self selectNote: newNote ].

	tagsFilterButton whenActivatedDo: [ self items: self filter ]
]

{ #category : 'layout' }
NTSpNoteIndexPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: (SpBoxLayout newLeftToRight
				   add: searchBar;
				   add: tagsFilterButton expand: false;
				   yourself)
		  expand: false;
		  add: componentList;
		  yourself
]

{ #category : 'layout' }
NTSpNoteIndexPresenter >> defaultOutputPort [

	^ SpDropListSelectionPort newPresenter: self
]

{ #category : 'callbacks' }
NTSpNoteIndexPresenter >> emptySearchBar [

	searchBar clearContent
]

{ #category : 'filtering' }
NTSpNoteIndexPresenter >> filter [

	| filteredItems |
	filteredItems := searchBar text
		                 ifEmpty: [ self model notes ]
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

{ #category : 'filtering' }
NTSpNoteIndexPresenter >> filteredNotesFor: aString [

	^ self model notesTitleMatching: aString
]

{ #category : 'filtering' }
NTSpNoteIndexPresenter >> filteredTagsSelection [

	^ filteredTagsSelection
]

{ #category : 'testing' }
NTSpNoteIndexPresenter >> hasSelectedNote [

	^ componentList listSize ~= 0
]

{ #category : 'initialization' }
NTSpNoteIndexPresenter >> initializePresenters [

	searchBar := self newTextInput
		             help: 'Create a note by just typing a name';
		             placeholder: 'Type note to search or create';
		             yourself.

	tagsFilterButton := self newButton
		                    icon: (self iconNamed: #recentMessages);
		                    addStyle: 'small';
		                    action: [ self openTagsSearcher ];
		                    help: 'Tags searcher';
		                    yourself.

	filteredTagsSelection := OrderedCollection new.

	componentList := self instantiate: SpComponentListPresenter.
	componentList beMultipleSelection.

	componentList contextMenu: [
			(self rootCommandsGroup / 'NTSelContextualMenu') beRoot
				asMenuPresenter ]
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> items [
	"Answer a <Collection> of notes"

	^ componentList items collect: [ :each | each note ]
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> items: aCollection [
	"componentList items: aCollection."
	
	aCollection ifNil: [ ^ self ].

	componentList presenters:
		(aCollection collect: [ :each | NTNotePresenter new note: each ])
]

{ #category : 'initialization' }
NTSpNoteIndexPresenter >> modelChanged [

	self model ifNotNil: [self items: self model notes]
]

{ #category : 'callbacks' }
NTSpNoteIndexPresenter >> notes: aNotesCollection withTags: aTagsCollection [
	"Answer a <Collection> of <NTNoteObject> whose names match tags"

	^ self model notes: aNotesCollection withTags: aTagsCollection
]

{ #category : 'opening' }
NTSpNoteIndexPresenter >> openTagsSearcher [

	| selectedItems |
	selectedItems := filteredTagsSelection collect: [ :tag | tag tagName ].

	(NTSpTagSelectionDialog newApplication: self application)
		allowTagCreation;
		title: 'tag name';
		items: (self model tags collect: [ :each | each tagName ]);
		selectedItems: selectedItems;
		display: #asString;
		onAccept: [ :dialog |
				filteredTagsSelection := dialog presenter selectedItems collect: [
						                         :each | self model tagNamed: each ] ];
		openModalWithParent: self window
]

{ #category : 'layout' }
NTSpNoteIndexPresenter >> removeNotes: aNoteCollection [

	self model notes removeAll: aNoteCollection.
	self updatePresenter
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> searchBar [

	^ searchBar
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> selectNote: aNTNoteObject [

	componentList selectItem:
		(componentList items detect: [ :each | each note = aNTNoteObject ])
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> selectedNote [

	^ componentList selectedItem ifNotNil: [ :notePresenter |
		  notePresenter note ]
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> selectedNotes [

	^ componentList selectedItems collect: [ :each | each note ]
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> tagsFilterButton [

	^ tagsFilterButton
]

{ #category : 'callbacks' }
NTSpNoteIndexPresenter >> whenSelectionChangedDo: aBlock [

	componentList whenSelectionChangedDo: aBlock
]
