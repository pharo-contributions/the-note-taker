"
I am one line of a view: an item together with the task it belongs to.

## Responsibility:

- I know an item and its task, so a view can show where an item comes from.
- I let the UI tick the item and save its task.

## Collaborators: 

- `NTItemView`: creates me.
- `NTTaskItem`, `NTTask`: what I point to.

## Public API and Key Messages

- `NTViewEntry item: anItem task: aTask`
- `item`, `task`

See `NTViewEntry class >> #exampleEntry`.

## Internal Representation

- `item`: an `NTTaskItem`; `task`: the `NTTask` that holds it.
"
Class {
	#name : 'NTViewEntry',
	#superclass : 'Object',
	#instVars : [
		'item',
		'task'
	],
	#category : 'TheNoteTaker-Tasks-Views',
	#package : 'TheNoteTaker-Tasks',
	#tag : 'Views'
}

{ #category : 'examples' }
NTViewEntry class >> exampleEntry [

	<sampleInstance>
	| task |
	task := NTTask examplePharoRelease.
	^ self item: task items second task: task
]

{ #category : 'instance creation' }
NTViewEntry class >> item: anItem task: aTask [

	^ self new
		  item: anItem;
		  task: aTask;
		  yourself
]

{ #category : 'accessing' }
NTViewEntry >> item [

	^ item
]

{ #category : 'accessing' }
NTViewEntry >> item: anItem [

	item := anItem
]

{ #category : 'testing' }
NTViewEntry >> matchesFilter: aString [
	"Answer whether I match the text of the filter field: nothing, a #tag of my item, or a text found, ignoring case, in the title or description of my item or in the title of my task."

	| filter |
	filter := aString trimBoth.
	filter ifEmpty: [ ^ true ].
	(filter first = $# and: [ filter size > 1 ]) ifTrue: [ ^ item tags anySatisfy: [ :each | each sameAs: filter allButFirst ] ].
	^ {
		  item title.
		  item description.
		  task title } anySatisfy: [ :each | each isNotNil and: [ each includesSubstring: filter caseSensitive: false ] ]
]

{ #category : 'accessing' }
NTViewEntry >> task [

	^ task
]

{ #category : 'accessing' }
NTViewEntry >> task: aTask [

	task := aTask
]
