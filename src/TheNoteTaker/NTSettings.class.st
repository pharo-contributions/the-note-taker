"
Class to manage The Note Taker settings.

"
Class {
	#name : 'NTSettings',
	#superclass : 'Object',
	#classVars : [
		'GithubPathString',
		'noteLocation'
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
NTSettings class >> noteLocation [
	"Answer the preferred <String> where notes will be stored"

	^ noteLocation ifNil:[ '/Users/ducasse/Workspace/FirstCircle/Writing/Working/researchnotes/faked' ]
]

{ #category : 'accessing' }
NTSettings class >> noteLocation: aString [
	"Set the preferred fileReference where notes will be stored"

	noteLocation := aString
]

{ #category : 'accessing' }
NTSettings class >> noteLocationFileReference: aFileReference [
	"Set the preferred fileReference where notes will be stored"

	noteLocation := aFileReference asFileReference
]

{ #category : 'accessing' }
NTSettings class >> projectPathSettingsOn: aBuilder [

	<systemsettings>
	
	(aBuilder group: #tnt)
		label: 'The Note Taker';
		description: 'All TNT related settings';
		noOrdering;
		with: [
				(aBuilder setting: #noteLocation)
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
