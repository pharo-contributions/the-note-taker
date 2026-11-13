"
I show a list of notes in one of three modes, with a tag search bar and the mode buttons below the list, followed by the `#` button that shows or hides the tags in the rows.

## Responsibility:

- I list the notes by date (month separators), by tag (one group per tag, then ""No tag"") or titles only, as my `NT3ListMode` says.
- I filter the notes by the exact tag names typed in the search bar (several names: any of them), completing tag names.
- I let several notes be selected (Cmd-click, Shift-click) and know which one was selected last, the one to show in the editor. A separator cannot be selected alone, and the selection survives mode and filter changes for the notes still listed; the last selected note hidden by a filter is selected again once it is listed again.

## Collaborators:

- `NT3ListMode` builds my rows; `NT3TagQuery` reads the search text.
- `NT3NoteRowPresenter` shows each row of my `SpEasyListViewPresenter`.
- `NT3Application` remembers my mode.

## Public API and Key Messages

- `notes:` sets the notes; `refresh` after a note changed (I do not track changes).
- `mode` / `mode:`; the buttons and Cmd+1/2/3 also change it.
- `showsTags` / `showsTags:`, also changed by the `#` button (`tagsButton`), which is disabled in titles only mode; the application remembers it for the session.
- `selectedNotes`; `selectedNote` (the note selected last), `selectNote:` (selects only that note), `selectFirstNote`, `whenNoteSelectedDo:` (the block receives the note selected last, or nil, when it changes).
- `isUnsaved:` (asked to the application): unsaved notes show a bullet before their title.
- `tagSearchText:`, `clearTagSearch` (Escape), `submitTagSearch` (Enter).

```
(NT3NoteListPresenter newApplication: NT3Application new)
	notes: NT3Application sampleNotes;
	open
```

## Internal Representation

- `noteList`: an `SpEasyListViewPresenter` whose items are notes and `NT3ListSeparator`s.
- `tagSearchInput`, `modeButtons` (toggle buttons in the order of `NT3ListMode modes`), `tagsButton` (a toggle button).
- `currentNote`: the note selected last; `lastSelectedIndex`: its row; `selectedIndexes`: the selected rows, to find the rows the user just added.
- `isAdjustingSelection`: to change the selection without reacting to it.
- `hiddenNote`: the selected note that a filter hides, to select it again.
- `textBeforeCompletion`: the search text when the completion list opened.

### Implementation Points

The list ignores selection changes made while it announces one, so moving off a separator is done with `defer:`.
"
Class {
	#name : 'NT3NoteListPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'noteList',
		'tagSearchInput',
		'modeButtons',
		'notes',
		'mode',
		'noteSelectedBlocks',
		'lastSelectedIndex',
		'isAdjustingSelection',
		'textBeforeCompletion',
		'hiddenNote',
		'selectedIndexes',
		'currentNote',
		'tagsButton'
	],
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'examples' }
NT3NoteListPresenter class >> example [
	"A note list on the sample notes, not opened"

	<sampleInstance>
	^ (self newApplication: NT3Application new)
		  notes: NT3Application sampleNotes;
		  yourself
]

