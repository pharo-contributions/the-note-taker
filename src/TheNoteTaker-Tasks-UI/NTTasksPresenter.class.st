"
I am the tasks pane: the views and the tree of sections and tasks on the left; on the right, the editor of the selected task or the items of the selected view.

```
Views
  Today  1                 │
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
- I list the views with the number of items they select today, show the selected view in an `NTItemViewPresenter`, and create, edit and delete views with an `NTItemViewFormPresenter` (views.md is saved at once).
- Selecting a task unselects the view and the other way round; double-clicking an item of a view selects its task.

## Collaborators: 

- `NTTaskRepository`: my model.
- `NTTaskEditorPresenter`: edits and saves the selected task.
- `NTItemViewPresenter`, `NTItemViewFormPresenter`: show and edit views.

## Public API and Key Messages

- `NTTasksPresenter newApplication: anApplication model: aRepository`
- `selectTask:`, `selectedTask`, `newTaskTitled:`, `deleteSelectedTask`, `refresh`
- `roots`, `childrenOf:`, `displayStringOf:` (what the tree shows)
- `selectView:`, `selectedView`, `viewFormOn:`, `deleteSelectedView`, `displayStringOfView:`, `detailPresenter`

See `NTTasksPresenter class >> #exampleInMemory`.

## Internal Representation

- `toolbar`: an `SpToolbarPresenter`; `taskTree`: an `SpTreePresenter` whose roots are section names (Strings) and whose children are `NTTask`s; `editor`: an `NTTaskEditorPresenter`.
- `viewsLabel`, `viewsList`: the views of the repository; `viewPresenter`: an `NTItemViewPresenter`.
- `detailLayout`: the box on the right, holding `editor` or `viewPresenter`.
"
Class {
	#name : 'NTTasksPresenter',
	#superclass : 'SpPresenterWithModel',
	#instVars : [
		'toolbar',
		'viewsLabel',
		'viewsList',
		'taskTree',
		'editor',
		'viewPresenter',
		'detailLayout'
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

	taskTree whenSelectionChangedDo: [ :selection | self taskSelected: (self taskIn: selection selectedItem) ].
	viewsList whenSelectionChangedDo: [ :selection | self viewSelected: selection selectedItem ].
	editor whenTaskSavedDo: [ :task |
			self refreshKeeping: task.
			self refreshViews ].
	viewPresenter whenTaskRequestedDo: [ :task | self selectTask: task ].
	viewPresenter whenItemsChangedDo: [
			self refreshKeeping: nil.
			self refreshViews ]
]

