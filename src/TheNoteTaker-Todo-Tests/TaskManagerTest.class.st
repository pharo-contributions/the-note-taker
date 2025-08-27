Class {
	#name : 'TaskManagerTest',
	#superclass : 'TestCase',
	#instVars : [
		'taskManager'
	],
	#category : 'TheNoteTaker-Todo-Tests',
	#package : 'TheNoteTaker-Todo-Tests'
}

{ #category : 'running' }
TaskManagerTest >> setUp [
	super setUp.

	taskManager := TodoRessourcesTest new generateTaskManager 
]

{ #category : 'tests' }
TaskManagerTest >> testGetDoneTask [

   | doneTasks |
doneTasks := taskManager getDoneTask.
	self assert: doneTasks size equals: 1.
	self assert: doneTasks first isDone 
]

{ #category : 'tests' }
TaskManagerTest >> testGetInBoxTask [

	| inboxTasks |
	inboxTasks := taskManager getInBoxTask.
	self assert: inboxTasks size equals: 1.
	self assertEmpty: inboxTasks first tags
]

{ #category : 'tests' }
TaskManagerTest >> testGetLateTask [

	| lateTasks |
	lateTasks := taskManager getLateTask.
	self assert: lateTasks size equals: 1.
	self assert: lateTasks first limitDate < DateAndTime now
]

{ #category : 'tests' }
TaskManagerTest >> testGetTodayTask [

	| todayTasks |
	todayTasks := taskManager getDoneTask.
	self assert: todayTasks size equals: 1.
	self assert: todayTasks first limitDate equals: Date today
]

{ #category : 'tests' }
TaskManagerTest >> testGetTrashTask [

	| trashTasks |
	trashTasks := taskManager getTrashTask .
	self assert: trashTasks size equals: 1.
	self assert: trashTasks first isTrash
]

{ #category : 'tests' }
TaskManagerTest >> testTagsNameMatching [

	self assert: (taskManager tagsNameMatching: 'tag') size equals: 3.
	self assert: (taskManager tagsNameMatching: '3') size equals: 1.
	self assert: (taskManager tagsNameMatching: 'ZZZ') size equals: 0
]

{ #category : 'tests' }
TaskManagerTest >> testTaskTitleMatching [

	self assert: (taskManager tasksTitleMatching: 'Task') size equals: 3.
	self assert: (taskManager tasksTitleMatching: 'Done') size equals: 1.
	self assert: (taskManager tasksTitleMatching: 'ZZZ') size equals: 0
]
