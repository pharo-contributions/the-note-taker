"
I test `NT3TagChoice` on the sample notes of `NT3NotesTestCase`: the initial states of the tags, toggling, adding typed tags, and the tags to add and remove.
"
Class {
	#name : 'NT3TagChoiceTest',
	#superclass : 'NT3NotesTestCase',
	#category : 'TheNoteTaker-UI3-Tests',
	#package : 'TheNoteTaker-UI3-Tests'
}

{ #category : 'helpers' }
NT3TagChoiceTest >> choiceFor: aCollectionOfNotes [

	^ NT3TagChoice notes: aCollectionOfNotes tagNames: #( 'books' 'pharo' 'spec' )
]

{ #category : 'tests' }
NT3TagChoiceTest >> testAddTagNamedChecksANewTag [

	| choice |
	choice := self choiceFor: { old }.
	choice addTagNamed: ' todo '.
	self assert: (choice tagNames includes: 'todo').
	self assert: (choice stateOf: 'todo') equals: #all.
	self assert: choice addedTagNames asArray equals: #( 'todo' )
]

{ #category : 'tests' }
NT3TagChoiceTest >> testAddTagNamedChecksAnExistingTagIgnoringCase [

	| choice |
	choice := self choiceFor: { old }.
	choice addTagNamed: 'Spec'.
	self assert: (choice tagNames select: [ :each | each asLowercase = 'spec' ]) asArray equals: #( 'spec' ).
	self assert: (choice stateOf: 'spec') equals: #all
]

{ #category : 'tests' }
NT3TagChoiceTest >> testAddTagNamedIgnoresABlankName [

	| choice |
	choice := self choiceFor: { old }.
	choice addTagNamed: ' , '.
	self assert: choice tagNames asArray equals: #( 'books' 'pharo' 'spec' )
]

{ #category : 'tests' }
NT3TagChoiceTest >> testAddTagNamedRemovesCommas [

	| choice |
	choice := self choiceFor: { old }.
	choice addTagNamed: 'to,do'.
	self assert: (choice stateOf: 'todo') equals: #all
]

{ #category : 'tests' }
NT3TagChoiceTest >> testCheckedTagsAreAdded [

	| choice |
	choice := self choiceFor: {
			          old.
			          middle }.
	choice toggle: 'spec'.
	choice toggle: 'books'.
	self assert: choice addedTagNames asArray equals: #( 'books' 'spec' ).
	self assertEmpty: choice removedTagNames
]

{ #category : 'tests' }
NT3TagChoiceTest >> testNotes [

	self
		assert: (self choiceFor: {
					 old.
					 middle }) notes asArray
		equals: {
				old.
				middle }
]

{ #category : 'tests' }
NT3TagChoiceTest >> testStateIsAllWhenEveryNoteHasTheTag [

	self
		assert: ((self choiceFor: {
					  old.
					  middle }) stateOf: 'pharo')
		equals: #all
]

{ #category : 'tests' }
NT3TagChoiceTest >> testStateIsNoneWhenNoNoteHasTheTag [

	self
		assert: ((self choiceFor: {
					  old.
					  middle }) stateOf: 'books')
		equals: #none
]

{ #category : 'tests' }
NT3TagChoiceTest >> testStateIsSomeWhenOnlySomeNotesHaveTheTag [

	self
		assert: ((self choiceFor: {
					  old.
					  middle }) stateOf: 'spec')
		equals: #some
]

{ #category : 'tests' }
NT3TagChoiceTest >> testTagNamesAreSortedIgnoringCase [

	| choice |
	choice := NT3TagChoice notes: { untagged } tagNames: #( 'spec' 'Books' 'pharo' ).
	self assert: choice tagNames asArray equals: #( 'Books' 'pharo' 'spec' )
]

{ #category : 'tests' }
NT3TagChoiceTest >> testTagNamesIncludeTheTagsOfTheNotes [

	| choice |
	choice := NT3TagChoice notes: { middle } tagNames: #(  ).
	self assert: choice tagNames asArray equals: #( 'pharo' 'spec' )
]

{ #category : 'tests' }
NT3TagChoiceTest >> testTogglingAllGivesNone [

	| choice |
	choice := self choiceFor: { old }.
	choice toggle: 'pharo'.
	self assert: (choice stateOf: 'pharo') equals: #none
]

{ #category : 'tests' }
NT3TagChoiceTest >> testTogglingNoneGivesAll [

	| choice |
	choice := self choiceFor: { old }.
	choice toggle: 'books'.
	self assert: (choice stateOf: 'books') equals: #all
]

{ #category : 'tests' }
NT3TagChoiceTest >> testTogglingSomeGivesAll [

	| choice |
	choice := self choiceFor: {
			          old.
			          middle }.
	choice toggle: 'spec'.
	self assert: (choice stateOf: 'spec') equals: #all
]

{ #category : 'tests' }
NT3TagChoiceTest >> testUncheckedTagsAreRemoved [

	| choice |
	choice := self choiceFor: {
			          old.
			          middle }.
	choice toggle: 'pharo'.
	choice
		toggle: 'spec';
		toggle: 'spec'.
	self assert: choice removedTagNames asArray equals: #( 'pharo' 'spec' ).
	self assertEmpty: choice addedTagNames
]

{ #category : 'tests' }
NT3TagChoiceTest >> testUntouchedChoiceAddsAndRemovesNothing [

	| choice |
	choice := self choiceFor: {
			          old.
			          middle }.
	self assertEmpty: choice addedTagNames.
	self assertEmpty: choice removedTagNames
]
