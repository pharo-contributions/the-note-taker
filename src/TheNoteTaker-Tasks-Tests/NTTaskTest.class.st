"
Tests of the task model and file format of the redesigned Todo part (TheNoteTaker-Tasks).
"
Class {
	#name : 'NTTaskTest',
	#superclass : 'NTTaskTestCase',
	#category : 'TheNoteTaker-Tasks-Tests',
	#package : 'TheNoteTaker-Tasks-Tests'
}

{ #category : 'tests' }
NTTaskTest >> testAbandonedIsNeverChangedByUpdate [

	| task |
	task := NTTask title: 'Old grant idea'.
	(task addItemTitled: 'Draft' on: (self nov: 1)) markDoneOn: (self nov: 2).
	task abandon.
	task updateStatusOn: (self nov: 10).
	self assert: task isAbandoned.
	self assert: task isClosed.
	self assert: task finishedDate isNil
]

{ #category : 'tests' }
NTTaskTest >> testAddItemTitledOnAddsCreatedKey [

	| task item |
	task := NTTask title: 'Pharo 14 release'.
	item := task addItemTitled: 'Freeze API' on: (self nov: 4).
	self assert: task items asArray equals: { item }.
	self assert: item createdDate equals: (self nov: 4)
]

{ #category : 'tests' }
NTTaskTest >> testAddingItemReopensTask [

	| task |
	task := NTTask title: 'Move office'.
	(task addItemTitled: 'Pack books' on: (self nov: 1)) markDoneOn: (self nov: 5).
	task updateStatusOn: (self nov: 10).
	task addItemTitled: 'Clean the old office' on: (self nov: 11).
	task updateStatusOn: (self nov: 11).
	self assert: task isOpen
]

{ #category : 'tests' }
NTTaskTest >> testAllItemsDoneFinishesTask [

	| task |
	task := NTTask title: 'Move office'.
	(task addItemTitled: 'Book movers' on: (self nov: 1)) markDoneOn: (self nov: 3).
	(task addItemTitled: 'Pack books' on: (self nov: 1)) markDoneOn: (self nov: 5).
	task updateStatusOn: (self nov: 10).
	self assert: task isFinished.
	self assert: task isClosed
]

{ #category : 'tests' }
NTTaskTest >> testAllTags [

	| task |
	task := NTTask title: 'Pharo 14 release'.
	(task addItemTitled: 'a' on: (self nov: 4))
		addTag: 'release';
		addTag: 'work'.
	(task addItemTitled: 'b' on: (self nov: 4)) addTag: 'work'.
	self assert: task allTags asSet equals: #( 'release' 'work' ) asSet
]

{ #category : 'tests' }
NTTaskTest >> testClosedSectionName [

	self assert: NTTask closedSectionName equals: 'Finished / Abandoned'
]

{ #category : 'tests' }
NTTaskTest >> testDoneCount [

	| task |
	task := NTTask title: 'Pharo 14 release'.
	(task addItemTitled: 'a' on: (self nov: 4)) markDoneOn: (self nov: 5).
	task addItemTitled: 'b' on: (self nov: 4).
	self assert: task doneCount equals: 1.
	self assert: task itemCount equals: 2
]

{ #category : 'tests' }
NTTaskTest >> testEmptySectionIsUnsorted [

	| task |
	task := NTTask title: 'Buy cables'.
	task section: ''.
	self assert: task sectionName equals: 'Unsorted'
]

{ #category : 'tests' }
NTTaskTest >> testFinishedDateIsKeptOnLaterUpdates [

	| task |
	task := NTTask title: 'Move office'.
	(task addItemTitled: 'Pack books' on: (self nov: 1)) markDoneOn: (self nov: 5).
	task updateStatusOn: (self nov: 10).
	task finishedDate: (self nov: 6).
	task updateStatusOn: (self nov: 12).
	self assert: task finishedDate equals: (self nov: 6)
]

{ #category : 'tests' }
NTTaskTest >> testFinishedDateIsLatestDoneDate [

	| task |
	task := NTTask title: 'Move office'.
	(task addItemTitled: 'Pack books' on: (self nov: 1)) markDoneOn: (self nov: 5).
	(task addItemTitled: 'Book movers' on: (self nov: 1)) markDoneOn: (self nov: 3).
	task updateStatusOn: (self nov: 10).
	self assert: task finishedDate equals: (self nov: 5)
]

{ #category : 'tests' }
NTTaskTest >> testFinishedDateWithoutDoneDatesIsUpdateDate [

	| task item |
	task := NTTask title: 'Move office'.
	item := task addItem: (NTTaskItem title: 'Pack books').
	item isDone: true.
	task updateStatusOn: (self nov: 10).
	self assert: task finishedDate equals: (self nov: 10)
]

{ #category : 'tests' }
NTTaskTest >> testMoveItemTo [

	| task a b c |
	task := NTTask title: 'Pharo 14 release'.
	a := task addItemTitled: 'a' on: (self nov: 4).
	b := task addItemTitled: 'b' on: (self nov: 4).
	c := task addItemTitled: 'c' on: (self nov: 4).
	task moveItem: c to: 1.
	self assert: task items asArray equals: {
			c.
			a.
			b }
]

{ #category : 'tests' }
NTTaskTest >> testNewTaskIsOpen [

	| task |
	task := NTTask title: 'Pharo 14 release'.
	self assert: task isOpen.
	self deny: task isClosed.
	self assert: task items isEmpty.
	self assert: task finishedDate isNil
]

{ #category : 'tests' }
NTTaskTest >> testRemoveItem [

	| task item |
	task := NTTask title: 'Pharo 14 release'.
	item := task addItemTitled: 'Freeze API' on: (self nov: 4).
	task removeItem: item.
	self assert: task items isEmpty
]

{ #category : 'tests' }
NTTaskTest >> testReopenAbandonedTask [

	| task |
	task := NTTask title: 'Old grant idea'.
	task addItemTitled: 'Draft' on: (self nov: 1).
	task abandon.
	task reopen.
	self assert: task isOpen
]

{ #category : 'tests' }
NTTaskTest >> testReplaceContentsFromKeepsIdentityAndFile [
	"Applying a parsed version of a task (from the Text tab) keeps the task object and its file."

	| task file parsed |
	task := NTTask title: 'Old'.
	file := FileSystem memory root / 'a.md'.
	task fileReference: file.
	task addItemTitled: 'old item' on: (self nov: 1).
	parsed := NTTask title: 'New'.
	parsed section: 'Pharo'.
	parsed otherMetadata at: 'owner' put: 'Stef'.
	parsed addItemTitled: 'new item' on: (self nov: 2).
	task replaceContentsFrom: parsed.
	self assert: task title equals: 'New'.
	self assert: task section equals: 'Pharo'.
	self assert: (task otherMetadata at: 'owner') equals: 'Stef'.
	self assert: (task items collect: [ :each | each title ] as: Array) equals: #( 'new item' ).
	self assert: task fileReference equals: file
]

{ #category : 'tests' }
NTTaskTest >> testSectionNameDefaultsToUnsorted [

	| task |
	task := NTTask title: 'Buy cables'.
	self assert: task section isNil.
	self assert: task sectionName equals: 'Unsorted'.
	task section: 'Home'.
	self assert: task sectionName equals: 'Home'
]

{ #category : 'tests' }
NTTaskTest >> testTaskWithOpenItemStaysOpen [

	| task |
	task := NTTask title: 'Pharo 14 release'.
	(task addItemTitled: 'Freeze API' on: (self nov: 1)) markDoneOn: (self nov: 2).
	task addItemTitled: 'Write notes' on: (self nov: 1).
	task updateStatusOn: (self nov: 10).
	self assert: task isOpen
]

{ #category : 'tests' }
NTTaskTest >> testTaskWithoutItemsStaysOpen [

	| task |
	task := NTTask title: 'Pharo 14 release'.
	task updateStatusOn: (self nov: 10).
	self assert: task isOpen
]

{ #category : 'tests' }
NTTaskTest >> testUntickingReopensTask [

	| task item |
	task := NTTask title: 'Move office'.
	item := task addItemTitled: 'Pack books' on: (self nov: 1).
	item markDoneOn: (self nov: 5).
	task updateStatusOn: (self nov: 10).
	item markUndone.
	task updateStatusOn: (self nov: 11).
	self assert: task isOpen.
	self assert: task finishedDate isNil
]
