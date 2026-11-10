"
I am the abstract superclass of the tests of the task presenters. I give each test an in-memory task repository and an `NTTasksApplication`, and close the windows a test opens.
"
Class {
	#name : 'NTTaskUITestCase',
	#superclass : 'NTTaskTestCase',
	#instVars : [
		'application',
		'repository'
	],
	#category : 'TheNoteTaker-Tasks-UI-Tests',
	#package : 'TheNoteTaker-Tasks-UI-Tests'
}

{ #category : 'testing' }
NTTaskUITestCase class >> isAbstract [

	^ self == NTTaskUITestCase
]

{ #category : 'helpers' }
NTTaskUITestCase >> fileOf: aTask [

	^ aTask fileReference contents
]

{ #category : 'helpers' }
NTTaskUITestCase >> finishedTask: aTitle section: aSection [

	| task |
	task := self newTask: aTitle section: aSection items: #( 'done' ).
	task items first markDoneOn: (self nov: 5).
	repository save: task at: (self timeOn: 5).
	^ task
]

{ #category : 'helpers' }
NTTaskUITestCase >> newTask: aTitle section: aSection items: titles [
	"Create and save a task with open items of those titles."

	| task |
	task := repository newTaskTitled: aTitle at: (self timeOn: 4).
	task section: aSection.
	titles do: [ :each | task addItemTitled: each on: (self nov: 4) ].
	repository save: task at: (self timeOn: 4).
	^ task
]

{ #category : 'running' }
NTTaskUITestCase >> setUp [

	super setUp.
	repository := NTTaskRepository on: FileSystem memory root / 'todos'.
	application := NTTasksApplication new.
	application today: (self nov: 10)
]

{ #category : 'helpers' }
NTTaskUITestCase >> task: aTitle section: aSection lines: itemLines [
	"Create and save a task whose items are read from checkbox lines."

	| task reader |
	reader := NTTaskReader new.
	task := repository newTaskTitled: aTitle at: (self timeOn: 4).
	task section: aSection.
	itemLines do: [ :each | task addItem: (reader readItemLine: each) ].
	repository save: task at: (self timeOn: 4).
	^ task
]

{ #category : 'running' }
NTTaskUITestCase >> tearDown [

	application closeAllWindows.
	super tearDown
]
