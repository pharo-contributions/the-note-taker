"
I test `NTItemView`: which items a view selects in a repository on a given day, and how it groups and sorts them. In these tests, today is Tuesday 10 November 2026.
"
Class {
	#name : 'NTItemViewTest',
	#superclass : 'NTTaskTestCase',
	#instVars : [
		'repository'
	],
	#category : 'TheNoteTaker-Tasks-Tests-Views',
	#package : 'TheNoteTaker-Tasks-Tests',
	#tag : 'Views'
}

{ #category : 'running' }
NTItemViewTest >> setUp [

	super setUp.
	repository := NTTaskRepository on: FileSystem memory root / 'todos'
]

{ #category : 'helpers' }
NTItemViewTest >> task: aTitle section: aSection lines: itemLines [
	"Create and save a task whose items are read from checkbox lines."

	| task reader |
	reader := NTTaskReader new.
	task := repository newTaskTitled: aTitle at: (self timeOn: 4).
	task section: aSection.
	itemLines do: [ :each | task addItem: (reader readItemLine: each) ].
	repository save: task at: (self timeOn: 4).
	^ task
]

{ #category : 'tests - selecting' }
NTItemViewTest >> testClosedTasksAreExcluded [

	| abandoned |
	self task: 'Finished' section: 'Pharo' lines: #( '- [x] f1 @done(2026-11-02)' ).
	abandoned := self task: 'Abandoned' section: 'Pharo' lines: #( '- [ ] g1' ).
	abandoned abandon.
	self task: 'Open' section: 'Pharo' lines: #( '- [ ] o1' ).
	self
		assert: (self titlesIn: (self view
					  done: true;
					  yourself))
		equals: #( 'o1' )
]

{ #category : 'tests' }
NTItemViewTest >> testCopyFieldsFrom [

	| view other |
	other := (NTItemView named: 'Other')
		         sections: #( 'Pharo' );
		         tags: #( 'work' );
		         period: 'week';
		         includeNoDue: true;
		         has: #( 'prio(high)' );
		         done: true;
		         groupBy: 'task';
		         sortBy: 'due';
		         yourself.
	view := NTItemView named: 'Mine'.
	view copyFieldsFrom: other.
	self
		assert: (NTItemViewSet new
				 add: view;
				 text)
		equals: (NTItemViewSet new
				 add: other;
				 text)
]

{ #category : 'tests - selecting' }
NTItemViewTest >> testDoneAlsoListsDoneItems [

	self task: 'A' section: 'Pharo' lines: #( '- [ ] a1' '- [x] a2 @done(2026-11-02)' ).
	self
		assert: (self titlesIn: (self view
					  done: true;
					  yourself))
		equals: #( 'a1' 'a2' )
]

{ #category : 'tests - selecting' }
NTItemViewTest >> testEntryKnowsItsTask [

	| task entries |
	task := self task: 'A' section: nil lines: #( '- [ ] a1' ).
	entries := self view entriesIn: repository on: self today.
	self assert: entries first task equals: task.
	self assert: entries first item equals: task items first
]

{ #category : 'tests - selecting' }
NTItemViewTest >> testFutureStartIsHidden [

	self task: 'A' section: nil lines: #( '- [ ] later @start(2026-11-11)' '- [ ] now @start(2026-11-10)'
	   '- [ ] free' ).
	self assert: (self titlesIn: self view) equals: #( 'now' 'free' )
]

{ #category : 'tests - sorting and grouping' }
NTItemViewTest >> testGroupBySection [

	| groups |
	self task: 'Release' section: 'Pharo' lines: #( '- [ ] r1' ).
	self task: 'Cables' section: nil lines: #( '- [ ] c1' ).
	self task: 'Fix CI' section: 'Pharo' lines: #( '- [ ] f1' ).
	groups := (self view
		           groupBy: 'section';
		           yourself) groupsIn: repository on: self today.
	self assert: groups keys asArray equals: #( 'Unsorted' 'Pharo' ).
	self assert: (self titlesOf: (groups at: 'Pharo')) equals: #( 'f1' 'r1' )
]

{ #category : 'tests - sorting and grouping' }
NTItemViewTest >> testGroupByTask [

	| groups |
	self task: 'Release' section: 'Pharo' lines: #( '- [ ] r1' '- [ ] r2' ).
	self task: 'Paper' section: 'Research' lines: #( '- [ ] p1' ).
	groups := (self view
		           groupBy: 'task';
		           yourself) groupsIn: repository on: self today.
	self assert: groups keys asArray equals: #( 'Paper' 'Release' ).
	self assert: (self titlesOf: (groups at: 'Release')) equals: #( 'r1' 'r2' )
]

{ #category : 'tests - sorting and grouping' }
NTItemViewTest >> testGroupByWaitingOthers [

	| groups |
	self
		task: 'A'
		section: nil
		lines: #( '- [ ] m1 @waitingOthers(Marcus)' '- [ ] x1 @waitingOthers' '- [ ] m2 @waitingOthers(Marcus)' ).
	groups := (self view
		           groupBy: 'waitingOthers';
		           yourself) groupsIn: repository on: self today.
	self assert: groups keys asArray equals: #( 'Marcus' 'Someone' ).
	self assert: (self titlesOf: (groups at: 'Marcus')) equals: #( 'm1' 'm2' )
]

{ #category : 'tests - selecting' }
NTItemViewTest >> testHasKey [

	self task: 'A' section: nil lines: #( '- [ ] w1 @waitingOthers' '- [ ] w2 @waitingOthers(Marcus)'
	   '- [ ] alone' ).
	self
		assert: (self titlesIn: (self view
					  has: #( 'waitingOthers' );
					  yourself))
		equals: #( 'w1' 'w2' )
]

{ #category : 'tests - selecting' }
NTItemViewTest >> testHasKeyWithValue [

	self task: 'A' section: nil lines: #( '- [ ] h @prio(high)' '- [ ] l @prio(low)' '- [ ] n' ).
	self
		assert: (self titlesIn: (self view
					  has: #( 'prio(high)' );
					  yourself))
		equals: #( 'h' )
]

{ #category : 'tests - periods' }
NTItemViewTest >> testIncludeNoDue [

	self task: 'A' section: nil lines: #( '- [ ] today @due(2026-11-10)' '- [ ] later @due(2026-12-24)'
	   '- [ ] none' ).
	self
		assert: (self titlesIn: (self view
					  period: 'today';
					  includeNoDue: true;
					  yourself))
		equals: #( 'today' 'none' )
]

{ #category : 'tests - periods' }
NTItemViewTest >> testIsValidPeriod [

	#( nil 'today' 'week' 'month' 'overdue' 'next 3 days' 'next 1 days' ) do: [ :each |
		self assert: (NTItemView isValidPeriod: each) ].
	#( 'tomorrow' 'next days' 'next 0 days' 'next x days' 'Today' ) do: [ :each | self deny: (NTItemView isValidPeriod: each) ]
]

{ #category : 'tests - selecting' }
NTItemViewTest >> testNoConditionListsOpenItemsInFileOrder [

	self task: 'A' section: 'Pharo' lines: #( '- [ ] a1' '- [x] a2 @done(2026-11-02)' '- [ ] a3' ).
	self task: 'B' section: nil lines: #( '- [ ] b1' ).
	self assert: (self titlesIn: self view) equals: #( 'a1' 'a3' 'b1' )
]

{ #category : 'tests - sorting and grouping' }
NTItemViewTest >> testNoGroupByGivesOneGroup [

	| groups |
	self task: 'A' section: nil lines: #( '- [ ] a1' ).
	groups := self view groupsIn: repository on: self today.
	self assert: groups keys asArray equals: #( nil ).
	self assert: (self titlesOf: (groups at: nil)) equals: #( 'a1' )
]

{ #category : 'tests - periods' }
NTItemViewTest >> testPeriodMonth [

	self
		task: 'A'
		section: nil
		lines:
			#( '- [ ] october @due(2026-10-31)' '- [ ] first @due(2026-11-01)' '- [ ] last @due(2026-11-30)' '- [ ] december @due(2026-12-01)'
			   '- [ ] lastYear @due(2025-11-15)' ).
	self
		assert: (self titlesIn: (self view
					  period: 'month';
					  yourself))
		equals: #( 'first' 'last' )
]

{ #category : 'tests - periods' }
NTItemViewTest >> testPeriodNextDaysStartsToday [
	"'next 3 days' is today and the two following days."

	self
		task: 'A'
		section: nil
		lines:
		#( '- [ ] yesterday @due(2026-11-09)' '- [ ] today @due(2026-11-10)' '- [ ] third @due(2026-11-12)'
		   '- [ ] fourth @due(2026-11-13)' ).
	self
		assert: (self titlesIn: (self view
					  period: 'next 3 days';
					  yourself))
		equals: #( 'today' 'third' )
]

{ #category : 'tests - periods' }
NTItemViewTest >> testPeriodOverdue [

	self
		task: 'A'
		section: nil
		lines: #( '- [ ] late @due(2026-11-09)' '- [ ] today @due(2026-11-10)' '- [ ] startedLongAgo @start(2026-10-01)'
			   '- [x] lateButDone @due(2026-11-01) @done(2026-11-02)' ).
	self
		assert: (self titlesIn: (self view
					  period: 'overdue';
					  done: true;
					  yourself))
		equals: #( 'late' )
]

{ #category : 'tests - periods' }
NTItemViewTest >> testPeriodToday [

	self
		task: 'A'
		section: nil
		lines: #( '- [ ] yesterday @due(2026-11-09)' '- [ ] today @due(2026-11-10)' '- [ ] tomorrow @due(2026-11-11)'
			   '- [ ] none' ).
	self
		assert: (self titlesIn: (self view
					  period: 'today';
					  yourself))
		equals: #( 'today' )
]

{ #category : 'tests - periods' }
NTItemViewTest >> testPeriodUsesStartWhenNoDue [

	self
		task: 'A'
		section: nil
		lines: #( '- [ ] startsToday @start(2026-11-10)' '- [ ] dueWins @start(2026-11-10) @due(2026-11-20)' ).
	self
		assert: (self titlesIn: (self view
					  period: 'today';
					  yourself))
		equals: #( 'startsToday' )
]

{ #category : 'tests - periods' }
NTItemViewTest >> testPeriodWeekIsMondayToSunday [

	self
		task: 'A'
		section: nil
		lines: #( '- [ ] sunBefore @due(2026-11-08)' '- [ ] monday @due(2026-11-09)' '- [ ] sunday @due(2026-11-15)'
			   '- [ ] mondayAfter @due(2026-11-16)' ).
	self
		assert: (self titlesIn: (self view
					  period: 'week';
					  yourself))
		equals: #( 'monday' 'sunday' )
]

{ #category : 'tests - periods' }
NTItemViewTest >> testPeriodWeekOnSunday [

	self task: 'A' section: nil lines: #( '- [ ] monday @due(2026-11-09)' '- [ ] mondayAfter @due(2026-11-16)' ).
	self
		assert: (self titlesOf: ((self view
					   period: 'week';
					   yourself) entriesIn: repository on: (self nov: 15)))
		equals: #( 'monday' )
]

{ #category : 'tests - selecting' }
NTItemViewTest >> testSectionsKeepThoseSections [

	self task: 'A' section: 'Pharo' lines: #( '- [ ] a1' ).
	self task: 'B' section: 'Research' lines: #( '- [ ] b1' ).
	self task: 'C' section: nil lines: #( '- [ ] c1' ).
	self
		assert: (self titlesIn: (self view
					  sections: #( 'Pharo' 'Unsorted' );
					  yourself))
		equals: #( 'a1' 'c1' )
]

{ #category : 'tests - sorting and grouping' }
NTItemViewTest >> testSortByCreatedOldestFirst [

	self task: 'A' section: nil lines: #( '- [ ] recent @created(2026-11-08)' '- [ ] none' '- [ ] old @created(2026-10-01)' ).
	self
		assert: (self titlesIn: (self view
					  sortBy: 'created';
					  yourself))
		equals: #( 'old' 'recent' 'none' )
]

{ #category : 'tests - sorting and grouping' }
NTItemViewTest >> testSortByDuePutsNoDueLast [

	self task: 'A' section: nil lines: #( '- [ ] none' '- [ ] late @due(2026-11-20)' '- [ ] soon @due(2026-11-11)' ).
	self
		assert: (self titlesIn: (self view
					  sortBy: 'due';
					  yourself))
		equals: #( 'soon' 'late' 'none' )
]

{ #category : 'tests - sorting and grouping' }
NTItemViewTest >> testSortByPrio [

	self task: 'A' section: nil lines: #( '- [ ] low @prio(low)' '- [ ] normal1' '- [ ] high @prio(high)' '- [ ] normal2' ).
	self
		assert: (self titlesIn: (self view
					  sortBy: 'prio';
					  yourself))
		equals: #( 'high' 'normal1' 'normal2' 'low' )
]

{ #category : 'tests - selecting' }
NTItemViewTest >> testTagsMustAllBePresent [

	self task: 'A' section: nil lines: #( '- [ ] both #work #urgent' '- [ ] one #work' '- [ ] none' ).
	self
		assert: (self titlesIn: (self view
					  tags: #( 'work' 'urgent' );
					  yourself))
		equals: #( 'both' )
]

{ #category : 'helpers' }
NTItemViewTest >> titlesIn: aView [
	"Answer the titles of the items aView selects today."

	^ self titlesOf: (aView entriesIn: repository on: self today)
]

{ #category : 'helpers' }
NTItemViewTest >> titlesOf: entries [

	^ entries collect: [ :each | each item title ] as: Array
]

{ #category : 'helpers' }
NTItemViewTest >> today [
	"Tuesday 10 November 2026."

	^ self nov: 10
]

{ #category : 'helpers' }
NTItemViewTest >> view [

	^ NTItemView named: 'test'
]
