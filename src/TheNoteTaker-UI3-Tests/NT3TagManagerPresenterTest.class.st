"
I test `NT3TagManagerPresenter`: the listed tags, the enabled buttons, and renaming and removing a tag on two notes of an application kept in memory.

The request dialogs are answered or cancelled with `SpWindowSimulateOpenModal` (see `answer:during:`, `cancelDuring:` and `requestOpenedBy:`).
"
Class {
	#name : 'NT3TagManagerPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'application',
		'presenter',
		'both',
		'pharoOnly'
	],
	#category : 'TheNoteTaker-UI3-Tests',
	#package : 'TheNoteTaker-UI3-Tests'
}

{ #category : 'helpers' }
NT3TagManagerPresenterTest >> answer: aString during: aBlock [
	"Run aBlock, answering aString to the request dialog it opens"

	SpWindowSimulateOpenModal
		value: [ :aDialog |
				aDialog presenter
					text: aString;
					accept ]
		during: aBlock
]

{ #category : 'helpers' }
NT3TagManagerPresenterTest >> cancelDuring: aBlock [
	"Run aBlock, cancelling the request dialog it opens"

	SpWindowSimulateOpenModal value: [ :aDialog | aDialog presenter cancel ] during: aBlock
]

{ #category : 'helpers' }
NT3TagManagerPresenterTest >> requestOpenedBy: aBlock [
	"Answer the request dialog opened by aBlock, cancelled"

	| request |
	request := nil.
	SpWindowSimulateOpenModal
		value: [ :aDialog |
				request := aDialog presenter.
				request cancel ]
		during: aBlock.
	^ request
]

{ #category : 'running' }
NT3TagManagerPresenterTest >> setUp [

	super setUp.
	application := NT3DeferringTestApplication new.
	both := application newNoteTitled: 'Both' tagNames: #( 'pharo' 'spec' ).
	pharoOnly := application newNoteTitled: 'Pharo' tagNames: #( 'pharo' ).
	presenter := NT3TagManagerPresenter newApplication: application
]

{ #category : 'helpers' }
NT3TagManagerPresenterTest >> tagNamesOf: aNote [

	^ aNote tags collect: [ :each | each tagName ] as: Set
]

{ #category : 'tests' }
NT3TagManagerPresenterTest >> testActionsAreDisabledWithoutSelectedTag [

	self deny: presenter renameButton isEnabled.
	self deny: presenter removeButton isEnabled
]

{ #category : 'tests' }
NT3TagManagerPresenterTest >> testActionsAreEnabledWithASelectedTag [

	presenter tagList selectItem: 'pharo'.
	self assert: presenter renameButton isEnabled.
	self assert: presenter removeButton isEnabled
]

{ #category : 'tests - removing' }
NT3TagManagerPresenterTest >> testCancellingTheRemoveKeepsTheTag [

	presenter tagList selectItem: 'pharo'.
	self cancelDuring: [ presenter removeButton click ].
	self assert: (self tagNamesOf: pharoOnly) equals: #( 'pharo' ) asSet.
	self assert: presenter tagList items asArray equals: #( 'pharo' 'spec' )
]

{ #category : 'tests - renaming' }
NT3TagManagerPresenterTest >> testCancellingTheRenameKeepsTheTag [

	presenter tagList selectItem: 'pharo'.
	self cancelDuring: [ presenter renameButton click ].
	self assert: (self tagNamesOf: pharoOnly) equals: #( 'pharo' ) asSet.
	self assert: presenter tagList items asArray equals: #( 'pharo' 'spec' )
]

{ #category : 'tests' }
NT3TagManagerPresenterTest >> testListShowsAllTheTagsSortedIgnoringCase [

	application newNoteTitled: 'Books' tagNames: #( 'Books' ).
	presenter := NT3TagManagerPresenter newApplication: application.
	self assert: presenter tagList items asArray equals: #( 'Books' 'pharo' 'spec' )
]

{ #category : 'tests - removing' }
NT3TagManagerPresenterTest >> testRemoveAcceptsNoWordOrOneWord [

	| request |
	presenter tagList selectItem: 'pharo'.
	request := self requestOpenedBy: [ presenter removeButton click ].
	request text: 'small talk'.
	self deny: request validateAnswer.
	request text: ''.
	self assert: request validateAnswer.
	request text: 'smalltalk'.
	self assert: request validateAnswer
]

{ #category : 'tests - removing' }
NT3TagManagerPresenterTest >> testRemoveRequestStartsEmpty [

	| request |
	presenter tagList selectItem: 'pharo'.
	request := self requestOpenedBy: [ presenter removeButton click ].
	self assert: request text isEmpty
]

{ #category : 'tests - removing' }
NT3TagManagerPresenterTest >> testRemoveWithAReplacementPutsItOnTheNotes [

	presenter tagList selectItem: 'pharo'.
	self answer: 'smalltalk' during: [ presenter removeButton click ].
	self assert: (self tagNamesOf: both) equals: #( 'smalltalk' 'spec' ) asSet.
	self assert: (self tagNamesOf: pharoOnly) equals: #( 'smalltalk' ) asSet.
	self assert: presenter tagList items asArray equals: #( 'smalltalk' 'spec' )
]

{ #category : 'tests - removing' }
NT3TagManagerPresenterTest >> testRemoveWithAnExistingTagAsReplacementMergesThem [

	presenter tagList selectItem: 'pharo'.
	self answer: 'spec' during: [ presenter removeButton click ].
	self assert: (self tagNamesOf: pharoOnly) equals: #( 'spec' ) asSet.
	self assert: presenter tagList items asArray equals: #( 'spec' )
]

{ #category : 'tests - removing' }
NT3TagManagerPresenterTest >> testRemoveWithoutReplacementRemovesTheTagFromTheNotes [

	presenter tagList selectItem: 'pharo'.
	self answer: '' during: [ presenter removeButton click ].
	self assert: (self tagNamesOf: both) equals: #( 'spec' ) asSet.
	self assert: (self tagNamesOf: pharoOnly) isEmpty.
	self assert: presenter tagList items asArray equals: #( 'spec' )
]

{ #category : 'tests - renaming' }
NT3TagManagerPresenterTest >> testRenameAcceptsOneWordOnly [

	| request |
	presenter tagList selectItem: 'pharo'.
	request := self requestOpenedBy: [ presenter renameButton click ].
	request text: 'small talk'.
	self deny: request validateAnswer.
	request text: ' smalltalk '.
	self assert: request validateAnswer
]

{ #category : 'tests - renaming' }
NT3TagManagerPresenterTest >> testRenameRenamesTheTagOfTheNotes [

	presenter tagList selectItem: 'pharo'.
	self answer: 'smalltalk' during: [ presenter renameButton click ].
	self assert: (self tagNamesOf: both) equals: #( 'smalltalk' 'spec' ) asSet.
	self assert: (self tagNamesOf: pharoOnly) equals: #( 'smalltalk' ) asSet
]

{ #category : 'tests - renaming' }
NT3TagManagerPresenterTest >> testRenameRequestStartsWithTheTagName [

	| request |
	presenter tagList selectItem: 'pharo'.
	request := self requestOpenedBy: [ presenter renameButton click ].
	self assert: request text equals: 'pharo'
]

{ #category : 'tests - renaming' }
NT3TagManagerPresenterTest >> testRenameShowsAndSelectsTheNewName [

	presenter tagList selectItem: 'pharo'.
	self answer: 'smalltalk' during: [ presenter renameButton click ].
	self assert: presenter tagList items asArray equals: #( 'smalltalk' 'spec' ).
	self assert: presenter tagList selectedItem equals: 'smalltalk'
]

{ #category : 'tests - renaming' }
NT3TagManagerPresenterTest >> testRenameToAnExistingTagMergesThem [

	presenter tagList selectItem: 'pharo'.
	self answer: 'spec' during: [ presenter renameButton click ].
	self assert: (self tagNamesOf: pharoOnly) equals: #( 'spec' ) asSet.
	self assert: presenter tagList items asArray equals: #( 'spec' )
]

{ #category : 'tests' }
NT3TagManagerPresenterTest >> testRowShowsTheTagAndItsNoteCount [

	self assert: (presenter labelFor: 'pharo') equals: 'pharo (2)'.
	self assert: (presenter labelFor: 'spec') equals: 'spec (1)'
]
