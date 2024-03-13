Class {
	#name : 'BaselineOfTheNoteTaker',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfTheNoteTaker',
	#package : 'BaselineOfTheNoteTaker'
}

{ #category : 'baselines' }
BaselineOfTheNoteTaker >> baseline: spec [
  <baseline>
	spec
		for: #(common)
		do: [ 
			self ical: spec.
			self microEd: spec.

			spec 
				package: 'TheNoteTaker';
				package: 'TheNoteTaker-UI'     with: [ spec requires: #(#MicroEd TheNoteTaker) ];
				package: 'TheNoteTaker-Tests'	with: [ spec requires: #(TheNoteTaker) ].
			spec 
				group: 'Core' 						with: #('TheNoteTaker');
				group: 'UI'                    with: #('TheNoteTaker-UI');
				group: 'Tests' 						with: #('TheNoteTaker' 'TheNoteTaker-Tests');
				group: 'default' 					with: #('Core' 'Tests' 'UI') ]
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
		with: [ spec repository: 'github://pillar-markup/Microdown/src' ]
]
