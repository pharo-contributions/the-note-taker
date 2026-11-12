"
I edit the text of one note, with an information line above it, and highlight the words searched.

## Responsibility:

- I show the whole contents of a note (its first line is the title) and put the edits into the note as they are typed; without a note I am empty and read-only.
- I save the note on Cmd+S and, on Cmd+L, bring it back to what it was when it was shown, and save it.
- I highlight the matches of an `NT3TextQuery`, put the cursor on the first one, and select the next or previous one (Cmd+G, Cmd+Shift+G).

## Collaborators:

- `NT3Application`: told of each edit (`noteEdited:`), saves the notes and knows which are unsaved.
- `NT3NotePreview`: gives my information line; `NT3TextQuery`: gives the ranges to highlight.
- `NT3NoteTakerPresenter`: sets my note and query, and listens to the edits.

## Public API and Key Messages

- `note:` (nil for none), `note`, `textQuery:`, `matchRanges`.
- `save`, `discardEdits`, `selectNextMatch`, `selectPreviousMatch`, `updateInfo`.
- `whenNoteEditedDo:` (the block receives the note).

```
NT3NoteEditorPresenter example open
```

## Internal Representation

- `infoLabel`: a label; `textEditor`: an `SpCodePresenter` without syntax highlight nor line numbers.
- `contentsWhenSelected`, `modificationDateWhenSelected`: what Cmd+L brings back.
- `isSettingText`: true while I set the text myself, so that it is not taken as an edit.
"
Class {
	#name : 'NT3NoteEditorPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'infoLabel',
		'textEditor',
		'note',
		'textQuery',
		'matchRanges',
		'contentsWhenSelected',
		'modificationDateWhenSelected',
		'isSettingText',
		'noteEditedBlocks'
	],
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'examples' }
NT3NoteEditorPresenter class >> example [
	"An editor showing the first sample note"

	<sampleInstance>
	| application |
	application := NT3Application example.
	^ (self newApplication: application)
		  note: application container notes first;
		  yourself
]

