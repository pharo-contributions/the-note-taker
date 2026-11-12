"
I test how `NT3TagQuery` reads the tag search text.
"
Class {
	#name : 'NT3TagQueryTest',
	#superclass : 'TestCase',
	#category : 'TheNoteTaker-UI3-Tests',
	#package : 'TheNoteTaker-UI3-Tests'
}

{ #category : 'helpers' }
NT3TagQueryTest >> searchedTagNamesOf: aString [

	^ (NT3TagQuery text: aString existingTagNames: #( 'pharo' 'spec' 'spectacle' )) searchedTagNames
]

{ #category : 'tests - completion' }
NT3TagQueryTest >> testCompletingReplacesTheLastWord [

	| tagNames |
	tagNames := #( 'pharo' 'spec' 'spectacle' ).
	self
		assert: ((NT3TagQuery text: 'pharo spe' existingTagNames: tagNames) textCompletedWith: 'spectacle')
		equals: 'pharo spectacle '.
	self assert: ((NT3TagQuery text: 'pharo ' existingTagNames: tagNames) textCompletedWith: 'spec') equals: 'pharo spec '
]

{ #category : 'tests - completion' }
NT3TagQueryTest >> testCompletionsAfterASpaceAreTheTagsNotYetSearched [

	| query |
	query := NT3TagQuery text: 'pharo ' existingTagNames: #( 'pharo' 'spec' 'spectacle' ).
	self assert: query completions asArray equals: #( 'spec' 'spectacle' )
]

{ #category : 'tests - completion' }
NT3TagQueryTest >> testCompletionsStartWithTheLastWord [

	| query |
	query := NT3TagQuery text: 'pharo spe' existingTagNames: #( 'pharo' 'spec' 'spectacle' ).
	self assert: query completions asArray equals: #( 'spec' 'spectacle' )
]

{ #category : 'tests' }
NT3TagQueryTest >> testEmptyTextSearchesNothing [

	self assert: (self searchedTagNamesOf: '') isEmpty.
	self assert: (self searchedTagNamesOf: '   ') isEmpty.
	self deny: (NT3TagQuery text: '' existingTagNames: #( 'pharo' )) isActive
]

{ #category : 'tests' }
NT3TagQueryTest >> testLastWordEqualToATagNameIsSearched [

	self assert: (self searchedTagNamesOf: 'spec') asArray equals: #( 'spec' ).
	self assert: (self searchedTagNamesOf: 'pharo   spec') asArray equals: #( 'pharo' 'spec' )
]

{ #category : 'tests' }
NT3TagQueryTest >> testTagNamesAreExact [

	self assert: (self searchedTagNamesOf: 'Spec') isEmpty.
	self assert: (self searchedTagNamesOf: 'Spec ') asArray equals: #( 'Spec' )
]

{ #category : 'tests' }
NT3TagQueryTest >> testUnfinishedLastWordIsIgnored [

	self assert: (self searchedTagNamesOf: 'pha') isEmpty.
	self assert: (self searchedTagNamesOf: 'pharo spe') asArray equals: #( 'pharo' )
]

{ #category : 'tests' }
NT3TagQueryTest >> testWordFollowedBySpaceIsSearched [

	self assert: (self searchedTagNamesOf: 'pharo ') asArray equals: #( 'pharo' ).
	self assert: (self searchedTagNamesOf: 'unknown ') asArray equals: #( 'unknown' ).
	self assert: (NT3TagQuery text: 'unknown ' existingTagNames: #( 'pharo' )) isActive
]
