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
		with: [ spec repository: 'github://hernanmd/PharoApplicationGenerator:allow_dwnld_ui_vm/src' ]
]

{ #category : 'baselines' }
BaselineOfTheNoteTaker >> baseline: spec [

	<baseline>
	spec for: #( common ) do: [
		"self ical: spec."
	
		self microdown: spec.
		self applicationGenerator: spec.
		self objcbridge: spec.
		self osSubProcess: spec.
		spec postLoadDoIt: #'postload:package:'.
		spec
			package: 'TheNoteTaker' 	with: [ spec requires: #( Microdown ) ];
			package: 'TheNoteTaker-UI' 	with: [ spec requires: #( TheNoteTaker ) ];
			package: 'TheNoteTaker-Release' with: [ spec requires: #( ApplicationGenerator ObjCBridge ) ];
			package: 'TheNoteTaker-Tests' with: [ spec requires: #( TheNoteTaker ) ];
			package: 'TheNoteTaker-UI-Tests' with: [ spec requires: #( 'TheNoteTaker-Tests' 'TheNoteTaker-UI' ) ].
		spec
			group: 'Core' with: #( 'TheNoteTaker' );
			group: 'UI' with: #( 'TheNoteTaker-UI' );
			group: 'Tests' with: #( 'Core' 'TheNoteTaker-Tests' 'TheNoteTaker-UI-Tests' );
			group: 'Release' with: #( 'Core' 'UI' 'ObjCBridge' 'TheNoteTaker-Release' );
			group: 'default' with: #( 'Core' 'Tests' 'UI' ) ]
]

{ #category : 'baselines' }
BaselineOfTheNoteTaker >> ical: spec [

	spec
		baseline: 'ICal'
		with: [ spec repository: 'github://Ducasse/Infhub/src' ]
]

{ #category : 'baselines' }
BaselineOfTheNoteTaker >> microEd: spec [

	spec
		baseline: 'MicroEd'
		with: [ spec repository: 'github://pillar-markup/MicroEd/src' ]
]

{ #category : 'baselines' }
BaselineOfTheNoteTaker >> microdown: spec [

	spec
		baseline: 'Microdown'
		with: [ spec 
			loads: 'All';
			repository: 'github://pillar-markup/Microdown:dev/src' ].
]

{ #category : 'baselines' }
BaselineOfTheNoteTaker >> objcbridge: spec [

	spec baseline: 'ObjCBridge' with: [
		spec repository: 'github://tesonep/objcbridge:master/src' ].	
]

{ #category : 'baselines' }
BaselineOfTheNoteTaker >> osSubProcess: spec [

	spec 
		baseline: 'OSSubprocess' 
		with: [ spec repository: 'github://pharo-contributions/OSSubprocess:v2.0.0/repository' ]

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
BaselineOfTheNoteTaker >> processWrapper: spec [ 

	spec configuration: 'ProcessWrapper' with: [
		spec
			versionString: '1.2';
			repository: 'http://smalltalkhub.com/mc/hernan/ProcessWrapper/main' ]
]
