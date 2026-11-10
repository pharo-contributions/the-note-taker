"
I test `NTViewEntry`, mainly the filter field of the views: a word or a #tag.
"
Class {
	#name : 'NTViewEntryTest',
	#superclass : 'NTTaskTestCase',
	#category : 'TheNoteTaker-Tasks-Tests-Views',
	#package : 'TheNoteTaker-Tasks-Tests',
	#tag : 'Views'
}

{ #category : 'helpers' }
NTViewEntryTest >> entry [
	"Item 'Write release notes' (#release, description about the compiler) of task 'Pharo 14 release'."

	| task |
	task := NTTask title: 'Pharo 14 release'.
	task addItem: ((NTTaskReader new readItemLine: '- [ ] Write release notes #release')
			 description: 'Mention the new compiler.';
			 yourself).
	^ NTViewEntry item: task items first task: task
]

{ #category : 'tests' }
NTViewEntryTest >> testEmptyFilterMatches [

	self assert: (self entry matchesFilter: '').
	self assert: (self entry matchesFilter: '   ')
]

{ #category : 'tests' }
NTViewEntryTest >> testFilterTag [

	self assert: (self entry matchesFilter: '#release').
	self assert: (self entry matchesFilter: ' #Release ').
	self deny: (self entry matchesFilter: '#rel')
]

{ #category : 'tests' }
NTViewEntryTest >> testFilterTagIsNotAWord [
	"#notes is a tag filter: the word notes in the title does not match it."

	self deny: (self entry matchesFilter: '#notes')
]

{ #category : 'tests' }
NTViewEntryTest >> testFilterWordInDescription [

	self assert: (self entry matchesFilter: 'compiler')
]

{ #category : 'tests' }
NTViewEntryTest >> testFilterWordInItemTitleIgnoresCase [

	self assert: (self entry matchesFilter: 'NOTES').
	self deny: (self entry matchesFilter: 'slides')
]

{ #category : 'tests' }
NTViewEntryTest >> testFilterWordInTaskTitle [

	self assert: (self entry matchesFilter: 'pharo 14')
]
