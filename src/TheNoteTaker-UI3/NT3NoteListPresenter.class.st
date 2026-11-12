"
I show a list of notes in one of three modes, with a tag search bar and the mode buttons below the list.

## Responsibility:

- I list the notes by date (month separators), by tag (one group per tag, then ""No tag"") or titles only, as my `NT3ListMode` says.
- I filter the notes by the exact tag names typed in the search bar (several names: any of them), completing tag names.
- I keep one note selected: separators cannot be selected, and the selection survives mode and filter changes when the note is still listed; a selected note hidden by a filter is selected again once it is listed again.

## Collaborators:

- `NT3ListMode` builds my rows; `NT3TagQuery` reads the search text.
- `NT3NoteRowPresenter` shows each row of my `SpEasyListViewPresenter`.
- `NT3Application` remembers my mode.

## Public API and Key Messages

- `notes:` sets the notes; `refresh` after a note changed (I do not track changes).
- `mode` / `mode:`; the buttons and Cmd+1/2/3 also change it.
- `selectedNote`, `selectNote:`, `selectFirstNote`, `whenNoteSelectedDo:` (the block receives the note, or nil).
- `isUnsaved:` (asked to the application): unsaved notes show a bullet before their title.
- `tagSearchText:`, `clearTagSearch` (Escape), `submitTagSearch` (Enter).

```
(NT3NoteListPresenter newApplication: NT3Application new)
	notes: NT3Application sampleNotes;
	open
```

## Internal Representation

- `noteList`: an `SpEasyListViewPresenter` whose items are notes and `NT3ListSeparator`s.
- `tagSearchInput`, `modeButtons` (toggle buttons in the order of `NT3ListMode modes`).
- `lastSelectedIndex`, `isAdjustingSelection`: to move the selection off separators.
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
		'hiddenNote'
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
		whenRowPresenterInstantiatedDo: [ :row |
			row
				showsDetails: mode showsDetails;
				isUnsavedBlock: [ :note | self isUnsaved: note ] ];
		whenSelectionChangedDo: [ self noteListSelectionChanged ].
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
	isAdjustingSelection := false.
	textBeforeCompletion := ''.
	mode := self application listMode.
	noteList := self newEasyListView
		            rowPresenterClass: NT3NoteRowPresenter;
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
	"Separators cannot be selected: a move by one row onto a separator goes on to the next note in that direction,
	any other selection of a separator (a click) restores the previous selection.
	The list ignores selection changes made while it announces one, so the correction is deferred"

	| index previousIndex target |
	isAdjustingSelection ifTrue: [ ^ self ].
	index := noteList selectedIndex.
	previousIndex := lastSelectedIndex.
	((index between: 1 and: noteList items size) and: [ (noteList items at: index) isNote not ]) ifFalse: [
			lastSelectedIndex := index.
			^ self announceSelectedNote ].
	target := self noteIndexMovingFrom: previousIndex to: index.
	self defer: [
			self adjustingSelectionDo: [
					target = 0
						ifTrue: [ noteList unselectAll ]
						ifFalse: [ noteList selectIndex: target ] ].
			lastSelectedIndex := noteList selectedIndex.
			target = previousIndex ifFalse: [ self announceSelectedNote ] ]
]

{ #category : 'accessing' }
NT3NoteListPresenter >> notes: aCollectionOfNotes [
	"Set the notes to list. The list does not track their changes: send refresh after a change"

	notes := aCollectionOfNotes.
	self refresh
]

{ #category : 'updating' }
NT3NoteListPresenter >> refresh [
	"Rebuild the rows from the notes, the mode and the searched tags, keeping the selected note when it is still listed.
	A selected note that a filter hides is remembered and selected again once it is listed again"

	| previous selected entries |
	previous := self selectedNote.
	selected := previous ifNil: [ hiddenNote ].
	entries := mode entriesFor: notes searchedTagNames: self tagQuery searchedTagNames.
	hiddenNote := (selected isNotNil and: [ (entries includes: selected) not ]) ifTrue: [ selected ].
	self adjustingSelectionDo: [
			noteList items: entries.
			(selected isNotNil and: [ hiddenNote isNil ]) ifTrue: [ noteList selectIndex: (entries indexOf: selected) ] ].
	lastSelectedIndex := noteList selectedIndex.
	self selectedNote == previous ifFalse: [ self announceSelectedNote ]
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
	"Select the first row of aNote, when it is listed"

	| index |
	index := noteList items indexOf: aNote.
	index > 0 ifTrue: [ noteList selectIndex: index ]
]

{ #category : 'selection' }
NT3NoteListPresenter >> selectedNote [

	^ noteList selectedItem ifNotNil: [ :entry | entry isNote ifTrue: [ entry ] ]
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

{ #category : 'private' }
NT3NoteListPresenter >> updateModeButtons [

	NT3ListMode modes with: modeButtons do: [ :each :button | button state: each class = mode class ]
]

{ #category : 'selection' }
NT3NoteListPresenter >> whenNoteSelectedDo: aBlock [
	"aBlock receives the selected note, or nil when no note is selected any more"

	noteSelectedBlocks add: aBlock
]
