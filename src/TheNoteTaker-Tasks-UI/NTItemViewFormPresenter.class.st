"
I am the form that creates or edits a view (`NTItemView`): its name, the sections and tags it looks at, its period, the keys its items must have, and how it groups and sorts them. My model is the view being edited, or nil for a new view; it is changed only when the form is accepted.

## Responsibility:

- I show the fields of my view, or empty fields for a new view.
- I build a view from the fields, and refuse it with a message when the name is empty or taken, or the number of days is not a positive whole number.
- On accept, I add the new view to the view set or change the edited view in place, then call the accept block.

## Collaborators: 

- `NTItemView`: what I edit (`copyFieldsFrom:`); `NTItemView class>>#isValidPeriod:`, `groupings`, `sortings`.
- `NTItemViewSet`: where a new view goes, and where names must be unique.
- `NTTasksPresenter`: opens me as a dialog and saves the views when I am accepted.

## Public API and Key Messages

- `NTItemViewFormPresenter newApplication: anApplication model: aViewOrNil`, then `viewSet: aViewSet sectionNames: names`
- `view` (built from the fields), `validationError`, `accept`, `whenAcceptedDo: aBlock`
- `openDialog` shows me with OK and Cancel buttons.

See `NTItemViewFormPresenter class >> #exampleEditMonthlyReview`.

## Internal Representation

- `viewSet`: the `NTItemViewSet` of the repository.
- One presenter per field: `nameInput`, `sectionsList` (multiple selection), `tagsInput` and `hasInput` (words separated by spaces or commas; a leading # of a tag is ignored), `periodList` and `daysInput` (for 'next N days'), `includeNoDueCheckBox`, `doneCheckBox`, `groupByList`, `sortByList`.
- `errorLabel`: why the form was refused; `acceptBlock`: evaluated with the view after accept.
"
Class {
	#name : 'NTItemViewFormPresenter',
	#superclass : 'SpPresenterWithModel',
	#instVars : [
		'viewSet',
		'nameInput',
		'sectionsList',
		'tagsInput',
		'hasInput',
		'periodList',
		'daysInput',
		'includeNoDueCheckBox',
		'doneCheckBox',
		'groupByList',
		'sortByList',
		'errorLabel',
		'acceptBlock'
	],
	#category : 'TheNoteTaker-Tasks-UI',
	#package : 'TheNoteTaker-Tasks-UI'
}

