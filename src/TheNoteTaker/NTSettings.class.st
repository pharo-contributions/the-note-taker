"
Class to manage The Note Taker settings.

"
Class {
	#name : 'NTSettings',
	#superclass : 'Object',
	#classVars : [
		'GithubPathString',
		'ProjectPathString'
	],
	#category : 'TheNoteTaker-Utilities',
	#package : 'TheNoteTaker',
	#tag : 'Utilities'
}

{ #category : 'accessing' }
NTSettings class >> githubPathString [

	^ GithubPathString
]

{ #category : 'accessing' }
NTSettings class >> githubPathString: aString [
	"Set the preferred <String> where notes will be stored"

	GithubPathString := aString
]

{ #category : 'accessing' }
NTSettings class >> projectPathSettingsOn: aBuilder [

	<systemsettings>
	
	(aBuilder group: #tnt)
		label: 'The Note Taker';
		description: 'All TNT related settings';
		noOrdering;
		with: [
				(aBuilder setting: #projectPathString)
					label: 'Project Path';
					ghostHelp:
						'/Users/ducasse/Workspace/FirstCircle/Writing/Working/researchnotes';
					default:
						'/Users/ducasse/Workspace/FirstCircle/Writing/Working/researchnotes/faked';
					description:
						'Enter your local or remote path where notes will be committed. It can be empty'.
				(aBuilder setting: #githubPathString)
					label: 'Github Path';
					ghostHelp: 'git@github.com:moufort/noteTest.git';
					default: 'git@github.com:moufort/noteTest.git';
					description:
						'Enter your github path where notes will be committed. It can be empty' ]
]

{ #category : 'accessing' }
NTSettings class >> projectPathString [
	"Answer the preferred <String> where notes will be stored"

	^ ProjectPathString ifNil:[ '/Users/ducasse/Workspace/FirstCircle/Writing/Working/researchnotes/faked' ]
]

{ #category : 'accessing' }
NTSettings class >> projectPathString: aString [
	"Set the preferred <String> where notes will be stored"

	ProjectPathString := aString
]
