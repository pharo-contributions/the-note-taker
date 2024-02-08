Class {
	#name : 'NTSpApplication',
	#superclass : 'SpApplication',
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'private' }
NTSpApplication class >> menuNoteTakersOn: aBuilder [
	<worldMenu>

	(aBuilder item: #NoteTaker)
		parent: #Tools;
		label: 'The Note Taker';
		icon: (self iconNamed: #catalog);
		action: [ NTSpApplication new run ];
		help: 'The Note Taker';
		order: 630
]

{ #category : 'accessig' }
NTSpApplication >> noteInformation: aNtNodeModel [

	self shouldBeImplemented.
	^ aNtNodeModel 
]

{ #category : 'running' }
NTSpApplication >> start [
	" Private - See superimplementor's comment "

	(NTSpNoteTakerMainUI newApplication: self) open.
]