{ #category : 'examples' }
NTItemViewFormPresenter class >> exampleEditMonthlyReview [

	<sampleInstance>
	| viewSet |
	viewSet := NTItemViewSet defaults.
	^ (self newApplication: NTTasksApplication new model: (viewSet viewNamed: 'Monthly review'))
		  viewSet: viewSet sectionNames: #( 'Admin' 'Pharo' 'Research' 'Unsorted' );
		  yourself
]

{ #category : 'accessing' }
NTItemViewFormPresenter class >> nextDaysChoice [
	"The choice of the period list that is completed by the number of days."

	^ 'next N days'
]

{ #category : 'actions' }
NTItemViewFormPresenter >> accept [
	"Add the new view, or change the edited one, then evaluate the accept block. Answer false, showing why, when the fields are refused."

	| error view |
	error := self validationError.
	errorLabel label: (error ifNil: [ '' ]).
	error ifNotNil: [ ^ false ].
	view := self view.
	self model ifNil: [ viewSet add: view ] ifNotNil: [ :edited |
			edited copyFieldsFrom: view.
			view := edited ].
	acceptBlock value: view.
	^ true
]

{ #category : 'initialization' }
NTItemViewFormPresenter >> connectPresenters [

	periodList whenSelectedItemChangedDo: [ :choice | daysInput enabled: choice = self class nextDaysChoice ]
]

{ #category : 'accessing' }
NTItemViewFormPresenter >> daysInput [

	^ daysInput
]

{ #category : 'layout' }
NTItemViewFormPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: (self row: 'Name' with: nameInput) expand: false;
		  add: 'Sections (none selected: all)' expand: false;
		  add: sectionsList height: 110;
		  add: (self row: 'Tags' with: tagsInput) expand: false;
		  add: (self row: 'Period' with: (SpBoxLayout newLeftToRight
						    spacing: 4;
						    add: periodList;
						    add: daysInput width: 60;
						    yourself))
		  expand: false;
		  add: includeNoDueCheckBox expand: false;
		  add: (self row: 'Has keys' with: hasInput) expand: false;
		  add: doneCheckBox expand: false;
		  add: (self row: 'Group by' with: groupByList) expand: false;
		  add: (self row: 'Sort by' with: sortByList) expand: false;
		  add: errorLabel expand: false;
		  yourself
]

{ #category : 'accessing' }
NTItemViewFormPresenter >> doneCheckBox [

	^ doneCheckBox
]

{ #category : 'accessing' }
NTItemViewFormPresenter >> errorLabel [

	^ errorLabel
]

{ #category : 'accessing' }
NTItemViewFormPresenter >> groupByList [

	^ groupByList
]

{ #category : 'accessing' }
NTItemViewFormPresenter >> hasInput [

	^ hasInput
]

{ #category : 'accessing' }
NTItemViewFormPresenter >> includeNoDueCheckBox [

	^ includeNoDueCheckBox
]

{ #category : 'initialization' }
NTItemViewFormPresenter >> initializeDialogWindow: aDialogWindowPresenter [
	"OK accepts the form, and keeps it open when the view is refused."

	aDialogWindowPresenter
		title: (self model ifNil: [ 'New view' ] ifNotNil: [ 'Edit view' ]);
		initialExtent: 480 @ 560;
		addButton: 'Cancel' do: [ :dialog | dialog close ];
		addDefaultButton: 'OK' do: [ :dialog | self accept ifTrue: [ dialog close ] ]
]

{ #category : 'initialization' }
NTItemViewFormPresenter >> initializePresenters [

	acceptBlock := [ :view |  ].
	nameInput := self newTextInput.
	sectionsList := self newList
		                beMultipleSelection;
		                yourself.
	tagsInput := self newInputWithPlaceholder: 'work urgent (all of them)'.
	hasInput := self newInputWithPlaceholder: 'waitingOthers prio(high)'.
	periodList := self newChoiceList: { nil } , NTItemView fixedPeriods , { self class nextDaysChoice } none: 'any date'.
	daysInput := self newInputWithPlaceholder: 'N'.
	includeNoDueCheckBox := self newCheckBox
		                        label: 'Also items without date';
		                        yourself.
	doneCheckBox := self newCheckBox
		                label: 'Also done items';
		                yourself.
	groupByList := self newChoiceList: { nil } , NTItemView groupings none: 'no groups'.
	sortByList := self newChoiceList: { nil } , NTItemView sortings none: 'file order'.
	errorLabel := self newLabel
]

{ #category : 'initialization' }
NTItemViewFormPresenter >> modelChanged [

	self updatePresenter
]

{ #category : 'accessing' }
NTItemViewFormPresenter >> nameInput [

	^ nameInput
]

{ #category : 'initialization' }
NTItemViewFormPresenter >> newChoiceList: choices none: aString [
	"A drop list of choices, nil shown as aString."

	^ self newDropList
		  items: choices;
		  display: [ :each | each ifNil: [ aString ] ];
		  yourself
]

{ #category : 'initialization' }
NTItemViewFormPresenter >> newInputWithPlaceholder: aString [

	^ self newTextInput
		  placeholder: aString;
		  yourself
]

{ #category : 'actions' }
NTItemViewFormPresenter >> period [

	periodList selectedItem = self class nextDaysChoice ifFalse: [ ^ periodList selectedItem ].
	^ 'next {1} days' format: { daysInput text trimBoth }
]

{ #category : 'accessing' }
NTItemViewFormPresenter >> periodList [

	^ periodList
]

{ #category : 'layout' }
NTItemViewFormPresenter >> row: aLabel with: aPresenterOrLayout [

	^ SpBoxLayout newLeftToRight
		  spacing: 4;
		  add: aLabel width: 80;
		  add: aPresenterOrLayout;
		  yourself
]

{ #category : 'accessing' }
NTItemViewFormPresenter >> sectionsList [

	^ sectionsList
]

{ #category : 'updating' }
NTItemViewFormPresenter >> showPeriodOf: aView [

	((aView period ifNil: [ '' ]) beginsWith: 'next ')
		ifTrue: [
				periodList selectItem: self class nextDaysChoice.
				daysInput text: aView nextDaysCount printString ]
		ifFalse: [
				periodList selectItem: aView period.
				daysInput text: '' ].
	daysInput enabled: periodList selectedItem = self class nextDaysChoice
]

{ #category : 'updating' }
NTItemViewFormPresenter >> shownView [

	^ self model ifNil: [ NTItemView named: '' ]
]

{ #category : 'accessing' }
NTItemViewFormPresenter >> sortByList [

	^ sortByList
]

{ #category : 'accessing' }
NTItemViewFormPresenter >> tagsInput [

	^ tagsInput
]

{ #category : 'updating' }
NTItemViewFormPresenter >> updatePresenter [
	"Show the fields of the edited view, or empty fields for a new one."

	| view |
	view := self shownView.
	nameInput text: view name.
	sectionsList unselectAll.
	view sections ifNotNil: [ :selected | sectionsList selectItems: selected ].
	tagsInput text: (String space join: view tags).
	hasInput text: (String space join: view has).
	self showPeriodOf: view.
	includeNoDueCheckBox state: view includeNoDue.
	doneCheckBox state: view done.
	groupByList selectItem: view groupBy.
	sortByList selectItem: view sortBy.
	errorLabel label: ''
]

{ #category : 'actions' }
NTItemViewFormPresenter >> validationError [
	"Answer why the fields do not make a valid view, or nil."

	| name |
	name := nameInput text trimBoth.
	name ifEmpty: [ ^ 'A view needs a name.' ].
	(viewSet isNotNil and: [ (viewSet viewNamed: name) isNotNil and: [ (viewSet viewNamed: name) ~~ self model ] ]) ifTrue: [
		^ 'Another view is named "{1}".' format: { name } ].
	(NTItemView isValidPeriod: self period) ifFalse: [ ^ 'The number of days must be a positive whole number.' ].
	^ nil
]

{ #category : 'actions' }
NTItemViewFormPresenter >> view [
	"Answer a new view built from the fields."

	^ (NTItemView named: nameInput text trimBoth)
		  sections: sectionsList selectedItems;
		  tags: ((self wordsOf: tagsInput text) collect: [ :each | each copyWithout: $# ]);
		  has: (self wordsOf: hasInput text);
		  period: self period;
		  includeNoDue: includeNoDueCheckBox state;
		  done: doneCheckBox state;
		  groupBy: groupByList selectedItem;
		  sortBy: sortByList selectedItem;
		  yourself
]

{ #category : 'accessing' }
NTItemViewFormPresenter >> viewSet: aViewSet sectionNames: names [
	"The views a name must be unique in, and the sections to choose from."

	| sections |
	viewSet := aViewSet.
	sections := names asOrderedCollection.
	self shownView sections ifNotNil: [ :selected | selected do: [ :each | sections addIfNotPresent: each ] ].
	sectionsList items: sections asArray.
	self updatePresenter
]

{ #category : 'announcing' }
NTItemViewFormPresenter >> whenAcceptedDo: aBlock [
	"aBlock is evaluated with the new or edited view after accept."

	acceptBlock := aBlock
]

{ #category : 'actions' }
NTItemViewFormPresenter >> wordsOf: aString [
	"Words are separated by spaces or commas."

	^ (aString substrings: ' ,') asArray
]
