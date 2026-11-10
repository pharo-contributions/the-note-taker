"
I am the tasks pane: the tree of sections and tasks on the left, the editor of the selected task on the right.

```
Tasks                     │ Pharo 14 release   section: Pharo   open   [Abandon]
 ├─ Pharo                 │ [List | Text]
 │   ├─ Fix CI       0/4  │ ...
 │   └─ Release      2/3  │
 ├─ Unsorted              │
 └─ Finished / Abandoned  │
     ├─ ✓ Move office     │
     └─ ✗ Old grant       │
```

## Responsibility:

- I show the open tasks grouped by section (alphabetically, then Unsorted), then the special Finished / Abandoned section.
- I create, delete and reload tasks through my toolbar.
- I show the selected task in an `NTTaskEditorPresenter` and refresh the tree when the editor saves a task.

## Collaborators: 

- `NTTaskRepository`: my model.
- `NTTaskEditorPresenter`: edits and saves the selected task.

## Public API and Key Messages

- `NTTasksPresenter newApplication: anApplication model: aRepository`
- `selectTask:`, `selectedTask`, `newTaskTitled:`, `deleteSelectedTask`, `refresh`
- `roots`, `childrenOf:`, `displayStringOf:` (what the tree shows)

See `NTTasksPresenter class >> #exampleInMemory`.

## Internal Representation

- `toolbar`: an `SpToolbarPresenter`; `taskTree`: an `SpTreePresenter` whose roots are section names (Strings) and whose children are `NTTask`s; `editor`: an `NTTaskEditorPresenter`.
"
Class {
	#name : 'NTTasksPresenter',
	#superclass : 'SpPresenterWithModel',
	#instVars : [
		'toolbar',
		'taskTree',
		'editor'
	],
	#category : 'TheNoteTaker-Tasks-UI',
	#package : 'TheNoteTaker-Tasks-UI'
}

