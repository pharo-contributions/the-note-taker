"
I test `NT3NoteTakerPresenter` without opening it: the text search, the selection, saving and creating notes.

## Responsibility:

- Check the filtering by words, combined with the tag filter, and the highlighting in the editor.
- Check that the edited note is saved when another note is selected, when it is hidden and when the window closes.
- Check that Enter opens the note with that title or creates one with the searched tags.

## Collaborators:

- `NT3NoteTakerPresenter`, `NT3DeferringTestApplication` (in-memory notes folder, manual timer).

## Public API and Key Messages

- `testSearchFiltersTheList`, `testEnterCreatesANoteWithTheSearchedTags`, `testHiddenNoteComesBackWhenTheSearchIsCleared`, …
"
Class {
	#name : 'NT3NoteTakerPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'application',
		'presenter',
		'specNote',
		'groceries',
		'old'
	],
	#category : 'TheNoteTaker-UI3-Tests',
	#package : 'TheNoteTaker-UI3-Tests'
}

{ #category : 'helpers' }
NT3NoteTakerPresenterTest >> listedNotes [

	^ presenter noteList entries select: [ :each | each isNote ]
]

{ #category : 'helpers' }
NT3NoteTakerPresenterTest >> noteWith: lines tagNames: tagNames daysAgo: days [

	| note |
	note := application newNoteTitled: lines first tagNames: tagNames.
	note
		contents: (String cr join: lines);
		modificationDate: DateAndTime now - days days.
	application
		noteEdited: note;
		saveNote: note.
	note modificationDate: DateAndTime now - days days.
	^ note
]

{ #category : 'helpers' }
NT3NoteTakerPresenterTest >> selectNote: aNote [

	presenter noteList selectNote: aNote.
	application runDeferred
]

{ #category : 'helpers' }
NT3NoteTakerPresenterTest >> selectNotes: aCollectionOfNotes [
	"Select the rows of the notes, in this order, as successive Cmd-clicks do"

	| entries indexes |
	entries := presenter noteList entries.
	indexes := OrderedCollection new.
	aCollectionOfNotes do: [ :each |
			indexes add: (entries indexOf: each).
			presenter noteList noteList selectIndexes: indexes copy.
			application runDeferred ]
]

{ #category : 'running' }
NT3NoteTakerPresenterTest >> setUp [

	super setUp.
	application := NT3DeferringTestApplication new.
	specNote := self noteWith: #( 'Spec list' 'The new list view' ) tagNames: #( 'spec' ) daysAgo: 1.
	groceries := self noteWith: #( 'Groceries' 'bread' ) tagNames: #(  ) daysAgo: 2.
	old := self noteWith: #( 'Old spec notes' 'toplo' ) tagNames: #( 'spec' ) daysAgo: 30.
	presenter := NT3NoteTakerPresenter newApplication: application
]

{ #category : 'tests - tags' }
NT3NoteTakerPresenterTest >> testApplyingATagChoiceKeepsTheSelection [

	| choice |
	self selectNotes: {
			specNote.
			groceries }.
	choice := presenter tagChoiceForSelectedNotes.
	choice addTagNamed: 'todo'.
	presenter applyTagChoice: choice.
	self assert: presenter noteList selectedNotes asSet equals: {
			specNote.
			groceries } asSet.
	self assert: presenter editor note identicalTo: groceries
]

{ #category : 'tests - tags' }
NT3NoteTakerPresenterTest >> testApplyingATagChoiceTagsTheSelectedNotes [

	| choice |
	self selectNotes: {
			specNote.
			groceries }.
	choice := presenter tagChoiceForSelectedNotes.
	choice
		addTagNamed: 'todo';
		toggle: 'spec'.
	presenter applyTagChoice: choice.
	self assert: (specNote tags collect: [ :each | each tagName ] as: Set) equals: #( 'spec' 'todo' ) asSet.
	self assert: (groceries tags collect: [ :each | each tagName ] as: Set) equals: #( 'spec' 'todo' ) asSet.
	self assert: (old tags collect: [ :each | each tagName ] as: Set) equals: #( 'spec' ) asSet
]

{ #category : 'tests - tags' }
NT3NoteTakerPresenterTest >> testApplyingATagChoiceUpdatesTheEditorInfo [

	| choice |
	self selectNotes: {
			specNote.
			groceries }.
	choice := presenter tagChoiceForSelectedNotes.
	choice addTagNamed: 'todo'.
	presenter applyTagChoice: choice.
	self assert: (presenter editor infoText includesSubstring: '#todo')
]

{ #category : 'tests' }
NT3NoteTakerPresenterTest >> testClearingTheSearchShowsAllNotes [

	presenter searchText: 'list'.
	presenter clearSearch.
	self assert: self listedNotes size equals: 3
]

{ #category : 'tests' }
NT3NoteTakerPresenterTest >> testClosingTheWindowSavesTheNotes [

	self selectNote: groceries.
	presenter editor textEditor text: 'Groceries!'.
	presenter windowClosed.
	self deny: (application isUnsaved: groceries)
]

{ #category : 'tests - creation' }
NT3NoteTakerPresenterTest >> testCreatedNoteHasTheCursorOnTheSecondLine [

	presenter searchText: 'New idea'.
	presenter openOrCreateNote.
	self assert: presenter editor textEditor selectionInterval equals: (10 to: 9)
]

{ #category : 'tests - creation' }
NT3NoteTakerPresenterTest >> testCreatingANoteClearsTheSearch [

	presenter searchText: 'New idea'.
	presenter openOrCreateNote.
	self assert: presenter searchText isEmpty.
	self assert: self listedNotes size equals: 4
]

{ #category : 'tests' }
NT3NoteTakerPresenterTest >> testEditingTheNoteMarksItInTheList [

	self selectNote: groceries.
	presenter editor textEditor text: 'Groceries!'.
	self assert: (presenter noteList isUnsaved: groceries)
]

{ #category : 'tests - tags' }
NT3NoteTakerPresenterTest >> testEditorShowsTheLastSelectedNote [

	self selectNotes: {
			specNote.
			groceries }.
	self assert: presenter editor note identicalTo: groceries
]

{ #category : 'tests - creation' }
NT3NoteTakerPresenterTest >> testEnterCreatesANoteEvenWhenOtherNotesMatch [

	| created |
	presenter searchText: 'spec'.
	presenter openOrCreateNote.
	created := presenter noteList selectedNote.
	self assert: created title equals: 'spec'.
	self assert: application container notes size equals: 4
]

{ #category : 'tests - creation' }
NT3NoteTakerPresenterTest >> testEnterCreatesANoteWithTheSearchedTags [

	| created |
	presenter noteList tagSearchText: 'spec '.
	presenter searchText: 'New idea'.
	presenter openOrCreateNote.
	created := presenter editor note.
	self assert: created title equals: 'New idea'.
	self assert: (created tags collect: [ :each | each tagName ] as: Array) equals: #( 'spec' ).
	self assert: created exists.
	self assert: presenter noteList selectedNote identicalTo: created
]

{ #category : 'tests - creation' }
NT3NoteTakerPresenterTest >> testEnterOnAnEmptySearchDoesNothing [

	presenter openOrCreateNote.
	self assert: application container notes size equals: 3
]

{ #category : 'tests - creation' }
NT3NoteTakerPresenterTest >> testEnterWithAnExactTitleSelectsTheNote [

	presenter searchText: 'groceries'.
	presenter openOrCreateNote.
	self assert: presenter noteList selectedNote identicalTo: groceries.
	self assert: application container notes size equals: 3
]

{ #category : 'tests' }
NT3NoteTakerPresenterTest >> testHiddenNoteComesBackWhenTheSearchIsCleared [

	self selectNote: groceries.
	presenter searchText: 'list'.
	presenter clearSearch.
	self assert: presenter editor note identicalTo: groceries
]

{ #category : 'tests' }
NT3NoteTakerPresenterTest >> testHidingTheEditedNoteSavesItAndEmptiesTheEditor [

	self selectNote: groceries.
	presenter editor textEditor text: 'Groceries and more'.
	presenter searchText: 'list'.
	self deny: (application isUnsaved: groceries).
	self assert: presenter editor note isNil
]

{ #category : 'tests - tags' }
NT3NoteTakerPresenterTest >> testListHasATagsAction [

	self assert: presenter tagsAction name equals: 'Tags…'.
	self assert: presenter tagsAction shortcutKey equals: $t actionModifier
]

{ #category : 'tests' }
NT3NoteTakerPresenterTest >> testListShowsTheNotesOfTheApplication [

	self assert: self listedNotes asArray equals: { specNote. groceries. old }
]

{ #category : 'tests' }
NT3NoteTakerPresenterTest >> testSavedNoteMovesToTheTop [

	self selectNote: old.
	presenter editor textEditor text: 'Old spec notes, revised'.
	application saveAll.
	self assert: self listedNotes first identicalTo: old
]

{ #category : 'tests' }
NT3NoteTakerPresenterTest >> testSearchCombinesWithTheTagFilter [

	presenter noteList tagSearchText: 'spec '.
	presenter searchText: 'notes'.
	self assert: self listedNotes asArray equals: { old }
]

{ #category : 'tests' }
NT3NoteTakerPresenterTest >> testSearchFiltersTheList [

	presenter searchText: 'LIST'.
	self assert: self listedNotes asArray equals: { specNote }
]

{ #category : 'tests' }
NT3NoteTakerPresenterTest >> testSearchHighlightsInTheEditor [

	self selectNote: specNote.
	presenter searchText: 'list'.
	self assert: presenter editor matchRanges size equals: 2
]

{ #category : 'tests' }
NT3NoteTakerPresenterTest >> testSearchWordsAreCombined [

	presenter searchText: 'spec toplo'.
	self assert: self listedNotes asArray equals: { old }
]

{ #category : 'tests' }
NT3NoteTakerPresenterTest >> testSelectingANoteShowsItInTheEditor [

	self selectNote: groceries.
	self assert: presenter editor note identicalTo: groceries
]

{ #category : 'tests' }
NT3NoteTakerPresenterTest >> testSelectingAnotherNoteSavesTheEditedOne [

	self selectNote: groceries.
	presenter editor textEditor text: 'Groceries and more'.
	self selectNote: specNote.
	self deny: (application isUnsaved: groceries).
	self assert: groceries fileReferenceContents equals: 'Groceries and more'
]

{ #category : 'tests - tags' }
NT3NoteTakerPresenterTest >> testTagChoiceIsOnTheSelectedNotes [

	| choice |
	self selectNotes: {
			specNote.
			groceries }.
	choice := presenter tagChoiceForSelectedNotes.
	self assert: choice notes asSet equals: {
			specNote.
			groceries } asSet.
	self assert: (choice stateOf: 'spec') equals: #some
]

{ #category : 'tests - tags' }
NT3NoteTakerPresenterTest >> testTagChoiceOffersTheTagsOfAllTheNotes [

	application container addNote: (NT3Application
			 noteTitled: 'Books'
			 body: ''
			 modifiedAt: DateAndTime now
			 tagNames: #( 'books' )).
	self selectNote: groceries.
	self assert: (presenter tagChoiceForSelectedNotes tagNames includesAll: #( 'books' 'spec' ))
]

{ #category : 'tests - tags' }
NT3NoteTakerPresenterTest >> testTagsActionIsDisabledWithoutSelectedNote [

	self deny: presenter tagsAction isEnabled.
	self selectNote: groceries.
	self assert: presenter tagsAction isEnabled
]
