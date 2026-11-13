"
I test the rows of the note list.
"
Class {
	#name : 'NT3NoteRowPresenterTest',
	#superclass : 'TestCase',
	#category : 'TheNoteTaker-UI3-Tests',
	#package : 'TheNoteTaker-UI3-Tests'
}

{ #category : 'helpers' }
NT3NoteRowPresenterTest >> note [

	^ NT3Application
		  noteTitled: '# Meeting'
		  body: 'About the **new** list'
		  modifiedAt: (DateAndTime
				   year: 2026
				   month: 11
				   day: 12
				   hour: 9
				   minute: 0)
		  tagNames: #( 'spec' )
]

{ #category : 'helpers' }
NT3NoteRowPresenterTest >> noteTagged: aCollection body: aString [

	^ NT3Application
		  noteTitled: 'Meeting'
		  body: aString
		  modifiedAt: (DateAndTime
				   year: 2026
				   month: 11
				   day: 12
				   hour: 9
				   minute: 0)
		  tagNames: aCollection
]

{ #category : 'helpers' }
NT3NoteRowPresenterTest >> rowShowingDetails: aBoolean on: anEntry [

	^ NT3NoteRowPresenter new
		  showsDetails: aBoolean;
		  today: (Date year: 2026 month: 11 day: 12);
		  model: anEntry;
		  yourself
]

{ #category : 'helpers' }
NT3NoteRowPresenterTest >> rowShowingTagsOn: aNote [

	^ NT3NoteRowPresenter new
		  showsTags: true;
		  today: (Date year: 2026 month: 11 day: 12);
		  model: aNote;
		  yourself
]

{ #category : 'tests' }
NT3NoteRowPresenterTest >> testCompactNoteRowShowsOnlyTheTitle [

	| row |
	row := self rowShowingDetails: false on: self note.
	self assert: row titleText equals: 'Meeting'.
	self deny: row showsDetailLine
]

{ #category : 'tests - tags' }
NT3NoteRowPresenterTest >> testCompactRowShowsNoTags [

	| row |
	row := NT3NoteRowPresenter new
		       showsDetails: false;
		       showsTags: true;
		       model: self note;
		       yourself.
	self deny: row showsDetailLine.
	self deny: row showsTagLabels
]

{ #category : 'tests - tags' }
NT3NoteRowPresenterTest >> testDetailLineShowsTheTagsBetweenDateAndText [

	self assert: (self rowShowingTagsOn: self note) detailText equals: 'today · #spec · About the new list'
]

{ #category : 'tests - tags' }
NT3NoteRowPresenterTest >> testDetailLineShowsTwoTagsAndTheHiddenCount [

	| row |
	row := self rowShowingTagsOn: (self noteTagged: #( 'talks' 'spec' 'books' 'pharo' ) body: 'Slides').
	self assert: row detailText equals: 'today · #books #pharo +2 · Slides'
]

{ #category : 'tests - tags' }
NT3NoteRowPresenterTest >> testDetailLineWithTagsAndNoText [

	self assert: (self rowShowingTagsOn: (self noteTagged: #( 'spec' ) body: '')) detailText equals: 'today · #spec'
]

{ #category : 'tests - tags' }
NT3NoteRowPresenterTest >> testHiddenCountHasAllTheTagsAsHelp [

	| row |
	row := self rowShowingTagsOn: (self noteTagged: #( 'talks' 'spec' 'books' 'pharo' ) body: 'Slides').
	self assert: row hiddenTagsLabel help equals: '#books #pharo #spec #talks'
]

{ #category : 'tests' }
NT3NoteRowPresenterTest >> testNoteRowShowsTitleAndDetailLine [

	| row |
	row := self rowShowingDetails: true on: self note.
	self assert: row titleText equals: 'Meeting'.
	self assert: row detailText equals: 'today · About the new list'.
	self assert: row showsDetailLine
]

{ #category : 'tests - tags' }
NT3NoteRowPresenterTest >> testNoteWithoutTagsHasNoTagLabels [

	| row |
	row := self rowShowingTagsOn: (self noteTagged: #(  ) body: 'Slides').
	self assert: row detailText equals: 'today · Slides'.
	self deny: row showsTagLabels
]

{ #category : 'tests' }
NT3NoteRowPresenterTest >> testSavedNoteTitleHasNoBullet [

	self assert: (self rowShowingDetails: false on: self note) titleText equals: 'Meeting'
]

{ #category : 'tests' }
NT3NoteRowPresenterTest >> testSeparatorRowShowsItsLabel [

	| row |
	row := self rowShowingDetails: true on: (NT3ListSeparator label: 'November 2026').
	self assert: row titleText equals: 'November 2026'.
	self deny: row showsDetailLine.
	self assert: row isSeparatorRow
]

{ #category : 'tests - tags' }
NT3NoteRowPresenterTest >> testTagLabelsHaveTheTagStyle [

	| row |
	row := self rowShowingTagsOn: (self noteTagged: #( 'talks' 'spec' 'books' 'pharo' ) body: 'Slides').
	self assert: (row shownTagsLabel styles includes: 'ntTag').
	self assert: (row hiddenTagsLabel styles includes: 'ntTag')
]

{ #category : 'tests - tags' }
NT3NoteRowPresenterTest >> testTagsAreHiddenWhenNotShown [

	| row |
	row := self rowShowingDetails: true on: self note.
	self assert: row detailText equals: 'today · About the new list'.
	self deny: row showsTagLabels
]

{ #category : 'tests' }
NT3NoteRowPresenterTest >> testUnsavedNoteTitleStartsWithABullet [

	| row |
	row := NT3NoteRowPresenter new
		       isUnsavedBlock: [ :each | true ];
		       model: self note;
		       yourself.
	self assert: row titleText equals: '• Meeting'
]

{ #category : 'tests' }
NT3NoteRowPresenterTest >> testUntitledNoteRowShowsUnnamed [

	| row |
	row := self rowShowingDetails: false on: (NTNote content: '#').
	self assert: row titleText equals: 'unnamed'
]