{ #category : 'examples' }
NTTasksPresenter class >> exampleInMemory [

	<sampleInstance>
	| application |
	application := NTTasksApplication new.
	application repository: NTTasksApplication demoRepository.
	^ self newApplication: application model: application repository
]

{ #category : 'tree' }
NTTasksPresenter >> childrenOf: aNode [

	aNode isString ifFalse: [ ^ #(  ) ].
	aNode = NTTask closedSectionName ifTrue: [ ^ self model closedTasks ].
	^ self model openTasksInSection: aNode
]

{ #category : 'initialization' }
NTTasksPresenter >> connectPresenters [

	taskTree whenSelectionChangedDo: [ :selection | editor model: (self taskIn: selection selectedItem) ].
	editor whenTaskSavedDo: [ :task | self refreshKeeping: task ]
]

{ #category : 'layout' }
NTTasksPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: toolbar expand: false;
		  add: (SpPanedLayout newLeftToRight
				   positionOfSlider: 30 percent;
				   add: taskTree;
				   add: editor;
				   yourself);
		  yourself
]

{ #category : 'actions' }
NTTasksPresenter >> deleteSelectedTask [

	self selectedTask ifNotNil: [ :task |
			self model remove: task.
			editor model: nil.
			self refreshKeeping: nil ]
]

{ #category : 'tree' }
NTTasksPresenter >> displayStringOf: aNode [

	aNode isString ifTrue: [ ^ aNode ].
	aNode isFinished ifTrue: [ ^ '✓ ' , aNode title ].
	aNode isAbandoned ifTrue: [ ^ '× ' , aNode title ].
	^ '{1}  {2}/{3}' format: {
			  aNode title.
			  aNode doneCount.
			  aNode itemCount }
]

{ #category : 'accessing' }
NTTasksPresenter >> editor [

	^ editor
]

{ #category : 'initialization' }
NTTasksPresenter >> initializePresenters [

	toolbar := self newToolbar
		           add: (self newToolbarButton
				            label: 'New task';
				            icon: (self iconNamed: #add);
				            action: [ self requestNewTask ];
				            yourself);
		           add: (self newToolbarButton
				            label: 'Delete';
				            icon: (self iconNamed: #remove);
				            action: [ self requestDeleteSelectedTask ];
				            yourself);
		           add: (self newToolbarButton
				            label: 'Reload';
				            icon: (self iconNamed: #refresh);
				            action: [ self reload ];
				            yourself);
		           yourself.
	taskTree := self newTree
		            children: [ :node | self childrenOf: node ];
		            display: [ :node | self displayStringOf: node ];
		            yourself.
	editor := self instantiate: NTTaskEditorPresenter
]

{ #category : 'initialization' }
NTTasksPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Tasks';
		initialExtent: 1000 @ 600
]

{ #category : 'initialization' }
NTTasksPresenter >> modelChanged [

	self updatePresenter
]

{ #category : 'actions' }
NTTasksPresenter >> newTaskTitled: aString [
	"Create a task, show it and select it. Answer it, or nil when the title is empty."

	| title task |
	title := aString asString trimBoth.
	title ifEmpty: [ ^ nil ].
	task := self model newTaskTitled: title.
	self refreshKeeping: task.
	^ task
]

{ #category : 'tree' }
NTTasksPresenter >> refreshKeeping: aTask [
	"Rebuild the tree, for instance after a task moved to another section, and select aTask again."

	taskTree roots: self roots.
	taskTree expandAll.
	aTask ifNotNil: [ self selectTask: aTask ]
]

{ #category : 'actions' }
NTTasksPresenter >> reload [
	"Read the task files again, for instance after a git pull."

	| selected |
	selected := self selectedTask.
	self model reload.
	editor model: nil.
	self refreshKeeping:
		(selected ifNotNil: [ self model tasks detect: [ :each | each fileReference = selected fileReference ] ifNone: [ nil ] ])
]

{ #category : 'actions' }
NTTasksPresenter >> requestDeleteSelectedTask [

	self selectedTask ifNil: [ ^ self ] ifNotNil: [ :task |
			(self application newConfirm
				 title: 'Delete task';
				 label: ('Delete the task {1} and its file?' format: { task title printString });
				 openModal) ifTrue: [ self deleteSelectedTask ] ]
]

{ #category : 'actions' }
NTTasksPresenter >> requestNewTask [

	(self application newRequest
		 title: 'New task';
		 label: 'Title of the new task';
		 openModal) ifNotNil: [ :title | self newTaskTitled: title ]
]

{ #category : 'tree' }
NTTasksPresenter >> roots [
	"Answer the section names of the open tasks, then the special section when some tasks are closed."

	| repository |
	repository := self model ifNil: [ ^ #(  ) ].
	^ repository closedTasks
		  ifEmpty: [ repository sectionNames ]
		  ifNotEmpty: [ repository sectionNames copyWith: NTTask closedSectionName ]
]

{ #category : 'actions' }
NTTasksPresenter >> selectTask: aTask [
	"Select aTask in the tree, under its section or under the special section when it is closed. selectPath: is used because selectPathByItems: waits until the tree is displayed."

	| section path |
	section := aTask isClosed
		           ifTrue: [ NTTask closedSectionName ]
		           ifFalse: [ aTask sectionName ].
	path := taskTree pathIndexOf: {
			        section.
			        aTask }.
	(path includes: 0) ifTrue: [ ^ self ].
	taskTree expandPath: path allButLast.
	taskTree selectPath: path
]

{ #category : 'actions' }
NTTasksPresenter >> selectedTask [

	^ self taskIn: taskTree selectedItem
]

{ #category : 'tree' }
NTTasksPresenter >> taskIn: aNode [

	^ (aNode isNil or: [ aNode isString ])
		  ifTrue: [ nil ]
		  ifFalse: [ aNode ]
]

{ #category : 'accessing' }
NTTasksPresenter >> taskTree [

	^ taskTree
]

{ #category : 'updating' }
NTTasksPresenter >> updatePresenter [

	editor repository: self model.
	self refreshKeeping: nil
]
