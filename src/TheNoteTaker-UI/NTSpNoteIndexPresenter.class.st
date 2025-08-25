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

	aNTNoteObject folderReference: self application currentFolder.
	self model addNote: aNTNoteObject.
	self updatePresenter.
	self selectNote: aNTNoteObject.
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> componentListCount [

	^ componentList listSize
]

{ #category : 'initialization' }
NTSpNoteIndexPresenter >> connectPresenters [

	searchBar
		whenTextChangedDo: [ self filter ];
		whenSubmitDo: [ :newNoteName |
				| newNote |
				newNote := self model addNoteNamed: newNoteName.
				newNote folderReference: self application currentFolder.
				searchBar clearContent.
				self selectNote: newNote ].

	tagsFilterButton whenActivatedDo: [ self filter ]
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

{ #category : 'filtering' }
NTSpNoteIndexPresenter >> filter [

	| filteredItems |
	filteredItems := searchBar text
		                 ifEmpty: [ self notes ]
		                 ifNotEmpty: [ :pattern |
		                 self model notesContentsMatching: pattern ].

	filteredItems := filteredTagsSelection
		                 ifEmpty: [ filteredItems ]
		                 ifNotEmpty: [ :pattern |
			                 self model
				                 notes: filteredItems
				                 withTags: filteredTagsSelection ].

	self items: filteredItems
]

{ #category : 'filtering' }
NTSpNoteIndexPresenter >> filteredTagsSelection [

	^ filteredTagsSelection
]

{ #category : 'testing' }
NTSpNoteIndexPresenter >> hasSelectedNote [

	^ componentList selectedItems isNotEmpty
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
	componentList
		beMultipleSelection;
		sortingBlock: [ :a :b |
			a note modificationDate > b note modificationDate ];
		addShortcutWith: [ :action |
				action
					shortcutKey: KeyboardKey delete;
					action: [
							NTSpRemoveNoteCommand new
								context: self;
								execute ] ];
		contextMenu: [
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

	self model ifNotNil: [ self items: self notes ]
]

{ #category : 'opening' }
NTSpNoteIndexPresenter >> notes [

	^ self model notes
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
						                         :each | self model ensureTagNamed: each ] ];
		openModalWithParent: self window
]

{ #category : 'accessing' }
NTSpNoteIndexPresenter >> refreshSelectedItem [

	componentList selectedItem ifNotNil: [ :item | item updatePresenter ]
]

{ #category : 'layout' }
NTSpNoteIndexPresenter >> removeNotes: aNoteCollection [

	self notes removeAll: aNoteCollection.
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
