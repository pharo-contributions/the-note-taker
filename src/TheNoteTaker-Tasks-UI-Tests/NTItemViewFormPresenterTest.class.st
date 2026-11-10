"
I test `NTItemViewFormPresenter` without opening it: filling the fields from a view, building a view from the fields, and accepting or refusing it.
"
Class {
	#name : 'NTItemViewFormPresenterTest',
	#superclass : 'NTTaskUITestCase',
	#instVars : [
		'viewSet'
	],
	#category : 'TheNoteTaker-Tasks-UI-Tests',
	#package : 'TheNoteTaker-Tasks-UI-Tests'
}

{ #category : 'helpers' }
NTItemViewFormPresenterTest >> formOn: aViewOrNil [

	^ (NTItemViewFormPresenter newApplication: application model: aViewOrNil)
		  viewSet: viewSet sectionNames: #( 'Admin' 'Pharo' 'Unsorted' );
		  yourself
]

{ #category : 'running' }
NTItemViewFormPresenterTest >> setUp [

	super setUp.
	viewSet := NTItemViewSet defaults
]

{ #category : 'tests' }
NTItemViewFormPresenterTest >> testAcceptEditChangesTheViewInPlace [

	| today form |
	today := viewSet viewNamed: 'Today'.
	form := self formOn: today.
	form nameInput text: 'Now'.
	form includeNoDueCheckBox state: true.
	self assert: form accept.
	self assert: viewSet views first equals: today.
	self assert: today name equals: 'Now'.
	self assert: today period equals: 'today'.
	self assert: today includeNoDue
]

{ #category : 'tests' }
NTItemViewFormPresenterTest >> testAcceptNewViewAddsIt [

	| form accepted |
	form := self formOn: nil.
	accepted := nil.
	form whenAcceptedDo: [ :view | accepted := view ].
	form nameInput text: 'Pharo only'.
	self assert: form accept.
	self assert: viewSet views last name equals: 'Pharo only'.
	self assert: accepted equals: viewSet views last
]

{ #category : 'tests - errors' }
NTItemViewFormPresenterTest >> testEmptyNameIsRefused [

	| form |
	form := self formOn: nil.
	form nameInput text: '   '.
	self deny: form accept.
	self assert: form errorLabel label equals: 'A view needs a name.'.
	self assert: viewSet views size equals: 5
]

{ #category : 'tests' }
NTItemViewFormPresenterTest >> testFieldsShowNextDaysPeriod [

	| form |
	form := self formOn: ((NTItemView named: 'Soon')
			         period: 'next 5 days';
			         yourself).
	self assert: form periodList selectedItem equals: form class nextDaysChoice.
	self assert: form daysInput text equals: '5'
]

{ #category : 'tests' }
NTItemViewFormPresenterTest >> testFieldsShowTheView [

	| form |
	form := self formOn: ((NTItemView named: 'Pharo hot')
			         sections: #( 'Pharo' );
			         tags: #( 'work' 'urgent' );
			         has: #( 'prio(high)' );
			         period: 'month';
			         done: true;
			         sortBy: 'due';
			         yourself).
	self assert: form nameInput text equals: 'Pharo hot'.
	self assert: form sectionsList selectedItems asArray equals: #( 'Pharo' ).
	self assert: form tagsInput text equals: 'work urgent'.
	self assert: form hasInput text equals: 'prio(high)'.
	self assert: form periodList selectedItem equals: 'month'.
	self assert: form doneCheckBox state.
	self assert: form sortByList selectedItem equals: 'due'
]

{ #category : 'tests - errors' }
NTItemViewFormPresenterTest >> testInvalidDaysAreRefused [

	| form today |
	today := viewSet viewNamed: 'Today'.
	form := self formOn: today.
	form periodList selectItem: form class nextDaysChoice.
	form daysInput text: 'two'.
	self deny: form accept.
	self assert: form errorLabel label equals: 'The number of days must be a positive whole number.'.
	self assert: today period equals: 'today'
]

{ #category : 'tests' }
NTItemViewFormPresenterTest >> testKeepingItsOwnNameIsAccepted [

	| form |
	form := self formOn: (viewSet viewNamed: 'Today').
	self assert: form validationError isNil
]

{ #category : 'tests' }
NTItemViewFormPresenterTest >> testNewFormHasEmptyFields [

	| view |
	view := (self formOn: nil) view.
	self assert: view name equals: ''.
	self assert: view period isNil.
	self assert: view sections isNil.
	self assert: view tags isEmpty.
	self deny: view includeNoDue.
	self assert: view groupBy isNil
]

{ #category : 'tests' }
NTItemViewFormPresenterTest >> testNextDaysPeriod [

	| form |
	form := self formOn: nil.
	form periodList selectItem: form class nextDaysChoice.
	form daysInput text: '3'.
	self assert: form view period equals: 'next 3 days'
]

{ #category : 'tests - errors' }
NTItemViewFormPresenterTest >> testTakenNameIsRefused [

	| form |
	form := self formOn: nil.
	form nameInput text: 'Today'.
	self deny: form accept.
	self assert: form errorLabel label equals: 'Another view is named "Today".'.
	self assert: viewSet views size equals: 5
]

{ #category : 'tests' }
NTItemViewFormPresenterTest >> testViewFromFields [

	| form view |
	form := self formOn: nil.
	form nameInput text: 'Admin work'.
	form sectionsList selectItems: #( 'Admin' 'Unsorted' ).
	form tagsInput text: '#work, urgent'.
	form hasInput text: 'waitingOthers prio(high)'.
	form periodList selectItem: 'week'.
	form includeNoDueCheckBox state: true.
	form groupByList selectItem: 'section'.
	view := form view.
	self assert: view name equals: 'Admin work'.
	self assert: view sections asSet equals: #( 'Admin' 'Unsorted' ) asSet.
	self assert: view tags equals: #( 'work' 'urgent' ).
	self assert: view has equals: #( 'waitingOthers' 'prio(high)' ).
	self assert: view period equals: 'week'.
	self assert: view includeNoDue.
	self assert: view groupBy equals: 'section'
]
