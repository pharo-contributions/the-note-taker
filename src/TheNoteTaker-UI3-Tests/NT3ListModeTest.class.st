"
I test the rows built by the `NT3ListMode` subclasses.
"
Class {
	#name : 'NT3ListModeTest',
	#superclass : 'NT3NotesTestCase',
	#category : 'TheNoteTaker-UI3-Tests',
	#package : 'TheNoteTaker-UI3-Tests'
}

{ #category : 'helpers' }
NT3ListModeTest >> labelsOf: aMode searching: aCollection [
	"Answer the titles of the notes and the labels of the separators, in list order"

	^ (aMode entriesFor: self notes searchedTagNames: aCollection)
		  collect: [ :each |
				  each isNote
					  ifTrue: [ each title ]
					  ifFalse: [ each label ] ]
		  as: Array
]

{ #category : 'tests - by date' }
NT3ListModeTest >> testByDateGroupsNewestFirstUnderMonthSeparators [

	self
		assert: (self labelsOf: NT3ByDateListMode new searching: #(  ))
		equals: #( 'November 2026' 'Untagged' 'Recent' 'October 2026' 'Middle' 'December 2025' 'Old' )
]

{ #category : 'tests - by date' }
NT3ListModeTest >> testByDateKeepsOnlyNotesHavingASearchedTag [

	self
		assert: (self labelsOf: NT3ByDateListMode new searching: #( 'pharo' ))
		equals: #( 'October 2026' 'Middle' 'December 2025' 'Old' )
]

{ #category : 'tests - by tag' }
NT3ListModeTest >> testByTagKeepsOnlySearchedTagGroups [

	self assert: (self labelsOf: NT3ByTagListMode new searching: #( 'spec' )) equals: #( '#spec' 'Recent' 'Middle' )
]

{ #category : 'tests - by tag' }
NT3ListModeTest >> testByTagListsEachNoteUnderEachOfItsTagsThenNoTag [

	self
		assert: (self labelsOf: NT3ByTagListMode new searching: #(  ))
		equals: #( '#pharo' 'Middle' 'Old' '#spec' 'Recent' 'Middle' 'No tag' 'Untagged' )
]

{ #category : 'tests - by tag' }
NT3ListModeTest >> testByTagSortsTagsIgnoringCase [

	untagged addTag: (NTTag newNamed: 'Apple').
	self
		assert: (self labelsOf: NT3ByTagListMode new searching: #(  ))
		equals: #( '#Apple' 'Untagged' '#pharo' 'Middle' 'Old' '#spec' 'Recent' 'Middle' )
]

{ #category : 'tests - compact' }
NT3ListModeTest >> testCompactListsNotesNewestFirstWithoutSeparators [

	self assert: (self labelsOf: NT3CompactListMode new searching: #(  )) equals: #( 'Untagged' 'Recent' 'Middle' 'Old' )
]

{ #category : 'tests' }
NT3ListModeTest >> testOnlyCompactModeHidesDetails [

	self assert: NT3ByDateListMode new showsDetails.
	self assert: NT3ByTagListMode new showsDetails.
	self deny: NT3CompactListMode new showsDetails
]

{ #category : 'tests - compact' }
NT3ListModeTest >> testSeveralSearchedTagsKeepNotesHavingAnyOfThem [

	untagged addTag: (NTTag newNamed: 'misc').
	self assert: (self labelsOf: NT3CompactListMode new searching: #( 'misc' 'spec' )) equals: #( 'Untagged' 'Recent' 'Middle' )
]

{ #category : 'tests - compact' }
NT3ListModeTest >> testUnknownSearchedTagKeepsNoNote [

	self assert: (self labelsOf: NT3CompactListMode new searching: #( 'unknown' )) isEmpty.
	self assert: (self labelsOf: NT3ByTagListMode new searching: #( 'unknown' )) isEmpty
]
