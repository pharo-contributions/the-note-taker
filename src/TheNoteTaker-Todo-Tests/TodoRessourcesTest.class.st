Class {
	#name : 'TodoRessourcesTest',
	#superclass : 'Object',
	#category : 'TheNoteTaker-Todo-Tests',
	#package : 'TheNoteTaker-Todo-Tests'
}

{ #category : 'as yet unclassified' }
TodoRessourcesTest >> doneTodayTask [

	^ Task new
		  title: 'DoneTask';
		  description: 'This is a done task';
		limitDate: Date today;
		  isDone: true
]

{ #category : 'as yet unclassified' }
TodoRessourcesTest >> generateTaskManager [

	| taskManager tag1 tag2 tag3 task1 task2 task3 |
	taskManager := TaskManager new.

	tag1 := taskManager addTagNamed: 'tag1'.
	tag2 := taskManager addTagNamed: 'tag2'.
	tag3 := taskManager addTagNamed: 'tag3'.

	task1 := taskManager addTask: self doneTodayTask.
	task2 := taskManager addTask: self trashTask.
	task3 := taskManager addTask: self lateTask.

	tag1 addTask: task1.
	tag2 addTask: task1.
	tag3 addTask: task3.

	^ taskManager
]

{ #category : 'as yet unclassified' }
TodoRessourcesTest >> lateTask [

	^ Task new
		  title: 'LateTask';
		  description: 'This is a late task';
		limitDate: Date yesterday
]

{ #category : 'as yet unclassified' }
TodoRessourcesTest >> trashTask [

	^ Task new
		  title: 'TrashTask';
		  description: 'This is a trash task';
		isTrash: true
]
