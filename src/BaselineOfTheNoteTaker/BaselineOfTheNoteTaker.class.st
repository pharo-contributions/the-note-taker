Class {
	#name : 'BaselineOfTheNoteTaker',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfTheNoteTaker',
	#package : 'BaselineOfTheNoteTaker'
}

{ #category : 'baselines' }
BaselineOfTheNoteTaker >> applicationGenerator: spec [

	spec
		baseline: 'ApplicationGenerator'
		with: [ spec repository: 'github://tesonep/PharoApplicationGenerator:master/src' ]
]

{ #category : 'baselines' }
BaselineOfTheNoteTaker >> baseline: spec [

	<baseline>
	spec for: #( common ) do: [
			spec preLoadDoIt: #preload:package:.
			spec postLoadDoIt: #postload:package:.
			self osWinSubprocess: spec.
			self osSubprocess: spec.
			self microdown: spec.
			self applicationGenerator: spec.
			self objcbridge: spec.
			spec
				package: 'TheNoteTaker' with: [ spec requires: #( Microdown ) ];
				package: 'TheNoteTaker-UI' with: [ spec requires: #( TheNoteTaker OSSubprocess OSWinSubprocess 'TheNoteTaker-Todo-UI' ) ];
				package: 'TheNoteTaker-Release' with: [ spec requires: #( 'TheNoteTaker-UI' 'ApplicationGenerator' 'ObjCBridge' ) ];
				package: 'TheNoteTaker-Tests' with: [ spec requires: #( TheNoteTaker ) ];
				package: 'TheNoteTaker-UI-Tests' with: [ spec requires: #( 'TheNoteTaker-Tests' 'TheNoteTaker-UI' ) ];
				package: 'TheNoteTaker-Todo';
				package: 'TheNoteTaker-Todo-Tests' with: [ spec requires: #( 'TheNoteTaker-Todo' ) ];
				package: 'TheNoteTaker-Todo-UI' with: [ spec requires: #( 'TheNoteTaker-Todo' ) ].

			spec
				group: 'Core' with: #( 'TheNoteTaker' );
				group: 'UI' with: #( 'TheNoteTaker-UI' );
				group: 'Tests' with: #( 'TheNoteTaker-Tests' 'TheNoteTaker-UI-Tests' 'TheNoteTaker-Todo-Tests' );
				group: 'Release' with: #( 'TheNoteTaker-Release' );
				group: 'default' with: #( 'Tests' 'UI' ) ]
]

{ #category : 'baselines' }
BaselineOfTheNoteTaker >> microdown: spec [

	spec
		baseline: 'Microdown'
		with: [ spec
			repository: 'github://pillar-markup/Microdown:dev/src';
			loads: 'Editor'
			].
]

{ #category : 'baselines' }
BaselineOfTheNoteTaker >> objcbridge: spec [

	spec baseline: 'ObjCBridge' with: [
		spec repository: 'github://tesonep/objcbridge:master/src' ].	
]

{ #category : 'baselines' }
BaselineOfTheNoteTaker >> osSubprocess: spec [

	spec 
		baseline: #OSSubprocess
		with: [ spec repository: 'github://pharo-contributions/OSSubprocess:master/repository' ]
]

{ #category : 'baselines' }
BaselineOfTheNoteTaker >> osWinSubprocess: spec [

	spec 
		baseline: #OSWinSubprocess
		with: [ spec repository: 'github://pharo-contributions/OSWinSubprocess:master/src' ]
]

{ #category : 'baselines' }
BaselineOfTheNoteTaker >> postload: loader package: packageSpec [
	
	'TheNoteTaker baseline postload ' traceCr.
	"OSSubProcess spawns a process that is polling and it clashes with the automatic rewriting
	so we kill it for now."
	
	((Process allInstances select: [ :p | p priority = 70 ]) select: [ :e | '*OSSub*' match: e name ]) 
		ifNotEmpty: [ : processArray | processArray first terminate ]
]

{ #category : 'baselines' }
BaselineOfTheNoteTaker >> preload: loader package: packageSpec [
	
	#( 'Microdown' ) do: [ :name |
		(IceRepository repositoryNamed: name)
			ifNil: [ self inform: 'Project not found: ' , name ]
			ifNotNil: [ :found |
				found
					unload;
					forget ] ].
	Smalltalk globals 
			at: #BaselineOfMicrodown 
			ifPresent: [ :c | c removeFromSystem ].
	
]
