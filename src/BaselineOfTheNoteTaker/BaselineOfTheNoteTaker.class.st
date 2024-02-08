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
			spec 
				package: 'TheNoteTaker';
				package: 'TheNoteTaker-Tests'	with: [ spec requires: #(TheNoteTaker) ].
			spec 
				group: 'Core' 						with: #('TheNoteTaker');
				group: 'Tests' 						with: #('TheNoteTaker' 'TheNoteTaker-Tests');
				group: 'default' 					with: #('Core' 'Tests') ]
]