{ #category : 'examples' }
NT3NoteEditorPresenter class >> scriptOpen [
	"Open an editor on the first sample note"

	<example>
	^ self example open
]

{ #category : 'initialization' }
NT3NoteEditorPresenter >> connectPresenters [

	textEditor
		whenTextChangedDo: [ :newText | self textChanged: newText ];
		whenSubmitDo: [ :text | self save ];
		whenResetDo: [ self discardEdits ];
		addShortcutWith: [ :action |
				action
					shortcutKey: $g actionModifier;
					action: [ self selectNextMatch ] ];
		addShortcutWith: [ :action |
				action
					shortcutKey: $g shift actionModifier;
					action: [ self selectPreviousMatch ] ]
]

{ #category : 'layout' }
NT3NoteEditorPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: infoLabel expand: false;
		  add: textEditor;
		  yourself
]

{ #category : 'actions' }
NT3NoteEditorPresenter >> discardEdits [
	"Bring the note back to its contents and modification date when it was selected, and save it"

	note ifNil: [ ^ self ].
	note
		contents: contentsWhenSelected;
		modificationDate: modificationDateWhenSelected.
	self application
		noteEdited: note;
		saveNote: note.
	self showNote.
	noteEditedBlocks do: [ :each | each value: note ]
]

{ #category : 'accessing' }
NT3NoteEditorPresenter >> infoText [

	^ infoLabel label
]

{ #category : 'initialization' }
NT3NoteEditorPresenter >> initializePresenters [

	isSettingText := false.
	textQuery := NT3TextQuery text: ''.
	matchRanges := #(  ).
	noteEditedBlocks := OrderedCollection new.
	infoLabel := self newLabel
		             addStyle: 'ntDetail';
		             addStyle: 'dim';
		             yourself.
	textEditor := self newCode
		              withoutSyntaxHighlight;
		              withoutLineNumbers;
		              beWrapWord;
		              yourself.
	self showNote
]

{ #category : 'accessing' }
NT3NoteEditorPresenter >> matchRanges [
	"Answer the intervals of the text where the words of the text query occur"

	^ matchRanges
]

{ #category : 'matches' }
NT3NoteEditorPresenter >> moveToFirstMatch [
	"Put the cursor at the start of the first match, without selecting it, so that the editor shows it"

	matchRanges ifEmpty: [ ^ self ].
	textEditor selectionInterval: (matchRanges first first to: matchRanges first first - 1)
]

{ #category : 'accessing' }
NT3NoteEditorPresenter >> note [

	^ note
]

{ #category : 'accessing' }
NT3NoteEditorPresenter >> note: aNote [
	"Show aNote, or nothing when aNote is nil. Discarding edits brings back aNote as it is now"

	note := aNote.
	note ifNotNil: [
		contentsWhenSelected := note contents.
		modificationDateWhenSelected := note modificationDate ].
	self showNote.
	self moveToFirstMatch
]

{ #category : 'actions' }
NT3NoteEditorPresenter >> save [
	"Write the note at once"

	note ifNotNil: [ self application saveNote: note ].
	self updateInfo
]

{ #category : 'matches' }
NT3NoteEditorPresenter >> selectNextMatch [
	"Select the first match after the cursor, going back to the first match after the last one"

	| start |
	matchRanges ifEmpty: [ ^ self ].
	start := textEditor selectionInterval first.
	textEditor selectionInterval: (matchRanges detect: [ :each | each first > start ] ifNone: [ matchRanges first ])
]

{ #category : 'matches' }
NT3NoteEditorPresenter >> selectPreviousMatch [
	"Select the last match before the cursor, going to the last match before the first one"

	| start |
	matchRanges ifEmpty: [ ^ self ].
	start := textEditor selectionInterval first.
	textEditor selectionInterval: (matchRanges reverse detect: [ :each | each first < start ] ifNone: [ matchRanges last ])
]

{ #category : 'private' }
NT3NoteEditorPresenter >> settingTextDo: aBlock [
	"Change the text without taking it as an edit of the user"

	isSettingText := true.
	aBlock ensure: [ isSettingText := false ]
]

{ #category : 'private' }
NT3NoteEditorPresenter >> showNote [

	self settingTextDo: [ textEditor text: (note ifNil: [ '' ] ifNotNil: [ note contents ]) ].
	textEditor editable: note isNotNil.
	self updateInfo.
	self updateMatches
]

{ #category : 'private' }
NT3NoteEditorPresenter >> textChanged: aText [
	"The user changed the text: put it into the note, which the application then considers unsaved"

	| newContents |
	(isSettingText or: [ note isNil ]) ifTrue: [ ^ self ].
	newContents := aText asString.
	newContents = note contents ifTrue: [ ^ self ].
	note contents: newContents.
	self application noteEdited: note.
	self updateInfo.
	self updateMatches.
	noteEditedBlocks do: [ :each | each value: note ]
]

{ #category : 'accessing' }
NT3NoteEditorPresenter >> textEditor [

	^ textEditor
]

{ #category : 'accessing' }
NT3NoteEditorPresenter >> textQuery: aTextQuery [
	"Highlight the words of aTextQuery in the text"

	textQuery := aTextQuery.
	self updateMatches
]

{ #category : 'updating' }
NT3NoteEditorPresenter >> updateInfo [

	infoLabel label: (note
			 ifNil: [ '' ]
			 ifNotNil: [ (NT3NotePreview note: note today: Date today) infoLineUnsaved: (self application isUnsaved: note) ])
]

{ #category : 'private' }
NT3NoteEditorPresenter >> updateMatches [

	matchRanges := textQuery rangesIn: textEditor text asString.
	textEditor removeAllTextSegmentDecorations.
	matchRanges do: [ :each |
		textEditor addTextSegmentDecoration: (SpTextPresenterDecorator forHighlight
				 interval: (each first to: each last + 1);
				 yourself) ]
]

{ #category : 'events' }
NT3NoteEditorPresenter >> whenNoteEditedDo: aBlock [
	"aBlock receives the note each time the user changes its text"

	noteEditedBlocks add: aBlock
]
