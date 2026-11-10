"
Tests of the task model and file format of the redesigned Todo part (TheNoteTaker-Tasks).
"
Class {
	#name : 'NTTaskItemTest',
	#superclass : 'NTTaskTestCase',
	#category : 'TheNoteTaker-Tasks-Tests',
	#package : 'TheNoteTaker-Tasks-Tests'
}

{ #category : 'tests' }
NTTaskItemTest >> testAddTag [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item addTag: 'work'.
	item addTag: 'bob'.
	self assert: item tags asArray equals: #( 'work' 'bob' ).
	self assert: (item hasTag: 'work')
]

{ #category : 'tests' }
NTTaskItemTest >> testAddTagTwiceKeepsOne [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item addTag: 'work'.
	item addTag: 'work'.
	self assert: item tags size equals: 1
]

{ #category : 'tests' }
NTTaskItemTest >> testDisplayAnnotationsHideDoneAndCreated [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item createdDate: (self nov: 4).
	item due: (self nov: 12).
	item markDoneOn: (self nov: 8).
	item addTag: 'work'.
	self assert: item displayAnnotations equals: '@due(2026-11-12) #work'
]

{ #category : 'tests' }
NTTaskItemTest >> testDue [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item due: (self nov: 15).
	self assert: item due equals: (self nov: 15).
	self assert: (item keyAt: 'due') equals: '2026-11-15'
]

{ #category : 'tests' }
NTTaskItemTest >> testDueAbsentIsNil [

	self assert: (NTTaskItem title: 'Send slides') due isNil
]

{ #category : 'tests' }
NTTaskItemTest >> testDueAcceptsDateAndTime [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item due: (DateAndTime
			 year: 2026
			 month: 11
			 day: 15
			 hour: 18
			 minute: 0).
	self assert: item due equals: (self nov: 15)
]

{ #category : 'tests' }
NTTaskItemTest >> testDueAcceptsDateArithmetic [
	"Date arithmetic answers a Timespan; it is stored as its date."

	| item |
	item := NTTaskItem title: 'Send slides'.
	item due: (self nov: 14) + 1 day.
	self assert: (item keyAt: 'due') equals: '2026-11-15'
]

{ #category : 'tests' }
NTTaskItemTest >> testDueSetToNilRemovesKey [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item due: (self nov: 15).
	item due: nil.
	self deny: (item hasKey: 'due')
]

{ #category : 'tests' }
NTTaskItemTest >> testDueWithInvalidDateIsNil [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item keyAt: 'due' put: 'soon'.
	self assert: item due isNil
]

{ #category : 'tests' }
NTTaskItemTest >> testIsLateOn [

	| item |
	item := NTTaskItem title: 'Send slides'.
	self deny: (item isLateOn: (self nov: 10)).
	item due: (self nov: 9).
	self assert: (item isLateOn: (self nov: 10)).
	self deny: (item isLateOn: (self nov: 9)).
	item markDoneOn: (self nov: 10).
	self deny: (item isLateOn: (self nov: 10))
]

{ #category : 'tests' }
NTTaskItemTest >> testIsVisibleOn [

	| item |
	item := NTTaskItem title: 'Call plumber'.
	self assert: (item isVisibleOn: (self nov: 10)).
	item start: (self nov: 20).
	self deny: (item isVisibleOn: (self nov: 10)).
	self assert: (item isVisibleOn: (self nov: 20))
]

{ #category : 'tests' }
NTTaskItemTest >> testKeyAtAbsentKeyIsNil [

	self assert: ((NTTaskItem title: 'Send slides') keyAt: 'due') isNil
]

{ #category : 'tests' }
NTTaskItemTest >> testKeyAtPutAppendsNewKey [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item addTag: 'work'.
	item keyAt: 'due' put: '2026-11-15'.
	self assert: (item annotations collect: [ :each | each name ] as: Array) equals: #( 'work' 'due' )
]

{ #category : 'tests' }
NTTaskItemTest >> testKeyAtPutReplacesValueInPlace [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item keyAt: 'due' put: '2026-11-15'.
	item addTag: 'work'.
	item keyAt: 'due' put: '2026-11-20'.
	self assert: (item annotations collect: [ :each | each name ] as: Array) equals: #( 'due' 'work' ).
	self assert: (item keyAt: 'due') equals: '2026-11-20'
]

{ #category : 'tests' }
NTTaskItemTest >> testMarkDoneAddsDoneKey [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item markDoneOn: (self nov: 8).
	self assert: item isDone.
	self assert: item doneDate equals: (self nov: 8).
	self assert: (item keyAt: 'done') equals: '2026-11-08'
]

{ #category : 'tests' }
NTTaskItemTest >> testMarkDoneKeepsExistingDoneDate [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item keyAt: 'done' put: '2026-11-02'.
	item markDoneOn: (self nov: 8).
	self assert: item doneDate equals: (self nov: 2)
]

{ #category : 'tests' }
NTTaskItemTest >> testMarkUndoneRemovesDoneKey [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item markDoneOn: (self nov: 8).
	item markUndone.
	self deny: item isDone.
	self deny: (item hasKey: 'done').
	self assert: item doneDate isNil
]

{ #category : 'tests' }
NTTaskItemTest >> testNewItemIsNotDone [

	| item |
	item := NTTaskItem title: 'Send slides'.
	self deny: item isDone.
	self assert: item title equals: 'Send slides'.
	self assert: item description isEmpty.
	self assert: item annotations isEmpty
]

{ #category : 'tests' }
NTTaskItemTest >> testNotWaitingOthers [

	self deny: (NTTaskItem title: 'Review chapter') isWaitingOthers
]

{ #category : 'tests' }
NTTaskItemTest >> testNoteUrlAndEvery [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item note: '2026-11-03_meeting_with_bob.md'.
	item url: 'https://pharo.org'.
	item every: 'month'.
	self assert: item note equals: '2026-11-03_meeting_with_bob.md'.
	self assert: item url equals: 'https://pharo.org'.
	self assert: item every equals: 'month'
]

{ #category : 'tests' }
NTTaskItemTest >> testPriority [

	| high low normal |
	high := (NTTaskItem title: 'a')
		        prio: 'high';
		        yourself.
	low := (NTTaskItem title: 'b')
		       prio: 'low';
		       yourself.
	normal := NTTaskItem title: 'c'.
	self assert: high isHighPriority.
	self deny: high isLowPriority.
	self assert: low isLowPriority.
	self deny: normal isHighPriority.
	self deny: normal isLowPriority
]

{ #category : 'tests' }
NTTaskItemTest >> testRemoveKey [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item keyAt: 'due' put: '2026-11-15'.
	item removeKey: 'due'.
	self deny: (item hasKey: 'due')
]

{ #category : 'tests' }
NTTaskItemTest >> testRemoveTag [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item addTag: 'work'.
	item removeTag: 'work'.
	self deny: (item hasTag: 'work')
]

{ #category : 'tests' }
NTTaskItemTest >> testStartAndCreatedDates [

	| item |
	item := NTTaskItem title: 'Call plumber'.
	item start: (self nov: 20).
	item createdDate: (self nov: 4).
	self assert: item start equals: (self nov: 20).
	self assert: item createdDate equals: (self nov: 4)
]

{ #category : 'tests' }
NTTaskItemTest >> testTagsAndKeysAreDistinct [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item addTag: 'due'.
	self deny: (item hasKey: 'due').
	self assert: (item hasTag: 'due')
]

{ #category : 'tests' }
NTTaskItemTest >> testUnknownKeyIsKept [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item keyAt: 'mood' put: 'happy'.
	self assert: (item hasKey: 'mood').
	self assert: (item keyAt: 'mood') equals: 'happy'
]

{ #category : 'tests' }
NTTaskItemTest >> testValuelessKey [

	| item |
	item := NTTaskItem title: 'Get contract'.
	item keyAt: 'waitingOthers' put: nil.
	self assert: (item hasKey: 'waitingOthers').
	self assert: item isWaitingOthers.
	self assert: item waitingOthers isNil
]

{ #category : 'tests' }
NTTaskItemTest >> testWaitingOthersWithName [

	| item |
	item := NTTaskItem title: 'Review chapter'.
	item waitingOthers: 'Bob'.
	self assert: item isWaitingOthers.
	self assert: item waitingOthers equals: 'Bob'
]
