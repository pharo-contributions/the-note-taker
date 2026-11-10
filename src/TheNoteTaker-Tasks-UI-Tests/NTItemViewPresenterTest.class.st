"
I test `NTItemViewPresenter` without opening windows. Today is Tuesday 10 November 2026.
"
Class {
	#name : 'NTItemViewPresenterTest',
	#superclass : 'NTTaskUITestCase',
	#category : 'TheNoteTaker-Tasks-UI-Tests',
	#package : 'TheNoteTaker-Tasks-UI-Tests'
}

{ #category : 'helpers' }
NTItemViewPresenterTest >> presenterOn: aView [

	^ (NTItemViewPresenter newApplication: application model: aView)
		  repository: repository;
		  yourself
]

{ #category : 'tests' }
NTItemViewPresenterTest >> testEntriesOfTheView [

	| presenter |
	self task: 'Release' section: 'Pharo' lines: #( '- [ ] notes @due(2026-11-12)' '- [ ] later @due(2026-12-01)' ).
	presenter := self presenterOn: ((NTItemView named: 'This week')
			              period: 'week';
			              yourself).
	self assert: (self titlesOf: presenter entries) equals: #( 'notes' ).
	self assert: (self titlesOf: presenter roots) equals: #( 'notes' )
]

{ #category : 'tests' }
NTItemViewPresenterTest >> testFilterHidesEmptyGroups [

	| presenter |
	self task: 'Release' section: 'Pharo' lines: #( '- [ ] r1 @due(2026-11-12)' ).
	self task: 'Paper' section: 'Research' lines: #( '- [ ] p1 @due(2026-11-11)' ).
	presenter := self presenterOn: self weekGroupedByTask.
	presenter filter: 'r1'.
	self assert: presenter roots asArray equals: #( 'Release' )
]

{ #category : 'tests' }
NTItemViewPresenterTest >> testFilterNarrowsEntries [

	| presenter |
	self task: 'Release' section: 'Pharo' lines: #( '- [ ] notes #release' '- [ ] slides' ).
	presenter := self presenterOn: (NTItemView named: 'All').
	presenter filter: '#release'.
	self assert: (self titlesOf: presenter entries) equals: #( 'notes' ).
	self assert: presenter titleLabel label equals: 'All  (1 of 2)'
]

{ #category : 'tests' }
NTItemViewPresenterTest >> testGroupsAreRoots [

	| presenter |
	self task: 'Release' section: 'Pharo' lines: #( '- [ ] r1 @due(2026-11-12)' '- [ ] r2 @due(2026-11-13)' ).
	self task: 'Paper' section: 'Research' lines: #( '- [ ] p1 @due(2026-11-11)' ).
	presenter := self presenterOn: self weekGroupedByTask.
	self assert: presenter roots asArray equals: #( 'Paper' 'Release' ).
	self assert: (self titlesOf: (presenter childrenOf: 'Release')) equals: #( 'r1' 'r2' )
]

{ #category : 'tests' }
NTItemViewPresenterTest >> testNoViewShowsNothing [

	| presenter |
	self task: 'Release' section: 'Pharo' lines: #( '- [ ] notes' ).
	presenter := (NTItemViewPresenter newApplication: application)
		             repository: repository;
		             yourself.
	self assert: presenter entries isEmpty.
	self assert: presenter titleLabel label equals: ''
]

{ #category : 'tests' }
NTItemViewPresenterTest >> testRequestTaskOfEntry [

	| task presenter requested |
	task := self task: 'Release' section: 'Pharo' lines: #( '- [ ] notes' ).
	presenter := self presenterOn: (NTItemView named: 'All').
	requested := nil.
	presenter whenTaskRequestedDo: [ :each | requested := each ].
	presenter requestTaskOf: presenter entries first.
	self assert: requested equals: task
]

{ #category : 'tests' }
NTItemViewPresenterTest >> testRequestTaskOfGroupDoesNothing [

	| presenter requested |
	self task: 'Release' section: 'Pharo' lines: #( '- [ ] r1 @due(2026-11-12)' ).
	presenter := self presenterOn: self weekGroupedByTask.
	requested := nil.
	presenter whenTaskRequestedDo: [ :each | requested := each ].
	presenter requestTaskOf: 'Release'.
	self assert: requested isNil
]

{ #category : 'tests' }
NTItemViewPresenterTest >> testTitleShowsNameAndCount [

	| presenter |
	self task: 'Release' section: 'Pharo' lines: #( '- [ ] a' '- [ ] b' ).
	presenter := self presenterOn: (NTItemView named: 'All').
	self assert: presenter titleLabel label equals: 'All  (2)'
]

{ #category : 'tests' }
NTItemViewPresenterTest >> testToggleDoneItemUnticksIt [

	| task presenter |
	task := self task: 'Release' section: 'Pharo' lines: #( '- [x] notes @done(2026-11-02)' '- [ ] slides' ).
	presenter := self presenterOn: ((NTItemView named: 'All')
			              done: true;
			              yourself).
	presenter toggle: presenter entries first.
	self deny: task items first isDone
]

{ #category : 'tests' }
NTItemViewPresenterTest >> testToggleMarksDoneAndSaves [

	| task presenter |
	task := self task: 'Release' section: 'Pharo' lines: #( '- [ ] notes' '- [ ] slides' ).
	presenter := self presenterOn: (NTItemView named: 'All').
	presenter toggle: presenter entries first.
	self assert: task items first isDone.
	self assert: task items first doneDate equals: (self nov: 10).
	self assert: ((self fileOf: task) includesSubstring: '- [x] notes').
	self assert: (self titlesOf: presenter entries) equals: #( 'slides' )
]

{ #category : 'tests' }
NTItemViewPresenterTest >> testToggleNotifiesOwner [

	| presenter changed |
	self task: 'Release' section: 'Pharo' lines: #( '- [ ] notes' ).
	presenter := self presenterOn: (NTItemView named: 'All').
	changed := false.
	presenter whenItemsChangedDo: [ changed := true ].
	presenter toggle: presenter entries first.
	self assert: changed
]

{ #category : 'tests' }
NTItemViewPresenterTest >> testUsesTheDayOfTheApplication [

	| presenter |
	self task: 'Release' section: 'Pharo' lines: #( '- [ ] today @due(2026-11-10)' '- [ ] tomorrow @due(2026-11-11)' ).
	presenter := self presenterOn: ((NTItemView named: 'Today')
			              period: 'today';
			              yourself).
	self assert: (self titlesOf: presenter entries) equals: #( 'today' ).
	application today: (self nov: 11).
	presenter refresh.
	self assert: (self titlesOf: presenter entries) equals: #( 'tomorrow' )
]

{ #category : 'helpers' }
NTItemViewPresenterTest >> titlesOf: entries [

	^ entries collect: [ :each | each item title ] as: Array
]

{ #category : 'helpers' }
NTItemViewPresenterTest >> weekGroupedByTask [

	^ (NTItemView named: 'This week')
		  period: 'week';
		  groupBy: 'task';
		  yourself
]
