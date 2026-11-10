"
Tests of the task presenters (TheNoteTaker-Tasks-UI), on an in-memory task repository.
"
Class {
	#name : 'NTTaskItemPresenterTest',
	#superclass : 'NTTaskUITestCase',
	#category : 'TheNoteTaker-Tasks-UI-Tests',
	#package : 'TheNoteTaker-Tasks-UI-Tests'
}

{ #category : 'helpers' }
NTTaskItemPresenterTest >> presenterOn: anItem [

	^ NTTaskItemPresenter newApplication: application model: anItem
]

{ #category : 'helpers' }
NTTaskItemPresenterTest >> sampleItem [

	| item |
	item := NTTaskItem title: 'Write release notes'.
	item description: 'Mention the compiler.'.
	item due: (self nov: 15).
	item prio: 'high'.
	item waitingOthers: 'Marcus'.
	item note: '2026-11-03_meeting.md'.
	item keyAt: 'mood' put: 'calm'.
	item addTag: 'release'.
	^ item
]

{ #category : 'tests' }
NTTaskItemPresenterTest >> testChangeDescription [

	| item presenter |
	item := self sampleItem.
	presenter := self presenterOn: item.
	presenter descriptionText text: 'New text'.
	self assert: item description equals: 'New text'
]

{ #category : 'tests' }
NTTaskItemPresenterTest >> testChangeDue [

	| item presenter changes |
	item := self sampleItem.
	presenter := self presenterOn: item.
	changes := 0.
	presenter whenItemChangedDo: [ changes := changes + 1 ].
	presenter dueDate date: (self nov: 20).
	self assert: item due equals: (self nov: 20).
	self assert: changes equals: 1
]

{ #category : 'tests' }
NTTaskItemPresenterTest >> testChangeNoteUrlEvery [

	| item presenter |
	item := self sampleItem.
	presenter := self presenterOn: item.
	presenter urlInput text: 'https://pharo.org'.
	presenter everyInput text: 'month'.
	presenter noteInput text: ''.
	self assert: item url equals: 'https://pharo.org'.
	self assert: item every equals: 'month'.
	self deny: (item hasKey: 'note')
]

{ #category : 'tests' }
NTTaskItemPresenterTest >> testChangePriority [

	| item presenter |
	item := self sampleItem.
	presenter := self presenterOn: item.
	presenter prioList selectItem: 'low'.
	self assert: item isLowPriority.
	presenter prioList selectItem: nil.
	self deny: (item hasKey: 'prio')
]

{ #category : 'tests' }
NTTaskItemPresenterTest >> testChangeStart [

	| item presenter |
	item := self sampleItem.
	presenter := self presenterOn: item.
	presenter startDate date: (self nov: 12).
	self assert: item start equals: (self nov: 12)
]

{ #category : 'tests' }
NTTaskItemPresenterTest >> testClearDueRemovesKey [

	| item presenter |
	item := self sampleItem.
	presenter := self presenterOn: item.
	presenter dueDate date: nil.
	self deny: (item hasKey: 'due')
]

{ #category : 'tests' }
NTTaskItemPresenterTest >> testEditOtherKeyValue [

	| item presenter |
	item := self sampleItem.
	presenter := self presenterOn: item.
	presenter otherKey: (item keyNamed: 'mood') value: 'tired'.
	self assert: (item keyAt: 'mood') equals: 'tired'
]

{ #category : 'tests' }
NTTaskItemPresenterTest >> testOtherKeysListsUnknownKeysOnly [

	| presenter |
	presenter := self presenterOn: self sampleItem.
	self assert: (presenter otherKeysTable items collect: [ :each | each name ] as: Array) equals: #( 'mood' )
]

{ #category : 'tests' }
NTTaskItemPresenterTest >> testSettingModelShowsIt [

	| presenter |
	presenter := self presenterOn: (NTTaskItem title: 'x').
	presenter model: self sampleItem.
	self assert: presenter dueDate date equals: (self nov: 15)
]

{ #category : 'tests' }
NTTaskItemPresenterTest >> testShowingItemDoesNotSignalChange [

	| presenter changes |
	presenter := self presenterOn: nil.
	changes := 0.
	presenter whenItemChangedDo: [ changes := changes + 1 ].
	presenter model: self sampleItem.
	self assert: changes equals: 0
]

{ #category : 'tests' }
NTTaskItemPresenterTest >> testShowsItem [

	| presenter |
	presenter := self presenterOn: self sampleItem.
	self assert: presenter descriptionText text asString equals: 'Mention the compiler.'.
	self assert: presenter dueDate date equals: (self nov: 15).
	self assert: presenter startDate date isNil.
	self assert: presenter prioList selectedItem equals: 'high'.
	self assert: presenter waitingCheckBox state.
	self assert: presenter waitingInput text equals: 'Marcus'.
	self assert: presenter noteInput text equals: '2026-11-03_meeting.md'.
	self assert: presenter urlInput text isEmpty
]

{ #category : 'tests' }
NTTaskItemPresenterTest >> testTagsAreKept [

	| item presenter |
	item := self sampleItem.
	presenter := self presenterOn: item.
	presenter dueDate date: nil.
	self assert: (item hasTag: 'release')
]

{ #category : 'tests' }
NTTaskItemPresenterTest >> testWaitingOthersName [

	| item presenter |
	item := NTTaskItem title: 'Get contract'.
	presenter := self presenterOn: item.
	presenter waitingInput text: 'Bob'.
	self assert: item waitingOthers equals: 'Bob'.
	self assert: presenter waitingCheckBox state
]

{ #category : 'tests' }
NTTaskItemPresenterTest >> testWaitingOthersOff [

	| item presenter |
	item := self sampleItem.
	presenter := self presenterOn: item.
	presenter waitingCheckBox state: false.
	self deny: item isWaitingOthers
]

{ #category : 'tests' }
NTTaskItemPresenterTest >> testWaitingOthersWithoutName [

	| item presenter |
	item := NTTaskItem title: 'Get contract'.
	presenter := self presenterOn: item.
	presenter waitingCheckBox state: true.
	self assert: item isWaitingOthers.
	self assert: item waitingOthers isNil
]

{ #category : 'tests' }
NTTaskItemPresenterTest >> testWithoutItem [

	| presenter |
	presenter := self presenterOn: nil.
	self assert: presenter descriptionText text isEmpty.
	self assert: presenter dueDate date isNil.
	self assert: presenter otherKeysTable items isEmpty
]
