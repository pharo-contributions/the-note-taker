"
I edit one task: its title, its section, its status, and its items in two tabs, List and Text.

## Responsibility:

- I show the title and the section (applied when Enter is pressed), the status, and a button to abandon or reopen the task.
- My List tab edits the items; my Text tab shows the raw file. Leaving the Text tab reads the text back; when a line cannot be read I stay on the Text tab, select the line and say why.
- I save the task to the repository after every change and tell my owner, so it can refresh.

## Collaborators: 

- `NTTask`: my model.
- `NTTaskRepository`: saves the task.
- `NTTaskItemsPresenter`: the List tab.
- `NTTaskReader` / `NTTaskWriter`: the Text tab.

## Public API and Key Messages

- `NTTaskEditorPresenter newApplication: anApplication model: aTask`, then `repository:`
- `whenTaskSavedDo: aBlock`
- `applyTitle`, `applySection`, `toggleAbandon`, `showListPage`, `showTextPage`, `saveTask`
- `isOnListPage`, `isEditingText` (a Text edit is pending)

See `NTTaskEditorPresenter class >> #exampleInMemory`.

## Internal Representation

- `notebook`: an `SpNotebookPresenter` with the List page (`itemsPresenter`) and the Text page (`textPresenter`).
- `errorLabel`: shows why the text could not be read.
- `savedBlock`: evaluated with the task after each save.

### Implementation Points

- The notebook ignores a page change made while it announces the previous one, so going back to the Text tab after an invalid text is deferred (`SpApplication>>#defer:`).
"
Class {
	#name : 'NTTaskEditorPresenter',
	#superclass : 'SpPresenterWithModel',
	#instVars : [
		'repository',
		'titleInput',
		'sectionInput',
		'statusLabel',
		'abandonButton',
		'notebook',
		'listPage',
		'textPage',
		'itemsPresenter',
		'textPresenter',
		'errorLabel',
		'savedBlock',
		'isShowingText',
		'isSwitchingPage'
	],
	#category : 'TheNoteTaker-Tasks-UI',
	#package : 'TheNoteTaker-Tasks-UI'
}