{ #category : 'examples' }
NT3NoteListPresenter class >> scriptOpen [
	"Open the note list on the sample notes"

	<example>
	self example open
]

{ #category : 'private' }
NT3NoteListPresenter >> adjustingSelectionDo: aBlock [
	"Change the list selection without reacting to it"

	isAdjustingSelection := true.
	aBlock ensure: [ isAdjustingSelection := false ]
]

{ #category : 'private' }
NT3NoteListPresenter >> announceSelectedNote [

	| note |
	note := self selectedNote.
	noteSelectedBlocks do: [ :each | each cull: note ]
]

{ #category : 'tag search' }
NT3NoteListPresenter >> clearTagSearch [

	self tagSearchText: ''
]

{ #category : 'private' }
NT3NoteListPresenter >> configureRow: aRowPresenter [
	"Tell a new row how the list shows the notes"

	aRowPresenter
		showsDetails: mode showsDetails;
		showsTags: self showsTags;
		isUnsavedBlock: [ :note | self isUnsaved: note ]
]

{ #category : 'initialization' }
NT3NoteListPresenter >> connectModes [
	"Each mode button, and Cmd+1/2/3 in the list, switch to its mode"

	NT3ListMode modes doWithIndex: [ :each :index |
		(modeButtons at: index) whenActivatedDo: [ self mode: each ].
		noteList addShortcutWith: [ :action |
			action
				shortcutKey: (Character digitValue: index) actionModifier;
				action: [ self mode: each ] ] ]
]

{ #category : 'initialization' }
NT3NoteListPresenter >> connectPresenters [

	noteList
		whenRowPresenterInstantiatedDo: [ :row | self configureRow: row ];
		whenSelectionChangedDo: [ self noteListSelectionChanged ].
	tagsButton whenChangedDo: [ :state | self showsTags: state ].
	self
		connectModes;
		connectTagSearch
]

{ #category : 'initialization' }
NT3NoteListPresenter >> connectTagSearch [

	tagSearchInput
		whenTextChangedDo: [ self refresh ];
		whenSubmitDo: [ :text | self submitTagSearch ];
		addShortcutWith: [ :action |
			action
				shortcutKey: KeyboardKey escape asKeyCombination;
				action: [ self clearTagSearch ] ]
]

{ #category : 'layout' }
NT3NoteListPresenter >> defaultLayout [

	| buttons |
	buttons := SpBoxLayout newLeftToRight
		           spacing: 2;
		           yourself.
	modeButtons do: [ :each | buttons add: each expand: false ].
	buttons addLast: tagsButton expand: false.
	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: noteList;
		  add: tagSearchInput expand: false;
		  add: buttons expand: false;
		  yourself
]

{ #category : 'accessing' }
NT3NoteListPresenter >> entries [
	"Answer the rows currently listed: notes and separators"

	^ noteList items
]

{ #category : 'initialization' }
NT3NoteListPresenter >> initializePresenters [

	notes := #(  ).
	noteSelectedBlocks := OrderedCollection new.
	lastSelectedIndex := 0.
	selectedIndexes := #(  ).
	isAdjustingSelection := false.
	textBeforeCompletion := ''.
	mode := self application listMode.
	noteList := self newEasyListView
		            rowPresenterClass: NT3NoteRowPresenter;
		            beMultipleSelection;
		            yourself.
	tagSearchInput := self newTextInput
		                  placeholder: 'Tags, e.g. pharo spec';
		                  entryCompletion: self tagCompletion;
		                  yourself.
	modeButtons := NT3ListMode modes collect: [ :each |
			               self newToggleButton
				               icon: (self iconNamed: each iconName);
				               help: each help;
				               yourself ].
	modeButtons first associatedToggleButtons: modeButtons allButFirst.
	tagsButton := self newToggleButton
		              label: '#';
		              help: 'Show tags';
		              state: self application showsTags;
		              yourself.
	self updateModeButtons
]

{ #category : 'initialization' }
NT3NoteListPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Notes';
		initialExtent: 320 @ 560
]

{ #category : 'testing' }
NT3NoteListPresenter >> isUnsaved: aNote [

	^ self application isUnsaved: aNote
]

{ #category : 'private' }
NT3NoteListPresenter >> keepCurrentNoteAmong: indexes [
	"Notes were only unselected: keep the current note when still selected, otherwise take the last selected one"

	| noteIndexes |
	noteIndexes := indexes asArray sort select: [ :each | (noteList items at: each) isNote ].
	noteIndexes ifEmpty: [
			lastSelectedIndex := 0.
			^ currentNote := nil ].
	lastSelectedIndex := noteIndexes detect: [ :each | (noteList items at: each) == currentNote ] ifNone: [ noteIndexes last ].
	currentNote := noteList items at: lastSelectedIndex
]

{ #category : 'accessing' }
NT3NoteListPresenter >> mode [

	^ mode
]

{ #category : 'accessing' }
NT3NoteListPresenter >> mode: aListMode [
	"Show the notes as aListMode says; the application remembers it for the session"

	aListMode class = mode class ifTrue: [ ^ self ].
	mode := aListMode.
	self application listMode: aListMode.
	self updateModeButtons.
	self refresh
]

{ #category : 'accessing - presenters' }
NT3NoteListPresenter >> modeButtons [

	^ modeButtons
]

{ #category : 'private' }
NT3NoteListPresenter >> noteIndexMovingFrom: previousIndex to: separatorIndex [
	"Answer the index of the note to select instead of the separator at separatorIndex"

	| entries step index |
	(separatorIndex - previousIndex) abs = 1 ifFalse: [ ^ previousIndex ].
	entries := noteList items.
	step := separatorIndex - previousIndex.
	index := separatorIndex.
	[ index between: 1 and: entries size ] whileTrue: [
			(entries at: index) isNote ifTrue: [ ^ index ].
			index := index + step ].
	^ previousIndex
]

{ #category : 'accessing - presenters' }
NT3NoteListPresenter >> noteList [

	^ noteList
]

{ #category : 'private' }
NT3NoteListPresenter >> noteListSelectionChanged [
	"Separators cannot be selected alone: see separatorSelectedAt:.
	Otherwise the selected note becomes the note the user just added to the selection, or stays the same when still selected"

	| indexes added previous |
	isAdjustingSelection ifTrue: [ ^ self ].
	indexes := noteList selection selectedIndexes asArray.
	(indexes size = 1 and: [ (noteList items at: indexes first) isNote not ]) ifTrue: [ ^ self separatorSelectedAt: indexes first ].
	added := indexes select: [ :each | (selectedIndexes includes: each) not and: [ (noteList items at: each) isNote ] ].
	selectedIndexes := indexes.
	previous := currentNote.
	added
		ifEmpty: [ self keepCurrentNoteAmong: indexes ]
		ifNotEmpty: [ "the row farthest from the previous one is the clicked row of a Shift-click range"
				lastSelectedIndex := added detectMax: [ :each | (each - lastSelectedIndex) abs ].
				currentNote := noteList items at: lastSelectedIndex ].
	currentNote == previous ifFalse: [ self announceSelectedNote ]
]

{ #category : 'accessing' }
NT3NoteListPresenter >> notes: aCollectionOfNotes [
	"Set the notes to list. The list does not track their changes: send refresh after a change"

	notes := aCollectionOfNotes.
	self refresh
]

{ #category : 'updating' }
NT3NoteListPresenter >> refresh [
	"Rebuild the rows from the notes, the mode and the searched tags, keeping the selected notes that are still listed.
	A selected note that a filter hides is remembered and selected again once it is listed again"

	| previous selected entries kept |
	previous := currentNote.
	selected := previous ifNil: [ hiddenNote ].
	kept := self selectedNotes.
	selected ifNotNil: [ kept := kept copyWith: selected ].
	entries := mode entriesFor: notes searchedTagNames: self tagQuery searchedTagNames.
	hiddenNote := (selected isNotNil and: [ (entries includes: selected) not ]) ifTrue: [ selected ].
	currentNote := hiddenNote ifNil: [ selected ] ifNotNil: [ nil ].
	self showEntries: entries selecting: kept.
	currentNote == previous ifFalse: [ self announceSelectedNote ]
]

{ #category : 'selection' }
NT3NoteListPresenter >> selectFirstNote [
	"Select the first listed note, unless a note is already selected"

	self selectedNote ifNotNil: [ ^ self ].
	noteList items
		detect: [ :each | each isNote ]
		ifFound: [ :note | self selectNote: note ]
]

{ #category : 'selection' }
NT3NoteListPresenter >> selectNote: aNote [
	"Select only the first row of aNote, when it is listed"

	| index |
	index := noteList items indexOf: aNote.
	index > 0 ifTrue: [ noteList selectIndexes: { index } ]
]

{ #category : 'selection' }
NT3NoteListPresenter >> selectedNote [
	"Answer the note the user selected last among the selected ones: the note shown in the editor"

	^ currentNote
]

{ #category : 'selection' }
NT3NoteListPresenter >> selectedNotes [
	"Answer the selected notes in the order of the list, each once even when it is listed several times"

	^ ((noteList selection selectedIndexes asArray sort collect: [ :each | noteList items at: each ]) select: [ :each | each isNote ])
		  asOrderedCollection removeDuplicates
]

{ #category : 'private' }
NT3NoteListPresenter >> separatorSelectedAt: separatorIndex [
	"A move by one row onto a separator goes on to the next note in that direction,
	any other selection of a separator (a click) restores the previous selection.
	The list ignores selection changes made while it announces one, so the correction is deferred"

	| previousIndex previousIndexes target |
	previousIndex := lastSelectedIndex.
	previousIndexes := selectedIndexes.
	target := self noteIndexMovingFrom: previousIndex to: separatorIndex.
	self defer: [
			self adjustingSelectionDo: [
					noteList selectIndexes: (target = previousIndex
							 ifTrue: [ previousIndexes ]
							 ifFalse: [ { target } ]) ].
			selectedIndexes := noteList selection selectedIndexes asArray.
			target = previousIndex ifFalse: [
					lastSelectedIndex := target.
					currentNote := noteList items at: target.
					self announceSelectedNote ] ]
]

{ #category : 'private' }
NT3NoteListPresenter >> showEntries: entries selecting: aCollectionOfNotes [
	"List entries and select the first row of each note of aCollectionOfNotes that is listed, without reacting to it"

	self adjustingSelectionDo: [
			noteList items: entries.
			noteList selectIndexes:
				((aCollectionOfNotes collect: [ :each | entries indexOf: each ]) reject: [ :each | each = 0 ]) asSet asArray sort ].
	selectedIndexes := noteList selection selectedIndexes asArray.
	lastSelectedIndex := currentNote ifNil: [ 0 ] ifNotNil: [ entries indexOf: currentNote ]
]

{ #category : 'accessing' }
NT3NoteListPresenter >> showsTags [
	"Answer whether the rows show the first tags of the notes; the application keeps it for the session"

	^ self application showsTags
]

{ #category : 'accessing' }
NT3NoteListPresenter >> showsTags: aBoolean [

	aBoolean = self showsTags ifTrue: [ ^ self ].
	self application showsTags: aBoolean.
	tagsButton state: aBoolean.
	self refresh
]

{ #category : 'tag search' }
NT3NoteListPresenter >> submitTagSearch [
	"Enter completes the word being typed, so that it is searched even when no tag has that name"

	| text |
	text := self tagSearchText.
	(text isEmpty or: [ text last isSeparator ]) ifTrue: [ ^ self ].
	self tagSearchText: (text copyWith: Character space)
]

{ #category : 'initialization' }
NT3NoteListPresenter >> tagCompletion [
	"Complete the tag being typed from the tags of the notes, keeping the tags already typed"

	^ EntryCompletion new
		  dataSourceBlock: [ :text |
				  textBeforeCompletion := text.
				  (self tagQueryOn: text) completions ];
		  filterBlock: [ :tagName :text | true ];
		  chooseBlock: [ :tagName | self tagSearchText: ((self tagQueryOn: textBeforeCompletion) textCompletedWith: tagName) ];
		  yourself
]

{ #category : 'tag search' }
NT3NoteListPresenter >> tagNames [
	"Answer the names of the tags of the listed notes, alphabetically ignoring case"

	^ (notes flatCollect: [ :note | note tags collect: [ :tag | tag tagName ] ]) asSet asArray sort: [ :a :b |
		  a asLowercase <= b asLowercase ]
]

{ #category : 'tag search' }
NT3NoteListPresenter >> tagQuery [

	^ self tagQueryOn: self tagSearchText
]

{ #category : 'tag search' }
NT3NoteListPresenter >> tagQueryOn: aString [

	^ NT3TagQuery text: aString existingTagNames: self tagNames
]

{ #category : 'accessing' }
NT3NoteListPresenter >> tagSearchInput [

	^ tagSearchInput
]

{ #category : 'tag search' }
NT3NoteListPresenter >> tagSearchText [

	^ tagSearchInput text
]

{ #category : 'tag search' }
NT3NoteListPresenter >> tagSearchText: aString [

	tagSearchInput text: aString
]

{ #category : 'accessing - presenters' }
NT3NoteListPresenter >> tagsButton [

	^ tagsButton
]

{ #category : 'private' }
NT3NoteListPresenter >> updateModeButtons [
	"Show the current mode; the tags button is disabled in the mode without detail line, but keeps its state"

	NT3ListMode modes with: modeButtons do: [ :each :button | button state: each class = mode class ].
	tagsButton enabled: mode showsDetails
]

{ #category : 'selection' }
NT3NoteListPresenter >> whenNoteSelectedDo: aBlock [
	"aBlock receives the selected note, or nil when no note is selected any more"

	noteSelectedBlocks add: aBlock
]
