"
Class to manage The Note Taker settings.

"
Class {
	#name : 'NTSettings',
	#superclass : 'Object',
	#classVars : [
		'ProjectPathString'
	],
	#category : 'TheNoteTaker-Utilities',
	#package : 'TheNoteTaker',
	#tag : 'Utilities'
}

{ #category : 'accessing' }
NTSettings class >> projectPathSettingsOn: aBuilder [
	<systemsettings>

	(aBuilder group: #tnt)
		label: 'The Note Taker';
		description: 'All TNT related settings';
		noOrdering;
		with: [
			(aBuilder setting: #projectPathString)
				label: 'Project Path' ;
				ghostHelp: '/Users/ducasse/Workspace/FirstCircle/Writing/Working/researchnotes';
				default: '';
				description: 'Enter your local or remote path where notes will be committed. It can be empty']
]

{ #category : 'accessing' }
NTSettings class >> projectPathString [
	"Answer the preferred <String> where notes will be stored"

	^ ProjectPathString
]

{ #category : 'accessing' }
NTSettings class >> projectPathString: aString [
	"Set the preferred <String> where notes will be stored"

	ProjectPathString := aString
]
