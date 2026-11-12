"
I test `NT3TextQuery`: splitting the words, matching notes and finding the ranges of the words.

## Responsibility:

- Check that all the words must occur, ignoring case, in the title or the contents.
- Check the ranges found in a text, merged when they overlap.

## Collaborators:

- `NT3TextQuery`, `NTNote`.

## Public API and Key Messages

- `testAllWordsMustMatch`, `testRangesOfAllOccurrencesOfAllWords`, …
"
Class {
	#name : 'NT3TextQueryTest',
	#superclass : 'TestCase',
	#category : 'TheNoteTaker-UI3-Tests',
	#package : 'TheNoteTaker-UI3-Tests'
}

{ #category : 'helpers' }
NT3TextQueryTest >> noteWith: aString [

	^ NTNote content: aString
]

{ #category : 'helpers' }
NT3TextQueryTest >> queryOn: aString [

	^ NT3TextQuery text: aString
]

{ #category : 'tests' }
NT3TextQueryTest >> testAllWordsMustMatch [

	| note |
	note := self noteWith: (String cr join: #( 'Spec' 'The list view' )).
	self assert: ((self queryOn: 'list spec') matches: note).
	self deny: ((self queryOn: 'list toplo') matches: note)
]

{ #category : 'tests' }
NT3TextQueryTest >> testEmptyTextIsNotActive [

	self deny: (self queryOn: '') isActive.
	self deny: (self queryOn: '  ') isActive
]

{ #category : 'tests' }
NT3TextQueryTest >> testEmptyTextMatchesEveryNote [

	self assert: ((self queryOn: '') matches: (self noteWith: 'Anything'))
]

{ #category : 'tests' }
NT3TextQueryTest >> testMatchesInsideWords [

	self assert: ((self queryOn: 'pha') matches: (self noteWith: 'Pharo'))
]

{ #category : 'tests' }
NT3TextQueryTest >> testMatchingIgnoresCase [

	self assert: ((self queryOn: 'PHARO') matches: (self noteWith: 'pharo notes'))
]

{ #category : 'tests' }
NT3TextQueryTest >> testOverlappingRangesAreMerged [

	self assert: ((self queryOn: 'aba ba') rangesIn: 'xabay') equals: { 2 to: 4 }
]

{ #category : 'tests' }
NT3TextQueryTest >> testRangesOfAllOccurrencesOfAllWords [

	self
		assert: ((self queryOn: 'ab x') rangesIn: 'ab x AB')
		equals: { 1 to: 2. 4 to: 4. 6 to: 7 }
]

{ #category : 'tests' }
NT3TextQueryTest >> testRangesOfInactiveQueryAreEmpty [

	self assert: ((self queryOn: '') rangesIn: 'some text') isEmpty
]

{ #category : 'tests' }
NT3TextQueryTest >> testTextIsActive [

	self assert: (self queryOn: 'spec') isActive
]

{ #category : 'tests' }
NT3TextQueryTest >> testWordsAreLowercaseAndUnique [

	self assert: (self queryOn: ' Spec  list spec ') words equals: #( 'spec' 'list' )
]
