Class {
	#name : 'TaskManagerTest',
	#superclass : 'TestCase',
	#instVars : [
		'taskManager',
		'memory'
	],
	#category : 'TheNoteTaker-Todo-Tests',
	#package : 'TheNoteTaker-Todo-Tests'
}

{ #category : 'running' }
TaskManagerTest >> setUp [

	super setUp.

	taskManager := TodoRessourcesTest new generateTaskManager.
	memory := FileSystem memory workingDirectory.
	taskManager folderReference: memory
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
TaskManagerTest >> testLoad [

	| newTaskManager |
	taskManager save.
	newTaskManager := TaskManager new folderReference: memory.

	self assertEmpty: newTaskManager tasks.
	self assertEmpty: newTaskManager tags.

	newTaskManager load.

	self assert: taskManager tasks size equals: newTaskManager tasks size.
	taskManager tasks do: [ :each |
			self
				deny:
				(newTaskManager tasks detect: [ :each2 | each title = each2 title ])
				equals: nil ].
	self assert: taskManager tags size equals: newTaskManager tags size.
	taskManager tags do: [ :each |
			self
				deny:
				(newTaskManager tags detect: [ :each2 |
					 each tagName = each2 tagName ])
				equals: nil ]
]

{ #category : 'tests' }
TaskManagerTest >> testLoadWhenCorruptFile [

	| newTaskManager |
	newTaskManager := TaskManager new.

	self assertEmpty: newTaskManager tasks.
	self assertEmpty: newTaskManager tags.

	newTaskManager fileReference writeStreamDo: [ :str |
		str nextPutAll: 'BLABLABLA' ].

	newTaskManager load.

	self assertEmpty: newTaskManager tasks.
	self assertEmpty: newTaskManager tags
]

{ #category : 'tests' }
TaskManagerTest >> testLoadWhenCorruptFileWithWrongObject [

	| newTaskManager |
	newTaskManager := TaskManager new.

	self assertEmpty: newTaskManager tasks.
	self assertEmpty: newTaskManager tags.

	newTaskManager fileReference writeStreamDo: [ :str |
		str << (STON toString: Task new) ].

	newTaskManager load.

	self assertEmpty: newTaskManager tasks.
	self assertEmpty: newTaskManager tags
]

{ #category : 'tests' }
TaskManagerTest >> testLoadWhenNonExistantFile [

	| newTaskManager |
	newTaskManager := TaskManager new.

	self assertEmpty: newTaskManager tasks.
	self assertEmpty: newTaskManager tags.

	newTaskManager load.

	self assertEmpty: newTaskManager tasks.
	self assertEmpty: newTaskManager tags
]

{ #category : 'tests' }
TaskManagerTest >> testSave [

	| ston |
	ston := STON toString: taskManager.

	taskManager save.

	self assert: taskManager fileReference exists.
	self assert: taskManager fileReference contents equals: ston
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
