"
Tests of the task model and file format of the redesigned Todo part (TheNoteTaker-Tasks).
"
Class {
	#name : 'NTTaskWriterTest',
	#superclass : 'NTTaskTestCase',
	#category : 'TheNoteTaker-Tasks-Tests',
	#package : 'TheNoteTaker-Tasks-Tests'
}

{ #category : 'helpers' }
NTTaskWriterTest >> assertRoundTrip: aString [

	self assert: (NTTaskWriter write: (NTTaskReader read: aString)) equals: aString
]

{ #category : 'helpers' }
NTTaskWriterTest >> canonicalFile [
	"Answer a task file written in the canonical form, so reading and writing it gives the same text."

	^ self text: '{
  "title" : "Pharo 14 release",
  "section" : "Pharo",
  "status" : "open",
  "creationDate" : "2026-11-04T10:00:00+01:00",
  "lastModificationDate" : "2026-11-09T18:20:00+01:00",
  "owner" : "Stef"
}

- [x] Freeze API @done(2026-11-02)
- [ ] Write release notes @due(2026-11-15) @prio(high) #release
  Mention the new compiler.
  Link the changelog.
- [ ] Sign-off @waitingOthers(Marcus) @mood(calm)
- [ ] Celebrate @waitingOthers #team
'
]

{ #category : 'tests' }
NTTaskWriterTest >> testNormalizesMixedTitleWords [
	"Title words written after annotations are moved before them."

	| task |
	task := NTTaskReader read: (self text: '- [ ] Send @due(2026-11-15) the slides
').
	self assert: (NTTaskWriter new itemLine: task items first) equals: '- [ ] Send the slides @due(2026-11-15)'
]

{ #category : 'tests' }
NTTaskWriterTest >> testRoundTripAbandonedTask [

	self assertRoundTrip: (self text: '{
  "title" : "Old grant idea",
  "section" : "Research",
  "status" : "abandoned"
}

- [ ] Draft
')
]

{ #category : 'tests' }
NTTaskWriterTest >> testRoundTripCanonicalFile [

	self assertRoundTrip: self canonicalFile
]

{ #category : 'tests' }
NTTaskWriterTest >> testRoundTripFinishedTask [

	self assertRoundTrip: (self text: '{
  "title" : "Move office",
  "section" : "Admin",
  "status" : "finished",
  "finishedDate" : "2026-10-21"
}

- [x] Book movers @done(2026-10-12)
- [x] Pack books @done(2026-10-21)
')
]

{ #category : 'tests' }
NTTaskWriterTest >> testRoundTripOfWrittenTask [
	"A task built in memory survives a write and a read."

	| task copy |
	task := NTTask title: 'Pharo 14 release'.
	task section: 'Pharo'.
	((task addItemTitled: 'Freeze API' on: (self nov: 1))
		 markDoneOn: (self nov: 2);
		 yourself) addTag: 'release'.
	(task addItemTitled: 'Sign-off' on: (self nov: 1)) waitingOthers: 'Marcus'.
	copy := NTTaskReader read: (NTTaskWriter write: task).
	self assert: copy title equals: 'Pharo 14 release'.
	self assert: copy section equals: 'Pharo'.
	self assert: copy items size equals: 2.
	self assert: copy items first doneDate equals: (self nov: 2).
	self assert: (copy items first hasTag: 'release').
	self assert: copy items second waitingOthers equals: 'Marcus'
]

{ #category : 'tests' }
NTTaskWriterTest >> testRoundTripTaskWithoutItems [

	self assertRoundTrip: (self text: '{
  "title" : "Empty",
  "status" : "open"
}
')
]

{ #category : 'tests' }
NTTaskWriterTest >> testRoundTripTitleWithQuotes [

	self assertRoundTrip: (self text: '{
  "title" : "Say \"hi\" to Bob",
  "status" : "open"
}
')
]

{ #category : 'tests' }
NTTaskWriterTest >> testWriteAnnotationsInOrder [

	| item |
	item := NTTaskItem title: 'Send slides'.
	item addTag: 'work'.
	item due: (self nov: 15).
	item keyAt: 'waitingOthers' put: nil.
	self assert: (NTTaskWriter new itemLine: item) equals: '- [ ] Send slides #work @due(2026-11-15) @waitingOthers'
]

{ #category : 'tests' }
NTTaskWriterTest >> testWriteDescriptionIndented [

	| task item |
	task := NTTask title: 'T'.
	item := task addItem: (NTTaskItem title: 'Write notes').
	item description: (String cr join: #( 'line one' 'line two' )).
	self assert: (NTTaskWriter write: task) equals: (self text: '{
  "title" : "T",
  "status" : "open"
}

- [ ] Write notes
  line one
  line two
')
]

{ #category : 'tests' }
NTTaskWriterTest >> testWriteDoneItemLine [

	| item |
	item := NTTaskItem title: 'Call Bob'.
	item markDoneOn: (self nov: 8).
	self assert: (NTTaskWriter new itemLine: item) equals: '- [x] Call Bob @done(2026-11-08)'
]

{ #category : 'tests' }
NTTaskWriterTest >> testWriteEscapesQuotesInMetadata [

	| task |
	task := NTTask title: 'Say "hi"'.
	self assert: ((NTTaskWriter write: task) includesSubstring: '"title" : "Say \"hi\""')
]

{ #category : 'tests' }
NTTaskWriterTest >> testWriteMetadataKeyOrder [

	| task |
	task := NTTask title: 'Move office'.
	task otherMetadata at: 'owner' put: 'Stef'.
	task creationDate: (DateAndTime fromString: '2026-10-01T09:00:00+02:00').
	task section: 'Admin'.
	task status: #finished.
	task finishedDate: (Date year: 2026 month: 10 day: 21).
	self assert: (NTTaskWriter write: task) equals: (self text: '{
  "title" : "Move office",
  "section" : "Admin",
  "status" : "finished",
  "finishedDate" : "2026-10-21",
  "creationDate" : "2026-10-01T09:00:00+02:00",
  "owner" : "Stef"
}
')
]

{ #category : 'tests' }
NTTaskWriterTest >> testWriteOpenItemLine [

	self assert: (NTTaskWriter new itemLine: (NTTaskItem title: 'Call Bob')) equals: '- [ ] Call Bob'
]

{ #category : 'tests' }
NTTaskWriterTest >> testWriteUsesLfOnly [

	| text |
	text := NTTaskWriter write: (NTTaskReader read: self canonicalFile).
	self deny: (text includes: Character cr)
]
