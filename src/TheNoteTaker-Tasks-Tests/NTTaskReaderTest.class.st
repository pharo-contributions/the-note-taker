"
Tests of the task model and file format of the redesigned Todo part (TheNoteTaker-Tasks).
"
Class {
	#name : 'NTTaskReaderTest',
	#superclass : 'NTTaskTestCase',
	#category : 'TheNoteTaker-Tasks-Tests',
	#package : 'TheNoteTaker-Tasks-Tests'
}

{ #category : 'tests' }
NTTaskReaderTest >> testAbandonedStatusIsKept [

	| task |
	task := NTTaskReader read: (self text: '{
  "title" : "Old grant",
  "status" : "abandoned"
}

- [x] Draft @done(2026-10-21)
').
	self assert: task isAbandoned
]

{ #category : 'tests' }
NTTaskReaderTest >> testAtInsideWordIsNotKey [

	| item |
	item := NTTaskReader new readItemLine: '- [ ] Mail bob@inria.fr'.
	self assert: item title equals: 'Mail bob@inria.fr'.
	self assert: item annotations isEmpty
]

{ #category : 'tests' }
NTTaskReaderTest >> testBlankLinesBetweenItemsAreIgnored [

	| task |
	task := NTTaskReader read: (self text: '- [ ] a

- [ ] b
').
	self assert: task items size equals: 2
]

{ #category : 'tests - errors' }
NTTaskReaderTest >> testDescriptionBeforeFirstItemRaisesError [

	self
		should: [
				NTTaskReader read: (self text: '  orphan description
') ]
		raise: NTTaskParseError
]

{ #category : 'tests - errors' }
NTTaskReaderTest >> testEmptyTitleRaisesError [

	self should: [ NTTaskReader new readItemLine: '- [ ] @due(2026-11-15)' ] raise: NTTaskParseError
]

{ #category : 'tests - errors' }
NTTaskReaderTest >> testFreeTextLineRaisesError [

	self
		should: [
				NTTaskReader read: (self text: '- [ ] a
not an item
') ]
		raise: NTTaskParseError
]

{ #category : 'tests' }
NTTaskReaderTest >> testHashInsideWordIsNotTag [

	| item |
	item := NTTaskReader new readItemLine: '- [ ] Learn C# today'.
	self assert: item title equals: 'Learn C# today'.
	self assert: item tags isEmpty
]

{ #category : 'tests - errors' }
NTTaskReaderTest >> testInvalidMetadataRaisesError [

	self
		should: [
				NTTaskReader read: (self text: '{
  title : x
}
') ]
		raise: NTTaskParseError
]

{ #category : 'tests - errors' }
NTTaskReaderTest >> testItemWithoutCheckboxRaisesError [

	self
		should: [
				NTTaskReader read: (self text: '- Call Bob
') ]
		raise: NTTaskParseError
]

{ #category : 'tests' }
NTTaskReaderTest >> testParseErrorReportsLine [

	| error |
	error := [
		         NTTaskReader read: (self text: '- [ ] a
not an item
') ]
		         on: NTTaskParseError
		         do: [ :e | e ].
	self assert: error lineNumber equals: 2.
	self assert: error line equals: 'not an item'
]

{ #category : 'tests' }
NTTaskReaderTest >> testReadCrLineEndings [

	| task |
	task := NTTaskReader read: (String crlf join: #( '- [ ] a' '- [ ] b' '' )).
	self assert: task items size equals: 2
]

{ #category : 'tests' }
NTTaskReaderTest >> testReadDescription [

	| task |
	task := NTTaskReader read: (self text: '- [ ] Write release notes
  Mention the new compiler.
  Link the changelog.
- [ ] Sign-off
').
	self assert: task items size equals: 2.
	self assert: task items first description equals: (String cr join: #( 'Mention the new compiler.' 'Link the changelog.' )).
	self assert: task items second description isEmpty
]

{ #category : 'tests' }
NTTaskReaderTest >> testReadDoneItem [

	| item |
	item := NTTaskReader new readItemLine: '- [x] Call Bob'.
	self assert: item isDone
]

{ #category : 'tests' }
NTTaskReaderTest >> testReadDoneItemWithUppercaseX [

	| item |
	item := NTTaskReader new readItemLine: '- [X] Call Bob'.
	self assert: item isDone
]

{ #category : 'tests' }
NTTaskReaderTest >> testReadEmptyText [

	| task |
	task := NTTaskReader read: ''.
	self assert: task items isEmpty.
	self assert: task isOpen
]

{ #category : 'tests' }
NTTaskReaderTest >> testReadFileWithoutMetadata [

	| task |
	task := NTTaskReader read: (self text: '- [ ] Call Bob
').
	self assert: task title isEmpty.
	self assert: task items size equals: 1
]

{ #category : 'tests' }
NTTaskReaderTest >> testReadFinishedDate [

	| task |
	task := NTTaskReader read: (self text: '{
  "title" : "Move office",
  "status" : "finished",
  "finishedDate" : "2026-10-21"
}

- [x] Pack books
').
	self assert: task isFinished.
	self assert: task finishedDate equals: (Date year: 2026 month: 10 day: 21)
]

{ #category : 'tests' }
NTTaskReaderTest >> testReadKeepsItemOrder [

	| task |
	task := NTTaskReader read: (self text: '- [ ] c
- [x] a
- [ ] b
').
	self assert: (task items collect: [ :each | each title ] as: Array) equals: #( 'c' 'a' 'b' )
]

{ #category : 'tests' }
NTTaskReaderTest >> testReadKeyValueWithSpaces [

	| item |
	item := NTTaskReader new readItemLine: '- [ ] Sign-off @waitingOthers(Marcus Denker)'.
	self assert: item waitingOthers equals: 'Marcus Denker'
]

{ #category : 'tests' }
NTTaskReaderTest >> testReadKeysAndTagsInOrder [

	| item |
	item := NTTaskReader new readItemLine: '- [ ] Write release notes @due(2026-11-15) #release @prio(high)'.
	self assert: item title equals: 'Write release notes'.
	self assert: (item annotations collect: [ :each | each name ] as: Array) equals: #( 'due' 'release' 'prio' ).
	self assert: item due equals: (self nov: 15).
	self assert: (item hasTag: 'release').
	self assert: item isHighPriority
]

{ #category : 'tests' }
NTTaskReaderTest >> testReadMetadata [

	| task |
	task := NTTaskReader read: (self text: '{
  "title" : "Pharo 14 release",
  "section" : "Pharo",
  "status" : "open",
  "creationDate" : "2026-11-04T10:00:00+01:00",
  "lastModificationDate" : "2026-11-09T18:20:00+01:00"
}
').
	self assert: task title equals: 'Pharo 14 release'.
	self assert: task section equals: 'Pharo'.
	self assert: task isOpen.
	self assert: task creationDate equals: '2026-11-04T10:00:00+01:00' asDateAndTime.
	self assert: task lastModificationDate equals: '2026-11-09T18:20:00+01:00' asDateAndTime
]

{ #category : 'tests' }
NTTaskReaderTest >> testReadOpenItem [

	| item |
	item := NTTaskReader new readItemLine: '- [ ] Call Bob'.
	self deny: item isDone.
	self assert: item title equals: 'Call Bob'
]

{ #category : 'tests' }
NTTaskReaderTest >> testReadUrlKey [

	| item |
	item := NTTaskReader new readItemLine: '- [ ] Read doc @url(https://pharo.org/a#b)'.
	self assert: item url equals: 'https://pharo.org/a#b'.
	self assert: item tags isEmpty
]

{ #category : 'tests' }
NTTaskReaderTest >> testReadValuelessKey [

	| item |
	item := NTTaskReader new readItemLine: '- [ ] Get contract @waitingOthers'.
	self assert: item title equals: 'Get contract'.
	self assert: item isWaitingOthers.
	self assert: item waitingOthers isNil
]

{ #category : 'tests' }
NTTaskReaderTest >> testStaleFinishedStatusIsCorrectedByItems [

	| task |
	task := NTTaskReader read: (self text: '{
  "title" : "Move office",
  "status" : "finished",
  "finishedDate" : "2026-10-21"
}

- [x] Pack books
- [ ] Clean old office
').
	self assert: task isOpen.
	self assert: task finishedDate isNil
]

{ #category : 'tests' }
NTTaskReaderTest >> testStaleOpenStatusBecomesFinished [

	| task |
	task := NTTaskReader read: (self text: '{
  "title" : "Move office",
  "status" : "open"
}

- [x] Pack books @done(2026-10-21)
').
	self assert: task isFinished.
	self assert: task finishedDate equals: (Date year: 2026 month: 10 day: 21)
]

{ #category : 'tests - errors' }
NTTaskReaderTest >> testUnclosedKeyValueRaisesError [

	self should: [ NTTaskReader new readItemLine: '- [ ] Send @due(2026-11-15' ] raise: NTTaskParseError
]

{ #category : 'tests - errors' }
NTTaskReaderTest >> testUnclosedMetadataRaisesError [

	self
		should: [
				NTTaskReader read: (self text: '{
  "title" : "x"
') ]
		raise: NTTaskParseError
]

{ #category : 'tests' }
NTTaskReaderTest >> testUnknownMetadataIsKept [

	| task |
	task := NTTaskReader read: (self text: '{
  "title" : "Pharo 14 release",
  "owner" : "Stef"
}
').
	self assert: (task otherMetadata at: 'owner') equals: 'Stef'
]

{ #category : 'tests - errors' }
NTTaskReaderTest >> testUnknownStatusRaisesError [

	self
		should: [
				NTTaskReader read: (self text: '{
  "status" : "sleeping"
}
') ]
		raise: NTTaskParseError
]

{ #category : 'tests' }
NTTaskReaderTest >> testWordsAfterAnnotationsGoToTitle [

	| item |
	item := NTTaskReader new readItemLine: '- [ ] Send @due(2026-11-15) the slides'.
	self assert: item title equals: 'Send the slides'.
	self assert: item due equals: (self nov: 15)
]
