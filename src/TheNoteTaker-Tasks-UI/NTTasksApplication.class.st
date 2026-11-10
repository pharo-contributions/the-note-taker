"
I am the application of the todo part of the notetaker, which runs on its own, without the notes.

## Responsibility:

- I know the tasks folder, a setting of its own (by default `Documents/Tasks`).
- I open the tasks pane on a repository of that folder.
- I am the application of all the task presenters, so they open each other through me.

## Collaborators: 

- `NTTaskRepository`: the tasks of the folder.
- `NTTasksPresenter`: the main pane I open.

## Public API and Key Messages

- `NTTasksApplication tasksFolder: aFolderReference` sets the folder.
- `NTTasksApplication new start` opens the tasks pane.
- `repository` answers the repository of the tasks folder, unless one was given with `repository:`.

```
NTTasksApplication tasksFolder: FileLocator documents / 'Tasks'.
NTTasksApplication new start
```

Run `NTTasksApplication class >> #scriptOpenOnExampleTasks` for a demo on an in-memory folder.

## Internal Representation

- `TasksFolder`: a class variable holding the folder (a FileReference or FileLocator), nil means the default.
- `repository`: the `NTTaskRepository` shown, created from `TasksFolder` on first use.
"
Class {
	#name : 'NTTasksApplication',
	#superclass : 'SpApplication',
	#instVars : [
		'repository'
	],
	#classVars : [
		'TasksFolder'
	],
	#category : 'TheNoteTaker-Tasks-UI',
	#package : 'TheNoteTaker-Tasks-UI'
}

{ #category : 'demo' }
NTTasksApplication class >> demoRepository [
	"Answer a repository on an in-memory folder holding a few tasks, for demos."

	| repository day release office grant |
	repository := NTTaskRepository on: FileSystem memory root / 'todos'.
	day := DateAndTime
		       year: 2026
		       month: 11
		       day: 4
		       hour: 10
		       minute: 0
		       second: 0.
	release := repository newTaskTitled: 'Pharo 14 release' at: day.
	release section: 'Pharo'.
	(release addItemTitled: 'Freeze API' on: day asDate) markDoneOn: day asDate.
	(release addItemTitled: 'Write release notes' on: day asDate)
		due: (Date year: 2026 month: 11 day: 15);
		prio: 'high';
		addTag: 'release'.
	(release addItemTitled: 'Sign-off' on: day asDate) waitingOthers: 'Marcus'.
	repository save: release at: day.
	(repository newTaskTitled: 'Write paper' at: day) section: 'Research'.
	(repository newTaskTitled: 'Buy cables' at: day) addItemTitled: 'USB-C cable' on: day asDate.
	office := repository newTaskTitled: 'Move office' at: day.
	office section: 'Admin'.
	(office addItemTitled: 'Pack books' on: day asDate) markDoneOn: day asDate.
	grant := repository newTaskTitled: 'Old grant idea' at: day.
	grant abandon.
	repository tasks do: [ :each | repository save: each at: day ].
	^ repository
]

{ #category : 'examples' }
NTTasksApplication class >> exampleInMemory [

	<sampleInstance>
	^ self new
		  repository: self demoRepository;
		  yourself
]

{ #category : 'script' }
NTTasksApplication class >> scriptOpen [
	"Open the tasks pane on the tasks folder of the settings."

	<script>
	self new start
]

{ #category : 'script' }
NTTasksApplication class >> scriptOpenOnExampleTasks [
	"Open the tasks pane on an in-memory folder with a few example tasks, without touching any real file."

	<script>
	(self new repository: self demoRepository) start
]

{ #category : 'settings' }
NTTasksApplication class >> tasksFolder [
	"The folder of the task files, a setting of the todo part."

	^ TasksFolder ifNil: [ FileLocator documents / 'Tasks' ]
]

{ #category : 'settings' }
NTTasksApplication class >> tasksFolder: aFolder [

	TasksFolder := aFolder
]

{ #category : 'accessing' }
NTTasksApplication >> repository [
	"Answer the repository of the tasks folder of the settings, unless another one was given."

	^ repository ifNil: [ repository := NTTaskRepository on: self class tasksFolder asFileReference ]
]

{ #category : 'accessing' }
NTTasksApplication >> repository: aTaskRepository [

	repository := aTaskRepository
]

{ #category : 'running' }
NTTasksApplication >> start [

	(NTTasksPresenter newApplication: self model: self repository) open
]
