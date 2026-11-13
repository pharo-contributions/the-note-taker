"
I am the note taker window: a search bar on top, the note list on the left and the editor on the right.

## Responsibility:

- I filter the list with the words of the search bar and give them to the editor to highlight.
- On Enter in the search bar I open the note having that title, or create a note with that title and the searched tags.
- I save the note being edited when another note is selected, when it is hidden by a filter and when I am closed, and I refresh the list when the title, the unsaved mark or the order of a note changes.

## Collaborators:

- `NT3NoteListPresenter`: the list with its tag search bar and mode buttons.
- `NT3NoteEditorPresenter`: the editor; `NT3TextQuery`: the search.
- `NT3Application`: the notes, their saving and creation.

## Public API and Key Messages

- `searchText` / `searchText:`, `clearSearch` (Escape), `openOrCreateNote` (Enter).
- `focusSearch` (Cmd+F anywhere), `focusList` (Down in the search bar); Enter in the list goes to the editor.
- `noteList`, `editor`, `searchInput`.

```
NT3NoteTakerPresenter example open
```

## Internal Representation

- `searchInput`: an `SpSearchInputFieldPresenter`; `noteList`, `editor`: my two panes.
- `listedState`: the title and unsaved mark of the edited note as the list shows them, to refresh it only when they change.
"
Class {
	#name : 'NT3NoteTakerPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'searchInput',
		'noteList',
		'editor',
		'listedState'
	],
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'examples' }
NT3NoteTakerPresenter class >> example [
	"A note taker on the sample notes, kept in memory"

	<sampleInstance>
	^ self newApplication: NT3Application example
]