{ #category : 'layout' }
NTTasksPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: toolbar expand: false;
		  add: (SpPanedLayout newLeftToRight
				   positionOfSlider: 30 percent;
				   add: (SpBoxLayout newTopToBottom
						    spacing: 4;
						    add: viewsLabel expand: false;
						    add: viewsList height: 140;
						    add: 'Tasks' expand: false;
						    add: taskTree;
						    yourself);
				   add: detailLayout;
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

{ #category : 'views' }
NTTasksPresenter >> deleteSelectedView [

	self selectedView ifNotNil: [ :view |
			self model views remove: view.
			self model saveViews.
			viewsList unselectAll.
			self refreshViews.
			self showDetail: editor ]
]

{ #category : 'accessing' }
NTTasksPresenter >> detailPresenter [
	"Answer the presenter shown on the right: the task editor or the view presenter."

	^ detailLayout presenters first
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

{ #category : 'views' }
NTTasksPresenter >> displayStringOfView: aView [
	"The name of the view and the number of items it selects today."

	^ '{1}  {2}' format: {
			  aView name.
			  (aView entriesIn: self model on: self application today) size }
]

{ #category : 'accessing' }
NTTasksPresenter >> editor [

	^ editor
]

{ #category : 'initialization' }
NTTasksPresenter >> initializePresenters [

	toolbar := self newTasksToolbar.
	viewsLabel := self newLabel.
	viewsList := self newList
		             display: [ :view | self displayStringOfView: view ];
		             yourself.
	taskTree := self newTree
		            children: [ :node | self childrenOf: node ];
		            display: [ :node | self displayStringOf: node ];
		            yourself.
	editor := self instantiate: NTTaskEditorPresenter.
	viewPresenter := self instantiate: NTItemViewPresenter.
	detailLayout := SpBoxLayout newTopToBottom
		                add: editor;
		                yourself
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

{ #category : 'initialization' }
NTTasksPresenter >> newTasksToolbar [

	^ self newToolbar
		  add: (self toolbarButton: 'New task' icon: #add action: [ self requestNewTask ]);
		  add: (self toolbarButton: 'Delete' icon: #remove action: [ self requestDeleteSelectedTask ]);
		  add: (self toolbarButton: 'Reload' icon: #refresh action: [ self reload ]);
		  add: (self toolbarButton: 'New view' icon: #add action: [ self requestNewView ]);
		  add: (self toolbarButton: 'Edit view' icon: #edit action: [ self requestEditSelectedView ]);
		  add: (self toolbarButton: 'Delete view' icon: #remove action: [ self requestDeleteSelectedView ]);
		  yourself
]

{ #category : 'tree' }
NTTasksPresenter >> refreshKeeping: aTask [
	"Rebuild the tree, for instance after a task moved to another section, and select aTask again."

	taskTree roots: self roots.
	taskTree expandAll.
	aTask ifNotNil: [ self selectTask: aTask ]
]

{ #category : 'views' }
NTTasksPresenter >> refreshViews [
	"Show the views and their counts again, keeping the selected view (found by name after a reload)."

	| selectedName |
	selectedName := viewsList selectedItem ifNotNil: [ :view | view name ].
	viewsList items: self model views views asArray.
	viewsLabel label: self viewsTitle.
	selectedName ifNotNil: [ (self model views viewNamed: selectedName) ifNotNil: [ :view | self selectView: view ] ]
]

{ #category : 'actions' }
NTTasksPresenter >> reload [
	"Read the task files and views.md again, for instance after a git pull."

	| selected |
	selected := self selectedTask.
	self model reload.
	editor model: nil.
	self refreshViews.
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

{ #category : 'views' }
NTTasksPresenter >> requestDeleteSelectedView [

	self selectedView ifNotNil: [ :view |
			(self application newConfirm
				 title: 'Delete view';
				 label: ('Delete the view {1}? Its items are not changed.' format: { view name printString });
				 openModal) ifTrue: [ self deleteSelectedView ] ]
]

{ #category : 'views' }
NTTasksPresenter >> requestEditSelectedView [

	self selectedView ifNotNil: [ :view | (self viewFormOn: view) openDialog ]
]

{ #category : 'actions' }
NTTasksPresenter >> requestNewTask [

	(self application newRequest
		 title: 'New task';
		 message: 'Title of the new task';
		 openModal) ifNotNil: [ :title | self newTaskTitled: title ]
]

{ #category : 'views' }
NTTasksPresenter >> requestNewView [

	(self viewFormOn: nil) openDialog
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

{ #category : 'views' }
NTTasksPresenter >> selectView: aView [

	viewsList selectItem: aView
]

{ #category : 'actions' }
NTTasksPresenter >> selectedTask [

	^ self taskIn: taskTree selectedItem
]

{ #category : 'views' }
NTTasksPresenter >> selectedView [

	^ viewsList selectedItem
]

{ #category : 'views' }
NTTasksPresenter >> showDetail: aPresenter [

	self detailPresenter == aPresenter ifTrue: [ ^ self ].
	detailLayout
		removeAll;
		add: aPresenter
]

{ #category : 'tree' }
NTTasksPresenter >> taskIn: aNode [

	^ (aNode isNil or: [ aNode isString ])
		  ifTrue: [ nil ]
		  ifFalse: [ aNode ]
]

{ #category : 'views' }
NTTasksPresenter >> taskSelected: aTaskOrNil [
	"Selecting a section shows no task but keeps a selected view on the right."

	editor model: aTaskOrNil.
	aTaskOrNil ifNil: [ ^ self ].
	viewsList unselectAll.
	self showDetail: editor
]

{ #category : 'accessing' }
NTTasksPresenter >> taskTree [

	^ taskTree
]

{ #category : 'initialization' }
NTTasksPresenter >> toolbarButton: aLabel icon: anIconName action: aBlock [

	^ self newToolbarButton
		  label: aLabel;
		  icon: (self iconNamed: anIconName);
		  action: aBlock;
		  yourself
]

{ #category : 'updating' }
NTTasksPresenter >> updatePresenter [

	editor repository: self model.
	viewPresenter repository: self model.
	self refreshViews.
	self refreshKeeping: nil
]

{ #category : 'views' }
NTTasksPresenter >> viewAccepted: aView [

	self model saveViews.
	self refreshViews.
	self selectView: aView.
	viewPresenter refresh
]

{ #category : 'views' }
NTTasksPresenter >> viewFormOn: aViewOrNil [
	"Answer the form that creates a view (nil) or edits aViewOrNil; once accepted, the views are saved."

	^ (NTItemViewFormPresenter newApplication: self application model: aViewOrNil)
		  viewSet: self model views sectionNames: self model sectionNames;
		  whenAcceptedDo: [ :view | self viewAccepted: view ];
		  yourself
]

{ #category : 'accessing' }
NTTasksPresenter >> viewPresenter [

	^ viewPresenter
]

{ #category : 'views' }
NTTasksPresenter >> viewSelected: aViewOrNil [

	viewPresenter model: aViewOrNil.
	aViewOrNil ifNil: [ ^ self ].
	viewPresenter refresh.
	taskTree unselectAll.
	self showDetail: viewPresenter
]

{ #category : 'accessing' }
NTTasksPresenter >> viewsLabel [

	^ viewsLabel
]

{ #category : 'accessing' }
NTTasksPresenter >> viewsList [

	^ viewsList
]

{ #category : 'views' }
NTTasksPresenter >> viewsTitle [

	^ self model viewsError ifNil: [ 'Views' ] ifNotNil: [ :error | 'Views (views.md not read: {1})' format: { error messageText } ]
]
