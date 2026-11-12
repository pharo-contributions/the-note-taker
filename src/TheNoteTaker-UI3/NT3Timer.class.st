"
I run a block once, in the UI process, after a delay; restarting me forgets the block waiting.

## Responsibility:

- I wait in a background process, then hand the block to the application with `defer:`.
- I can be restarted (the previous block is dropped) or stopped.

## Collaborators:

- `NT3Application`: uses me for the autosave and runs my block with `defer:`.

## Public API and Key Messages

- `NT3Timer application: anApplication`
- `restartAfter: aDuration do: aBlock`, `stop`, `isRunning`

```
(NT3Timer application: NT3Application new) restartAfter: 1 second do: [ 'saved' traceCr ]
```

## Internal Representation

- `application`: an `SpApplication`; `process`: the waiting `Process`, or nil.
"
Class {
	#name : 'NT3Timer',
	#superclass : 'Object',
	#instVars : [
		'application',
		'process'
	],
	#category : 'TheNoteTaker-UI3',
	#package : 'TheNoteTaker-UI3'
}

{ #category : 'instance creation' }
NT3Timer class >> application: anApplication [

	^ self new
		  application: anApplication;
		  yourself
]

{ #category : 'examples' }
NT3Timer class >> example [
	"A timer of the note taker application, not running"

	<sampleInstance>
	^ self application: NT3Application new
]

{ #category : 'accessing' }
NT3Timer >> application: anApplication [

	application := anApplication
]

{ #category : 'testing' }
NT3Timer >> isRunning [

	^ process isNotNil and: [ process isTerminated not ]
]

{ #category : 'running' }
NT3Timer >> restartAfter: aDuration do: aBlock [
	"Forget the waiting block, if any, and run aBlock in the UI process once aDuration has passed"

	self stop.
	process := [
		           aDuration wait.
		           application defer: aBlock ]
		           forkAt: Processor userBackgroundPriority
		           named: 'NoteTaker autosave'
]

{ #category : 'running' }
NT3Timer >> stop [

	process ifNotNil: [ :each | each terminate ].
	process := nil
]
