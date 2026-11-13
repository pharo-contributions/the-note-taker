"
I test the relative date and the excerpt of `NT3NotePreview`.
"
Class {
	#name : 'NT3NotePreviewTest',
	#superclass : 'TestCase',
	#category : 'TheNoteTaker-UI3-Tests',
	#package : 'TheNoteTaker-UI3-Tests'
}

{ #category : 'helpers' }
NT3NotePreviewTest >> excerptOf: aContents [

	^ (self previewOf: aContents modifiedAt: DateAndTime now) excerpt
]

{ #category : 'helpers' }
NT3NotePreviewTest >> infoPreviewTagged: aCollection modifiedAt: aString [

	| note |
	note := NTNote content: 'Title'.
	aCollection do: [ :each | note addTag: (NTTag newNamed: each) ].
	note
		creationDate: (DateAndTime fromString: '2026-11-03T10:00:00');
		modificationDate: (DateAndTime fromString: aString).
	^ NT3NotePreview note: note today: (Date year: 2026 month: 11 day: 12)
]

{ #category : 'helpers' }
NT3NotePreviewTest >> previewOf: aContents modifiedAt: aDateAndTime [

	^ NT3NotePreview
		  note: ((NTNote content: aContents)
				   modificationDate: aDateAndTime;
				   yourself)
		  today: (Date year: 2026 month: 11 day: 12)
]

{ #category : 'helpers' }
NT3NotePreviewTest >> relativeDateOf: aDateAndTime [

	^ (self previewOf: 'Title' modifiedAt: aDateAndTime) relativeDate
]

{ #category : 'tests' }
NT3NotePreviewTest >> testDetailLineJoinsDateAndExcerpt [

	| nineToday |
	nineToday := DateAndTime
		             year: 2026
		             month: 11
		             day: 12
		             hour: 9
		             minute: 0.
	self
		assert: (self previewOf: (String cr join: #( 'Title' 'Some body' )) modifiedAt: nineToday) detailLine
		equals: 'today · Some body'.
	self assert: (self previewOf: 'Title' modifiedAt: nineToday) detailLine equals: 'today'
]

{ #category : 'tests - excerpt' }
NT3NotePreviewTest >> testExcerptOfNoteWithOnlyATitleIsEmpty [

	self assert: (self excerptOf: '# Only a title') isEmpty.
	self assert: (self excerptOf: (String cr join: #( 'Title' '' '   ' ))) isEmpty
]

{ #category : 'tests - excerpt' }
NT3NotePreviewTest >> testExcerptRemovesEmphasisUnderscoresButKeepsInnerOnes [

	self
		assert: (self excerptOf: (String cr join: #( 'Title' 'Use _emphasis_. Keep snake_case (_here_)' )))
		equals: 'Use emphasis. Keep snake_case (here)'
]

{ #category : 'tests - excerpt' }
NT3NotePreviewTest >> testExcerptRemovesMarkdownAndLineBreaks [

	self
		assert:
		(self excerptOf: (String cr join: #( '# Title' '## **Bold** text with `code`' '- a [link](http://pharo.org) and _more_' )))
		equals: 'Bold text with code a link and more'
]

{ #category : 'tests - info line' }
NT3NotePreviewTest >> testInfoLineOfUnsavedNoteStartsWithABullet [

	self
		assert: ((self infoPreviewTagged: #( 'spec' ) modifiedAt: '2026-11-12T14:32:00') infoLineUnsaved: true)
		equals: '• #spec · modified today 14:32 · created 3 Nov 2026'
]

{ #category : 'tests - info line' }
NT3NotePreviewTest >> testInfoLineShowsTagsAndDates [

	self
		assert: ((self infoPreviewTagged: #( 'spec' 'pharo' ) modifiedAt: '2026-11-12T14:32:00') infoLineUnsaved: false)
		equals: '#pharo #spec · modified today 14:32 · created 3 Nov 2026'
]

{ #category : 'tests - info line' }
NT3NotePreviewTest >> testInfoLineWithoutTags [

	self
		assert: ((self infoPreviewTagged: #(  ) modifiedAt: '2026-11-11T09:05:00') infoLineUnsaved: false)
		equals: 'modified yesterday 09:05 · created 3 Nov 2026'
]

{ #category : 'tests - excerpt' }
NT3NotePreviewTest >> testLongExcerptIsCutWithEllipsis [

	| excerpt |
	excerpt := self excerptOf: (String cr join: {
				            'Title'.
				            (String new: 500 withAll: $a) }).
	self assert: excerpt size equals: NT3NotePreview maximumExcerptSize.
	self assert: excerpt last equals: $…
]

{ #category : 'tests - date' }
NT3NotePreviewTest >> testRelativeDateAfterAWeekGivesWeekDayAndDay [

	self
		assert: (self relativeDateOf: (DateAndTime
					  year: 2026
					  month: 11
					  day: 5
					  hour: 8
					  minute: 0))
		equals: 'Thu 5'.
	self
		assert: (self relativeDateOf: (DateAndTime
					  year: 2025
					  month: 12
					  day: 20
					  hour: 8
					  minute: 0))
		equals: 'Sat 20'
]

{ #category : 'tests - date' }
NT3NotePreviewTest >> testRelativeDateOfRecentDays [

	self
		assert: (self relativeDateOf: (DateAndTime
					  year: 2026
					  month: 11
					  day: 12
					  hour: 23
					  minute: 50))
		equals: 'today'.
	self
		assert: (self relativeDateOf: (DateAndTime
					  year: 2026
					  month: 11
					  day: 11
					  hour: 8
					  minute: 0))
		equals: 'yesterday'.
	self
		assert: (self relativeDateOf: (DateAndTime
					  year: 2026
					  month: 11
					  day: 9
					  hour: 8
					  minute: 0))
		equals: '3 days ago'.
	self
		assert: (self relativeDateOf: (DateAndTime
					  year: 2026
					  month: 11
					  day: 6
					  hour: 8
					  minute: 0))
		equals: '6 days ago'
]
