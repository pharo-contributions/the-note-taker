Class {
	#name : 'TodoTagTest',
	#superclass : 'TestCase',
	#instVars : [
		'tag'
	],
	#category : 'TheNoteTaker-Todo-Tests',
	#package : 'TheNoteTaker-Todo-Tests'
}

{ #category : 'running' }
TodoTagTest >> setUp [
	super setUp.

	tag := TodoTag newNamed: 'test'
]

{ #category : 'tests' }
TodoTagTest >> testAddTask [

	| task |
	task := Task new.
	self assertEmpty: tag tasks.
	tag addTask: task.
	self assert: tag tasks size equals: 1.
	self assert: (tag tasks includes: task).
	
   self assert: task tags size equals: 1.
   self assert: (task tags includes: tag).
]

{ #category : 'tests' }
TodoTagTest >> testHasTask [

	| task |
	task := Task new.
	self deny: (tag hasTask: task).
	tag addTask: task.
	self assert: (tag hasTask: task).
]

{ #category : 'tests' }
TodoTagTest >> testRemoveTask [

	| task |
	task := Task new.
	tag addTask: task.
	self assert: tag tasks size equals: 1.
	tag removeTask: task.
	self assertEmpty: tag tasks.
]
