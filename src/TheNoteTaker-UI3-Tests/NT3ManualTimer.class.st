"
I replace `NT3Timer` in tests: I keep the block until `fire` is sent.

## Responsibility:

- I remember the block and the duration given to `restartAfter:do:`.
- I run the block when told to, as if the delay was over.

## Collaborators:

- `NT3Application`: the autosave timer of the tests (`autosaveTimer:`).

## Public API and Key Messages

- `restartAfter:do:`, `stop`, `fire`, `isRunning`, `duration`

```
NT3ManualTimer example fire
```

## Internal Representation

- `block`: the block waiting, or nil; `duration`: the last delay asked.
"
Class {
	#name : 'NT3ManualTimer',
	#superclass : 'Object',
	#instVars : [
		'block',
		'duration'
	],
	#category : 'TheNoteTaker-UI3-Tests',
	#package : 'TheNoteTaker-UI3-Tests'
}

{ #category : 'examples' }
NT3ManualTimer class >> example [
	"A timer waiting to print a message, until fire is sent"

	<sampleInstance>
	^ self new
		  restartAfter: 10 seconds do: [ 'done' traceCr ];
		  yourself
]

{ #category : 'accessing' }
NT3ManualTimer >> duration [

	^ duration
]

{ #category : 'running' }
NT3ManualTimer >> fire [
	"Run the block as if its delay was over"

	| toRun |
	toRun := block.
	block := nil.
	toRun ifNotNil: [ toRun value ]
]

{ #category : 'testing' }
NT3ManualTimer >> isRunning [

	^ block isNotNil
]

{ #category : 'running' }
NT3ManualTimer >> restartAfter: aDuration do: aBlock [

	duration := aDuration.
	block := aBlock
]

{ #category : 'running' }
NT3ManualTimer >> stop [

	block := nil
]
