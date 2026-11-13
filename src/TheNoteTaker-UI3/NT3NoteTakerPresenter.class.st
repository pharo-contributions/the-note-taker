"
I am the note taker window: a search bar on top, the note list on the left and the editor on the right.

## Responsibility:

- I filter the list with the words of the search bar and give them to the editor to highlight.
- On Enter in the search bar I open the note having that title, or create a note with that title and the searched tags.
- With Cmd+T or the list menu 'Tags…', I open `NT3TagsPresenter` to add and remove tags of all the selected notes at once.
- I save the note being edited when another note is selected, when it is hidden by a filter and when I am closed, and I refresh the list when the title, the unsaved mark or the order of a note changes.

## Collaborators:

- `NT3NoteListPresenter`: the list with its tag search bar and mode buttons.
- `NT3NoteEditorPresenter`: the editor, showing the note selected last; `NT3TextQuery`: the search.
- `NT3TagsPresenter` and `NT3TagChoice`: the tags dialog and the choice it edits.
- `NT3Application`: the notes, their saving and creation.

## Public API and Key Messages

- `searchText` / `searchText:`, `clearSearch` (Escape), `openOrCreateNote` (Enter).
- `focusSearch` (Cmd+F anywhere), `focusList` (Down in the search bar); Enter in the list goes to the editor.
- `editTagsOfSelectedNotes` (Cmd+T), `tagChoiceForSelectedNotes`, `applyTagChoice:`, `tagsAction`.
- `noteList`, `editor`, `searchInput`.

```
NT3NoteTakerPresenter example open
```

## Internal Representation

- `searchInput`: an `SpSearchInputFieldPresenter`; `noteList`, `editor`: my two panes.
- `tagsAction`: the `SpAction` of the list (context menu and Cmd+T), enabled when notes are selected.
- `listedState`: the title and unsaved mark of the edited note as the list shows them, to refresh it only when they change.
"
Class {
	#name : 'NT3NoteTakerPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'searchInput',
		'noteList',
		'editor',
		'listedState',
		'tagsAction'
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

{ #category : 'tags' }
NT3NoteTakerPresenter >> applyTagChoice: aTagChoice [
	"Add and remove the tags of the notes of aTagChoice and save them; the list and the editor show the new tags"

	self application tagNotes: aTagChoice notes adding: aTagChoice addedTagNames removing: aTagChoice removedTagNames
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

{ #category : 'tags' }
NT3NoteTakerPresenter >> editTagsOfSelectedNotes [
	"Open the dialog to check and uncheck the tags of the selected notes; Apply changes the notes"

	| choice |
	noteList selectedNotes ifEmpty: [ ^ self ].
	choice := self tagChoiceForSelectedNotes.
	(self application instantiate: NT3TagsPresenter on: choice) openDialog okAction: [ self applyTagChoice: choice ]
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
	tagsAction := SpAction new
		              name: 'Tags…';
		              description: 'Add or remove tags of the selected notes';
		              shortcutKey: $t actionModifier;
		              action: [ self editTagsOfSelectedNotes ];
		              actionEnabled: [ noteList selectedNotes isNotEmpty ];
		              yourself.
	noteList noteList addAction: tagsAction.
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

{ #category : 'tags' }
NT3NoteTakerPresenter >> tagChoiceForSelectedNotes [
	"Answer the choice of tags for the selected notes, offering the tags of all the notes"

	^ NT3TagChoice notes: noteList selectedNotes tagNames: self application tagNames
]

{ #category : 'accessing' }
NT3NoteTakerPresenter >> tagsAction [

	^ tagsAction
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
