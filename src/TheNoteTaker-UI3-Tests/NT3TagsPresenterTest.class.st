"
I test `NT3TagsPresenter` without opening it: the icons of the tags, toggling them with a click, filtering them, and adding a typed tag.
"
Class {
	#name : 'NT3TagsPresenterTest',
	#superclass : 'NT3NotesTestCase',
	#instVars : [
		'application',
		'choice',
		'presenter'
	],
	#category : 'TheNoteTaker-UI3-Tests',
	#package : 'TheNoteTaker-UI3-Tests'
}

{ #category : 'running' }
NT3TagsPresenterTest >> setUp [

	super setUp.
	application := NT3DeferringTestApplication new.
	choice := NT3TagChoice
		          notes: {
				          old.
				          middle }
		          tagNames: #( 'books' 'pharo' 'spec' ).
	presenter := NT3TagsPresenter newApplication: application model: choice
]

{ #category : 'tests' }
NT3TagsPresenterTest >> testClickingAFilteredTagTogglesIt [

	presenter filterText: 'sp'.
	presenter tagList clickAtIndex: 1.
	self assert: (choice stateOf: 'spec') equals: #all
]

{ #category : 'tests' }
NT3TagsPresenterTest >> testClickingAPartialTagTwiceUnchecksIt [

	presenter tagList clickAtIndex: 3.
	presenter tagList clickAtIndex: 3.
	self assert: (choice stateOf: 'spec') equals: #none
]

{ #category : 'tests' }
NT3TagsPresenterTest >> testClickingATagTogglesIt [

	presenter tagList clickAtIndex: 3.
	self assert: (choice stateOf: 'spec') equals: #all.
	self assert: (presenter iconNameFor: 'spec') equals: #checkedBox
]

{ #category : 'tests' }
NT3TagsPresenterTest >> testFilterShowsTheMatchingTags [

	presenter filterText: 'P'.
	self assert: presenter tagList items asArray equals: #( 'pharo' 'spec' )
]

{ #category : 'tests' }
NT3TagsPresenterTest >> testIconShowsTheStateOfATag [

	self assert: (presenter iconNameFor: 'pharo') equals: #checkedBox.
	self assert: (presenter iconNameFor: 'spec') equals: #partialCheckedBox.
	self assert: (presenter iconNameFor: 'books') equals: #uncheckedBox
]

{ #category : 'tests' }
NT3TagsPresenterTest >> testListShowsAllTagNames [

	self assert: presenter tagList items asArray equals: #( 'books' 'pharo' 'spec' )
]

{ #category : 'tests' }
NT3TagsPresenterTest >> testSubmittingAnEmptyFilterDoesNothing [

	presenter submitFilter.
	self assert: presenter tagList items asArray equals: #( 'books' 'pharo' 'spec' )
]

{ #category : 'tests' }
NT3TagsPresenterTest >> testSubmittingTheFilterAddsTheTypedTag [

	presenter filterText: 'todo'.
	presenter submitFilter.
	self assert: (choice stateOf: 'todo') equals: #all.
	self assert: presenter filterText isEmpty.
	self assert: presenter tagList items asArray equals: #( 'books' 'pharo' 'spec' 'todo' )
]