{ #category : 'examples' }
NT3NoteTakerPresenter class >> scriptOpen [
	"Open the note taker on the sample notes, kept in memory"

	<example>
	^ self example open
]

{ #category : 'search' }
NT3NoteTakerPresenter >> clearSearch [

	self searchText: ''
]

{ #category : 'initialization' }
NT3NoteTakerPresenter >> connectFocus [
	"Cmd+F goes back to the search bar from anywhere; Tab goes from the search bar to the list, the tag bar and the editor"

	{ noteList noteList. noteList tagSearchInput. editor textEditor } do: [ :each |
		self on: each key: $f actionModifier do: [ self focusSearch ] ].
	self focusOrder
		removeAll;
		add: searchInput;
		add: noteList noteList;
		add: noteList tagSearchInput;
		add: editor textEditor
]

{ #category : 'initialization' }
NT3NoteTakerPresenter >> connectPanes [

	noteList whenNoteSelectedDo: [ :note | self noteSelected: note ].
	"deferred, so that the key press that activated the row is not typed into the editor"
	noteList noteList whenActivatedDo: [ :selection | self defer: [ editor textEditor takeKeyboardFocus ] ].
	editor whenNoteEditedDo: [ :note | self noteEdited: note ].
	self application whenNoteSavedDo: [ :note | self noteSaved: note ]
]

{ #category : 'initialization' }
NT3NoteTakerPresenter >> connectPresenters [

	self
		connectSearch;
		connectPanes;
		connectFocus
]

{ #category : 'initialization' }
NT3NoteTakerPresenter >> connectSearch [

	searchInput
		whenTextChangedDo: [ self updateSearch ];
		whenSubmitDo: [ :text | self openOrCreateNote ].
	self
		on: searchInput key: KeyboardKey escape asKeyCombination do: [ self clearSearch ];
		on: searchInput key: KeyboardKey down asKeyCombination do: [ self focusList ];
		on: searchInput key: $g actionModifier do: [ editor selectNextMatch ];
		on: searchInput key: $g shift actionModifier do: [ editor selectPreviousMatch ]
]

{ #category : 'actions' }
NT3NoteTakerPresenter >> createNoteTitled: aString [
	"Create the note, show all the notes again and put the cursor on the line after the title"

	| note |
	note := self application newNoteTitled: aString tagNames: noteList tagQuery searchedTagNames.
	self clearSearch.
	noteList selectNote: note.
	editor textEditor
		selectionInterval: (note contents size + 1 to: note contents size);
		takeKeyboardFocus
]

{ #category : 'layout' }
NT3NoteTakerPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: searchInput expand: false;
		  add: (SpPanedLayout newLeftToRight
				   positionOfSlider: 30 percent;
				   add: noteList;
				   add: editor;
				   yourself);
		  yourself
]

{ #category : 'accessing' }
NT3NoteTakerPresenter >> editor [

	^ editor
]

{ #category : 'focus' }
NT3NoteTakerPresenter >> focusList [

	noteList selectFirstNote.
	noteList noteList takeKeyboardFocus
]

{ #category : 'focus' }
NT3NoteTakerPresenter >> focusSearch [

	searchInput
		takeKeyboardFocus;
		selectAll
]

{ #category : 'initialization' }
NT3NoteTakerPresenter >> initializePresenters [

	searchInput := self newSearchInput
		               placeholder: 'Search, or Enter to create a note';
		               yourself.
	noteList := self instantiate: NT3NoteListPresenter.
	editor := self instantiate: NT3NoteEditorPresenter.
	self updateSearch
]

{ #category : 'initialization' }
NT3NoteTakerPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Notes';
		initialExtent: 1000 @ 650;
		whenOpenedDo: [ self focusSearch ];
		whenClosedDo: [ self windowClosed ]
]

{ #category : 'private' }
NT3NoteTakerPresenter >> listedStateOf: aNote [
	"Answer what the list shows of aNote that editing can change"

	^ aNote ifNotNil: [ { aNote displayTitle. self application isUnsaved: aNote } ]
]

{ #category : 'events' }
NT3NoteTakerPresenter >> noteEdited: aNote [
	"Refresh the list only when what it shows of the note changed: its title or its unsaved bullet"

	| state |
	state := self listedStateOf: aNote.
	state = listedState ifTrue: [ ^ self ].
	listedState := state.
	noteList refresh
]

{ #category : 'accessing' }
NT3NoteTakerPresenter >> noteList [

	^ noteList
]

{ #category : 'events' }
NT3NoteTakerPresenter >> noteSaved: aNote [

	listedState := self listedStateOf: editor note.
	noteList refresh.
	editor updateInfo
]

{ #category : 'events' }
NT3NoteTakerPresenter >> noteSelected: aNote [
	"Save the note being edited before showing aNote (nil when no note is selected)"

	editor note ifNotNil: [ :previous | self application saveNote: previous ].
	editor note: aNote.
	listedState := self listedStateOf: aNote
]

{ #category : 'private' }
NT3NoteTakerPresenter >> on: aPresenter key: aKeyCombination do: aBlock [

	aPresenter addShortcutWith: [ :action |
		action
			shortcutKey: aKeyCombination;
			action: aBlock ]
]

{ #category : 'actions' }
NT3NoteTakerPresenter >> openOrCreateNote [
	"Select the note whose title is the searched text, or create a note with that title and the searched tags"

	| title note |
	title := self searchText trimBoth.
	title ifEmpty: [ ^ self ].
	note := self application container notes
		        detect: [ :each | each displayTitle asLowercase = title asLowercase ]
		        ifNone: [ ^ self createNoteTitled: title ].
	noteList selectNote: note.
	editor textEditor takeKeyboardFocus
]

{ #category : 'accessing' }
NT3NoteTakerPresenter >> searchInput [

	^ searchInput
]

{ #category : 'search' }
NT3NoteTakerPresenter >> searchText [

	^ searchInput text
]

{ #category : 'search' }
NT3NoteTakerPresenter >> searchText: aString [

	searchInput text: aString
]

{ #category : 'search' }
NT3NoteTakerPresenter >> textQuery [

	^ NT3TextQuery text: self searchText
]

{ #category : 'search' }
NT3NoteTakerPresenter >> updateSearch [
	"List the notes matching the text search and highlight its words in the editor"

	| query |
	query := self textQuery.
	editor textQuery: query.
	noteList notes: (self application container notes select: [ :each | query matches: each ])
]

{ #category : 'events' }
NT3NoteTakerPresenter >> windowClosed [

	self application saveAll
]