{ #category : 'examples' }
NTTaskEditorPresenter class >> exampleInMemory [

	<sampleInstance>
	| repository |
	repository := NTTasksApplication demoRepository.
	^ (self newApplication: NTTasksApplication new model: repository tasks first)
		  repository: repository;
		  yourself
]

{ #category : 'accessing' }
NTTaskEditorPresenter >> abandonButton [

	^ abandonButton
]

{ #category : 'actions' }
NTTaskEditorPresenter >> applySection [
	"An empty section removes the task from its section: it goes to Unsorted."

	| section |
	self model ifNil: [ ^ self ].
	section := sectionInput text asString trimBoth.
	self model section: (section ifEmpty: [ nil ]).
	self saveTask
]

{ #category : 'actions' }
NTTaskEditorPresenter >> applyTitle [

	| title |
	self model ifNil: [ ^ self ].
	title := titleInput text asString trimBoth.
	title ifEmpty: [ ^ titleInput text: self model title ].
	self model title: title.
	self saveTask
]

{ #category : 'initialization' }
NTTaskEditorPresenter >> connectPresenters [

	titleInput whenSubmitDo: [ :text | self applyTitle ].
	sectionInput whenSubmitDo: [ :text | self applySection ].
	itemsPresenter whenItemsChangedDo: [ self saveTask ].
	notebook whenSelectedPageChangedDo: [ :page | self pageChangedTo: page ]
]

{ #category : 'layout' }
NTTaskEditorPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 4;
				   add: titleInput;
				   add: sectionInput width: 150;
				   add: statusLabel width: 80;
				   add: abandonButton expand: false;
				   yourself)
		  expand: false;
		  add: notebook;
		  add: errorLabel expand: false;
		  yourself
]

{ #category : 'private - pages' }
NTTaskEditorPresenter >> enterTextPage [

	isShowingText := true.
	errorLabel label: ''.
	textPresenter text: (self model ifNil: [ '' ] ifNotNil: [ :task | NTTaskWriter write: task ])
]

{ #category : 'accessing' }
NTTaskEditorPresenter >> errorLabel [

	^ errorLabel
]

{ #category : 'initialization' }
NTTaskEditorPresenter >> initializePresenters [

	savedBlock := [ :task |  ].
	isShowingText := false.
	isSwitchingPage := false.
	titleInput := self newTextInput
		              placeholder: 'Title, then Enter';
		              yourself.
	sectionInput := self newTextInput
		                placeholder: 'Section, then Enter';
		                yourself.
	statusLabel := self newLabel.
	abandonButton := self newButton
		                 label: 'Abandon';
		                 action: [ self toggleAbandon ];
		                 yourself.
	itemsPresenter := self instantiate: NTTaskItemsPresenter.
	textPresenter := self newText.
	errorLabel := self newLabel.
	listPage := SpNotebookPage title: 'List' provider: [ itemsPresenter ].
	textPage := SpNotebookPage title: 'Text' provider: [ textPresenter ].
	notebook := self newNotebook
		            addPage: listPage;
		            addPage: textPage;
		            yourself
]

{ #category : 'private - pages' }
NTTaskEditorPresenter >> intervalOfLine: aNumber in: aString [
	"Answer the interval of the characters of line aNumber of aString, whatever its line endings."

	| line |
	line := 0.
	aString lineIndicesDo: [ :start :endWithoutDelimiters :end |
			line := line + 1.
			line = aNumber ifTrue: [ ^ start to: endWithoutDelimiters ] ].
	^ 1 to: 0
]

{ #category : 'private - pages' }
NTTaskEditorPresenter >> isEditingText [
	"Answer whether a Text tab edit is pending: the Text tab is shown, or could not be left because its text is invalid."

	^ isShowingText
]

{ #category : 'accessing' }
NTTaskEditorPresenter >> isOnListPage [

	^ notebook selectedPage = listPage
]

{ #category : 'accessing' }
NTTaskEditorPresenter >> itemsPresenter [

	^ itemsPresenter
]

{ #category : 'private - pages' }
NTTaskEditorPresenter >> leaveTextPage [

	| parsed |
	self model ifNil: [ ^ isShowingText := false ].
	parsed := [ NTTaskReader read: textPresenter text asString ]
		          on: NTTaskParseError
		          do: [ :error |
				          self showError: error.
				          ^ self ].
	isShowingText := false.
	errorLabel label: ''.
	self model replaceContentsFrom: parsed.
	self updatePresenter.
	self saveTask
]

{ #category : 'initialization' }
NTTaskEditorPresenter >> modelChanged [

	self updatePresenter
]

{ #category : 'accessing' }
NTTaskEditorPresenter >> notebook [

	^ notebook
]

{ #category : 'private - pages' }
NTTaskEditorPresenter >> pageChangedTo: aPage [
	"Entering the Text tab shows the file; leaving it reads the text back, or goes back to it when the text cannot be read."

	isSwitchingPage ifTrue: [ ^ self ].
	aPage = textPage ifTrue: [ ^ self enterTextPage ].
	isShowingText ifTrue: [ self leaveTextPage ]
]

{ #category : 'accessing' }
NTTaskEditorPresenter >> repository [

	^ repository
]

{ #category : 'accessing' }
NTTaskEditorPresenter >> repository: aTaskRepository [

	repository := aTaskRepository
]

{ #category : 'actions' }
NTTaskEditorPresenter >> saveTask [
	"Write the task to its file, show its new status and tell my owner."

	self model ifNil: [ ^ self ].
	repository ifNotNil: [ repository save: self model ].
	self updateStatus.
	savedBlock value: self model
]

{ #category : 'accessing' }
NTTaskEditorPresenter >> sectionInput [

	^ sectionInput
]

{ #category : 'private - pages' }
NTTaskEditorPresenter >> showError: aParseError [
	"Refuse to leave the Text tab: keep the text edit pending, select the faulty line and say why. The notebook cannot be switched back while it announces the page change, so going back to the Text tab is deferred."

	isShowingText := true.
	errorLabel label: aParseError messageText.
	textPresenter selectionInterval: (self intervalOfLine: aParseError lineNumber in: textPresenter text asString).
	self application defer: [ isShowingText ifTrue: [ self switchToPage: textPage ] ]
]

{ #category : 'actions' }
NTTaskEditorPresenter >> showListPage [

	notebook selectPage: listPage
]

{ #category : 'actions' }
NTTaskEditorPresenter >> showTextPage [

	notebook selectPage: textPage
]

{ #category : 'accessing' }
NTTaskEditorPresenter >> statusLabel [

	^ statusLabel
]

{ #category : 'private - pages' }
NTTaskEditorPresenter >> switchToPage: aPage [
	"Select aPage without reacting to the change."

	isSwitchingPage := true.
	[ notebook selectPage: aPage ] ensure: [ isSwitchingPage := false ].
	isShowingText := aPage = textPage
]

{ #category : 'accessing' }
NTTaskEditorPresenter >> textPresenter [

	^ textPresenter
]

{ #category : 'accessing' }
NTTaskEditorPresenter >> titleInput [

	^ titleInput
]

{ #category : 'actions' }
NTTaskEditorPresenter >> toggleAbandon [

	self model ifNil: [ ^ self ].
	self model isAbandoned
		ifTrue: [ self model reopen ]
		ifFalse: [ self model abandon ].
	self saveTask
]

{ #category : 'updating' }
NTTaskEditorPresenter >> updatePresenter [
	"Show the model; a pending Text edit of the previous task is dropped."

	| task |
	task := self model.
	titleInput text: (task ifNil: [ '' ] ifNotNil: [ task title ]).
	sectionInput text: ((task ifNotNil: [ task section ]) ifNil: [ '' ]).
	titleInput enabled: task isNotNil.
	sectionInput enabled: task isNotNil.
	itemsPresenter model: task.
	errorLabel label: ''.
	self switchToPage: listPage.
	self updateStatus
]

{ #category : 'initialization' }
NTTaskEditorPresenter >> updateStatus [

	| task |
	task := self model.
	statusLabel label: (task ifNil: [ '' ] ifNotNil: [ task status asString ]).
	abandonButton label: ((task isNotNil and: [ task isAbandoned ])
			 ifTrue: [ 'Reopen' ]
			 ifFalse: [ 'Abandon' ]).
	abandonButton enabled: (task isNotNil and: [ task isFinished not ])
]

{ #category : 'actions' }
NTTaskEditorPresenter >> whenTaskSavedDo: aBlock [

	savedBlock := aBlock
]
